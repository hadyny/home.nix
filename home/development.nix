{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # general development
    moreutils
    ripgrep # better grep
    cmake
    coreutils-prefixed
    duf # better df
    gdu # better du
    curl
    wget
    glibtool
    fd # better find
    fontconfig
    superfile
    shfmt
    shellcheck
    stylelint
    terraform

    # docker
    docker
    docker-credential-helpers
    lazydocker # docker UI
    dockfmt

    # golang
    go
    gopls
    gotools
    golangci-lint
    ghc
    gomodifytags
    gotests
    gore
    gotools
    cargo
    golangci-lint-langserver
    delve

    # nix
    nixfmt-classic
    nil

    # dotnet
    omnisharp-roslyn
    netcoredbg
    csharpier
    csharprepl

    # frontend dev
    typescript
    nodePackages.typescript-language-server
    tailwindcss-language-server
    rustywind
    vscode-langservers-extracted
    jsbeautifier
    vtsls
  ];
}
