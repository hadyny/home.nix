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
    spicedb
    spicedb-zed
    mitmproxy

    # kafka
    redpanda-client
    kafkactl
    kcat

    # docker
    docker-credential-helpers
    dockfmt
  ];

  home.file.".nvm" = {
    source = nvm;
    recursive = true;
  };

  programs.zsh.initContent = ''
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  '';
}
