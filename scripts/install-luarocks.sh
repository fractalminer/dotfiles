#!/bin/bash
set -e

# ---------------------------------------------------------------
# Lua
# ---------------------------------------------------------------
lua_version=5.4

rocks='
    ftcsv
    luaposix
    lunajson
    redis-lua
'

luarocks config lua_version "$lua_version"

lua_v_cmd="sudo update-alternatives --set lua-interpreter /usr/bin/lua$lua_version"
echo "setting lua version..."
echo "$lua_v_cmd"
$lua_v_cmd

for rock in $rocks; do
    echo "installing luarock: $rock"
    luarocks install "$rock" --local
done

if [[ ! -d ~/.luarocks/lib/luarocks/rocks-$lua_version/lua-cityhash ]]; then
    echo "installing lua-cityhash..."
    pushd /tmp
    rm -rf lua-cityhash
    git clone https://github.com/csfrancis/lua-cityhash.git
    cd lua-cityhash
    luarocks make --local lua-cityhash-1.0-1.rockspec
    popd
else
    echo "lua-cityhash already installed."
fi
