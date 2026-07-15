#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# --impure lets flake.nix read the username from the environment (SUDO_USER).
exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac --impure
