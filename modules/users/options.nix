{ lib, ... }:
let
  inherit (lib) mkOption types;

  userOptions = {
    name = mkOption {
      type = types.str;
      default = "Tommy Duchesne";
    };
    username = mkOption {
      type = types.str;
      default = "tommy";
    };
    email = mkOption {
      type = types.str;
      default = "tduchesne@dimonoff.com";
    };
  };
  nixosUserOptions = userOptions // {
    groups = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };
in
{
  flake.modules = {
    homeManager.users.options.user = userOptions;
    nixos.users.options.user = nixosUserOptions;
  };
}
