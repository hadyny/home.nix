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
      curl
      wget
      docker
      docker-credential-helpers
      lazydocker # docker UI
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
