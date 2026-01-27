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
      "google-chrome"
      "firefox"
      "obsidian"
      "postman"
      "slack"
      "ghostty"
      "visual-studio-code"
      "rider"
      "datagrip"
      "spotify"
      "zed"
      "emacs-plus-app@master"
    ];

    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [ "d12frosted/emacs-plus" ];
    brews = [
    ];
  };
}
