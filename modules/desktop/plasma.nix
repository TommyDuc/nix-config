{ inputs, ... }:
{
  flake-file.inputs.plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

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

    homeManager.desktop = {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        enable = true;
      };
    };
  };
}
