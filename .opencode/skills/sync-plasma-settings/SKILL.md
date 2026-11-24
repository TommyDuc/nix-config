---
name: sync-plasma-settings
description: Sync KDE Plasma settings changed through the GUI (System Settings, panel edits) back into the declarative plasma-manager config in `modules/desktop/plasma.nix`. Diffs the live `~/.config` files against what is declared, shows a table for approval, then edits the Nix module and verifies the build. Use when the user asks to sync, save, capture, import or update their KDE or Plasma settings, or says a setting they changed in the GUI was lost or reverted.
---

# Sync Plasma Settings

Bring KDE Plasma settings changed in the GUI into `programs.plasma` in
`modules/desktop/plasma.nix`, which is managed by
[plasma-manager](https://github.com/nix-community/plasma-manager).

## Hard rules

- **One direction only: live system to Nix.** Never write to `~/.config` or run
  `kwriteconfig6`, `plasma-apply-*` or similar.
- **Edit nothing before approval.** Show the table from step 4 and wait.
- **Only edit `modules/desktop/plasma.nix`.** Never edit `flake.nix` directly; it
  is generated.
- Keep `overrideConfig` off unless the user explicitly asks for it.
- Do not commit. Stop after the build passes.

## 1. Read the live settings

Run in parallel:

- plasma-manager's exporter, which prints the KDE files as Nix:

  ```sh
  nix run github:nix-community/plasma-manager 2>/dev/null
  ```

- Shortcuts that differ from their recorded default. Each line in
  `kglobalshortcutsrc` is `current,default,description`:

  ```sh
  cd ~/.config && awk -F'=' '/^\[/{sec=$0; next} NF>=2{split($2,a,","); if(a[1]!=a[2]) print sec" "$1" => now=["a[1]"] default=["a[2]"]"}' kglobalshortcutsrc | grep -v '_k_friendly_name'
  ```

- The files the exporter skips (power, panel geometry, theme package):

  ```sh
  cd ~/.config && for f in powerdevilrc kxkbrc ksmserverrc kwinrc kcminputrc kscreenlockerrc plasmarc ksplashrc kiorc krunnerrc breezerc klipperrc plasmashellrc kdedefaults/package; do [ -f "$f" ] && { echo "##### $f"; cat "$f"; }; done
  ```

- The panel and widget layout, without window-geometry noise:

  ```sh
  cd ~/.config && grep -vE '^(popupHeight|popupWidth|DialogHeight|DialogWidth|PreloadWeight|ItemGeometries|lastScreen|formfactor|location|immutability|activityId|wallpaperplugin|extraItems|knownItems)' plasma-org.kde.plasma.desktop-appletsrc
  ```

## 2. Read what is declared

- Read `modules/desktop/plasma.nix`.
- Dump the values plasma-manager will write, using the host name from
  `./hostname` and the user name from the config:

  ```sh
  host=$(cat hostname)
  user=$(nix eval --raw ".#nixosConfigurations.$host.config.user.username")
  nix eval --json ".#nixosConfigurations.$host.config.home-manager.users.$user.programs.plasma.configFile" > /tmp/opencode/plasma-declared.json
  ```

  Each entry is `file -> group -> key -> { value, ... }`; ignore keys whose
  `value` is null. Nested groups are joined with `/` (for example `AC/Display`
  for `[AC][Display]`).

- The panel is not in that output. Compare it against the `panels` block in the
  module, or against the generated script
  `home-files/.local/share/plasma-manager/data/desktop_script_panels.js` in the
  built Home Manager generation.

## 3. Diff

Sort every difference into one of these groups:

| Group | Meaning |
| :--- | :--- |
| Changed | Declared in Nix, but the live value is different |
| New | Set on the live system, not declared in Nix |
| Stale | Declared in Nix, but the live file no longer has the key or the device |
| Uncertain | Live value exists, but it may be a default or written by a theme |

Rules for the diff:

- **Always exclude machine state:** `kwinoutputconfig.json` (monitor layout),
  activity and virtual-desktop IDs, `[Tiling]` groups, window and dialog
  geometry, timestamps, `kwalletrc`, `kactivitymanagerdrc`,
  `plasmashellrc [Updates]`, `baloofilerc`, `plasmanotifyrc ... Seen`, and
  Spectacle folder names.
- **Exclude what NixOS already owns:** keyboard layout and locale come from
  `modules/locale/`.
- **Shortcuts:** only report entries from the shortcut diff. Ignore the
  `[kwin][$InverseAction]` group. Keys whose binding contains `=` (for example
  `view_zoom_in` with `Meta+=`) are false positives of the `=` split; check
  those lines by hand.
- **Defaults are not recorded** outside `kglobalshortcutsrc`. If you cannot
  confirm a value differs from Plasma's default, put it in Uncertain instead of
  guessing. Known theme-written values: `kdeglobals [KDE] contrast` and
  `frameContrast`, `kdeglobals [WM]` colours, `kdeglobals [Icons] Theme`,
  `plasmarc [Theme] name`.
- **Panel:** the whole panel is declared and rebuilt at login, so report any
  panel difference as one row that replaces the `panels` block.
- **Per-device input:** `kcminputrc [Libinput][vendor][product][name]` groups
  use decimal IDs; plasma-manager's `input.mice` and `input.touchpads` take
  them as hex strings.

## 4. Show the table and wait

Present one table, then stop and ask which rows to apply:

| # | Group | Setting | Declared | Live | Proposed Nix |
| :--- | :--- | :--- | :--- | :--- | :--- |

- Describe each setting in plain words, with the file and key in the last
  column's Nix snippet.
- Decode numeric enums (power button action, lid action, sleep mode, sorting
  strategy) into their names.
- If there are no differences, say so and stop.

## 5. Apply the approved rows

- Prefer plasma-manager's typed options (`workspace`, `input`,
  `kscreenlocker`, `powerdevil`, `kwin`, `panels`, `shortcuts`); fall back to
  `programs.plasma.configFile.<file>.<group>.<key>` only when no typed option
  exists.
- Check option names and enum values against the module source before writing:

  ```sh
  nix eval --raw --impure --expr '(builtins.getFlake "github:nix-community/plasma-manager").outPath'
  ```

  Options live in `modules/*.nix` and `modules/widgets/*.nix` under that path.
- For Stale rows, remove the declaration only if the user approved that row.
- Keep the existing ordering and style of the module.

## 6. Verify

1. `nix fmt`
2. `nil diagnostics modules/desktop/plasma.nix`
3. `just build`
4. Re-run the `nix eval` from step 2 and confirm each applied row now matches
   the live value.

Then tell the user:

- which rows were applied and which were skipped;
- that nothing is active until `just test` (or `just switch`);
- that theme and panel changes apply only after logging out and back in.
