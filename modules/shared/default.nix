# Composition module for all shared home-manager modules
#
# Import this single file to get all shared functionality:
#   imports = [ ../shared ];
#
{ inputs, ... }:
{
  imports = [
    # Editors
    ./helix
    ./zed
    inputs.dotemacs.homeManagerModules.default

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
