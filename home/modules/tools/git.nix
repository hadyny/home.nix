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
              commit-decoration-style = "bold yellow box ul";
              file-decoration-style = "none";
              file-style = "bold yellow ul";
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
          };
        };

        extraConfig = {
          # core = { autocrlf = false; };
          github.user = cfg.githubUser;
          init.defaultBranch = "main";
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
            branchLogCmd = "git logs --graph";
            paging.pager = "delta --features 'default lazygit'";
            parseEmoji = true;
          };
        };
      };
    };

    home.packages = with pkgs; [
      git-crypt
    ];
  };
}
