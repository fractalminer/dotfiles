#!/bin/bash
# ╔═════════════════════════════════════════════════════════════╗
# ║                    Dotfiles Setup Script                    ║
# ╚═════════════════════════════════════════════════════════════╝
source scripts/utils.sh
msg 'Setting up environment...'

mkdir -p ~/bin
mkdir -p ~/.local/bin

# Run setup scripts
bash scripts/make-links.sh; check 'make symlinks'

msg 'Sourcing new .bashrc...'
# Now  that  we  probably  have a new bashrc file let's source it
# since we will need some of the settings in there for subsequent
# commands.
source ~/.bashrc; check 'source new .bashrc'

bash scripts/rebuild.sh "$@"; check 'rebuild and/or update components'

# Set terminal colors (probably assumes GNOME terminal).
[[ $(uname) == Linux ]] &&
 { bash term-colors/set-gnome-terminal-colors.sh; check 'set terminal colors'; }

# Exit with success
true
