let
  host = baseNameOf ./.;
in
{
  flake.modules = {
    nixos.${host}.networking.firewall.lan.allowedTCPPorts = [ 21118 ];
    homeManager.${host} =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.rustdesk-flutter ];
      };
  };
}
