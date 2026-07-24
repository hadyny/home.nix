# Composition module for all shared home-manager modules
#
# Import this single file to get all shared functionality:
#   imports = [ ../shared ];
#
{ inputs, ... }:
{
  # Shared across every home config (darwin + linux); kept here so the overlay
  # list and allowUnfree stay defined once rather than per host.
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      inputs.emacs-overlay.overlays.default
      inputs.dotemacs.overlays.default
      inputs.nix-nvim.overlays.default
      inputs.claude-code.overlays.default
      inputs.helix.overlays.default
      inputs.csharp-language-server.overlays.default
      (import ../../overlays/pinned.nix)
    ];
  };

  imports = [
    # Editors
    ./helix
    ./zed
    inputs.dotemacs.homeModules.default

    # Terminal
    ./ghostty

    # Services
    ./services/colima.nix

    # Settings
    ./settings/wallpaper.nix

    # Tools
    ./tools/aws.nix
    ./tools/docker.nix
    ./tools/dotnet.nix
    ./tools/git.nix
    ./tools/koji.nix
  ];
}
