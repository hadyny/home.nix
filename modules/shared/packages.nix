{ pkgs, ... }:
with pkgs;
[
  # ─────────────────────────────────────────────────────────────
  # CLI Tools & Productivity
  # ─────────────────────────────────────────────────────────────
  _1password-cli
  claude-code
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

  # ─────────────────────────────────────────────────────────────
  # Language Servers & LSPs
  # ─────────────────────────────────────────────────────────────
  typescript-language-server
  tailwindcss-language-server
  vscode-langservers-extracted

  # ─────────────────────────────────────────────────────────────
  # JavaScript / TypeScript
  # ─────────────────────────────────────────────────────────────
  bun
  rustywind # tailwind class sorter

  # ─────────────────────────────────────────────────────────────
  # .NET
  # ─────────────────────────────────────────────────────────────
  (buildDotnetGlobalTool {
    pname = "EasyDotnet";
    version = "2.3.61";
    executables = "dotnet-easydotnet";
    nugetHash = "sha256-0ud+u1PEwY11KFQBdYJWUFAJdS6mmcCIu2DlNmN3m/o=";
    meta = with lib; {
      description = "C# JSON-RPC server powering the easy-dotnet.nvim Neovim plugin";
      homepage = "https://github.com/GustavEikaas/easy-dotnet.nvim";
      license = licenses.mit;
      maintainers = with maintainers; [ ];
      mainProgram = "dotnet-easydotnet";
    };
  })

  # ─────────────────────────────────────────────────────────────
  # Emacs Dependencies
  # ─────────────────────────────────────────────────────────────
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
