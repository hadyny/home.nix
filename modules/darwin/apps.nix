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
      "firefox"
      "vivaldi"
      "microsoft-edge"
      "postman"
      "slack"
      "rider"
      "spotify"
      "emacs-plus-app@master"
      "zed"
    ];

    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
      extraFlags = [ "--force" ];
    };

    taps = [ "d12frosted/emacs-plus" ];
    brews = [
      "libvterm"
    ];
  };
}
