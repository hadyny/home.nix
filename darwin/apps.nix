{
  darwin.apps = {
    raycast.enable = true;
    iterm2.enable = true;
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "cloudflare-warp"
      "google-chrome"
      "firefox@developer-edition"
      "Rider"
      "DataGrip"
      "GoLand"
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
