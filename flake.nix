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
    dotemacs = {
      url = "github:hadyny/.emacs.d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    devenv.url = "github:cachix/devenv";
    # Helix from git for LSP pull-diagnostics support (helix#11315), not yet in
    # a tagged release (25.07.1). Required for C# diagnostics via Roslyn.
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Wrapper that patches Roslyn's initialize response so Helix is offered pull
    # diagnostics (works around dotnet/roslyn#76624).
    csharp-language-server = {
      url = "github:SofusA/csharp-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nix-darwin,
      home-manager,
      nixpkgs,
      ...
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

      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
        aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-tree;
        x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-tree;
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      };

      devShells = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" ] (system: {
        default = inputs.devenv.lib.mkShell {
          inherit inputs;
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./devenv.nix ];
        };
      });

    };
}
