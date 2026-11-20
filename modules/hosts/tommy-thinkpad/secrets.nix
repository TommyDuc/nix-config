{
  flake.modules =
    let
      identityPaths = [ "/etc/agenix/agenix_key" ];
      rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtKLbUWwdz8iZlzBe/AXBssclTlXm+xL3wyrQNqkim9";
    in
    {
      homeManager.tommy-thinkpad.age = { inherit identityPaths rekey; };
      nixos.tommy-thinkpad.age = {
        inherit identityPaths rekey;

        secrets = {
          linux-password.rekeyFile = ./linux-password.age;
        };
      };
    };
}
