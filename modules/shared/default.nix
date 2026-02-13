# Composition module for all shared home-manager modules
#
# Import this single file to get all shared functionality:
#   imports = [ ../shared ];
#
{ ... }:
{
  imports = [
    # Terminal & Editor
    ./ghostty
    ./neovim

    # Services
    ./services/colima.nix

    # Settings
    ./settings/wallpaper.nix

    # Tools
    ./tools/aws.nix
    ./tools/docker.nix
    ./tools/dotnet.nix
    ./tools/git.nix
  ];
}
