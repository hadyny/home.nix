#!/usr/bin/env bash

{ # Prevent script running if partially downloaded

set -euo pipefail

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

header() {
  printf '%b%s%b\n' "$CYAN" "$*" "$NOCOLOR"
}

info() {
  printf '%b%s%b\n' "$GREEN" "$*" "$NOCOLOR"
}

warn() {
  printf '%b%s%b\n' "$ORANGE" "$*" "$NOCOLOR"
}

error() {
  printf '%b%s%b\n' "$RED" "$*" "$NOCOLOR"
}

sudo_prompt() {
  echo
  header "We are going to check if you have 'sudo' permissions."
  echo "Please enter your password for sudo authentication"
  sudo -k
  sudo echo "sudo authentication successful!"
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
    printf "n\ny\ny" | bash -i <(curl -fsSL https://nixos.org/nix/install) --daemon
    # shellcheck source=/dev/null
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

    # nix-darwin controls nix.conf; move the stock one aside first so the
    # initial switch can take it over (it refuses to clobber an existing file).
    if [ -f /etc/nix/nix.conf ] && [ ! -L /etc/nix/nix.conf ]; then
      sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.backup-before-nix-darwin
    fi

    # Flakes are not enabled by default on a stock nixos.org install, so enable
    # them for this bootstrap invocation and point at this flake + host.
    sudo nix --extra-experimental-features 'nix-command flakes' \
      run nix-darwin/master#darwin-rebuild -- \
      switch --flake /etc/nix-darwin#Hadyns-MacBook-Pro
  }
  info "'nix-darwin' is installed!"
}

install_homebrew() {
  echo
  header "Installing Homebrew"
  command -v brew >/dev/null || {
    warn "'Homebrew' is not installed. Installing..."
    printf "\n" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # shellcheck disable=SC2016  # the single-quoted eval line is written verbatim to .zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
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
  local repository="ephadyn/home.nix"
  local clone_target="/etc/nix-darwin"
  header "Setting up the configuration from github.com:${repository}..."

  sudo mkdir -p "${clone_target}"
  sudo chown "$(id -nu):$(id -ng)" "${clone_target}"

  if [ ! -d "${clone_target}/.git" ]; then
    warn "Cloning 'github.com:${repository}' into '${clone_target}'..."
    # git refuses to clone into a non-empty directory; the mkdir above only
    # creates an empty one, so this is safe on a fresh machine.
    git clone "https://github.com/${repository}.git" "${clone_target}"
  else
    info "'${clone_target}' already contains a git checkout, skipping clone."
  fi

  info "'${clone_target}' is sourced from github.com:'${repository}'."
  git -C "${clone_target}" remote -v
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
