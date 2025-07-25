{
  description = "Home-manager darwin config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, nixCats
    , neovim-nightly-overlay, emacs-overlay }:
    let
      # User configuration - define your user details here
      userConfig = {
        name = "hadyn";
        fullName = "Hadyn Youens";
        email = "hadyn@youens.nz"; # Replace with your actual email
        home = "/Users/hadyn";

        # Git-specific configurations
        githubUser = "hadyny";
        gitWorkspaces = {
          "src/ep" = {
            user = {
              email = "hadyn.youens@educationperfect.com";
              name = userConfig.fullName;
            };
            core = { autocrlf = "input"; };
          };
        };
      };
    in {
      darwinConfigurations."Hadyns-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs userConfig; };
        modules = [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.hadyn = ./home;
            home-manager.extraSpecialArgs = { inherit inputs userConfig; };
          }
        ];
      };
    };
}
