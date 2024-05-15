{ pkgs
, config
, fetchFromGitHub
, ...
}:
{
  programs = {
    neovim = {
      enable = false;
      defaultEditor = true;
    };
  };

  home.packages = with pkgs; [
    rnix-lsp
    haskell-language-server
    tailwindcss
    vscode-langservers-extracted
    tailwindcss-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier
    omnisharp-roslyn
    typescript
    marksman
    terraform-ls
    lua-language-server
  ];
}
