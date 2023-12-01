{ config, lib, pkgs, ... }:

{
  home.sessionPath = [

  ];

  home.packages = with pkgs; [
    tree
    broot
    clang
    delta # diff stuff, https://github.com/dandavison/delta
    curl
    wget
    httpie # HTTP requests tool, Python
    xh # Friendly and fast tool for sending HTTP requests, written in Rust
    docker
    docker-credential-helpers
    dive # docker images exploration, https://github.com/wagoodman/dive
    duf # better df
    gdu # better du
    fd # better find
    moreutils
    ripgrep # better grep
    watch
    jq
    jqp #jq playground, https://github.com/noahgorstein/jqp
    mediainfo
    libmediainfo
    mitmproxy
    terraform
  ];
}
