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
    csharp-language-server.url = "github:sofusa/csharp-language-server";
    helix.url = "github:helix-editor/helix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
      nixCats,
      neovim-nightly-overlay,
      csharp-language-server,
      helix,
    }:
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
            core = {
              autocrlf = "input";
            };
          };
        };
      };
    in
    {
      darwinConfigurations."Hadyns-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs userConfig; };
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              users.hadyn = ./modules/darwin/work;
              extraSpecialArgs = { inherit inputs userConfig; };
            };
          }
          ./hosts/darwin/work
        ];
      };
    };
}
