{ inputs, ... }:
let
  host = baseNameOf ./.;
in
{
  flake-file.inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  # Lenovo ThinkPad T15p Gen 3 (21DA): i7-12800H + Iris Xe + RTX 3050 Mobile.
  # nixos-hardware has no T15p profile; the P15v Gen 3 is the same chassis but
  # we compose the generic pieces to stay explicit.
  flake.modules.nixos.${host} =
    { config, ... }:
    {
      imports = with inputs.nixos-hardware.nixosModules; [
        lenovo-thinkpad
        common-cpu-intel
        common-gpu-nvidia # PRIME offload
        common-pc-laptop
        common-pc-laptop-ssd
      ];

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        # Recommended by NVIDIA for Turing and newer (RTX 3050 is Ampere).
        open = true;
        modesetting.enable = true;
        # Save/restore VRAM across suspend and hibernate.
        powerManagement.enable = true;
        # Power the dGPU off when idle; run apps on it with `nvidia-offload <cmd>`.
        powerManagement.finegrained = true;
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
    };
}
