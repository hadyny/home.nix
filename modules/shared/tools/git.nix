{ config, lib, pkgs, ... }:

with lib;

let cfg = config.tools.git;
in {
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
    home.file = lib.mapAttrs' (k: v:
      lib.nameValuePair "${k}/.gitconfig" {
        text = lib.generators.toINI { } v;
      }) cfg.workspaces;

    programs = {
      git = {
        enable = true;
        settings.aliases = {
          aliases = "config --get-regexp ^alias.";
          branches =
            "branch -a --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:blue)(%(committerdate:short)) [%(authorname)]' --sort=-committerdate";
          logs =
            "log --pretty=format:'%C(auto)%h%C(reset) %C(cyan)%ad%C(auto)%d%C(reset) %s %C(blue)[%cn]%C(reset)' --date=short-local --graph --all";
          uncommit = "reset --mixed HEAD~1";
        };
        lfs.enable = true;
        settings.user.name = cfg.userName;
        settings.user.email = cfg.userEmail;

        settings = {
          github.user = cfg.githubUser;
          init.defaultBranch = "main";
          diff.colorMoved = "default";
        };

        includes = map (x: {
          condition = "gitdir:~/${x}/";
          path = "~/${x}/.gitconfig";
        }) (lib.attrNames cfg.workspaces);
      };

      delta = {
        enable = true;
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
          diff-so-fancy = true;
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
            pagers = [{ pager = "delta --features 'default lazygit'"; }];
            parseEmoji = true;
          };
          customCommands = [
            {
              key = "C";
              command = "npx git-cz";
              description = "commit with commitizen";
              context = "files";
              loadingText = "opening commitizen commit tool";
              output = "terminal";
            }
            {
              key = "t";
              command =
                "tig {{.SelectedSubCommit.Sha}} -- {{.SelectedCommitFile.Name}}";
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

    home.packages = with pkgs; [ git-crypt gh tig ];

    home.sessionVariables = { GH_PAGER = "delta"; };
  };
}
