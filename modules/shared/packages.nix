{ pkgs, ... }:
with pkgs;
[
  # ─────────────────────────────────────────────────────────────
  # CLI Tools & Productivity
  # ─────────────────────────────────────────────────────────────
  _1password-cli
  posting

  # ─────────────────────────────────────────────────────────────
  # Core Utilities
  # ─────────────────────────────────────────────────────────────
  coreutils-prefixed
  moreutils
  curl
  wget
  fd # better find
  duf # better df
  gdu # better du
  tabiew # csv viewer
  rich-cli # everything viewer
  kew # music player
  nur.repos.forkprince.helium-nightly

  # ─────────────────────────────────────────────────────────────
  # Development Tools
  # ─────────────────────────────────────────────────────────────
  devenv
  cmake
  gcc
  shfmt
  shellcheck
  stylelint
  fontconfig
  nvim-pkg
  scooter
  koji
  claude-code
  gemini-cli
  fnm

  # ─────────────────────────────────────────────────────────────
  # JavaScript / TypeScript
  # ─────────────────────────────────────────────────────────────
  bun

  # ─────────────────────────────────────────────────────────────
  # Infrastructure & DevOps
  # ─────────────────────────────────────────────────────────────
  terraform
  spicedb
  spicedb-zed

  # ─────────────────────────────────────────────────────────────
  # Docker
  # ─────────────────────────────────────────────────────────────
  docker-credential-helpers
  dockfmt

  # ─────────────────────────────────────────────────────────────
  # Kafka
  # ─────────────────────────────────────────────────────────────
  redpanda-client
  kafkactl
  kcat

  # ─────────────────────────────────────────────────────────────
  # Networking & Debugging
  # ─────────────────────────────────────────────────────────────
  mitmproxy
  dbeaver-bin
  github-mcp-server
]
