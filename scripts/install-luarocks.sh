#!/bin/bash
set -e

# ---------------------------------------------------------------
# Lua
# ---------------------------------------------------------------
lua_version=5.4

rocks='
  argparse
  ftcsv
  luaposix
  lunajson
  minicurses
  redis-lua
  lsqlite3
  lua-zlib
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

# Special patch to fix a bug in redis-lua. It is possible that it
# might be fixed in a future version of the library, but seems
# unlikely. If that happens, this may start failing.
{
  redis_lua="$HOME/.luarocks/share/lua/5.4/redis.lua"

  old='table_insert(parsers, #requests, reply.parser)'
  new='parsers[#requests] = reply.parser or false'

  if grep -Fq "$new" "$redis_lua"; then
    echo "redis-lua already patched."
  elif grep -Fq "$old" "$redis_lua"; then
    sed -i "s|$old|$new|" "$redis_lua"
    echo "Patched redis-lua."
  else
    echo "error: cannot patch $redis_lua" >&2
    exit 1
  fi
}
