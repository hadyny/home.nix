{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.tools.koji;

  tomlFormat = pkgs.formats.toml { };

  commitTypeType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "The commit type name (e.g., feat, fix, docs)";
      };
      emoji = mkOption {
        type = types.str;
        description = "The emoji to prepend to commits of this type";
      };
      description = mkOption {
        type = types.str;
        description = "A description of what this commit type represents";
      };
    };
  };

  defaultCommitTypes = [
    { name = "feat"; emoji = "✨"; description = "A new feature"; }
    { name = "fix"; emoji = "🐛"; description = "A bug fix"; }
    { name = "docs"; emoji = "📚"; description = "Documentation only changes"; }
    { name = "style"; emoji = "💄"; description = "Changes that do not affect the meaning of the code"; }
    { name = "refactor"; emoji = "♻️"; description = "A code change that neither fixes a bug nor adds a feature"; }
    { name = "perf"; emoji = "⚡"; description = "A code change that improves performance"; }
    { name = "test"; emoji = "✅"; description = "Adding missing tests or correcting existing tests"; }
    { name = "build"; emoji = "📦"; description = "Changes that affect the build system or external dependencies"; }
    { name = "ci"; emoji = "🤖"; description = "Changes to CI configuration files and scripts"; }
    { name = "chore"; emoji = "🔧"; description = "Other changes that don't modify src or test files"; }
    { name = "revert"; emoji = "⏪"; description = "Reverts a previous commit"; }
  ];

in
{
  options.tools.koji = {
    enable = mkEnableOption "Enable Koji commit message tool";

    emoji = mkOption {
      type = types.bool;
      default = true;
      description = "Prepend commit messages with emoji";
    };

    autocomplete = mkOption {
      type = types.bool;
      default = true;
      description = "Enable autocomplete for scope from commit history";
    };

    breakingChanges = mkOption {
      type = types.bool;
      default = true;
      description = "Enable breaking change prompts";
    };

    issues = mkOption {
      type = types.bool;
      default = true;
      description = "Enable issue reference prompts";
    };

    sign = mkOption {
      type = types.bool;
      default = false;
      description = "GPG sign commits";
    };

    commitTypes = mkOption {
      type = types.listOf commitTypeType;
      default = defaultCommitTypes;
      description = "List of commit types with their emoji mappings";
    };
  };

  config = mkIf cfg.enable {
    home.file.".config/koji/config.toml".source = tomlFormat.generate "koji-config" {
      emoji = cfg.emoji;
      autocomplete = cfg.autocomplete;
      breaking_changes = cfg.breakingChanges;
      issues = cfg.issues;
      sign = cfg.sign;
      commit_types = cfg.commitTypes;
    };
  };
}
