{ config, ... }:
{
  system.defaults.dock = {
    # Whether to automatically hide and show the Dock. Default is false.
    autohide = true;
    # Sets the speed of the autohide delay. Default is "0.24".
    autohide-delay = 0.0;
    # Sets the speed of animation when hiding/showing the Dock. Default is "1.0".
    autohide-time-modifier = 1.0;
    # Position of dock. Default is "bottom"; alternatives are "left" and "right".
    orientation = "left";
    # Whether to make icons of hidden applications translucent. Default is false.
    showhidden = true;
    # Show recent applications in the dock. Default is true.
    show-recents = false;
    # Show only open applications in the Dock. Default is false.
    static-only = false;
    # Size of the icons in the Dock. Default is 64.
    tilesize = 56;
  };

  targets.darwin.dock = {
    # Apps to be added to Dock.
    apps = [
      "Slack"
      "Firefox Developer Edition"
      "Google Chrome"
      "Visual Studio Code"
      "Rider"
      "DataGrip"
      "Obsidian"
    ];

    # "Others" section in Dock (the one after the bar, where the Bin sits).
    others = [
      ({ path = "${config.user.home}/Downloads"; sort = "dateadded"; view = "grid"; })
    ];
  };
}
