{ ... }:
{
  programs.television = {
    enable = true;
    enableNushellIntegration = true;

    settings = {
      ui.use_nerd_font_icons = true;
    };

    channels = {
      docker-containers = {
        metadata = {
          name = "docker-containers";
          description = "List and manage Docker containers";
          requirements = [ "docker" ];
        };
        source = {
          command = [
            "docker ps --format '{{.Names}}\\t{{.Image}}\\t{{.Status}}'"
            "docker ps -a --format '{{.Names}}\\t{{.Image}}\\t{{.Status}}'"
          ];
          display = "{split:\\t:0} ({split:\\t:2})";
          output = "{split:\\t:0}";
        };
        preview.command = "docker inspect '{split:\\t:0}' | head -n 50";
        keybindings = {
          ctrl-s = "actions:start";
          ctrl-l = "actions:logs";
          ctrl-e = "actions:exec";
        };
        actions = {
          start = {
            description = "Start container";
            command = "docker start '{split:\\t:0}'";
            mode = "fork";
          };
          logs = {
            description = "Follow logs";
            command = "docker logs -f '{split:\\t:0}'";
            mode = "execute";
          };
          exec = {
            description = "Exec shell";
            command = "docker exec -it '{split:\\t:0}' /bin/sh";
            mode = "execute";
          };
        };
      };

      docker-images = {
        metadata = {
          name = "docker-images";
          description = "List Docker images";
          requirements = [ "docker" ];
        };
        source = {
          command = "docker images --format '{{.Repository}}:{{.Tag}}\\t{{.Size}}\\t{{.ID}}'";
          display = "{split:\\t:0} ({split:\\t:1})";
          output = "{split:\\t:0}";
        };
        preview.command = "docker image inspect '{split:\\t:2}' | head -n 50";
      };

      nu-history = {
        metadata = {
          name = "nu-history";
          description = "Select from nushell history";
        };
        source = {
          command = "nu -c 'open $nu.history-path | lines | uniq | reverse | to text'";
          no_sort = true;
          frecency = false;
        };
      };

      nu-commands = {
        metadata = {
          name = "nu-commands";
          description = "Browse nushell built-in commands";
        };
        source = {
          command = "nu -c 'help commands | select name category description | each { |row| $\"($row.name)\\t($row.category)\\t($row.description)\" } | to text'";
          display = "{split:\\t:0} ({split:\\t:1})";
          output = "{split:\\t:0}";
        };
        preview.command = "nu -c 'help {split:\\t:0}'";
      };

      git-log = {
        metadata = {
          name = "git-log";
          description = "Browse git log";
          requirements = [ "git" ];
        };
        source = {
          command = "git log --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always";
          output = "{strip_ansi|split: :1}";
          ansi = true;
          no_sort = true;
          frecency = false;
        };
        preview.command = "git show -p --stat --pretty=fuller --color=always '{strip_ansi|split: :1}' | head -n 1000";
        keybindings = {
          ctrl-y = "actions:cherry-pick";
          ctrl-o = "actions:checkout";
        };
        actions = {
          cherry-pick = {
            description = "Cherry-pick commit";
            command = "git cherry-pick '{strip_ansi|split: :1}'";
            mode = "execute";
          };
          checkout = {
            description = "Checkout commit";
            command = "git checkout '{strip_ansi|split: :1}'";
            mode = "execute";
          };
        };
      };

      git-branch = {
        metadata = {
          name = "git-branch";
          description = "Browse and switch git branches";
          requirements = [ "git" ];
        };
        source = {
          command = "git branch -a --format='%(refname:short)\\t%(committerdate:short)\\t%(subject)'";
          display = "{split:\\t:0} ({split:\\t:1})";
          output = "{split:\\t:0}";
          no_sort = true;
        };
        preview.command = "git log --oneline --graph --color=always '{split:\\t:0}' | head -n 50";
        keybindings.ctrl-o = "actions:checkout";
        actions.checkout = {
          description = "Checkout branch";
          command = "git checkout '{split:\\t:0}'";
          mode = "execute";
        };
      };

      channels = {
        metadata = {
          name = "channels";
          description = "Browse available television channels";
        };
        source = {
          command = "tv list-channels";
          no_sort = true;
        };
      };

      docker-compose = {
        metadata = {
          name = "docker-compose";
          description = "List and manage Docker Compose services";
          requirements = [ "docker" ];
        };
        source = {
          command = [
            "docker compose ps --format '{{.Name}}\\t{{.Service}}\\t{{.Status}}'"
            "docker compose ps -a --format '{{.Name}}\\t{{.Service}}\\t{{.Status}}'"
          ];
          display = "{split:\\t:1} ({split:\\t:2})";
          output = "{split:\\t:1}";
        };
        preview.command = "docker compose logs --tail 50 '{split:\\t:1}'";
        keybindings = {
          ctrl-u = "actions:up";
          ctrl-d = "actions:down";
          ctrl-r = "actions:restart";
          ctrl-l = "actions:logs";
        };
        actions = {
          up = {
            description = "Start service";
            command = "docker compose up -d '{split:\\t:1}'";
            mode = "fork";
          };
          down = {
            description = "Stop service";
            command = "docker compose down '{split:\\t:1}'";
            mode = "fork";
          };
          restart = {
            description = "Restart service";
            command = "docker compose restart '{split:\\t:1}'";
            mode = "fork";
          };
          logs = {
            description = "Follow logs";
            command = "docker compose logs -f '{split:\\t:1}'";
            mode = "execute";
          };
        };
      };

      gh-prs = {
        metadata = {
          name = "gh-prs";
          description = "Browse GitHub pull requests";
          requirements = [ "gh" ];
        };
        source = {
          command = "gh pr list --limit 50 --json number,title,author,state --template '{{range .}}{{.number}}{{\"\\t\"}}{{.title}}{{\"\\t\"}}{{.author.login}}{{\"\\t\"}}{{.state}}{{\"\\n\"}}{{end}}'";
          display = "#{split:\\t:0} {split:\\t:1} ({split:\\t:2})";
          output = "{split:\\t:0}";
          no_sort = true;
          frecency = false;
        };
        preview.command = "gh pr view '{split:\\t:0}'";
        keybindings = {
          ctrl-o = "actions:open";
          ctrl-d = "actions:diff";
          ctrl-k = "actions:checkout";
        };
        actions = {
          open = {
            description = "Open in browser";
            command = "gh pr view --web '{split:\\t:0}'";
            mode = "fork";
          };
          diff = {
            description = "View diff";
            command = "gh pr diff '{split:\\t:0}'";
            mode = "execute";
          };
          checkout = {
            description = "Checkout PR";
            command = "gh pr checkout '{split:\\t:0}'";
            mode = "execute";
          };
        };
      };

      git-reflog = {
        metadata = {
          name = "git-reflog";
          description = "Browse git reflog";
          requirements = [ "git" ];
        };
        source = {
          command = "git reflog --color=always --pretty=format:'%C(yellow)%h%Creset %gd: %gs %Cgreen(%cr)%Creset'";
          output = "{strip_ansi|split: :0}";
          ansi = true;
          no_sort = true;
          frecency = false;
        };
        preview.command = "git show -p --stat --color=always '{strip_ansi|split: :0}'";
        keybindings.ctrl-o = "actions:checkout";
        actions.checkout = {
          description = "Checkout ref";
          command = "git checkout '{strip_ansi|split: :0}'";
          mode = "execute";
        };
      };

      man-pages = {
        metadata = {
          name = "man-pages";
          description = "Browse man pages";
        };
        source = {
          command = "man -k . | sort";
          display = "{split: :0}";
          output = "{split: :0|strip_ansi|split:(:0}";
        };
        preview.command = "man '{split: :0|strip_ansi|split:(:0}' 2>/dev/null | head -n 100";
      };

      npm-scripts = {
        metadata = {
          name = "npm-scripts";
          description = "Browse and run npm scripts from package.json";
          requirements = [ "jq" ];
        };
        source = {
          command = "jq -r '.scripts | to_entries[] | \"\\(.key)\\t\\(.value)\"' package.json 2>/dev/null";
          display = "{split:\\t:0} — {split:\\t:1}";
          output = "{split:\\t:0}";
        };
        preview.command = "echo 'npm run {split:\\t:0}' && echo '' && echo '{split:\\t:1}'";
        keybindings.enter = "actions:run";
        actions.run = {
          description = "Run script";
          command = "npm run '{split:\\t:0}'";
          mode = "execute";
        };
      };

      tmux-sessions = {
        metadata = {
          name = "tmux-sessions";
          description = "Browse and switch tmux sessions";
          requirements = [ "tmux" ];
        };
        source = {
          command = "tmux list-sessions -F '#{session_name}\\t#{session_windows} windows\\t#{session_created_string}'";
          display = "{split:\\t:0} ({split:\\t:1})";
          output = "{split:\\t:0}";
          no_sort = true;
        };
        preview.command = "tmux capture-pane -t '{split:\\t:0}' -p 2>/dev/null || echo 'No preview available'";
        keybindings = {
          enter = "actions:switch";
          ctrl-d = "actions:kill";
        };
        actions = {
          switch = {
            description = "Switch to session";
            command = "tmux switch-client -t '{split:\\t:0}'";
            mode = "execute";
          };
          kill = {
            description = "Kill session";
            command = "tmux kill-session -t '{split:\\t:0}'";
            mode = "fork";
          };
        };
      };

      git-stash = {
        metadata = {
          name = "git-stash";
          description = "Browse git stash entries";
          requirements = [ "git" ];
        };
        source = {
          command = "git stash list --color=always";
          output = "{split:::0}";
          ansi = true;
          no_sort = true;
          frecency = false;
        };
        preview.command = "git stash show -p --color=always '{split:::0}'";
        keybindings = {
          ctrl-a = "actions:apply";
          ctrl-d = "actions:drop";
        };
        actions = {
          apply = {
            description = "Apply stash";
            command = "git stash apply '{split:::0}'";
            mode = "execute";
          };
          drop = {
            description = "Drop stash";
            command = "git stash drop '{split:::0}'";
            mode = "execute";
          };
        };
      };
    };
  };
}
