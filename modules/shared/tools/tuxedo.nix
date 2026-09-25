# tuxedo: keyboard-driven todo.txt TUI — https://github.com/webstonehq/tuxedo
{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.tools.tuxedo;

  configFile = pkgs.writeText "tuxedo-config.toml" ''
    theme = "${cfg.theme}"
  '';
in
{
  options.tools.tuxedo = {
    enable = mkEnableOption "Enable tuxedo, a keyboard-driven todo.txt TUI";

    todoDir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/notes/todo";
      description = "Directory holding the todo.txt files (exported as $TODO_DIR)";
    };

    todoFile = mkOption {
      type = types.str;
      default = "${cfg.todoDir}/todo.txt";
      description = "Path to the active todo.txt file (exported as $TODO_FILE)";
    };

    doneFile = mkOption {
      type = types.str;
      default = "${cfg.todoDir}/done.txt";
      description = "Path to the archive file for completed tasks (exported as $DONE_FILE)";
    };

    theme = mkOption {
      type = types.str;
      default = "Catppuccin Mocha";
      description = "Theme persisted to tuxedo's config.toml (Catppuccin Mocha/Latte are installed as custom themes below; cycle with `T`)";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ pkgs.tuxedo ];

      sessionVariables = {
        TODO_DIR = cfg.todoDir;
        TODO_FILE = cfg.todoFile;
        DONE_FILE = cfg.doneFile;
      };

      # Custom themes tuxedo picks up from its themes dir (joins the `T`
      # picker in sorted filename order). These are plain Nix-store symlinks:
      # tuxedo never rewrites files here, only config.toml.
      file = {
        ".config/tuxedo/themes/catppuccin-mocha.toml".source = ./themes/catppuccin-mocha.toml;
        ".config/tuxedo/themes/catppuccin-latte.toml".source = ./themes/catppuccin-latte.toml;
      };

      # tuxedo rewrites config.toml itself (theme/density/sort/etc. all
      # persist there), so it can't be a home-manager-managed symlink into
      # the read-only Nix store. Seed it once, as a plain writable file, and
      # leave it alone on subsequent activations so tuxedo's own edits stick.
      activation.tuxedoConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        configFile="${config.home.homeDirectory}/.config/tuxedo/config.toml"
        if [ ! -e "$configFile" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$configFile")"
          $DRY_RUN_CMD install -m u+rw ${configFile} "$configFile"
        fi
      '';
    };
  };
}
