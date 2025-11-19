{
  environment.variables = {
    HOMEBREW_NO_ENV_HINTS = "1";
  };
  darwin.apps = {
    raycast.enable = true;
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "cloudflare-warp"
      "google-chrome"
      "brave-browser"
      "firefox"
      "microsoft-edge"
      "obsidian"
      "postman"
      "slack"
      "ghostty"
      "visual-studio-code"
      "rider"
      "datagrip"
      "spotify"
      "vivaldi"
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
