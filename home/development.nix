{ pkgs, ... }:
let
  nvm = builtins.fetchGit {
    url = "https://github.com/nvm-sh/nvm";
    rev = "977563e97ddc66facf3a8e31c6cff01d236f09bd";
  };
in {
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
    gcc
    fd # better find
    fontconfig
    shfmt
    shellcheck
    stylelint
    terraform
    sqlite
    sqlitebrowser
    spicedb
    spicedb-zed
    mitmproxy
    csharprepl
    nodejs_23
    netcoredbg

    # kafka
    redpanda-client
    kafkactl
    kcat

    # docker
    docker
    docker-credential-helpers
    lazydocker # docker UI
    dockfmt

    # language servers
    lua-language-server
    stylua

    nixfmt-classic
    nil

    roslyn-ls
    netcoredbg
    csharpier

    typescript-language-server
    tailwindcss-language-server
    rustywind
    graphql-language-service-cli
    vscode-langservers-extracted

  ];

  home.file.".nvm" = {
    source = nvm;
    recursive = true;
  };

  programs.zsh.initExtra = ''
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  '';
}
