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
  # Language Servers & LSPs
  # ─────────────────────────────────────────────────────────────
  typescript-language-server
  tailwindcss-language-server
  vscode-langservers-extracted
  lua-language-server
  nil
  roslyn-ls

  # ─────────────────────────────────────────────────────────────
  # JavaScript / TypeScript
  # ─────────────────────────────────────────────────────────────
  bun
  # rustywind # tailwind class sorter

  # ─────────────────────────────────────────────────────────────
  # Emacs Dependencies
  # ─────────────────────────────────────────────────────────────
  (python3Packages.buildPythonPackage rec {
    pname = "rassumfrassum";
    version = "0.3.3";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Gs2Qgwafj9m1tdVcw1k4UXTbxgbS5awTCINBkb5HIhc=";
    };
    pyproject = true;
    build-system = [ pkgs.python3.pkgs.setuptools ];
  })
  multimarkdown
  # prettier

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
