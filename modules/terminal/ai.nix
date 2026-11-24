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
        # Last matching rule wins
        permissions = [
          {
            action = "external_directory";
            resource = "*";
            effect = "ask";
          }
          {
            action = "external_directory";
            resource = "/tmp/opencode/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/.opencode/plan/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "/nix/store/*";
            effect = "allow";
          }

          {
            action = "shell";
            resource = "*";
            effect = "ask";
          }
          {
            action = "shell";
            resource = "ls *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "cat *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "head *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "tail *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "wc *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "rg *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "git status *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "git diff *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "git log *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "git show *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "git branch --show-current";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "git rev-parse *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "just build *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "nix eval *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "nix flake check *";
            effect = "allow";
          }
        ];
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
