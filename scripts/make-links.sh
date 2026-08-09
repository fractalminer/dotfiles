#!/bin/bash
# Must be run from dotfiles root folder.
unalias -a

# ╔═════════════════════════════════════════════════════════════╗
# ║                          Utilities                          ║
# ╚═════════════════════════════════════════════════════════════╝
source scripts/utils.sh

# ╔═════════════════════════════════════════════════════════════╗
# ║                       Symlink Creator                       ║
# ╚═════════════════════════════════════════════════════════════╝
safe_link() {
    # src --> target
    local target="$(pwd)/dot/$1"
    local src="$HOME/.$1"
    local dir="$(dirname "$src")"
    if [[ ! -d "$dir" ]]; then
        mkdir -p $dir
    fi
    if [[ ! -e "$src" ]]; then
        # At this point the file does not exist, however we  will
        # run a forced remove on it anyway because it could be  a
        # broken  link  (which  will be reported as a nonexistent
        # file)  which  we want to remove. We need the -f just in
        # case it really doesn't exist  --  in that case it would
        # emit errors to stderr  which  we  don't want. Note that
        # this command should never return  non-zero,  but  we'll
        # check for it anyway.
        rm -f "$src"; check "remove possible link"
    else
        # Source file exists
        [[ ! -L "$src" ]] && {
            # Source file exists and is not a link; let's just
            # rename it.
            mv "$src" "$src.bak"; check "rename $src"
        }
        [[   -L "$src" ]] && {
          # Source file exists and is a link, so remove the link
          # and proceed.
          rm "$src"; check "remove $src"
        }
    fi
    ln -s "$target" "$src"; check "create link $src"
}

# ╔═════════════════════════════════════════════════════════════╗
# ║                           Driver                            ║
# ╚═════════════════════════════════════════════════════════════╝
main() {
    msg "Making symlinks..."

    list='
        alsoftrc
        bashrc
        config/alacritty
        config/bat
        config/compton.conf
        config/fish
        config/htop/htoprc
        config/jesseduffield/lazygit/config.yml
        config/lua
        config/nvim
        config/polybar
        config/redshift.conf
        dwm
        fdignore
        fonts
        ghc
        gitconfig
        gnuplot
        hgrc
        icons
        lua-format
        nr-make-rc.mk
        tmux
        tmux.conf
        vim
    '

    for f in $list; do safe_link $f; done
}

main
