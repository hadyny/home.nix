{ config, lib, pkgs, ... }:

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
    home.file = lib.mapAttrs' (k: v: lib.nameValuePair "${k}/.gitconfig" { text = lib.generators.toINI { } v; }) cfg.workspaces;

    programs = {
      git = {
        enable = true;
        aliases = {
          aliases = "config --get-regexp ^alias\.";
          branches = "branch -a --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:blue)(%(committerdate:short)) [%(authorname)]' --sort=-committerdate";
          logs = "log --pretty=format:'%C(auto)%h%C(reset) %C(cyan)%ad%C(auto)%d%C(reset) %s %C(blue)[%cn]%C(reset)' --date=short-local --graph --all";
          uncommit = "reset --mixed HEAD~1";
        };
        lfs.enable = true;
        userName = cfg.userName;
        userEmail = cfg.userEmail;

        delta = {
          enable = true;
          options = {
            decorations = {
              blame-palette = "#1e1e2e #181825 #11111b #313244 #45475a";
	            commit-decoration-style = "box ul";
              dark = true;
              file-decoration-style = "#cdd6f4";
              file-style = "#cdd6f4";
              hunk-header-decoration-style = "box ul";
              hunk-header-file-style = "bold";
              hunk-header-line-number-style = "bold #a6adc8";
              hunk-header-style = "file line-number syntax";
              line-numbers = true;
              line-numbers-left-style = "#6c7086";
              line-numbers-minus-style = "bold #f38ba8";
              line-numbers-plus-style = "bold #a6e3a1";
              line-numbers-right-style = "#6c7086";
              line-numbers-zero-style = "#6c7086";
              # 25% red 75% base
              minus-emph-style = "bold syntax #53394c";
              # 10% red 90% base
              minus-style = "syntax #35293b";
              # 25% green 75% base
              plus-emph-style = "bold syntax #40504b";
              # 10% green 90% base
              plus-style = "syntax #2c333a";
              map-styles = "bold purple => syntax \"#494060\", bold blue => syntax \"#394361\", bold cyan => syntax \"#384d5e\", bold yellow => syntax \"#544f4e\"";
              # Should match the name of the bat theme
              syntax-theme = "catppuccin";
            };
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

        extraConfig = {
          github.user = cfg.githubUser;
          init.defaultBranch = "main";
          diff.colorMoved = "default";
        };

        includes = map (x: { condition = "gitdir:~/${x}/"; path = "~/${x}/.gitconfig"; })
          (lib.attrNames cfg.workspaces);
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
            paging.pager = "delta --features 'default lazygit'";
            parseEmoji = true;
          };
          customCommands = [
            {
              key = "C";
              command = "git cz c";
              description = "commit with commitizen";
              context = "files";
              loadingText = "opening commitizen commit tool";
              subprocess = true;
            }
            {
              key = "t";
              command = "tig {{.SelectedSubCommit.Sha}} -- {{.SelectedCommitFile.Name}}";
              context = "commitFiles";
              description = "tig file (history of commits affecting file)";
              subprocess = true;
            }
            {
              key = "t";
              command = "tig -- {{.SelectedFile.Name}}";
              context = "files";
              description = "tig file (history of commits affecting file)";
              subprocess = true;
            }
            {
              key = "E";
              description = "Add empty commit";
              context = "commits";
              command = "git commit --allow-empty -m \"empty commit\"";
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
                      description = "a butfix branch";
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

    home.packages = with pkgs; [
      git-crypt
      commitizen
      delta
      gh
      git-standup
      tig
    ];
  };
}
