# Main user-level configuration
{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets;
  modules = import ../lib/modules.nix { inherit lib; };
in {
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
    # Development packages
    ./development.nix

    # everything for work
    ./work
  ] ++ (modules.importAllModules ./modules);

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = config.user.name;
    homeDirectory = config.user.home;
    wallpaper.file = ./config/wallpaper/wallpaper.jpg;

    sessionVariables = { EDITOR = "nvim"; };

    sessionPath = [ "/opt/homebrew/bin" ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    _1password-cli

    # fonts
    nerd-fonts.geist-mono
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  programs = {
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
    };

    bat = { enable = true; };

    btop = {
      enable = true;
      settings = { theme_background = false; };
    };

    jq.enable = true;
    htop.enable = true;
    ssh.enable = true;

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [ "--group-directories-first" "--header" "--long" ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    kitty = {
      enable = true;
      themeFile = "rose-pine-moon";
      extraConfig = builtins.readFile ./config/kitty/kitty.conf;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraLuaConfig = builtins.readFile ./config/neovim/init.lua;
      extraPackages = with pkgs; [
        lua-language-server
        stylua

        nixfmt-classic
        nil

        roslyn-ls
        netcoredbg
        csharpier

        typescript-language-server
        tailwindcss-language-server
        rustywind
        graphql-language-service-cli
        vscode-langservers-extracted

      ];
      plugins = with pkgs.vimPlugins; [
        mini-basics
        mini-bufremove
        mini-extra
        mini-icons
        rose-pine
        lualine-nvim
        nvim-highlight-colors
        blink-cmp
        colorful-menu-nvim
        friendly-snippets
        which-key-nvim
        nvim-treesitter.withAllGrammars
        gitsigns-nvim
        nvim-lspconfig
        none-ls-nvim
        snacks-nvim
        typescript-tools-nvim
        tsc-nvim
        actions-preview-nvim
        neotest-vitest
        neotest-dotnet
        obsidian-nvim
        roslyn-nvim
        nvim-dap
        overseer-nvim
        tailwind-tools-nvim
        yazi-nvim
        tiny-inline-diagnostic-nvim
        CopilotChat-nvim
      ];
    };

    tmux = {
      enable = true;
      tmuxinator.enable = true;
      keyMode = "vi";
      focusEvents = true;
      baseIndex = 1;
      mouse = true;
      plugins = with pkgs.tmuxPlugins; [
        better-mouse-mode
        rose-pine
        tmux-which-key
      ];
    };

    yazi.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autocd = true;
      autosuggestion.enable = true;
      dirHashes = {
        dl = "$HOME/Downloads";
        src = "$HOME/src";
        ep = "$HOME/src/ep";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "1password"
          "aws"
          "docker"
          "docker-compose"
          "dotnet"
          "git"
          "iterm2"
          "nvm"
        ];
      };
      shellAliases = {
        nu = "nvm use";
        dcu = "docker compose up";
        dcd = "docker compose down";
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" ];
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = { scan_timeout = 100; };
    };
  };

  services = {
    colima = {
      enable = true;

      config = {
        cpu = 4;
        memory = 8;
      };
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
