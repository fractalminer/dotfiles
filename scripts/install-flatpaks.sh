#!/bin/bash
set -e

# ---------------------------------------------------------------
# Flatpacks.
# ---------------------------------------------------------------
paks='
  com.redis.RedisInsight
'

flatpak install -y flathub com.redis.RedisInsight
