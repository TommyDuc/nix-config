{
  flake.modules.homeManager.desktop =
    { pkgs, config, ... }:
    {
      home = {
        packages = with pkgs; [
          tangram
        ];
        sessionVariables.BROWSER = "brave";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
          "x-scheme-handler/about" = "brave-browser.desktop";
          "x-scheme-handler/unknown" = "brave-browser.desktop";
        };
      };

      programs = {
        brave = {
          enable = true;
          dictionaries = with pkgs.hunspellDictsChromium; [
            fr_FR
            en_US
          ];
        };
        firefox = {
          enable = true;
          configPath = "${config.xdg.configHome}/mozilla/firefox";
        };
      };
    };
}
