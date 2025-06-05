#!/usr/bin/env bash

{ # Prevent script running if partially downloaded

set -eo pipefail

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
    printf "n\ny\ny" | bash -i <(curl -kL https://nixos.org/nix/install) --daemon
    source /etc/bashrc
  }
  info "'Nix' is installed! Here is what we have:"
  nix-shell -p nix-info --run "nix-info -m"
}

install_nix_darwin() {
  echo
  header "Installing Nix on macOS..."
  command -v darwin-rebuild >/dev/null || {
    warn "'nix-darwin' is not installed. Installing..."
    sudo nix run nix-darwin/master#darwin-rebuild -- switch
 
    # nix-darwin controls nix.conf
    sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.backup-before-nix-darwin
  }
  info "'nix-darwin' is installed!"
}

install_homebrew() {
  echo
  header "Installing Homebrew"
  command -v brew >/dev/null || {
    warn "'Homebrew' is not installed. Installing..."
    printf "\n" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  }
  
  info "'Homebrew' is installed! Here is what we have:"
  brew --version
}

install_rosetta() {
  header "Setting up Rosetta"

  if arch -x86_64 /usr/bin/true 2> /dev/null; then
    info "Rosetta is already installed, skipping"
  else
    warn "Rosetta is not installed, installing now"
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi
}

clone_repository() {
  echo
  sudo mkdir -p /etc/nix-darwin
  sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
  local repository="hadyny/home.nix"
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

darwin_build() {
  echo
  header "Setting up 'darwin' configuration..."
  for filename in shells bashrc zshrc; do
    filepath="/etc/${filename}"
    if [ -f "${filepath}" ] && [ ! -L "${filepath}" ]; then
      warn "Backing up '${filepath}' as '${filepath}.backup-before-nix-darwin'..."
      sudo mv "${filepath}" "${filepath}.backup-before-nix-darwin"
    fi
  done

  echo
  info "==========================================================="
  info "All done and ready"
  echo
  echo "Now you can edit the configuration in '/etc/nix-darwin'".
  echo
  echo
}

sudo_prompt
install_homebrew
install_nix
clone_repository
install_nix_darwin
install_rosetta
darwin_build

} # Prevent script running if partially downloaded
