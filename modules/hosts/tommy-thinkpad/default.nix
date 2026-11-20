{
  config,
  lib,
  ...
}:
let
  # The directory name is the hostname; no other file repeats it.
  host = baseNameOf ./.;
in
{
  flake =
    let
      inherit (config.flake.modules) homeManager nixos;
      modules = [
        nixos.default
        nixos.disk
        nixos.${host}
        nixos.work
      ];
      homeModules = [
        homeManager.default
        homeManager.${host}
        homeManager.work
      ];
    in
    {
      nixosConfigurations.${host} = lib.nixosSystem { inherit modules; };
      modules.nixos.${host} =
        { config, ... }:
        {
          home-manager.users.${config.user.username}.imports = homeModules;
          networking.hostName = host;
        };
    };
}
