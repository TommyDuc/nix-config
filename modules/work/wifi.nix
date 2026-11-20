{
  flake.modules.nixos.work =
    { config, ... }:
    {
      # $VARs below are substituted by envsubst from this file.
      age.secrets.wifi-env.rekeyFile = ./wifi-env.age;

      networking.networkmanager.ensureProfiles = {
        environmentFiles = [ config.age.secrets.wifi-env.path ];

        profiles = {
          Dimonoff-IoT = {
            connection = {
              id = "Dimonoff-IoT";
              uuid = "0b8e118a-f2d0-4a58-8952-b1468ec07cb1";
              type = "wifi";
            };
            wifi.ssid = "Dimonoff-IoT";
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$DOO_IOT_PSK";
            };
          };
        };
      };
    };
}
