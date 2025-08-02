# My Arch Linux Dotfiles

This repository contains my personal configuration files for Arch Linux.

## Included Configs

- Hyprland (`.config/hypr`)
- Waybar (`.config/waybar`)
- Mako (`.config/mako`)
- Tmux Sessionizer (`.config/tmux-sessionizer`)
- Zsh (`.zshrc`)
- Gitignore (`.gitignore`)

> **Note:** My Neovim configuration is managed in a separate repository.

---

## 🧠 Shell Setup: Using Oh My Zsh

I use [**Oh My Zsh**](https://ohmyz.sh/) for managing my Zsh configuration.

### 📦 Install:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## 🟢 Using LINE Messenger on Linux (Arch)

To use LINE Messenger on Arch Linux, follow these steps:

1. **Install Google Chrome**
   LINE’s extension only works in the official Google Chrome browser (not Chromium).

   ```bash
   yay -S google-chrome
   ```

2. **Install the LINE Extension**
   - Visit: [LINE Chrome Web Store Page](https://chrome.google.com/webstore/detail/line/ophjlpahpchlmihnnnihgmmeilfjmjjc)
   - Click **"Add to Chrome"**

3. **Enable Dark Theme in Chrome**
   - Open `chrome://flags` in the address bar
   - Search for **"Force Dark Mode for Web Contents"**
   - Enable it to apply a dark theme to LINE and all websites

4. **Fix Wayland Compatibility and Scaling**
   Edit Chrome’s `.desktop` file and replace the `Exec` line with:

```ini
Exec=/usr/bin/google-chrome-stable --ozone-platform=wayland --enable-features=UseOzonePlatform --force-device-scale-factor=1 %U
```

   You can do this in your local desktop entry:

```ini
~/.local/share/applications/google-chrome.desktop
```

---

## 💬 Launching Vesktop with Wayland Support

To run Vesktop with proper Wayland support and avoid graphical glitches or missing window decorations:

```ini
vesktop --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto & disown
```

This ensures:

- Native window decorations on Wayland
- Correct platform hint for better compatibility
- The process runs in the background and doesn't block your terminal

# My Arch Dual Boot Process

I won't be going into the extra process for laptop setups here because those are model specific. You can use this as a base and figure those out on your own.

---

## From Windows

- Make unallocated space
- Turn secure boot off
- Turn USB bootable on
- Insert Arch bootable USB
- Reboot and go into boot manager (usually F12 or F11)
- Select the USB

---

## In the Arch USB

Set font:

BASH
setfont ter-132n
END

---

### If using Wi-Fi

Start iwctl:

BASH
iwctl
END

List devices and connect:

BASH
device list
station wlan0 get-networks
station wlan0 connect SSID-NAME
END

---

### For Enterprise Wi-Fi

Create and edit config:

BASH
sudo vim /var/lib/iwd/SSID_NAME.8021x
END

Add these lines:

INI
[Security]
EAP-Method=PEAP
EAP-Identity=your_username@example.com
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=your_username@example.com
EAP-PEAP-Phase2-Password=your_password
AutoConnect=true
END

Set permissions and restart:

BASH
chmod 600 /var/lib/iwd/SSID_NAME.8021x
systemctl restart iwd
iwctl
station wlan0 connect SSID_NAME
END

---

## Sync package database

INI
pacman -Sy
END

INI
pacman -S archlinux-keyring
END

---

## Partitioning

List devices:

BASH
lsblk
END

Open partition tool:

BASH
cfdisk /dev/nvme0n1
END

Create partitions:

- 1 GB EFI partition
- Main Linux partition
- Swap partition (rest of space)

Example partitions (change accordingly):

| Partition     | Purpose          |
|---------------|------------------|
| nvme0n1p5     | EFI              |
| nvme0n1p6     | Linux filesystem |
| nvme0n1p7     | Swap             |

---

## Format partitions

BASH
mkfs.fat -F32 /dev/nvme0n1p5
mkfs.ext4 /dev/nvme0n1p6
mkswap /dev/nvme0n1p7
swapon /dev/nvme0n1p7
END

Mount partitions:

BASH
mount /dev/nvme0n1p6 /mnt
mkdir /mnt/efi
mount /dev/nvme0n1p5 /mnt/efi
END

Check mountpoints:

BASH
lsblk
END

Make sure:
- nvme0n1p5 mounted at `/mnt/efi`
- nvme0n1p6 mounted at `/mnt`
- nvme0n1p7 active swap

---

## Installing Arch Linux base system

Replace `intel-ucode` with `amd-ucode` if you use AMD.

BASH
pacstrap -K /mnt base base-devel linux linux-headers linux-firmware intel-ucode sudo git nano vim fastfetch htop make cmake curl wget bluez bluez-utils networkmanager cargo gcc mpv pipewire efibootmgr grub dosfstools mtools os-prober iw
END

Generate fstab:

BASH
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
END

Change root:

BASH
arch-chroot /mnt
END

Set root password:

BASH
passwd
END

Add user:

BASH
useradd -m -g users -G wheel,storage,video,audio -s /bin/bash your-name
passwd your-name
END

---

## Configure sudoers

BASH
EDITOR=vim visudo
END

Uncomment this line:

%wheel ALL=(ALL:ALL) ALL

---

## Set timezone

List timezones (use Tab for completion):

BASH
ln -sf /usr/share/zoneinfo/
END

Example:

BASH
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
END

---

## Locales

Edit locale.gen:

BASH
vim /etc/locale.gen
END

Uncomment your locale, e.g.:

#en_US.UTF-8 UTF-8

Generate locale:

BASH
locale-gen
END

Set LANG:

BASH
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
cat /etc/locale.conf
END

---

## Hostname and hosts

Set hostname (replace `arch`):

BASH
echo "arch" >> /etc/hostname
END

Edit hosts file:

BASH
vim /etc/hosts
END

Add this line (replace `arch`):

INI
127.0.1.1       arch.localdomain        arch
END

---

## Grub Setup

Mount Windows EFI (replace with your Windows EFI partition):

BASH
mkdir /windows
mount /dev/nvme0n1p1 /windows
END

Edit GRUB defaults:

BASH
vim /etc/default/grub
END

- Increase `GRUB_TIMEOUT` to `30`
- Uncomment `GRUB_DISABLE_OS_PROBER`

Install GRUB:

BASH
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
END

---

## Enable services

BASH
systemctl enable bluetooth
systemctl enable NetworkManager
END

Exit chroot and unmount:

BASH
exit
umount -lR /mnt
shutdown now
END

Remove USB and boot into Arch.

If it boots Windows instead, go into boot manager and select GRUB or adjust boot priority in UEFI.

---

# In Arch Linux

Login and set font:

BASH
setfont ter-132n
END

---

### Wi-Fi commands

List Wi-Fi networks:

BASH
nmcli device wifi list
END


Connect to Wi-Fi:

BASH
sudo nmcli device wifi connect SSID-NAME password WIFI-PASSWORD
END

---

If your Wi-Fi does not show but neighbors do, rescan:

BASH
sudo iw wlp0s20f3 scan | grep "SSID"
nmcli device wifi rescan
nmcli device wifi list
END

---

### Enterprise Wi-Fi via nmcli

BASH
sudo nmcli connection add type wifi \
  con-name MyEnterpriseWiFi \
  ifname wlp0s20f3 \
  ssid MyEnterpriseWiFi \
  wifi-sec.key-mgmt wpa-eap \
  802-1x.eap peap \
  802-1x.identity "your_username" \
  802-1x.password "your_password" \
  802-1x.phase2-auth mschapv2 \
  802-1x.password-flags 0
nmcli connection up MyEnterpriseWiFi
END

---

# Installing NVIDIA Drivers

(If using AMD or Intel GPU, follow their respective guides.)

BASH
sudo pacman -S nvidia nvidia-utils nvidia-settings egl-wayland libva-nvidia-driver
END

Edit grub:

BASH
sudo vim /etc/default/grub
END

Change:

GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"

to

GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1"

Rebuild grub config:

BASH
sudo grub-mkconfig -o /boot/grub/grub.cfg
END

---

### Installing CUDA (optional)

BASH
sudo pacman -S cuda cudnn nvidia-prime opencl-nvidia
END

---

# Audio Setup with PipeWire

BASH
sudo pacman -S pipewire pipewire-pulse wireplumber alsa-utils pavucontrol
systemctl --user enable --now pipewire pipewire-pulse wireplumber
END

---

# Installing Hyprland and essential apps

INI
sudo pacman -S hyprland xdg-desktop-portal-hyprland xorg-server-xwayland \
xdg-desktop-portal wl-clipboard qt5-wayland qt6-wayland waybar kitty \
thunar wofi firefox grim slurp swappy brightnessctl pamixer pavucontrol ly less
END

Enable ly (login manager):

BASH
sudo systemctl enable ly.service
sudo systemctl start ly
END

---

# Additional utilities

BASH
sudo pacman -S hyprlock hyprpaper hyprshot flatpak feh ffmpeg calcurse
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji noto-fonts-cjk
sudo pacman -S ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-commonz
END

---

# Dotfiles

BASH
git clone https://github.com/ZT-Things/dotfiles
cp -r dotfiles/.config ~/
END

---

# Installing yay (AUR helper)

BASH
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
END

---

# Installing Zen Browser

BASH
yay -S zen-browser-bin
END

---

# Installing Oh My Zsh

BASH
sudo pacman -S zsh
chsh -s $(which zsh)
END

---

If you get an error about `/sbin/zsh` not listed in `/etc/shells`:

BASH
sudo vim /etc/shells
# Add this line at the end:
/sbin/zsh
END

Then:

BASH
chsh -s /sbin/zsh
END

---
