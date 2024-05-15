#!/usr/bin/env bash

{ # Prevent script running if partially downloaded

set -euo pipefail

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

header() {
  printf "${CYAN}%s${NOCOLOR}\n" "$@"
}

info() {
  printf "${GREEN}%s${NOCOLOR}\n" "$@"
}

warn() {
  printf "${ORANGE}%s${NOCOLOR}\n" "$@"
}

error() {
  printf "${RED}%s${NOCOLOR}\n" "$@"
}

# Lifted from https://github.com/kalbasit/shabka/blob/8f6ba74a9670cc3aad384abb53698f9d4cea9233/os-specific/darwin/setup.sh#L22
sudo_prompt() {
  echo
  header "We are going to check if you have 'sudo' permissions."
  echo "Please enter your password for sudo authentication"
  sudo -k
  sudo echo "sudo authenticaion successful!"
  while true ; do sudo -n true ; sleep 60 ; kill -0 "$$" || exit ; done 2>/dev/null &
}

install_nix() {
  echo
  header "Installing Nix"
  command -v nix >/dev/null || {
    warn "'Nix' is not installed. Installing..."
    # printf responses based on:
    #    - Would you like to see a more detailed list of what we will do? n
    #    - Can we use sudo? y
    #    - Ready to continue? y
    printf "n\ny\ny" | sh <(curl -fsSL https://nixos.org/nix/install) --daemon
    # Update local shell
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  }
  info "'Nix' is installed! Here is what we have:"
  nix-shell -p nix-info --run "nix-info -m"
}

install_home_manager() {
  echo
  header "Installing Home Manager"
  if [[ ! $( nix-channel --list | grep home-manager ) ]]; then
    warn "Adding 'home-manager' Nix channel..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
  fi

  command -v home-manager >/dev/null || {
    warn "Installing Home Manager..."
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
    nix-shell '<home-manager>' -A install
  }

  info "Home Manager is installed. Here are available channels:"
  nix-channel --list
}

clone_repository() {
  echo
  local repository="ephadyn/home.nix"
  local clone_target="${HOME}/.nixpkgs"
  header "Setting up the configuration from github.com:${repository}..."

  if [[ ! $( cat "${clone_target}/.git/config" | grep "github.com" | grep "${repository}" ) ]]; then
    if [ -d "${clone_target}" ]; then
      warn "Looks like '${clone_target}' exists and it is not what we want. Backing up as '${clone_target}.backup-before-clone'..."
      mv "${clone_target}" "${clone_target}.backup-before-clone"
    fi
    warn "Cloning 'github.com:${repository}' into '${clone_target}'..."
    git clone "https://github.com/${repository}.git" "${clone_target}"
  fi

  info "'${clone_target}' is sourced from github.com:'${repository}'."
  cd "${clone_target}"
  git remote -v
  cd - >/dev/null
}

install_nvim_config() {
  echo
  local repository="ephadyn/neovim-config"
  local clone_target="${HOME}/.config/nvim"
  header "Setting up the configuration from github.com:${repository}..."

  if [[ ! $( cat "${clone_target}/.git/config" | grep "github.com" | grep "${repository}" ) ]]; then
    if [ -d "${clone_target}" ]; then
      warn "Looks like '${clone_target}' exists and it is not what we want. Backing up as '${clone_target}.backup-before-clone'..."
      mv "${clone_target}" "${clone_target}.backup-before-clone"
    fi
    warn "Cloning 'github.com:${repository}' into '${clone_target}'..."
    git clone "https://github.com/${repository}.git" "${clone_target}"
  fi

  info "'${clone_target}' is sourced from github.com:'${repository}'."
  cd "${clone_target}"
  git remote -v
  cd - >/dev/null
}

set_up_secrets() {
  echo
  header "Setting up secrets"
  local full_name=$(id -F)
  local user_name=$(id -F | cut -f1 -d" ")
  local email_name=$(id -F | tr -s ' ' | tr "[:upper:]" "[:lower:]" | tr ' ' '.')
  un_template() {
    local src="$1"
    local dst="${1%.*}"

    if [ ! -f "$dst" ]; then
      warn "Creating '${dst}'..."
      sed -e "s/{full-name}/${full_name}/g" \
          -e "s/{user-name}/${user_name}/g" \
          -e "s/{email-name}/${email_name}/g" \
          "${src}" > "${dst}"
      warn "Auto-created '${dst}'. Don't forget to check it out as some default values may need to be changed."
    else
      info "Skipping '${dst}' since it already exists."
    fi
  }

  build() {
  echo
  header "Setting up configuration..."
  for filename in shells bashrc zshrc; do
    filepath="/etc/${filename}"
    if [ -f "${filepath}" ] && [ ! -L "${filepath}" ]; then
      warn "Backing up '${filepath}' as '${filepath}.backup-before-nix'..."
      sudo mv "${filepath}" "${filepath}.backup-before-nix"
    fi
  done

  echo
  info "==========================================================="
  info "All done and ready"
  echo
  echo "Now you can edit the configuration in '$HOME/.nixpkgs'".
  echo
  echo "You may want to fill in the secrets that are required for this configuration:"
  echo
  warn "  ~/.nixpkgs/home/secrets/default.nix"
  warn "  ~/.nixpkgs/home/work/secrets/default.nix"
  echo
  echo "Review and edit both secrets files."
  echo
  echo "When you finish tuning the configuration, please **RE-ENTER YOUR SHELL** and call:"
  echo
  echo "> nixos-rebuild switch"
  echo
}

# Run the installation workflow
sudo_prompt
install_nix
install_home_manager
clone_repository
install_nvim_config
set_up_secrets
build

} # Prevent script running if partially downloaded