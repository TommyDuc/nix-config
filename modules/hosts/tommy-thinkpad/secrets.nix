let
  host = baseNameOf ./.;
in
{
  flake.modules =
    let
      rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtKLbUWwdz8iZlzBe/AXBssclTlXm+xL3wyrQNqkim9";
    in
    {
      homeManager.${host}.age = { inherit rekey; };
      nixos.${host}.age = {
        inherit rekey;

        secrets = {
          linux-password.rekeyFile = ./linux-password.age;
        };
      };
    };
}
