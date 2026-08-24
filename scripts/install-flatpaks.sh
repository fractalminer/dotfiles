#!/bin/bash
set -e

# ---------------------------------------------------------------
# Flatpacks.
# ---------------------------------------------------------------
paks='
  com.redis.RedisInsight
'

flatpak install flathub com.redis.RedisInsight
