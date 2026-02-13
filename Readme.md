# Nix Darwin Configuration

A declarative system configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager) for macOS, with NixOS support.

## Repository Structure

```
.
├── flake.nix                 # Main entry point
├── hosts/
│   ├── darwin/               # macOS system configuration
│   │   ├── default.nix       # Base darwin config
│   │   └── work/             # Work machine overrides
│   └── nixos/                # NixOS system configuration
├── modules/
│   ├── shared/               # Cross-platform modules
│   │   ├── home-manager.nix  # Program configurations
│   │   ├── packages.nix      # System packages
│   │   ├── fonts.nix         # Font packages
│   │   ├── neovim/           # Neovim IDE setup (nixCats)
│   │   ├── ghostty/          # Terminal configuration
│   │   ├── services/
│   │   │   └── colima.nix    # Docker virtualization
│   │   ├── settings/
│   │   │   └── wallpaper.nix # Desktop wallpaper
│   │   ├── secureEnv/
│   │   │   └── onePassword.nix # 1Password integration
│   │   └── tools/
│   │       ├── aws.nix       # AWS CLI & profiles
│   │       ├── docker.nix    # Docker utilities
│   │       ├── dotnet.nix    # .NET SDK & NuGet
│   │       └── git.nix       # Git configuration
│   ├── darwin/               # macOS-specific modules
│   │   ├── apps.nix          # Homebrew packages
│   │   ├── dock-apps.nix     # Dock configuration
│   │   ├── plists.nix        # Plist modifications
│   │   └── raycast.nix       # Raycast launcher
│   └── nixos/                # NixOS-specific modules
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
     home = "/Users/your-username";
     githubUser = "your-github";
   };
   ```

3. Apply the configuration:
   ```bash
   # macOS
   nix run nix-darwin/master#darwin-rebuild -- switch --flake /etc/nix-darwin

   # NixOS
   sudo nixos-rebuild switch --flake /etc/nix-darwin
   ```

## Updating

```bash
# Update flake inputs
nix flake update

# Rebuild
darwin-rebuild switch --flake /etc/nix-darwin
```

## Modules

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
      user.email = "work@company.com";
      core.autocrlf = "input";
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

Installs .NET SDKs (8.0, 9.0, 10.0) and configures private NuGet sources.

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

Secrets are stored in macOS Keychain (or libsecret on Linux) and retrieved at shell startup, avoiding repeated 1Password authentication prompts.

### Colima (`services.colima`)

Docker virtualization for macOS using Colima with Apple Virtualization framework.

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

### Dock (`targets.darwin.dock`)

Declaratively configure macOS Dock applications.

```nix
targets.darwin.dock = {
  apps = [
    "Slack"
    "Firefox"
    "Obsidian"
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
    "slack"
    "visual-studio-code"
  ];
  brews = [ ];
  taps = [ ];

  onActivation = {
    cleanup = "zap";      # Remove unlisted packages
    autoUpdate = true;
    upgrade = true;
  };
};
```

## Included Programs

The configuration includes numerous CLI tools and programs:

- **Shells**: zsh with oh-my-zsh, starship prompt, fzf-tab
- **Editors**: Neovim (nixCats), Zed, Emacs
- **Terminals**: Ghostty, WezTerm
- **Dev Tools**: direnv, devenv, lazygit, lazydocker
- **File Management**: yazi, eza, fd, ripgrep, bat
- **Multiplexers**: zellij with custom layouts
- **Utilities**: btop, jq, mcfly, zoxide, yt-dlp

## Key Bindings

- **Caps Lock** is remapped to **Control**
- Zellij: `Ctrl+e` for session mode (instead of `Ctrl+o`)
