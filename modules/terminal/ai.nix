{
  flake.modules.homeManager.terminal = {
    home.shellAliases = {
      oc = "opencode";
      occ = "opencode -c";
    };

    xdg.configFile = {
      "opencode/plugins/i-have-adhd.js".text = ''
        export { default } from '${./opencode/vendor/i-have-adhd}/.opencode/plugins/i-have-adhd.mjs';
      '';
      "opencode/.i-have-adhd-always".text = "";
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
        ];
        # Hard-deny: applies after agent rules and saved approvals
        policies = [
          {
            action = "tool.use";
            resource = "read:*.env";
            effect = "deny";
          }
          {
            action = "tool.use";
            resource = "read:*.env.*";
            effect = "deny";
          }
          {
            action = "tool.use";
            resource = "read:*.env.example";
            effect = "allow";
          }
        ];
      };

      cli = {
        session = {
          grouping = "none";
          thinking = "show";
          sidebar = "hide";
          verbosity = "high";
        };
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
