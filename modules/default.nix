{ config, ... }:
{
  flake.modules = {
    homeManager.default.imports = with config.flake.modules.homeManager; [
      desktop
      home
      nix
      programing
      secrets
      terminal
      users
      virtualisation
    ];
    nixos.default.imports = with config.flake.modules.nixos; [
      desktop
      home
      locale
      network
      nix
      secrets
      system
      terminal
      users
      virtualisation
    ];
  };
}
