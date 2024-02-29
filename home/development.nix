{ config, lib, pkgs, ... }:

let
  csharprepl = pkgs.callPackage ./pkgs/csharprepl/default.nix {};
  csharp-ls = pkgs.callPackage ./pkgs/csharp-ls/default.nix {};
in
{
  home = {
    sessionPath = [];

    sessionVariables = {
      EDITOR = "nvim";
      GH_PAGER = "delta";
    };

    packages = with pkgs; [

      csharprepl
      csharp-ls
      tree
      broot
      clang
      curl
      wget
      httpie # HTTP requests tool, Python
      xh # Friendly and fast tool for sending HTTP requests, written in Rust
      docker
      docker-credential-helpers
      lazydocker # docker UI
      dive # docker images exploration, https://github.com/wagoodman/dive
      duf # better df
      gdu # better du
      fd # better find
      ghc
      cabal-install
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
  };
}
