{
  flake.modules.homeManager.terminal =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          choose
          coreutils-full
          curl
          doggo
          dua
          duf
          file
          hyperfine
          iputils
          just
          ouch
          python314
          rnr
          rustscan
          sd
          tere
          tree
          viddy
          wl-clipboard
          xclip
          xh
        ];
        sessionVariables.PAGER = "less";
        shellAliases = {
          atree = "command tree -a";
          bat = "bat -p";
          batc = "command bat --force-colorization --paging never";
          batf = "bat --style=full";
          batp = "command bat --force-colorization --paging always";
          j = "just";
          open = "xdg-open";
          pp = "wl-copy --trim-newline";
          rga = "rg --no-ignore --no-ignore-dot";
          tree = "tree --gitignore -a -I '.git'";
        };
      };

      programs = {
        bat = {
          enable = true;
          config.theme = "ansi";
        };
        bottom.enable = true;
        fd.enable = true;
        less.enable = true;
        lesspipe.enable = true;
        ripgrep.enable = true;
        eza = {
          enable = true;
          git = true;
          icons = "auto";
          extraOptions = [
            "--classify"
            "--group-directories-first"
            "--time-style=long-iso"
          ];
        };
      };
    };
}
