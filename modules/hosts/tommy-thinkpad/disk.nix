{ config, ... }:
let
  host = baseNameOf ./.;
in
{
  flake = {
    modules.nixos.${host} = {
      imports = [ config.flake.diskoConfigurations.${host} ];

      boot.initrd = {
        kernelModules = [
          # External USB keyboards
          "usbhid"
          "hid_generic"
          "hid"
          # Internal laptop keyboard ("AT Translated Set 2 keyboard" on the i8042 controller)
          "i8042"
          "atkbd"
        ];
      };
      security.tpm2.enable = true;

      # Hibernate to the swap LV, which lives inside the LUKS container.
      boot.resumeDevice = "/dev/pool/swap";
      boot.kernelParams = [
        "zswap.enabled=1"
        "zswap.compressor=zstd"
        "zswap.zpool=zsmalloc"
        "zswap.max_pool_percent=25"
      ];
      # Lid close / idle suspend, then hibernate after a while to save battery.
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend";
      };
      systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";

      services.fstrim.enable = true;
    };
    diskoConfigurations.${host} = {
      disko.devices = {
        disk.main = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-eui.8ce38e0403ae40f5";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                label = "boot";
                type = "EF00";
                size = "2G";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              luks = {
                label = "system";
                size = "100%";
                content = {
                  name = "rootcrypted";
                  type = "luks";
                  settings = {
                    # Allow SSD TRIM at the cost of exposing allocation patterns.
                    allowDiscards = true;
                    # Requires separate TPM enrollment (`just enroll-tpm`); otherwise prompts for the passphrase.
                    crypttabExtraOpts = [ "tpm2-device=auto" ];
                  };
                  extraFormatArgs = [
                    "--type=luks2"
                    "--pbkdf=argon2id"
                  ];
                  # Write the passphrase here before running disko from the installer.
                  passwordFile = "/run/luks-passphrase";
                  content = {
                    type = "lvm_pv";
                    vg = "pool";
                  };
                };
              };
            };
          };
        };
        lvm_vg.pool = {
          type = "lvm_vg";
          lvs = {
            # 38 GiB RAM: swap must be >= RAM for reliable hibernation.
            swap = {
              size = "40G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            root = {
              size = "100%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                  "commit=60"
                ];
              };
            };
          };
        };
      };
    };
  };
}
