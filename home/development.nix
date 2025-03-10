{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # general development & utils
    httpie
    moreutils
    ripgrep # better grep
    cmake
    coreutils-prefixed
    duf # better df
    gdu # better du
    curl
    wget
    glibtool
    gcc
    libgccjit
    fd # better find
    fontconfig
    superfile
    shfmt
    shellcheck
    stylelint
    stylua
    terraform
    lua-language-server
    sqlite
    sqlitebrowser
    # kafka
    redpanda-client
    kafkactl
    kcat

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
    typescript-language-server
    tailwindcss-language-server
    rustywind
    vscode-langservers-extracted
    jsbeautifier
    vtsls
    nodejs_23
  ];
}
