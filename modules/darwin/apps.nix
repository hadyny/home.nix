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
      "obsidian"
      "postman"
      "slack"
      "ghostty"
      "rider"
      "datagrip"
      "spotify"
      "emacs-plus-app@master"
      "claude-code"
    ];

    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [ "d12frosted/emacs-plus" ];
    brews = [
      "libvterm"
      "dstask"
    ];
  };
}
