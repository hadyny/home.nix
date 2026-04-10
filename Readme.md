# Nix Configuration

A flake-based declarative system configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager) for macOS and Linux. Only requires nix to be installed — home-manager is bootstrapped from the flake.

This configuration provides a complete development environment with:
- Cross-platform support (macOS via nix-darwin, any Linux via standalone home-manager)
- Modular structure for shared, darwin-specific, and linux-specific configurations
- Work profile support with separate configurations and certificates
- Custom modules for Git, AWS, Docker, .NET, 1Password integration, and more
- Comprehensive development tools including Neovim (via nix-nvim), Zed, Emacs, and Ghostty terminal

## Repository Structure

```
.
├── flake.nix                 # Main entry point
├── hosts/
│   └── darwin/               # macOS system configuration
│       ├── default.nix       # Base darwin config
│       └── work/             # Work machine overrides
│           ├── certificates.nix # Work certificates
│           └── default.nix   # Work-specific config
├── modules/
│   ├── shared/               # Cross-platform modules
│   │   ├── default.nix       # Shared module entrypoint
│   │   ├── home-manager.nix  # Program configurations
│   │   ├── packages.nix      # System packages
│   │   ├── fonts.nix         # Font packages
│   │   ├── ghostty/          # Terminal configuration
│   │   ├── helix/            # Helix editor configuration
│   │   ├── zed/              # Zed editor configuration
│   │   ├── config/           # Static config files & assets
│   │   │   └── wallpaper/    # Wallpaper images
│   │   ├── services/
│   │   │   └── colima.nix    # Docker virtualisation
│   │   ├── settings/
│   │   │   └── wallpaper.nix # Desktop wallpaper
│   │   ├── secureEnv/
│   │   │   └── onePassword.nix # 1Password integration
│   │   ├── tools/
│   │   │   ├── aws.nix       # AWS CLI & profiles
│   │   │   ├── docker.nix    # Docker utilities
│   │   │   ├── dotnet.nix    # .NET SDK & NuGet
│   │   │   ├── git.nix       # Git configuration
│   │   │   └── koji.nix      # Conventional commit tool
│   │   └── work.nix          # Work-specific settings
│   ├── darwin/               # macOS-specific modules
│   │   ├── apps.nix          # Homebrew packages
│   │   ├── home-manager.nix  # Darwin home-manager config
│   │   ├── packages.nix      # Darwin-specific packages
│   │   ├── dock-apps.nix     # Dock configuration
│   │   ├── plists.nix        # Plist modifications
│   │   ├── raycast.nix       # Raycast launcher
│   │   └── work/             # Work-specific darwin modules
│   │       ├── aws.nix       # Work AWS configuration
│   │       └── default.nix   # Work darwin entrypoint
│   └── linux/                # Linux-specific modules
│       ├── home-manager.nix  # Linux home-manager config
│       └── packages.nix      # Linux-specific packages
└── overlays/
    └── pinned.nix            # Version-pinned packages
```

## Installation

### Prerequisites

1. Install [Nix](https://nixos.org/download.html):
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. (macOS) Install [Homebrew](https://brew.sh/):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Setup

1. Create and clone the configuration:
   ```bash
   sudo mkdir -p /etc/nix-darwin
   sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
   git clone <your-repo> /etc/nix-darwin
   ```

2. Update `flake.nix` with your user details:
   ```nix
   userConfig = {
     name = "your-username";
     fullName = "Your Name";
     email = "your@email.com";
     githubUser = "your-github";

     # Optional: Git workspace-specific settings
     gitWorkspaces = {
       "src/work" = {
         user = {
           email = "work@company.com";
           name = userConfig.fullName;
         };
         core = {
           autocrlf = "input";
         };
       };
     };
   };
   ```

3. Apply the configuration:
   ```bash
   # macOS
   nix run nix-darwin/master#darwin-rebuild -- switch --flake /etc/nix-darwin

   # Linux (any distro — only nix required)
   nix run home-manager/master -- switch --flake /etc/nix-darwin#your-username
   ```

## Updating

```bash
# Update flake inputs
nix flake update

# Rebuild (macOS)
darwin-rebuild switch --flake /etc/nix-darwin

# Rebuild (Linux)
home-manager switch --flake /etc/nix-darwin#your-username
```

## Modules

### Koji (`tools.koji`)

Configures Koji, a conventional commit message tool with emoji support and interactive prompts.

```nix
tools.koji = {
  enable = true;
  emoji = true;                # Prepend commits with emoji
  autocomplete = true;         # Scope autocomplete from history
  breakingChanges = true;      # Prompt for breaking changes
  issues = true;               # Prompt for issue references
  sign = false;                # GPG sign commits

  # Customise commit types
  commitTypes = [
    { name = "feat"; emoji = "✨"; description = "A new feature"; }
    { name = "fix"; emoji = "🐛"; description = "A bug fix"; }
    # ... more types
  ];
};
```

### Git (`tools.git`)

Configures Git with aliases, delta diff viewer, lazygit, and workspace-specific settings.

```nix
tools.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your@email.com";
  githubUser = "username";

  # Per-directory git config overrides
  workspaces = {
    "src/work" = {
      user = {
        email = "work@company.com";
        name = "Your Name";
      };
      core = {
        autocrlf = "input";
      };
    };
  };
};
```

### AWS (`tools.aws`)

Manages AWS CLI profiles with support for SSO sessions, static credentials, and external credential processes.

```nix
tools.aws = {
  enable = true;

  # SSO session with multiple profiles
  sessions = {
    my-sso = {
      sso_startUrl = "https://company.awsapps.com/start";
      sso_region = "ap-southeast-2";
      profiles = {
        dev = {
          sso_account_id = "123456789012";
          sso_role_name = "Developer";
          region = "ap-southeast-2";
        };
        prod = {
          sso_account_id = "210987654321";
          sso_role_name = "ReadOnly";
          region = "ap-southeast-2";
        };
      };
    };
  };

  # Standalone SSO profiles
  ssoProfiles = {
    legacy = {
      sso_start_url = "https://old.awsapps.com/start";
      sso_account_id = "111111111111";
      sso_role_name = "Admin";
      sso_region = "us-east-1";
      region = "us-east-1";
    };
  };

  # External credential process
  externalCredentials = {
    special = "/path/to/credential/file";
  };
};
```

### .NET (`tools.dotnet`)

Installs .NET SDKs (8.0, 9.0, 10.0) and configures private NuGet sources with environment variable support.

```nix
tools.dotnet = {
  enable = true;
  nugetSources = {
    private-feed = {
      url = "https://nuget.pkg.github.com/org/index.json";
      userName = "username";
      password = "%ENV_VAR_WITH_TOKEN%";  # Use with secureEnv
    };
  };
};
```

The module also includes `easydotnet`, a JSON-RPC server for Neovim .NET development.

### 1Password (`secureEnv.onePassword`)

Syncs secrets from 1Password to the system keychain, exposing them as environment variables or SSH keys.

```nix
secureEnv.onePassword = {
  enable = true;
  namespace = "nixConfig";  # Keychain account name

  sessionVariables = {
    API_TOKEN = {
      vault = "Development";
      item = "API Keys";
      field = "token";
    };
  };

  sshKeys = {
    deploy_key = {
      vault = "DevOps";
      item = "Deploy SSH Key";
      field = "private key";
    };
  };
};
```

Secrets are stored in macOS Keychain (or libsecret on Linux) and cached in `~/.zshenv.local` during activation. This allows secrets to be retrieved at shell startup without repeated 1Password authentication prompts or slow keychain lookups.

### Docker (`tools.docker`)

Provides Docker utilities including docker-compose, lazydocker, and dive for image analysis.

```nix
tools.docker = {
  enable = true;
};
```

### Colima (`services.colima`)

Docker virtualisation for macOS using Colima with Apple Virtualisation framework.

```nix
services.colima = {
  enable = true;
  config = {
    cpu = 4;
    memory = 8;
    autoActivate = true;
    forwardAgent = true;
    network = {
      address = true;
      dns = [ "8.8.8.8" ];
      dnsHosts = {
        "local.dev" = "127.0.0.1";
      };
    };
  };
};
```

### Zed (`zed-editor`)

Declarative Zed editor configuration with LSP support, extensions, and theming.

```nix
zed-editor = {
  enable = true;
  extensions = [ "nix" "lua" "csharp" "eslint" "tailwindcss" "rose-pine" ];
  userSettings = {
    theme = {
      mode = "system";
      light = "Rosé Pine Dawn";
      dark = "Rosé Pine";
    };
    # LSP configuration for nil, roslyn, tailwindcss, typescript, eslint
  };
};
```

### Dock (`targets.darwin.dock`)

Declaratively configure macOS Dock applications.

```nix
targets.darwin.dock = {
  apps = [
    "Slack"
    "Firefox"
  ];

  others = [
    {
      path = "/Users/you/Downloads";
      sort = "dateadded";
      view = "grid";
      display = "folder";
    }
  ];
};
```

### Wallpaper (`home.wallpaper`)

Set desktop wallpaper declaratively.

```nix
home.wallpaper.file = ./path/to/wallpaper.jpg;
```

### Plists (`targets.darwin.plists`)

Modify macOS plist files via PlistBuddy.

```nix
targets.darwin.plists = {
  "Library/Preferences/com.example.app.plist" = {
    "Setting:Key" = "value";
  };
};
```

## Homebrew Integration

Homebrew packages are managed via `modules/darwin/apps.nix`:

```nix
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "firefox"
      "postman"
      "slack"
      "rider"
      "datagrip"
      "spotify"
      "emacs-plus-app@master"
      "zed"
    ];
    brews = [ "libvterm" ];
    taps = [ "d12frosted/emacs-plus" ];

  onActivation = {
    cleanup = "zap";      # Remove unlisted packages
    autoUpdate = true;
    upgrade = true;
  };
};
```

## Included Programs

The configuration includes numerous CLI tools and programs:

- **Shells**: zsh (with pure prompt, fzf-tab, syntax highlighting), mcfly history search
- **Editors**: Neovim (nix-nvim), Helix (Rose Pine theme, LSP for Nix/Lua/Markdown/C#/TypeScript/ESLint/Tailwind), Zed (declarative config with LSP & extensions), Emacs (emacs-plus on macOS, emacs-unstable on Linux)
- **Terminals**: Ghostty (Rose Pine theme, Maple Mono NF font), tmux (Rose Pine dark/dawn themes, tmux-which-key, dev session with Claude, Project, Git, Files, Shell windows)
- **Dev Tools**: direnv, devenv, lazygit, lazydocker, gh (GitHub CLI), gh-dash, opencode, claude-code, koji, scooter
- **File Management**: yazi (with git + rich-preview plugins for CSV/MD/JSON/IPYNB), broot, eza, fd, ripgrep, bat (with extras)
- **Languages**: .NET 8/9/10, Bun, fnm (Node version manager), Roslyn LSP
- **LSPs**: typescript-language-server, tailwindcss-language-server, lua-language-server, nil (Nix), roslyn-ls (.NET)
- **Containers**: Docker, docker-compose, dive, Colima
- **Infrastructure**: Terraform, SpiceDB
- **Kafka**: redpanda-client, kafkactl, kcat
- **Utilities**: btop, jq, zoxide, posting (API client), tabiew (CSV viewer), kew (music player), mitmproxy
- **Databases**: DataGrip (via Homebrew), DBeaver
- **Knowledge Management**: Obsidian
- **Browsers**: Firefox, Helium

## Key Bindings

- **Caps Lock** is remapped to **Control** (macOS)
- tmux prefix: `Ctrl+a`
- tmux: `Prefix + D` for dark theme, `Prefix + L` for light (dawn) theme
- tmux: `Prefix + Space` for which-key menu, `Ctrl+Space` for root which-key
- tmux: vim-style pane navigation (`h/j/k/l`), splitting (`|` / `-`)

## Flake Inputs

- **nixpkgs**: NixOS/nixpkgs nixos-unstable
- **nix-darwin**: LnL7/nix-darwin for macOS configuration
- **home-manager**: nix-community/home-manager for user environment
- **emacs-overlay**: nix-community/emacs-overlay for latest Emacs builds
- **nix-nvim**: hadyny/nix-nvim for custom Neovim configuration
- **nur**: nix-community/NUR for additional packages
- **claude-code**: sadjow/claude-code-nix for Claude Code CLI

## Platform-Specific Features

### macOS (Darwin)
- Homebrew integration with automatic cleanup
- Dock configuration
- Raycast launcher setup
- Plist modification support
- Work profile with certificates
- Colima Docker virtualisation

### Linux
- Sway window manager with themed configuration
- Wayland display server
- GTK theming (Rose Pine)
- Emacs daemon service
- Works on any Linux distribution — only requires nix and home-manager
