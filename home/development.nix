{ pkgs, ... }:

{
  home = {
    sessionPath = [ ];

    sessionVariables = {
      EDITOR = "nvim";
      GH_PAGER = "delta";
    };

    packages = with pkgs; [
      cargo
      csharprepl
      tree
      broot
      curl
      wget
      docker
      docker-credential-helpers
      lazydocker # docker UI
      duf # better df
      gdu # better du
      go
      gopls
      golangci-lint
      fd # better find
      ghc
      cabal-install
      moreutils
      ripgrep # better grep
      omnisharp-roslyn
      nodePackages.typescript-language-server
      tailwindcss-language-server
      rustywind
      vscode-langservers-extracted
      dockfmt
      gomodifytags
      gotests
      gore
      gotools
      stylelint
      watch
      jq
      jqp #jq playground, https://github.com/noahgorstein/jqp
      mediainfo
      libmediainfo
      # mitmproxy
      terraform
    ];
  };
}
