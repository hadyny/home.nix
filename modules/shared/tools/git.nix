{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.tools.git;
in
{
  options.tools.git = {
    enable = mkEnableOption "Enable GIT";

    userName = mkOption { type = types.str; };
    userEmail = mkOption { type = types.str; };
    githubUser = mkOption { type = types.str; };

    workspaces = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home = {
      file = lib.mapAttrs' (
        k: v:
        lib.nameValuePair "${k}/.gitconfig" {
          text = lib.generators.toINI { } v;
        }
      ) cfg.workspaces;

      packages = with pkgs; [
        git-crypt
        gh
        tig
        git-extras
      ];

      sessionVariables = {
        GH_PAGER = "delta";
      };
    };

    programs = {
      git = {
        enable = true;
        signing.format = null;
        lfs.enable = true;
        settings = {
          alias = {
            aliases = "config --get-regexp ^alias.";
            branches = "branch -a --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:blue)(%(committerdate:short)) [%(authorname)]' --sort=-committerdate";
            logs = "log --pretty=format:'%C(auto)%h%C(reset) %C(cyan)%ad%C(auto)%d%C(reset) %s %C(blue)[%cn]%C(reset)' --date=short-local --graph --all";
            uncommit = "reset --mixed HEAD~1";
          };
          user.name = cfg.userName;
          user.email = cfg.userEmail;
          github.user = cfg.githubUser;
          init.defaultBranch = "main";
          diff.colorMoved = "default";

          # git-extras reads `git-extras.default-branch` and uses
          # `init.defaultBranch` when that key is absent, thus the key above
          # covers every git-extras command that needs the default branch.
          "git-extras" = {
            # `git get <url>` clones under this directory. The command has no
            # default and stops with an error when the key is absent.
            get.clone-path = "${config.home.homeDirectory}/src";
          };

          # `git bulk -w <name> <command>` runs one git command in every
          # repository of a workspace. The names come from the same workspace
          # list that supplies the per-directory gitconfig.
          #
          # Each value must be a literal absolute path. `git bulk` treats a
          # value that starts with `$` as the *name* of an environment
          # variable, so a path such as `$HOME/src/ep` fails.
          bulkworkspaces = lib.mapAttrs' (
            path: _: lib.nameValuePair (baseNameOf path) "${config.home.homeDirectory}/${path}"
          ) cfg.workspaces;
        };

        includes = map (x: {
          condition = "gitdir:~/${x}/";
          path = "~/${x}/.gitconfig";
        }) (lib.attrNames cfg.workspaces);
      };

      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          lazygit = {
            hyperlinks = false;
            paging = "never";
            side-by-side = false;
          };
          features = "decorations";
          whitespace-error-style = "22 reverse";
          true-color = "always";
          line-numbers = true;
          hyperlinks = true;
        };
      };

      lazygit = {
        enable = true;
        settings = {
          gui = {
            returnImmediately = true;
            nerdFontsVersion = "3";
            timeFormat = "2006-01-02 15:04:05";
            showRandomTip = false;
          };
          git = {
            diffRenderers = [
              {
                type = "stdinFilter";
                command = "delta --paging=never --features 'default lazygit'";
              }
            ];
            parseEmoji = true;
          };
          customCommands = [
            {
              key = "C";
              command = "koji";
              description = "commit with koji";
              context = "files";
              loadingText = "opening koji commit tool";
              output = "terminal";
            }
            {
              key = "t";
              command = "tig {{.SelectedSubCommit.Sha}} -- {{.SelectedCommitFile.Name}}";
              context = "commitFiles";
              description = "tig file (history of commits affecting file)";
              output = "terminal";
            }
            {
              key = "t";
              command = "tig -- {{.SelectedFile.Name}}";
              context = "files";
              description = "tig file (history of commits affecting file)";
              output = "terminal";
            }
            {
              key = "E";
              description = "Add empty commit";
              context = "commits";
              command = ''git commit --allow-empty -m "empty commit"'';
              loadingText = "Committing empty commit...";
            }
            {
              key = "n";
              context = "localBranches";
              prompts = [
                {
                  type = "menu";
                  title = "What kind of branch is it?";
                  key = "BranchType";
                  options = [
                    {
                      name = "feature";
                      description = "a feature branch";
                      value = "feature";
                    }
                    {
                      name = "bugfix";
                      description = "a bugfix branch";
                      value = "bugfix";
                    }
                    {
                      name = "release";
                      description = "a release branch";
                      value = "release";
                    }
                  ];
                }
                {
                  type = "input";
                  title = "What is the new branch name?";
                  key = "BranchName";
                  initialValue = "";
                }
              ];
              command = "git branch {{.Form.BranchType}}/{{.Form.BranchName}}";
              loadingText = "Creating branch";
            }
          ];
        };
      };
    };

  };
}
