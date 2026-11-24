{
  flake.modules.homeManager.terminal =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        git-cola
        git-ignore
        meld
      ];

      programs = {
        git = {
          enable = true;
          lfs.enable = true;
          ignores = [
            ".direnv"
            ".envrc"
          ];
          signing.format = null;
          settings = {
            user = { inherit (config.user) name email; };
            alias = {
              aliases = "config --get-regexp ^alias\.";
              branches = "branch -a --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:blue)(%(committerdate:short)) [%(authorname)]'";
              logs = "log --pretty=format:'%C(auto)%h%C(reset) %C(cyan)%ad%C(auto)%d%C(reset) %s %C(blue)[%cn]%C(reset)' --date=short-local --ext-diff";
              save = "!git add -A && git commit -m 'chore: savepoint'";
              uncommit = "reset --mixed HEAD~1";
              nuke = "!git reset --hard && git clean -fdx";
            };
            branch.sort = "-committerdate";
            column.ui = "auto";
            core = {
              autocrlf = "input";
              ignorecase = false;
            };
            diff = {
              algorithm = "histogram";
              colorMoved = "plain";
              colormovedws = "allow-indentation-change";
              mnemonicPrefix = "true";
              renames = "copy";
            };
            fetch = {
              prune = true;
              pruneTags = true;
            };
            help.autocorrect = "prompt";
            init.defaultBranch = "main";
            log = {
              date = "iso";
            };
            merge = {
              conflictstyle = "zdiff3";
              directoryRenames = true;
            };
            pager.difftool = true;
            pull = {
              rebase = true;
            };
            push = {
              autoSetupRemote = true;
              followTags = true;
            };
            rebase = {
              autoSquash = true;
              autoStash = true;
              updateRefs = true;
            };
            rerere = {
              autoupdate = true;
              enabled = true;
            };
            tag.sort = "version:refname";
          };
        };
        difftastic = {
          enable = true;
          git = {
            enable = true;
            mode = "both";
          };
          options.background = "dark";
        };
        lazygit = {
          enable = true;
          settings = {
            gui = {
              returnImmediately = true;
              nerdFontsVersion = "3";
              timeFormat = "2006-01-02 15:04:05";
              theme = {
                selectedLineBgColor = [ "#4b4873" ];
                selectedRangeBgColor = [ "#4b4873" ];
              };
            };
            git = {
              branchLogCmd = "git logs --graph";
              truncateCopiedCommitHashesTo = 40;
              localBranchSortOrder = "date";
              remoteBranchSortOrder = "date";
              diffContextSize = 5;
              diffRenderers = [
                {
                  command = "difft --color=always --context={{diffContext}}";
                  type = "extDiff";
                }
              ];
              parseEmoji = true;
            };
            refresher = {
              refreshInterval = 10;
            };
            os = {
              open = "alacritty -e nvim {{filename}}";
              edit = "nvim {{filename}}";
              editAtLine = "nvim {{filename}} +{{line}}";
              editAtLineAndWait = "nvim {{filename}} +{{line}}";
              editInTerminal = true;
            };
          };
        };
        zsh.initContent = ''
          meldiff() {
            if [[ -z ''${1:-} ]]; then
              echo "usage: meldiff <ref>" >&2
              return 1
            fi
            git difftool -t meld -d "$1~1" "$1" || return 1
          }
        '';
      };
      home.shellAliases = {
        cdg = ''cd "$(git rev-parse --show-toplevel)"'';
        dag = "git dag --all &";
        lg = "lazygit";
      };
    };
}
