{
  flake.modules =
    let
      user.email = "tduchesne@dimonoff.com";
    in
    {
      homeManager.work = { inherit user; };
      nixos.work = { inherit user; };
    };
}
