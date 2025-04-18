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
  ];
}
