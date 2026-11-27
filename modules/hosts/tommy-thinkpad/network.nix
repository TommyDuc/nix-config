let
  host = baseNameOf ./.;
in
{
  flake.modules.nixos.${host}.networking.firewall.lan.subnet = "192.168.0.0/24";
}
