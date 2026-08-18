{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.settings.zed;
in
{
  options.settings.zed = {
    enable = mkEnableOption "Enable Zed editor configuration";

    fontFamily = mkOption {
      type = types.str;
      default = "Maple Mono NF";
      description = "Buffer (code) font family to use in Zed";
    };

    uiFontFamily = mkOption {
      type = types.str;
      default = "Maple Mono NF";
      description = "UI font family to use in Zed";
    };

    fontSize = mkOption {
      type = types.number;
      default = 15;
      description = "Font size to use in Zed";
    };
  };

  config = mkIf cfg.enable {
    home.file.".config/zed/settings.json".text = builtins.toJSON {
      auto_install_extensions = {
        nix = true;
        lua = true;
        csharp = true;
        eslint = true;
        tailwindcss = true;
        tokyo-night = true;
        authzed-zed = true;
        # Icon themes carry no colour scheme, so this one suits Tokyo Night.
        material-icon-theme = true;
        terraform = true;
        editorconfig = true;
        ghostty = true;
        graphql = true;
        astro = true;
      };

      theme = {
        mode = "system";
        light = "Tokyo Night Light";
        dark = "Tokyo Night";
      };

      theme_overrides = {
        "Tokyo Night".syntax = {
          comment = {
            font_style = "italic";
          };
          "comment.doc" = {
            font_style = "italic";
          };
        };
        "Tokyo Night Light".syntax = {
          comment = {
            font_style = "italic";
          };
          "comment.doc" = {
            font_style = "italic";
          };
        };
      };

      project_panel = {
        dock = "right";
      };

      vim_mode = true;

      buffer_font_family = cfg.fontFamily;
      buffer_font_size = cfg.fontSize;
      ui_font_family = cfg.uiFontFamily;

      languages = {
        Nix = {
          # nixd only, as in the Helix module. The nix extension supplies both
          # servers, and the two report the same problem twice. The extension
          # downloads no binary: it calls `which` against the project shell
          # environment, so a devenv or direnv nixd wins over the profile one.
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
        "C#" = {
          language_servers = [
            "csharp-language-server"
            "!roslyn"
            "!omnisharp"
          ];
        };
        SpiceDB = {
          format_on_save = "off";
        };
      };

      lsp = {
        csharp-language-server = {
          binary = {
            path_lookup = true;
          };
        };
        tailwindcss-language-server = {
          binary = {
            path_lookup = true;
          };
        };
        typescript-language-server = {
          binary = {
            path_lookup = true;
          };
        };
        eslint = {
          binary = {
            path_lookup = true;
          };
        };
      };
    };
  };
}
