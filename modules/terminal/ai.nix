{
  flake.modules.homeManager.terminal = {
    home.shellAliases = {
      oc = "opencode";
      occ = "opencode -c";
    };

    programs.opencode = {
      enable = true;
      validateFiles = {
        config = true;
        cli = true;
      };

      settings = {
        update = "disable";
        default_agent = "plan";
        model = "github-copilot/claude-fable-5.2#medium";
        agents = {
          plan.model = "github-copilot/claude-fable-5.2#medium";
          build.model = "github-copilot/claude-fable-5.2#medium";
        };
      };

      cli = {
        keybinds = {
          "agent.cycle" = "tab";
        };
      };

      skills = {
        generic-commits = ./opencode/skills/generic-commits;
        nix-version-check = ./opencode/skills/nix-version-check;
      };
    };
  };
}
