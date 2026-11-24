let
  host = baseNameOf ./.;
in
{
  flake.modules.nixos.${host} = {
    hardware.bluetooth.enable = true;
  };
}
