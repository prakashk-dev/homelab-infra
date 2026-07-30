# OS install (the one manual step)

Prep the USB from the mini's current macOS, then wipe and install Ubuntu.

1. On macOS: download Ubuntu Server 24.04 LTS (amd64). Flash to USB (balenaEtcher, or
   `sudo dd if=ubuntu-...-amd64.iso of=/dev/rdiskN bs=4m`; find with `diskutil list`,
   `diskutil unmountDisk` first).
2. Reboot holding ⌥ (Option). Pick the orange "EFI Boot" USB. (2014 has no T2 — it just boots.)
3. Installer: choose **Ubuntu Server** (not minimized). Skip all Featured Server Snaps
   (k3s comes via Ansible, not here). Erase the whole disk. Enable OpenSSH server. Hostname
   `homelab`. Import SSH key from GitHub if it's there, else set a password.
4. Use **Ethernet**, not the flaky Broadcom Wi-Fi.
5. After boot it's headless — SSH in, set the static IP (netplan), reserve it in router DHCP.
