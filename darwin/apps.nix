{ config, lib, pkgs, ... }:

{
  darwin.apps = {
    raycast.enable = true;
    iterm2.enable = true;

    vscode = {
      enable = true;
      extensions = [
        "bbenoist.Nix"
        "bradlc.vscode-tailwindcss"
        "Catppuccin.catppuccin-vsc"
        "dbaeumer.vscode-eslint"
        "dweber019.vscode-style-formatter"
        "eamodio.gitlens"
        "ecmel.vscode-html-css"
        "esbenp.prettier-vscode"
        "figma.figma-vscode-extension"
        "GitHub.vscode-pull-request-github"
        "hashicorp.terraform"
        "jock.svg"
        "kumar-harsh.graphql-for-vscode"
        "mquandalle.graphql"
        "ms-azuretools.vscode-docker"
        "ms-dotnettools.csharp"
        "ms-dotnettools.vscode-dotnet-runtime"
        "ms-vscode-remote.remote-containers"
        "ms-vscode.live-server"
        "nilobarp.javascript-test-runner"
        "Orta.vscode-jest"
        "redhat.vscode-yaml"
        "yzhang.markdown-all-in-one"
      ];
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "brave-browser"
      "cloudflare-warp"
      "figma"
      "firefox"
      "gitkraken"
      "github"
      "jetbrains-toolbox"
      "obsidian"
      "postman"
      "rider"
      "slack"
      "spotify"
      "vlc"
      "zoom"
    ];

    brews = [
    ];

    global.brewfile = true;
    onActivation.cleanup = "zap";

    taps = [
    ];
  };
}
