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
      cmake
      coreutils-prefixed
      csharprepl
      discount
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
      gotools
      golangci-lint
      fd # better find
      ghc
      nixfmt-classic
      moreutils
      ripgrep # better grep
      omnisharp-roslyn
      netcoredbg
      csharpier
      typescript
      nodePackages.typescript-language-server
      tailwindcss-language-server
      rustywind
      vscode-langservers-extracted
      dockfmt
      gomodifytags
      gotests
      gore
      gotools
      fontconfig
      golangci-lint-langserver
      delve
      superfile
      graphviz
      shfmt
      nil
      shellcheck
      jsbeautifier
      stylelint
      timewarrior
      watch
      jq
      jqp # jq playground, https://github.com/noahgorstein/jqp
      mediainfo
      libmediainfo
      terraform
    ];
  };
}
