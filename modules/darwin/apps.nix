{
  darwin.apps = {
    raycast.enable = true;
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
      "ghostty"
      "visual-studio-code"
      "rider"
      "datagrip"
      "spotify"
      "zed"
    ];

    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [ ];
    brews = [ ];
  };
}
