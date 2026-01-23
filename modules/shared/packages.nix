{ inputs, pkgs, ... }:
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
  inputs.csharp-language-server.packages.${stdenv.hostPlatform.system}.default

  # emacs
  (python3Packages.buildPythonPackage rec {
    pname = "rassumfrassum";
    version = "0.3.2";

    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-T4lODtOX7vXd5iZA6c47j/d/9bss6esnnJP4U3Ekzug=";
    };
    pyproject = true;
    build-system = [ pkgs.python3.pkgs.setuptools ];
  })
  typescript-language-server
  tailwindcss-language-server
  vscode-langservers-extracted

  posting
  gh-dash
  harlequin
  tasksh
  taskwarrior-tui

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
