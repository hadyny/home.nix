/* Main user-level configuration */
{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets;
  modules = import ../lib/modules.nix {inherit lib;};
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    # sometimes it is useful to pin a version of some tool or program.
    # this can be done in "overlays/pinned.nix"
    (import ../overlays/pinned.nix)
  ];

  # Flakes are not standard yet, but widely used, enable them.
  xdg.configFile."nix/nix.conf".text = ''
      experimental-features = nix-command flakes
  '';

  imports = [
    # Programs to install
    ./packages.nix

    # everything for work
    ./work
  ] ++ (modules.importAllModules ./modules);
 
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = config.user.name;
    homeDirectory = config.user.home;
    wallpaper.file = ./config/wallpaper/wallpaper.jpg;

    sessionVariables = {
      EDITOR = "nvim";
      GH_PAGER = "delta";
    };

    sessionPath = [
    ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    _1password

    # fonts
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
  ];

  programs = {
    bat = {
      enable = true;
      config = { theme = "Nord"; };
    };
    jq.enable = true;
    htop.enable = true;
    bottom.enable = true;
    ssh.enable = true;

    eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--long"
      ];
    };

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    nnn.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      colors = {
        "bg+" = "#313244"; 
        "bg" = "#1e1e2e";
        "spinner" = "#f5e0dc";
        "hl" = "#f38ba8";
        "fg" = "#cdd6f4";
        "header" = "#f38ba8";
        "info" = "#cba6f7";
        "pointer" = "#f5e0dc";
        "marker" = "#f5e0dc";
        "fg+" = "#cdd6f4";
        "prompt" = "#cba6f7";
        "hl+" = "#f38ba8";
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  services.colima = {
    enable = true;

    config = {
      cpu = 4;
      memory = 8;
    };
  };

  tools = {
    aws.enable = true;
    dotnet.enable = true;
    git = {
      enable = true;
      userName = secrets.github.fullName;
      userEmail = secrets.github.userEmail;
      githubUser = secrets.github.userName;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    # history.extended = true;

    # this is to workaround zsh syntax highlighting slowness on copy/paste
    # https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
    initExtra = ''
      zstyle ':bracketed-paste-magic' active-widgets '.self-*'

      autoload -U add-zsh-hook
      load-nvmrc() {
        local nvmrc_path
        nvmrc_path="$(nvm_find_nvmrc)"

        if [ -n "$nvmrc_path" ]; then
          local nvmrc_node_version
          nvmrc_node_version=$(nvm version "$(cat "''${nvmrc_path}")")

          if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
          elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
            nvm use
          fi
        elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
          echo "Reverting to nvm default version"
          nvm use default
        fi
      }

      add-zsh-hook chpwd load-nvmrc
      load-nvmrc

      #compdef gh

      # zsh completion for gh

      __gh_debug()
      {
          local file="$BASH_COMP_DEBUG_FILE"
          if [[ -n ''${file} ]]; then
              echo "$*" >> "''${file}"
          fi
      }

      _gh()
      {
          local shellCompDirectiveError=1
          local shellCompDirectiveNoSpace=2
          local shellCompDirectiveNoFileComp=4
          local shellCompDirectiveFilterFileExt=8
          local shellCompDirectiveFilterDirs=16

          local lastParam lastChar flagPrefix requestComp out directive comp lastComp noSpace
          local -a completions

          __gh_debug "\n========= starting completion logic =========="
          __gh_debug "CURRENT: ''${CURRENT}, words[*]: ''${words[*]}"

          # The user could have moved the cursor backwards on the command-line.
          # We need to trigger completion from the $CURRENT location, so we need
          # to truncate the command-line ($words) up to the $CURRENT location.
          # (We cannot use $CURSOR as its value does not work when a command is an alias.)
          words=("''${=words[1,CURRENT]}")
          __gh_debug "Truncated words[*]: ''${words[*]},"

          lastParam=''${words[-1]}
          lastChar=''${lastParam[-1]}
          __gh_debug "lastParam: ''${lastParam}, lastChar: ''${lastChar}"

          # For zsh, when completing a flag with an = (e.g., gh -n=<TAB>)
          # completions must be prefixed with the flag
          setopt local_options BASH_REMATCH
          if [[ "''${lastParam}" =~ '-.*=' ]]; then
              # We are dealing with a flag with an =
              flagPrefix="-P ''${BASH_REMATCH}"
          fi

          # Prepare the command to obtain completions
          requestComp="''${words[1]} __complete ''${words[2,-1]}"
          if [ "''${lastChar}" = "" ]; then
              # If the last parameter is complete (there is a space following it)
              # We add an extra empty parameter so we can indicate this to the go completion code.
              __gh_debug "Adding extra empty parameter"
              requestComp="''${requestComp} \"\""
          fi

          __gh_debug "About to call: eval ''${requestComp}"

          # Use eval to handle any environment variables and such
          out=$(eval ''${requestComp} 2>/dev/null)
          __gh_debug "completion output: ''${out}"

          # Extract the directive integer following a : from the last line
          local lastLine
          while IFS='\n' read -r line; do
              lastLine=''${line}
          done < <(printf "%s\n" "''${out[@]}")
          __gh_debug "last line: ''${lastLine}"

          if [ "''${lastLine[1]}" = : ]; then
              directive=''${lastLine[2,-1]}
              # Remove the directive including the : and the newline
              local suffix
              (( suffix=''${#lastLine}+2))
              out=''${out[1,-''$suffix]}
          else
              # There is no directive specified.  Leave $out as is.
              __gh_debug "No directive found.  Setting do default"
              directive=0
          fi

          __gh_debug "directive: ''${directive}"
          __gh_debug "completions: ''${out}"
          __gh_debug "flagPrefix: ''${flagPrefix}"

          if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
              __gh_debug "Completion received error. Ignoring completions."
              return
          fi

          local activeHelpMarker="_activeHelp_ "
          local endIndex=''${#activeHelpMarker}
          local startIndex=''$((''${#activeHelpMarker}+1))
          local hasActiveHelp=0
          while IFS='\n' read -r comp; do
              # Check if this is an activeHelp statement (i.e., prefixed with $activeHelpMarker)
              if [ "''${comp[1,''$endIndex]}" = "$activeHelpMarker" ];then
                  __gh_debug "ActiveHelp found: $comp"
                  comp="''${comp[''$startIndex,-1]}"
                  if [ -n "$comp" ]; then
                      compadd -x "''${comp}"
                      __gh_debug "ActiveHelp will need delimiter"
                      hasActiveHelp=1
                  fi

                  continue
              fi

              if [ -n "''$comp" ]; then
                  # If requested, completions are returned with a description.
                  # The description is preceded by a TAB character.
                  # For zsh's _describe, we need to use a : instead of a TAB.
                  # We first need to escape any : as part of the completion itself.
                  comp=''${comp//:/\\:}

                  local tab="$(printf '\t')"
                  comp=''${comp//''$tab/:}

                  __gh_debug "Adding completion: ''${comp}"
                  completions+=''${comp}
                  lastComp=$comp
              fi
          done < <(printf "%s\n" "''${out[@]}")

          # Add a delimiter after the activeHelp statements, but only if:
          # - there are completions following the activeHelp statements, or
          # - file completion will be performed (so there will be choices after the activeHelp)
          if [ $hasActiveHelp -eq 1 ]; then
              if [ ''${#completions} -ne 0 ] || [ ''$((directive & shellCompDirectiveNoFileComp)) -eq 0 ]; then
                  __gh_debug "Adding activeHelp delimiter"
                  compadd -x "--"
                  hasActiveHelp=0
              fi
          fi

          if [ ''$((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
              __gh_debug "Activating nospace."
              noSpace="-S '''"
          fi

          if [ ''$((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
              # File extension filtering
              local filteringCmd
              filteringCmd='_files'
              for filter in ''${completions[@]}; do
                  if [ ''${filter[1]} != '*' ]; then
                      # zsh requires a glob pattern to do file filtering
                      filter="\*.''$filter"
                  fi
                  filteringCmd+=" -g ''$filter"
              done
              filteringCmd+=" ''${flagPrefix}"

              __gh_debug "File filtering command: $filteringCmd"
              _arguments '*:filename:'"''$filteringCmd"
          elif [ ''$((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
              # File completion for directories only
              local subdir
              subdir="''${completions[1]}"
              if [ -n "''$subdir" ]; then
                  __gh_debug "Listing directories in ''$subdir"
                  pushd "''${subdir}" >/dev/null 2>&1
              else
                  __gh_debug "Listing directories in ."
              fi

              local result
              _arguments '*:dirname:_files -/'" ''${flagPrefix}"
              result=''$?
              if [ -n "''$subdir" ]; then
                  popd >/dev/null 2>&1
              fi
              return ''$result
          else
              __gh_debug "Calling _describe"
              if eval _describe "completions" completions ''$flagPrefix ''$noSpace; then
                  __gh_debug "_describe found some completions"

                  # Return the success of having called _describe
                  return 0
              else
                  __gh_debug "_describe did not find completions."
                  __gh_debug "Checking if we should do file completion."
                  if [ ''$((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
                      __gh_debug "deactivating file completion"

                      # We must return an error code here to let zsh know that there were no
                      # completions found by _describe; this is what will trigger other
                      # matching algorithms to attempt to find completions.
                      # For example zsh can match letters in the middle of words.
                      return 1
                  else
                      # Perform file completion
                      __gh_debug "Activating file completion"

                      # We must return the result of this command, so it must be the
                      # last command, or else we must store its result to return it.
                      _arguments '*:filename:_files'" ''${flagPrefix}"
                  fi
              fi
          fi
      }

      # don't run the completion function when being source-ed or eval-ed
      if [ "''$funcstack[1]" = "_gh" ]; then
          _gh
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "aws"
        "dirhistory"
        "git-extras"
        "git"
        "gitfast"
        "github"
        "nvm"
      ];
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
