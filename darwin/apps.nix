{
  darwin.apps = {
    raycast.enable = true;
    iterm2.enable = true;

    vscode = {
      enable = true;
      extensions = [
        "bodil.file-browser"
        "bradlc.vscode-tailwindcss"
        "christian-kohler.npm-intellisense"
        "dbaeumer.vscode-eslint"
        "docker.docker"
        "ecmel.vscode-html-css"
        "editorconfig.editorconfig"
        "esbenp.prettier-vscode"
        "github.copilot"
        "github.copilot-chat"
        "github.vscode-github-actions"
        "github.vscode-pull-request-github"
        "graphql.vscode-graphql"
        "graphql.vscode-graphql-syntax"
        "gruntfuggly.todo-tree"
        "hashicorp.terraform"
        "jnoortheen.nix-ide"
        "jock.svg"
        "kahole.magit"
        "mechatroner.rainbow-csv"
        "ms-azuretools.vscode-docker"
        "ms-dotnettools.csdevkit"
        "ms-dotnettools.csharp"
        "ms-dotnettools.vscode-dotnet-runtime"
        "ms-dotnettools.vscodeintellicode-csharp"
        "ms-vscode-remote.remote-containers"
        "ms-vscode.live-server"
        "mvllow.rose-pine"
        "redhat.vscode-yaml"
        "sumneko.lua"
        "vscodevim.vim"
        "vspacecode.vspacecode"
        "vspacecode.whichkey"
        "yoavbls.pretty-ts-errors"
        "yzhang.markdown-all-in-one"
      ];
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "cloudflare-warp"
      "google-chrome"
      "firefox@developer-edition"
      "obsidian"
      "postman"
      "slack"
    ];

    global.brewfile = true;
    onActivation.cleanup = "zap";

    taps = [ ];
    brews = [ ];
  };
}
