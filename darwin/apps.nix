{ config, lib, pkgs, ... }:

{
  darwin.apps = {
    raycast.enable = true;
    iterm2.enable = true;

    vscode = {
      enable = true;
      extensions = [
        "asvetliakov.vscode-neovim"
        "bbenoist.nix"
        "bradlc.vscode-tailwindcss"
        "catppuccin.catppuccin-vsc"
        "dbaeumer.vscode-eslint"
        "eamodio.gitlens"
        "ecmel.vscode-html-css"
        "esbenp.prettier-vscode"
        "github.copilot"
        "github.copilot-chat"
        "github.vscode-github-actions"
        "github.vscode-pull-request-github"
        "hashicorp.terraform"
        "haskell.haskell"
        "hediet.vscode-drawio"
        "jock.svg"
        "justusadam.language-haskell"
        "kumar-harsh.graphql-for-vscode"
        "mquandalle.graphql"
        "ms-azuretools.vscode-docker"
        "ms-dotnettools.csdevkit"
        "ms-dotnettools.csharp"
        "ms-dotnettools.vscode-dotnet-runtime"
        "ms-dotnettools.vscodeintellicode-csharp"
        "ms-vscode-remote.remote-containers"
        "ms-vscode.live-server"
        "nilobarp.javascript-test-runner"
        "orta.vscode-jest"
        "redhat.vscode-yaml"
        "statelyai.stately-vscode"
        "tgriesser.avro-schemas"
        "yzhang.markdown-all-in-one"
      ];
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "chromium"
      "cloudflare-warp"
      "figma"
      "firefox"
      "gitkraken"
      "jetbrains-toolbox"
      "obsidian"
      "postman"
      "slack"
      "spotify"
      "vivaldi"
    ];

    global.brewfile = true;
    onActivation.cleanup = "zap";

    taps = [];
  };
}
