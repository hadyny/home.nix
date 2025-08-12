{ pkgs, ... }:
with pkgs; [
  _1password-cli

  # dev
  devenv
  emacs-lsp-booster
  vtsls
  tailwindcss-language-server
  rustywind
  nixd
  nil
  nixfmt-classic
  prettierd
  scooter
  fsautocomplete
  omnisharp-roslyn
  roslyn-ls
  emmet-language-server
  (vscode-langservers-extracted.overrideAttrs (oldAttrs: {
    version = "4.8.0";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "vscode-langservers-extracted";
      rev = "v4.8.0";
      sha256 = "sha256-sGnxmEQ0J74zNbhRpsgF/cYoXwn4jh9yBVjk6UiUdK0=";
    };
  }))

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
