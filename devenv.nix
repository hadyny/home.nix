{ pkgs, ... }:
{
  packages = [
    pkgs.nodejs
    pkgs.nixd
    pkgs.nixfmt
  ];

  git-hooks.hooks = {
    # replaces .githooks/pre-commit (`nix fmt -- --ci`)
    nixfmt-rfc-style.enable = true;

    # replaces .githooks/pre-push (`nix flake check`)
    # --impure is required because the devenv devShells output needs to
    # determine the working directory, which pure eval disallows.
    flake-check = {
      enable = true;
      name = "nix flake check";
      entry = "nix flake check --impure";
      pass_filenames = false;
      always_run = true;
      stages = [ "pre-push" ];
    };
  };
}
