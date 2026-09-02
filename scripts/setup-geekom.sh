#!/usr/bin/env bash
set -euo pipefail
set -x
# ----------------------------------------------------------------------
# GEEKOM A7 Max -- Pop!_OS build-worker setup.
#
# Assumes:
#   * Pop!_OS 22.04 is already installed.
#   * BIOS Power Mode has manually been set to Performance.
#   * BIOS Wake-on-LAN has manually been enabled.
#   * The machine is connected by Ethernet.
#
# Deliberately NOT done here:
#   * Install TLP. Pop!_OS uses system76-power.
#   * Install redis-server. Workers only need Redis client tools.
#   * Change swappiness/zram. Pop!_OS defaults work well.
#   * Tune CPU clocks/C-states/SMT.
#   * Install r8125-dkms. The Jammy package does not build against
#     the current Pop!_OS 7.1 kernel.
# ----------------------------------------------------------------------

echo '=== Installing worker utilities ==='

sudo apt install -y \
  ethtool \
  redis-tools


echo '=== Removing TLP if present ==='

# TLP is unnecessary here and can conflict conceptually with the
# System76 power-management stack.
if dpkg-query -W -f='${Status}' tlp 2>/dev/null \
     | grep -q 'install ok installed'; then
  sudo apt purge -y tlp tlp-rdw
fi


echo '=== Configuring System76 Performance mode ==='

# system76-power does not appear to persist the Performance profile
# across boots on Pop!_OS 22.04, so enforce it with a system service.

sudo tee /etc/systemd/system/system76-performance.service >/dev/null <<'EOF'
[Unit]
Description=Set System76 power profile to performance
After=com.system76.PowerDaemon.service
Requires=com.system76.PowerDaemon.service

[Service]
Type=oneshot
ExecStart=/usr/bin/system76-power profile performance
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable system76-performance.service
sudo systemctl restart system76-performance.service


echo '=== Configuring remote power control ==='

# Allow the build-farm user to power off or reboot the worker remotely
# without granting unrestricted passwordless sudo.
sudo tee /etc/sudoers.d/power-control >/dev/null <<EOF
$USER ALL=(root) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot
EOF

sudo chmod 0440 /etc/sudoers.d/power-control

# Fail the setup immediately if we somehow generated invalid sudoers syntax.
sudo visudo -cf /etc/sudoers.d/power-control


echo '=== Configuring Wake-on-LAN ==='

# Configure every NetworkManager Ethernet connection for magic-packet
# Wake-on-LAN. This is persistent across boots.
while IFS=: read -r name type; do
  [[ "$type" == "802-3-ethernet" ]] || continue

  echo "Enabling WoL on NetworkManager connection: $name"
  sudo nmcli connection modify "$name" \
    802-3-ethernet.wake-on-lan magic
done < <(
  nmcli -t -f NAME,TYPE connection show
)

# Apply the changed profile immediately to any currently-connected
# Ethernet interfaces.
while IFS=: read -r iface type state; do
  [[ "$type" == "ethernet" && "$state" == "connected" ]] || continue

  echo "Reapplying NetworkManager connection on: $iface"
  sudo nmcli device reapply "$iface"
done < <(
  nmcli -t -f DEVICE,TYPE,STATE device status
)

# Verify the live NIC state.
while IFS=: read -r iface type; do
  [[ "$type" == "ethernet" ]] || continue

  echo "--- $iface ---"
  sudo ethtool "$iface" 2>/dev/null |
    grep -E 'Speed:|Duplex:|Supports Wake-on:|Wake-on:|Link detected:' || true
done < <(
  nmcli -t -f DEVICE,TYPE device status
)


echo '=== Disabling automatic suspend on AC power ==='

# This setting belongs to the desktop user, so do NOT sudo it.
# The build worker should remain awake unless deliberately suspended.
gsettings set \
  org.gnome.settings-daemon.plugins.power \
  sleep-inactive-ac-type \
  'nothing'


echo
echo '=== Verification ==='

echo
echo 'System76 power profile:'
system76-power profile

echo
echo 'CPU governor:'
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

echo
echo 'CPU energy/performance preference:'
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference

echo
echo 'Ethernet links:'
for iface in /sys/class/net/*; do
  iface=${iface##*/}

  [[ -e "/sys/class/net/$iface/device" ]] || continue
  [[ -e "/sys/class/net/$iface/type" ]] || continue
  [[ $(cat "/sys/class/net/$iface/type") == 1 ]] || continue

  echo "--- $iface ---"
  sudo ethtool "$iface" 2>/dev/null |
    grep -E 'Speed:|Duplex:|Wake-on:|Link detected:' || true
done

echo
echo 'Memory/swap:'
free -h
swapon --show

echo
echo 'Failed systemd units:'
sudo systemctl reset-failed user@111.service 2>/dev/null || true
systemctl --failed --no-pager || true

echo
echo 'Setup complete.'