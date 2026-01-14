{ pkgs, ... }:
with pkgs;
[
  _1password-cli

  # dev
  devenv
  rustywind
  bun

  # for zed
  nil
  nixfmt
  csharpier

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
]
