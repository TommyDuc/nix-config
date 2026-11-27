{
  flake.modules.nixos.work = {
    networking.firewall.lan.allowedTCPPorts = [
      8015
      9090
    ];
  };
}
