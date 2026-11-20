{
  # Single source of truth for the user identity. Home-manager receives it via home/propagate.nix.
  flake.modules.nixos.users.user = {
    name = "Tommy Duchesne";
    username = "tommy";
    email = "tduchesne@dimonoff.com";
  };
}
