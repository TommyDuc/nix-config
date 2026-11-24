{
  flake.modules.homeManager.terminal =
    { pkgs, ... }:
    let
      coop-nvim = pkgs.vimUtils.buildVimPlugin {
        pname = "coop.nvim";
        version = "2026-01-01";
        src = pkgs.fetchFromGitHub {
          owner = "gregorias";
          repo = "coop.nvim";
          rev = "26df3be54846ed44b5a9d7749f7780049931b8a8";
          hash = "sha256-Kntwgxjr1skuxE7rOEeLip4OzOAs+YNx6DcPNkTMUwI=";
        };
      };

      coerce-nvim = pkgs.vimUtils.buildVimPlugin {
        pname = "coerce.nvim";
        version = "4.1.0";
        src = pkgs.fetchFromGitHub {
          owner = "gregorias";
          repo = "coerce.nvim";
          rev = "b7927c42bd7f3adaae5f5dcf86a89140d5d80430";
          hash = "sha256-Pd++sslfMn5ZYQowiCMkcyVpyHGZ/qtNlsaacbutDcY=";
        };
        dependencies = [ coop-nvim ];
      };

      graph-view-yaml-parser = pkgs.vimUtils.buildVimPlugin {
        pname = "graph_view_yaml_parser";
        version = "2026-01-01";
        src = pkgs.fetchFromGitHub {
          owner = "Owen-Dechow";
          repo = "graph_view_yaml_parser";
          rev = "ecc5ba0a0b8c3a6eb3e7fa5a2caeeee2263729c3";
          hash = "sha256-nZyAHAoulTLwq4IVLlWd0kZ9je+9Upe7jY3apAt3anw=";
        };
      };

      nvim-json-graph-view = pkgs.vimUtils.buildVimPlugin {
        pname = "nvim_json_graph_view";
        version = "2026-01-01";
        src = pkgs.fetchFromGitHub {
          owner = "Owen-Dechow";
          repo = "nvim_json_graph_view";
          rev = "b14fde46fcf1a75338977af8cc65c174ef94582e";
          hash = "sha256-PbP1CF0Zri7fsZRyTRG8gPzn5k42gTHujdIq5hfyOZ0=";
        };
        dependencies = [ graph-view-yaml-parser ];
      };

      linrongbin-gitlinker-nvim = pkgs.vimUtils.buildVimPlugin {
        pname = "gitlinker.nvim";
        version = "2026-01-01";
        src = pkgs.fetchFromGitHub {
          owner = "linrongbin16";
          repo = "gitlinker.nvim";
          rev = "b710fe0e0c997236104f43db49905ab67f8d1f64";
          hash = "sha256-Oh9/AIE5rskv1BgZN2mOmb9QpfX/XBiMnfDDxZBqIF8=";
        };
        nvimRequireCheck = "gitlinker";
      };
    in
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        extraPackages = with pkgs; [
          fd
          ripgrep
          wl-clipboard
        ];
        plugins = with pkgs.vimPlugins; [
          SchemaStore-nvim
          blink-cmp
          catppuccin-nvim
          coerce-nvim
          conform-nvim
          fff-nvim
          hop-nvim
          linrongbin-gitlinker-nvim
          marks-nvim
          mini-nvim
          nvim-json-graph-view
          nvim-lint
          nvim-lspconfig
          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects
          plenary-nvim
          telescope-nvim
          vim-protobuf
        ];
        initLua = ''
          vim.g.mapleader = " "
          vim.g.maplocalleader = "\\"

          require("tommy")
          require("after")
        '';
      };

      xdg.configFile = {
        "nvim/lua".source = ./nvim/lua;
        "nvim/cspell.json".source = ./nvim/cspell.json;
        "nvim/markdownlint.jsonc".source = ./nvim/markdownlint.jsonc;
      };

      home.shellAliases = {
        gnvim = "alacritty -e nvim";
        o = "nvim .";
      };
    };
}
