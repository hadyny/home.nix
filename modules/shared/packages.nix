{ pkgs, inputs, ... }:
with pkgs;
[
  _1password-cli

  # dev
  devenv
  rustywind
  nixd
  nixfmt
  bun
  podman
  podman-tui
  podman-desktop
  podman-compose
  inputs.csharp-language-server.packages.${stdenv.hostPlatform.system}.default

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
