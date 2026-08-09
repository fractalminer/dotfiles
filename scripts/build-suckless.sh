#!/bin/bash
set -e
set -o pipefail

cd ~/dev
[[ ! -d suckless ]] && git clone ssh://git@github.com/fractalminer/suckless

cd ~/dev/suckless
make

./dwm/install.sh