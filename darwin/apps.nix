{
  darwin.apps = {
    raycast.enable = true;
    iterm2.enable = true;

    vscode = {
      enable = true;
      extensions = [
        "asvetliakov.vscode-neovim"
        "authzed.spicedb-vscode"
        "bbenoist.nix"
        "bradlc.vscode-tailwindcss"
        "catppuccin.catppuccin-vsc"
        "christian-kohler.npm-intellisense"
        "dbaeumer.vscode-eslint"
        "dsznajder.es7-react-js-snippets"
        "ecmel.vscode-html-css"
        "editorconfig.editorconfig"
        "esbenp.prettier-vscode"
        "figma.figma-vscode-extension"
        "github.copilot"
        "github.copilot-chat"
        "github.vscode-github-actions"
        "github.vscode-pull-request-github"
        "golang.go"
        "hashicorp.terraform"
        "hmarr.cel"
        "jock.svg"
        "kumar-harsh.graphql-for-vscode"
        "mechatroner.rainbow-csv"
        "ms-azuretools.vscode-docker"
        "ms-dotnettools.csdevkit"
        "ms-dotnettools.csharp"
        "ms-dotnettools.vscode-dotnet-runtime"
        "ms-dotnettools.vscodeintellicode-csharp"
        "ms-vscode-remote.remote-containers"
        "ms-vscode.live-server"
        "redhat.vscode-yaml"
        "statelyai.stately-vscode"
        "sumneko.lua"
        "tgriesser.avro-schemas"
        "yzhang.markdown-all-in-one"
      ];
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "cloudflare-warp"
      "chromium"
      "firefox@developer-edition"
      "messenger"
      "vivaldi"
      "Rider"
      "DataGrip"
      "GoLand"
      "obsidian"
      "postman"
      "slack"
      "spotify"
    ];

    global.brewfile = true;
    onActivation.cleanup = "zap";

    taps = [];
    brews = [];
  };
}
