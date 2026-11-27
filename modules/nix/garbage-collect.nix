let
  B = 1;
  KB = 1024 * B;
  MB = 1024 * KB;
  GB = 1024 * MB;
in
{
  flake.modules.nixos.nix = {
    nix.extraOptions = ''
      min-free = ${toString (1 * GB)}
      max-free = ${toString (5 * GB)}
    '';
    programs.nh.clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };
}
