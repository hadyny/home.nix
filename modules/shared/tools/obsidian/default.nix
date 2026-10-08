# Obsidian: Markdown notes app — https://obsidian.md
{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.tools.obsidian;
  plugins = import ./plugins.nix { inherit pkgs lib; };
  vaultDir = "${config.home.homeDirectory}/${cfg.vault}";

  # Plugins write data.json whenever a setting changes in the UI, so it can't
  # be a home-manager-managed symlink into the read-only Nix store. Seed it
  # once, as a plain writable file, and leave it alone on later activations.
  seeds = {
    obsidian-minimal-settings = pkgs.writeText "obsidian-minimal-settings-data.json" (
      builtins.toJSON {
        lightStyle = "minimal-light";
        darkStyle = "minimal-dark";
        lightScheme = "minimal-catppuccin-light";
        darkScheme = "minimal-catppuccin-dark";
      }
    );
  };
in
{
  options.tools.obsidian = {
    enable = mkEnableOption "Obsidian with the notes vault, Minimal theme and community plugins";

    vault = mkOption {
      type = types.str;
      default = "notes";
      description = "Vault path relative to $HOME";
    };
  };

  config = mkIf cfg.enable {
    programs.obsidian = {
      enable = true;
      cli.enable = true;
      vaults.${cfg.vault}.settings = {
        # Follow the OS light/dark mode; Minimal Theme Settings then picks
        # the Catppuccin light or dark scheme.
        appearance.theme = "system";
        themes = [ plugins.minimal ];
        communityPlugins = with plugins; [
          git
          minimal-settings
          notebook-navigator
          tasknotes
        ];
      };
    };

    # After linkGeneration, so the plugin folder already exists.
    home.activation.obsidianPluginData = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      concatStrings (
        mapAttrsToList (id: seed: ''
          dataFile="${vaultDir}/.obsidian/plugins/${id}/data.json"
          if [ ! -e "$dataFile" ]; then
            run mkdir -p "$(dirname "$dataFile")"
            run install -m u+rw ${seed} "$dataFile"
          fi
        '') seeds
      )
    );
  };
}
