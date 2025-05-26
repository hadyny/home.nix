{
  description = "Hadyn's darwin config";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-24.11-darwin` to use Nixpkgs 24.11.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Use `github:LnL7/nix-darwin/nix-darwin-24.11` to use Nixpkgs 24.11.
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }: {
    darwinConfigurations."Hadyns-MacBook-Pro" =
      nix-darwin.lib.darwinSystem { modules = [ ./darwin-configuration.nix ]; };
  };
}
