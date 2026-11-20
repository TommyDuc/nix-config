{
  flake.modules = {
    nixos.desktop =
      { pkgs, ... }:
      {
        services = {
          displayManager.sddm = {
            enable = true;
            wayland.enable = true;
          };
          desktopManager.plasma6.enable = true;
        };
        programs.evolution = {
          enable = true;
          plugins = [ pkgs.evolution-ews ];
        };
        environment.plasma6.excludePackages = with pkgs.kdePackages; [
          elisa
        ];
      };
  };
}
