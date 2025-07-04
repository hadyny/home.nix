# Home Manager Nix configuration

It uses [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager) to set up and manage the user's home environment.

## Installation

### Automated installation

Currently MacOS-specific

```bash
$ bash -i <(curl -fsSL https://raw.githubusercontent.com/ephadyn/home.nix/main/install.sh)
$ darwin-rebuild switch
```

### Manual installation

0. Install [Nix](https://nixos.org/download.html)
   ```bash
    $ sh <(curl -L https://nixos.org/nix/install) --daemon
   ```
1. Clone this repository as your local `/etc/nix-darwin` after creating the folder with correct permissions </br>
  ```bash
  $ sudo mkdir -p /etc/nix-darwin
  $ sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
  ```
2. Install [nix-darwin](https://github.com/LnL7/nix-darwin)
   ```bash
    $ sudo nix run nix-darwin/master#darwin-rebuild -- switch
   ```

3. (Optionaly, MacOS only) Install [Homebrew](https://brew.sh/)
   ```bash
   $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

4. Switch the profile:
   ```bash
    $ sudo darwin-rebuild switch
   ```

## Updating the configuration

Make changes to the configuration files and run `sudo darwin-rebuild switch` to update the configuration.

## Updating packages

 ```bash
    $ sudo nix flake update
    $ sudo darwin-rebuild switch
   ```


## Note on integration with Homebrew

If `Homebrew` is installed, this configuration will manage `Homebrew` packages via [modules/darwin/apps.nix](./modules/darwin/apps.nix) file.
Use [modules/darwin/apps.nix](./modules/darwin/apps.nix) to specify which packages should be installed via `brew` and Nix will handle the rest.


## Modules overview

A short overview of modules and what they can download

### Git

`git.nix` module installs and enables `Git and creates a global configuration (username/email/github user name).

It also allows configuring "workspaces": folders that should have their own alterations of git configuration.
For example, email addresses that are used for git commits can be different for private and work-related projects.

Example:

```nix
  tools.git = {
    enable = true;
    userName = "Donald Duck";
    userEmail = "donald.duck@gmail.com";
    githubUser = secrets.github.userName;

    workspaces = {
      "src/work" = {
        user = { email = "donald.duck@bigbank.com"; };
        core = { autocrlf = true; };
      };
      "src/charity" {
        user = { email = "donald.duck@charity-works.net"; };
      };
    };
  };
```

### SecureEnv

`SecureEnv` allows to store secrets securely populating them from password managers (currently only `1Password`) with an ability to export
these secrets as environment variables and ssh keys in ssh-agent.

The reason for not exporting them from password managers directly is that they only keeps a session open for a short period of time,
which means that users will be asked to re-authenticate often.

Instead, secrets are copied to `Keychain` (on MacOS) or `Keyring` (on Linux) and then used to source env variables.
This way secrets are never stored on disk unencrypted but can still be made conveniently available to the user as environment variables.

Example:

```nix
  secureEnv.onePassword = {
    enable = true;
    sessionVariables = {
      # This env variable will be set up for user's session
      GITHUB_TOKEN = {
        vault = "Private";
        item = "Github";
        field = "token";
      };
    };
    sshKeys = {
      # These keys will be set up for SSH
      staging_pem = {
        vault = "Dev - Shared DevOps";
        item = "staging-ssh-key";
        field = "notes";
      };
      test_pem = {
        vault = "Dev - Shared DevOps";
        item = "test-ssh-key";
        field = "notes";
      };
    };
  };

```

**NOTE**: `Secret Store` module will _not_ remove any passwords from `Keychain`/`Keyring`. It will only сopy passwords and update existing ones.

### .NET

`dotnet.nix` module makes .NET SDK available for the machine. It

It also allows configuring extra Nuget sources, which is useful in setups with private nuget repositories.

Example:

```nix
  tools.dotnet = {
    enable = true;
    nugetSources = {
      bigBankGithub = {
        url = "https://nuget.pkg.github.com/BigBank/index.json";
        userName = secrets.github.userName;
        password = secrets.github.token;
      };
    };
  };
```

### AWS

AWS can be configured via `tools.aws` module.

AWS can have statically defined profiles, and SAML profiles (using Google as ID Provider) such as:

```nix
  tools.aws = {
    enable = true;

    profiles = {
      default = {
        accessKeyId = "AKIAIOSFODNN7EXAMPLE";
        secretAccessKey = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";
      };
    };

    ssoProfiles = {
      test = {
        sso_start_url = "https://my-company.awsapps.com/start";
        sso_account_id = "123456789012";
        sso_role_name = "admin";
        sso_region = "ap-southeast-2";
        region = "ap-southeast-2";
      };

      prod = {
        sso_start_url = "https://my-company.awsapps.com/start";
        sso_account_id = "210987654321";
        sso_role_name = "admin";
        sso_region = "ap-southeast-2";
        region = "ap-southeast-2";
      };
    };
  };
```

When `ssoProfiles` are defined, an AWS SDK `aws sso login --profile <name>` command can be used to log in to AWS.
