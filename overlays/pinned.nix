self: super:

let
  # a function that takes a descriptive name and a hash of nixpkgs-unstable to pin
  # and returns the channel at that version
  pinned =
    name: hash:
    import (builtins.fetchGit {
      # Descriptive name to make the store path easier to identify
      name = "pinned-${name}";
      url = "https://github.com/NixOS/nixpkgs/";
      ref = "refs/heads/nixpkgs-unstable";
      rev = hash;
    }) { system = super.system; };

in
{
  # nixpkgs = pinned "nixpkgs" "70801e06d9730c4f1704fbd3bbf5b8e11c03a2a7";
  zed-editor = (pinned "zed-editor" "4533d9293756b63904b7238acb84ac8fe4c8c2c4").zed-editor;
}
