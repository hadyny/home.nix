{ pkgs, ... }:
with pkgs; [
  _1password-cli

  # fonts
  nerd-fonts.geist-mono
  nerd-fonts.fira-code
  nerd-fonts.victor-mono
  nerd-fonts.commit-mono

  emacs-lsp-booster
  vtsls
  tailwindcss-language-server
  rustywind

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
