{
  description = "Nix home-manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-nvim.url = "github:hadyny/nix-nvim";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
      nur,
      emacs-overlay,
      nix-nvim,
      claude-code,
    }:
    let
      # User configuration - define your user details here
      userConfig = {
        name = "hadyn";
        fullName = "Hadyn Youens";
        email = "hadyn@youens.nz"; # Replace with your actual email

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

      # Standalone home-manager for any Linux system (no NixOS required)
      homeConfigurations.${userConfig.name} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = { inherit inputs userConfig; };
        modules = [
          ./modules/linux/home-manager.nix
        ];
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-tree;
      formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-tree;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

    };
}
