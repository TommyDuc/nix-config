{
  config,
  lib,
  ...
}:
{
  flake =
    let
      inherit (config.flake.modules) homeManager nixos;
      hostName = "tommy-thinkpad";
      modules = with nixos; [
        default
        disk
        tommy-thinkpad
        work
      ];
      homeModules = with homeManager; [
        default
        tommy-thinkpad
        work
      ];
    in
    {
      nixosConfigurations.${hostName} = lib.nixosSystem { inherit modules; };
      modules.nixos.tommy-thinkpad =
        { config, ... }:
        {
          home-manager.users.${config.user.username}.imports = homeModules;
          networking = { inherit hostName; };
        };
    };
}
