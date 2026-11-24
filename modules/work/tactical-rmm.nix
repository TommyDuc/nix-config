{ inputs, ... }:
{
  flake-file.inputs.tactical-rmm = {
    url = "git+https://bitbucket.org/amotus/tactical-rmm-nix.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos.work =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.tactical-rmm.nixosModules.default ];

      age.secrets = {
        tactical-agent-token.rekeyFile = ./tactical-agent-token.age;
      };

      services.tacticalAgent = {
        enable = true;
        apiUrl = "https://tactical-api.amotus.com";
        tokenFile = config.age.secrets.tactical-agent-token.path;
        # TEST: remove once tactical-rmm-nix is bumped to 2.12.0
        package =
          (pkgs.callPackage "${inputs.tactical-rmm}/pkgs/tactical-agent.nix" { }).overrideAttrs
            (old: rec {
              version = "2.12.0";
              src = old.src.override {
                rev = "v${version}";
                sha256 = "sha256-kzvLRfNwip1RTuAzNlX4TtejghRl5hQR7bhcUeQ0qX4=";
              };
              vendorHash = "sha256-ho5KSoP34rbjnstW/bt7YQva9cXtDJjizjdiRTF1Cfk=";
            });
      };
    };
}
