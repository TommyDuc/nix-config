{ inputs, ... }:
{
  flake-file.inputs.plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  flake.modules = {
    nixos.desktop =
      { pkgs, ... }:
      {
        services = {
          displayManager.sddm = {
            enable = true;
            wayland.enable = true;
          };
          desktopManager.plasma6.enable = true;
        };
        programs.evolution = {
          enable = true;
          plugins = [ pkgs.evolution-ews ];
        };
        environment.plasma6.excludePackages = with pkgs.kdePackages; [
          elisa
        ];
      };

    homeManager.desktop = {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        enable = true;

        workspace.lookAndFeel = "org.kde.breezedark.desktop";

        input = {
          keyboard = {
            numlockOnStartup = "on";
            repeatDelay = 250;
            repeatRate = 75;
          };
          mice = [
            {
              name = "Logitech M510";
              vendorId = "046d";
              productId = "4051";
              acceleration = 0.2;
              accelerationProfile = "none";
            }
            {
              name = "Logitech Yeti Orb Consumer Control";
              vendorId = "046d";
              productId = "0ad5";
              enable = false;
            }
          ];
        };

        kscreenlocker = {
          timeout = 30;
          passwordRequiredDelay = 60;
        };

        powerdevil = {
          AC = {
            powerProfile = "performance";
            powerButtonAction = "shutDown";
            autoSuspend.action = "nothing";
            whenSleepingEnter = "hybridSleep";
            inhibitLidActionWhenExternalMonitorConnected = false;
            turnOffDisplay.idleTimeout = "never";
            dimDisplay.enable = false;
          };
          battery = {
            powerProfile = "powerSaving";
            powerButtonAction = "shutDown";
            autoSuspend.idleTimeout = 900;
            whenSleepingEnter = "standbyThenHibernate";
            whenLaptopLidClosed = "hibernate";
            inhibitLidActionWhenExternalMonitorConnected = false;
          };
          lowBattery = {
            powerProfile = "powerSaving";
            powerButtonAction = "shutDown";
            autoSuspend.idleTimeout = 120;
            whenSleepingEnter = "hybridSleep";
            inhibitLidActionWhenExternalMonitorConnected = false;
            turnOffDisplay.idleTimeoutWhenLocked = "immediately";
          };
        };

        configFile = {
          kdeglobals = {
            KDE = {
              AnimationDurationFactor = 0;
              DndBehavior = "MoveIfSameDevice";
              DoubleClickInterval = 300;
              SmoothScroll = false;
            };
            "KFileDialog Settings" = {
              "Sort directories first" = true;
              "View Style" = "DetailTree";
            };
          };
          kwinrc = {
            Input.TabletMode = "off";
            Windows.Placement = "Maximizing";
          };
          dolphinrc."KFileDialog Settings" = {
            "Places Icons Auto-resize" = false;
            "Places Icons Static Size" = 22;
          };
        };
      };
    };
  };
}
