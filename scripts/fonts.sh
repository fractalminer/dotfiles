#!/bin/bash
set -eo pipefail
set -x
# Install fonts in user's home folder and update font cache.
#
# It is assumed that this script will be run with CWD one level
# above the folder containing this script.

source scripts/utils.sh

# NOTE: this one is deprecated, we're now using the NERD version
# below since it has a lot of extra icons.
if [[ ! -e ~/.local/share/fonts/"Literation Mono Powerline.ttf" ]]; then
  msg "Powerline fonts not installed... installing"

  cd /tmp
  rm -rf fonts

  git clone https://github.com/powerline/fonts
  cd fonts

  # This should update the font cache, which should then also pick
  # up the fonts in the ~/.fonts folder that will now exist after
  # the symlinks are set up into the .dotfiles folder.
  ./install.sh

  # Reset the font cache do this:
  fc-cache -fv; check "update font cache"
fi

# ---------------------------------------------------------------
# Install Nerd Font.
# ---------------------------------------------------------------
if [[ ! -e ~/.local/share/fonts/LiterationMono ]]; then
  msg "NERD Liberation Mono fonts not installed... installing"

  cd /tmp
  rm -f LiberationMono.tar.xz

  wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/LiberationMono.tar.xz"

  mkdir -p ~/.local/share/fonts/LiterationMono
  tar xf LiberationMono.tar.xz -C ~/.local/share/fonts/LiterationMono

  # Reset the font cache do this:
  fc-cache -fv; check "update font cache"
fi
