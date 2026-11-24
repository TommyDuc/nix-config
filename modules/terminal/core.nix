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
          viddy
          xclip
          xh
        ];
        sessionVariables.PAGER = "less";
        shellAliases = {
          bat = "bat -p";
          batc = "command bat --force-colorization --paging never";
          batf = "bat --style=full";
          batp = "command bat --force-colorization --paging always";
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
