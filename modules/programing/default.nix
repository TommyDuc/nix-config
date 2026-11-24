{
  flake.modules.homeManager.programing =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        basedpyright
        ruff
        bash-language-server
        buf
        cspell
        dockerfile-language-server
        gopls
        lua-language-server
        markdownlint-cli2
        prettier
        stylua
        vscode-langservers-extracted
        taplo
        yaml-language-server
        nil
        nixd
        typescript-language-server
        nixfmt
        nixfmt-tree
      ];
    };
}
