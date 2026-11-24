{
  flake.modules = {
    nixos.terminal =
      { pkgs, ... }:
      {
        fonts.packages = with pkgs; [
          nerd-fonts.ubuntu-mono
        ];
      };

    homeManager.terminal =
      { config, lib, ... }:
      {
        programs = {
          alacritty = {
            enable = true;
            settings = {
              general = {
                working_directory = "${config.home.homeDirectory}/projects";
                import = [
                  "${./alacritty/themes/catppuccin-mocha.toml}"
                ];
              };
              window = {
                startup_mode = "Maximized";
                opacity = 0.80;
                decorations = "None";
              };
              scrolling = {
                history = 10000;
                multiplier = 10;
              };
              cursor = {
                style = {
                  shape = "Block";
                  blinking = "On";
                };
                blink_interval = 300;
                blink_timeout = 0;
              };
              mouse.hide_when_typing = true;
              colors.transparent_background_colors = true;
              keyboard.bindings = [
                {
                  key = "F11";
                  action = "ToggleFullscreen";
                }
              ];
              font = {
                normal = {
                  family = "UbuntuMono Nerd Font";
                  style = "Regular";
                };
                bold = {
                  family = "UbuntuMono Nerd Font";
                  style = "Bold";
                };
                italic = {
                  family = "UbuntuMono Nerd Font";
                  style = "Italic";
                };
                bold_italic = {
                  family = "UbuntuMono Nerd Font";
                  style = "BoldItalic";
                };
              };
            };
          };
          zellij.enable = true;
          # `zellij attach` resurrects a dead session, unlike plain `zellij`.
          zsh.initContent = lib.mkOrder 200 ''
            if [[ -z "$ZELLIJ" ]]; then
              zellij attach --create default
            fi
          '';
        };

        xdg.configFile."zellij/config.kdl".source = ./zellij/config.kdl;

        home.shellAliases = {
          z = "zellij";
          zr = "zellij run -- direnv-run";
          zrf = "zellij run --floating -- direnv-run";
          zri = "zellij run --in-place -- direnv-run";
          ze = "zellij edit";
          zef = "zellij edit --floating";
          zei = "zellij edit --in-place";
        };
      };
  };
}
