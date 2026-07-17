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
      "brave-browser"
      "firefox"
      "vivaldi"
      "microsoft-edge"
      "postman"
      "slack"
      "rider"
      "spotify"
      "zed"
    ];

    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
      extraFlags = [ "--force" ];
    };

    # libvterm is kept for straight.el's vterm module compilation under the
    # nix Emacs; the d12frosted/emacs-plus tap is gone with the cask.
    brews = [
      "libvterm"
    ];
  };
}
