{
  flake.modules = {
    homeManager.users =
      { config, osConfig, ... }:
      let
        inherit (config.user) username;
      in
      {
        home = {
          inherit username;
          homeDirectory = osConfig.users.users.${username}.home;
        };
      };
    nixos.users =
      { config, ... }:
      let
        inherit (config.user) username name groups;
      in
      {
        user.groups = [
          "dialout"
          "wheel"
        ];
        users.users.${username} = {
          home = "/home/${username}";
          hashedPasswordFile = config.age.secrets.linux-password.path;
          isNormalUser = true;
          description = name;
          extraGroups = groups;
        };
      };
  };
}
