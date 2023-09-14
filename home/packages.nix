{ config, lib, pkgs, ... }:

{
  home.sessionPath = [

  ];

  home.packages = with pkgs; [
    tree
    broot # better tree

    clang

    delta # diff stuff, https://github.com/dandavison/delta
    difftastic # A structural diff that understands syntax.
    diff-so-fancy # better diff

    curl
    wget
    # curlie
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
  ];
}