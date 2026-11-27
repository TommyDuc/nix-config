{
  flake.modules.nixos.network =
    { config, lib, ... }:
    let
      cfg = config.networking.firewall.lan;
    in
    {
      options.networking.firewall.lan = {
        subnet = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "192.168.0.0/24";
          description = "IPv4 subnet allowed to reach `allowedTCPPorts`.";
        };
        allowedTCPPorts = lib.mkOption {
          type = lib.types.listOf lib.types.port;
          default = [ ];
          description = "TCP ports accepted only from `subnet`. Closed when `subnet` is null.";
        };
      };

      # Rules land in nixos-fw, which the firewall flushes on reload and stop.
      config.networking.firewall.extraCommands = lib.mkIf (cfg.subnet != null) (
        lib.concatMapStrings (port: ''
          iptables -w -A nixos-fw -p tcp -s ${cfg.subnet} --dport ${toString port} -j nixos-fw-accept
        '') cfg.allowedTCPPorts
      );
    };
}
