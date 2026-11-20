{ lib, ... }:
let
  inherit (lib) mkOption types;

  userOptions = {
    name = mkOption {
      type = types.str;
    };
    username = mkOption {
      type = types.str;
    };
    email = mkOption {
      type = types.str;
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
