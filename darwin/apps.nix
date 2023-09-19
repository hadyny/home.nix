{ config, lib, pkgs, ... }:

{
  darwin.apps = {
    raycast.enable = true;
    iterm2.enable = true;

    vscode = {
      enable = true;
      extensions = [
        "arcticicestudio.nord-visual-studio-code"
        "bbenoist.Nix"
        "bradlc.vscode-tailwindcss"
        "Catppuccin.catppuccin-vsc"
        "christian-kohler.npm-intellisense"
        "dbaeumer.vscode-eslint"
        "dcortes92.FreeMarker"
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
        "ms-dotnettools.blazorwasm-companion"
        "ms-dotnettools.csharp"
        "ms-dotnettools.vscode-dotnet-runtime"
        "ms-vscode-remote.remote-containers"
        "ms-vscode-remote.remote-wsl"
        "ms-vscode.live-server"
        "ms-vscode.powershell"
        "nilobarp.javascript-test-runner"
        "Orta.vscode-jest"
        "rebornix.project-snippets"
        "redhat.vscode-yaml"
        "svelte.svelte-vscode"
        "Vue.volar"
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
      "homebrew/cask"
      "homebrew/core"
    ];
  };
}
