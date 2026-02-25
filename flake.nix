{
  description = "Home-manager darwin config";

  inputs = {
    # TODO: swift is broken on nixpkgs-unstable: https://github.com/nixos/nixpkgs/issues/483584
    nixpkgs.url = "github:NixOS/nixpkgs/70801e06d9730c4f1704fbd3bbf5b8e11c03a2a7";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-nvim.url = "github:hadyny/nix-nvim";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
      nur,
      nixCats,
      neovim-nightly-overlay,
      emacs-overlay,
      nix-nvim,
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
              users.${userConfig.name} = ./modules/darwin/work;
              extraSpecialArgs = { inherit inputs userConfig; };
            };
          }
          ./hosts/darwin/work
        ];
      };

      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userConfig; };
        modules = [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              users.${userConfig.name} = ./modules/nixos/home-manager.nix;
              extraSpecialArgs = { inherit inputs userConfig; };
            };
          }
          ./hosts/nixos
        ];
      };
    };
}
