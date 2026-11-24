# AGENTS.md

Guidance for coding agents working in this NixOS + Home Manager configuration repository.

## Architecture: Dendritic Flake Pattern

This repository uses **`flake-parts` + `import-tree` + `flake-file`** (`modules/flake/dendritic.nix`):

- **`flake.nix` is auto-generated — never edit it directly.** Declare flake inputs via `flake-file.inputs.<name>` and `nixConfig` via `flake-file.nixConfig` in the feature module that uses them, then regenerate with `just write-flake` (or `nix run .#write-flake`).
- **Automatic discovery (`import-tree`)**: `flake.nix` imports every `.nix` file under `modules/` as a top-level `flake-parts` module. There is no manual file import list.
- **Aspect-based composition**: Feature files contribute to named aspects under `flake.modules.nixos.<aspect>` and `flake.modules.homeManager.<aspect>`. Because `flake-parts` merges attribute sets across files, multiple files in a directory (e.g., `modules/terminal/*.nix`) automatically merge into the same aspect.
- **Flakes only see Git-tracked files**: Whenever you create a new file, run `git add -N <path>` so Nix can evaluate it.

## Host & Module Composition

- **Default profiles (`modules/default.nix`)**:
  - `flake.modules.nixos.default` imports: `desktop`, `home`, `locale`, `network`, `nix`, `secrets`, `system`, `terminal`, `users`, `virtualisation`.
  - `flake.modules.homeManager.default` imports: `desktop`, `home`, `nix`, `programing`, `secrets`, `terminal`, `users`, `virtualisation`.
  - Note: `programing` is intentionally spelled with one `m` (`modules/programing/`).
- **Hosts (`modules/hosts/<hostname>/`)**:
  - Each host file derives `host = baseNameOf ./.`, making the directory name the single source of truth for `networking.hostName`, `nixosConfigurations.${host}`, `diskoConfigurations.${host}`, and host-scoped module names.
  - `modules/hosts/<hostname>/default.nix` assembles `flake.nixosConfigurations.${host}` (combining `default`, `disk`, `${host}`, `work`) and wires Home Manager modules (`home-manager.users.${config.user.username}.imports`).
  - `./hostname` holds the default host name (`tommy-thinkpad`) used by `justfile` commands.
- **User identity & Home Manager integration**:
  - Home Manager runs as a NixOS module (`modules/home/home-manager.nix`) with `useGlobalPkgs = true`, `useUserPackages = true`, and `backupFileExtension = "hmbkp"`.
  - Custom `user.{name, username, email}` options (`modules/users/options.nix`) are defined once in `modules/users/identity.nix` on NixOS and propagated to Home Manager by `modules/home/propagate.nix`.
  - NixOS modules add supplementary user groups via `user.groups = [ ... ];` (consumed by `modules/users/user.nix`), rather than mutating `users.users.<name>.extraGroups` directly.
  - Before modifying a configuration, ask yourself if it is host specific or module specific.

## Directory Map

| Path                              | Responsibility                                                                                                                                                                                                                                                                    |
| :-------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `modules/flake/`                  | `flake-file` dendritic setup, `nixpkgs` (`nixos-unstable`), `devShells.default`, `nixfmt-tree` formatter, and flake template (`templates/flake/`).                                                                                                                                |
| `modules/nix/`                    | `nh`/`nom`/`nvd`, `nix-community` Cachix, `direnv`/`nix-direnv` (+ `direnv-run`, `nixify`), flake registry & `NIX_PATH`, daily GC (`7d`), `nix-index-database` (`comma`), `allowUnfree`.                                                                                          |
| `modules/system/`                 | `systemd-boot` EFI, PipeWire audio, Bluetooth, CUPS + Avahi + `brlaser` printing, NTFS, libinput touchpad.                                                                                                                                                                        |
| `modules/desktop/`                | KDE Plasma 6 + SDDM (Wayland), Evolution (EWS), browsers (Firefox, Brave, Tangram), media/chat/productivity apps, `.face` icon.                                                                                                                                                   |
| `modules/terminal/`               | Alacritty + Zellij (`zellij/config.kdl`), Zsh + Oh My Zsh + Atuin + Starship, Helix (default editor), Git + Difftastic + Lazygit, SSH multiplexing, OpenCode, CLI utilities.                                                                                                      |
| `modules/programing/`             | Language servers and Helix LSP/formatter settings (Nix, Python, Rust, JS/TS).                                                                                                                                                                                                     |
| `modules/virtualisation/`         | Docker (`dive`, `lazydocker`, `docker-enable-qemu`), Podman (`oci-containers` backend), KVM/libvirtd + GNOME Boxes + SPICE USB redirection.                                                                                                                                       |
| `modules/locale/`                 | `America/Toronto`, `ca`/`cf` keyboard, `en_CA.UTF-8`, IBus `typing-booster` (`en-ca`/`fr-moderne`), Hunspell dicts.                                                                                                                                                               |
| `modules/network/`                | NetworkManager + OpenVPN plugin.                                                                                                                                                                                                                                                  |
| `modules/disk/`                   | `disko` flake/NixOS integration; per-host disk layouts live in `modules/hosts/<host>/disk.nix` (GPT + LUKS2 + TPM2 + LVM swap/root).                                                                                                                                              |
| `modules/secrets/`                | `agenix` + `agenix-rekey` configuration (`storageMode = "local"`).                                                                                                                                                                                                                |
| `modules/users/`, `modules/home/` | Custom `user.*` options, single-source identity, Home Manager module integration & NixOS-to-HM propagation.                                                                                                                                                                       |
| `modules/work/`                   | Work-specific aspect (Dimonoff/Amotus): Bitdefender, Tactical RMM, NetworkManager VPN/Wi-Fi profiles (`envsubst` secrets), encrypted SSH config, `*.fundamentum.test` `/etc/hosts` + CA cert, insecure Docker registry, `armv7l-linux` binfmt, Expo ports, Teams desktop entries. |
| `modules/hosts/<host>/`           | Per-host NixOS assembly, hardware (`nixos-hardware`), Disko layout, host agenix pubkey/secrets, and `stateVersion`.                                                                                                                                                               |

## Secrets (`agenix` + `agenix-rekey`)

- Configured in `modules/secrets/agenix.nix` with `storageMode = "local"` and host decryption key at `/etc/agenix/agenix_key`.
- Source `.age` files are encrypted to the passphrase-protected master key (`secrets/master-key.age`) and colocated next to the modules that consume them (e.g., `modules/work/*.age`, `modules/hosts/<host>/*.age`).
- Rekeyed host-specific ciphertexts live under `secrets/<host>/{nixos,home}/` and are committed to Git.
- Edit/add secrets with `just edit-secret` (runs `agenix edit`, `git add -N **/*.age`, and `agenix rekey -a`). Never commit plaintext secrets.

## Common Commands & Conventions

All `just` recipes default `--host` to `./hostname` and support `--deploy <ssh-target>` where applicable:

- `just write-flake` — regenerate `flake.nix` after changing `flake-file.*` options.
- `just build` — build the NixOS configuration without activating (`nh os build`).
- `just test` — build and activate immediately without adding a boot entry (`nh os test`).
- `just switch` — stage a new boot generation (`nh os boot --ask`; applies on next reboot, does **not** live-switch). For immediate + persistent activation, use `nh os switch --ask --hostname <host> .`.
- `just update [inputs]` / `just update-all` — update `flake.lock`.
- `just deploy` / `just enroll-tpm` — bare-metal installation via `nixos-anywhere` and TPM2 LUKS enrollment.
- `nix fmt` — format Nix files with `nixfmt-tree`.

### Git Hooks & Quality Checks (`lefthook.toml`, `.gitlint`)

- **Commit messages** (`commit-msg`): must follow Conventional Commits (`feat:`, `fix:`, `chore:`, etc.), validated by `gitlint`.
- **Pre-commit**: runs `nil diagnostics` on staged `.nix` files.
- **Pre-push**: runs `just build`.
- Note: `README.md` is legacy (references `nix-starter-configs`) and does not reflect the current dendritic layout.
