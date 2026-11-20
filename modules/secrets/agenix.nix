{ inputs, ... }:
{
  flake-file.inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  imports = [
    inputs.agenix-rekey.flakeModule
  ];

  flake.modules =
    let
      masterIdentities = [
        {
          identity = ../../secrets/master-key.age;
          pubkey = "age1jxav0439zr8ena99njckgyrke2r04xxhuxs82zal4gu05p5yyp4s4fu3ts";
        }
      ];
      storageMode = "local";
    in
    {
      homeManager.secrets = {
        imports = with inputs; [
          agenix.homeManagerModules.default
          agenix-rekey.homeManagerModules.default
        ];
        age.rekey = { inherit masterIdentities storageMode; };
      };
      nixos.secrets =
        { config, ... }:
        {
          imports = with inputs; [
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
          ];
          age.rekey = {
            inherit masterIdentities storageMode;
            localStorageDir = ../../secrets/${config.networking.hostName}/nixos;
          };
        };
    };
}
