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

# My Arch Dual Boot Process

I won't be going into the extra process for laptop setups here because those are model specific. You can use this as a base and figure those out on your own.
Keep in mind that this guide is mainly for myself.

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

```bash
setfont ter-132n
```

---

### If using Wi-Fi

Start iwctl:

```bash
iwctl
```

List devices and connect:

```bash
device list
station wlan0 get-networks
station wlan0 connect SSID-NAME
```

---

### For Enterprise Wi-Fi

Create and edit config:

```bash
sudo vim /var/lib/iwd/SSID_NAME.8021x
```

Add these lines:

```ini
[Security]
EAP-Method=PEAP
EAP-Identity=your_username@example.com
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=your_username@example.com
EAP-PEAP-Phase2-Password=your_password
AutoConnect=true
```

Set permissions and restart:

```bash
chmod 600 /var/lib/iwd/SSID_NAME.8021x
systemctl restart iwd
iwctl
station wlan0 connect SSID_NAME
```

---

## Sync package database

```ini
pacman -Sy
```

```ini
pacman -S archlinux-keyring
```

---

## Partitioning

List devices:

```bash
lsblk
```

Open partition tool:

```bash
cfdisk /dev/nvme0n1
```

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

```bash
mkfs.fat -F32 /dev/nvme0n1p5
mkfs.ext4 /dev/nvme0n1p6
mkswap /dev/nvme0n1p7
swapon /dev/nvme0n1p7
```

Mount partitions:

```bash
mount /dev/nvme0n1p6 /mnt
mkdir /mnt/efi
mount /dev/nvme0n1p5 /mnt/efi
```

Check mountpoints:

```bash
lsblk
```

Make sure:
- nvme0n1p5 mounted at `/mnt/efi`
- nvme0n1p6 mounted at `/mnt`
- nvme0n1p7 active swap

---

## Installing Arch Linux base system

Replace `intel-ucode` with `amd-ucode` if you use AMD.

```bash
pacstrap -K /mnt base base-devel linux linux-headers linux-firmware intel-ucode sudo git nano vim fastfetch htop make cmake curl wget bluez bluez-utils networkmanager cargo gcc mpv pipewire efibootmgr grub dosfstools mtools os-prober iw
```

Generate fstab:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

Change root:

```bash
arch-chroot /mnt
```

Set root password:

```bash
passwd
```

Add user:

```bash
useradd -m -g users -G wheel,storage,video,audio -s /bin/bash your-name
passwd your-name
```

---

## Configure sudoers

```bash
EDITOR=vim visudo
```

Uncomment this line:

%wheel ALL=(ALL:ALL) ALL

---

## Set timezone

List timezones (use Tab for completion):

```bash
ln -sf /usr/share/zoneinfo/
```

Example:

```bash
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
```

---

## Locales

Edit locale.gen:

```bash
vim /etc/locale.gen
```

Uncomment your locale, e.g.:

```ini
#en_US.UTF-8 UTF-8
```

Generate locale:

```bash
locale-gen
```

Set LANG:

```bash
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
cat /etc/locale.conf
```

---

## Hostname and hosts

Set hostname (replace `arch`):

```bash
echo "arch" >> /etc/hostname
```

Edit hosts file:

```bash
vim /etc/hosts
```

Add this line (replace `arch`):

```ini
127.0.1.1       arch.localdomain        arch
```

---

## Grub Setup

Mount Windows EFI (replace with your Windows EFI partition):

```bash
mkdir /windows
mount /dev/nvme0n1p1 /windows
```

Edit GRUB defaults:

```bash
vim /etc/default/grub
```

- Increase `GRUB_TIMEOUT` to `30`
- Uncomment `GRUB_DISABLE_OS_PROBER`

Install GRUB:

```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

---

## Enable services

```bash
systemctl enable bluetooth
systemctl enable NetworkManager
```

Exit chroot and unmount:

```bash
exit
umount -lR /mnt
shutdown now
```

Remove USB and boot into Arch.

If it boots Windows instead, go into boot manager and select GRUB or adjust boot priority in UEFI.

---

# In Arch Linux

This is for hyprland mainly.

---

Login and set font:

```bash
setfont -d
```

---

### Wi-Fi commands

List Wi-Fi networks:

```bash
nmcli device wifi list
```


Connect to Wi-Fi:

```bash
sudo nmcli device wifi connect SSID-NAME password WIFI-PASSWORD
```

---

If your Wi-Fi does not show but neighbors do, rescan:

```bash
sudo iw wlp0s20f3 scan | grep "SSID"
nmcli device wifi rescan
nmcli device wifi list
```

---

### Enterprise Wi-Fi via nmcli

```bash
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
```

---

## Installing NVIDIA Drivers

(If using AMD or Intel GPU, follow their respective guides.)

```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings egl-wayland libva-nvidia-driver
```

Edit grub:

```bash
sudo vim /etc/default/grub
```

Change:

```ini
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
```

to

```ini
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1"
```

Rebuild grub config:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

### Installing CUDA (optional)

```bash
sudo pacman -S cuda cudnn nvidia-prime opencl-nvidia
```

---

## Audio Setup with PipeWire

```bash
sudo pacman -S pipewire pipewire-pulse wireplumber alsa-utils pavucontrol
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

---

## Installing Hyprland and essential packages

```ini
sudo pacman -S hyprland xdg-desktop-portal-hyprland xorg-server-xwayland \
xdg-desktop-portal wl-clipboard qt5-wayland qt6-wayland waybar kitty \
thunar wofi grim slurp swappy brightnessctl pamixer pavucontrol ly less tmux \
mako neovim hyprshot hyprpicker
```

Enable ly (login manager):

```bash
sudo systemctl enable ly.service
sudo systemctl start ly
```

---

## Additional utilities

```bash
sudo pacman -S hyprlock hyprpaper hyprshot flatpak feh ffmpeg calcurse
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common
sudo pacman -S ripgrep fzf
```

---

## Dotfiles

```bash
git clone https://github.com/ZT-Things/dotfiles
cp -r dotfiles/.config ~/
```

Create screenshots folder

```bash
mkdir ~/screenshots
```

---

## Installing yay (AUR helper)

```bash
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

---

## Installing Zen Browser

```bash
yay -S zen-browser-bin
```

Config

Set this to true in `about:config`

`zen.view.experimental-no-window-controls`

Set this to false

`zen.view.show-newtab-button-top`

---

## Installing Oh My Zsh

Install zsh

```bash
sudo pacman -S zsh
chsh -s $(which zsh)
```

---

If you get an error about `/sbin/zsh` not listed in `/etc/shells`:

```bash
sudo vim /etc/shells
# Add this line at the end:
/sbin/zsh
```

Then:

```bash
chsh -s /sbin/zsh
```

---

Then install oh-my-zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Now install the required plugins

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

Now clone my `.zshrc` into `~/.zshrc`

Then:

```bash
source ~/.zshrc
```


---

## Installing Neovim

```bash
sudo pacman -S neovim
```

## Setting up MY neovim config

```bash
git clone https://github.com/ZT-Things/neovim-config

mv neovim-config ~/.config/nvim
```

Installing go and node for lsp, or change this in the lsp config:

```bash
sudo pacman -S go nodejs npm
```

Run this to initialize:

```bash
nvim .
```

---

## Installing vencord

```bash
yay -S vencord-bin
```

Now run vencord with this

```bash
vesktop --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto & disown
```

OR

Modify the Vesktop launcher to include hyprland launch flags

```bash
cp /usr/share/applications/vesktop.desktop ~/.local/share/applications/
vim ~/.local/share/applications/vesktop.desktop
```

Find the `Exec=` line. It probably looks like:

```ini
Exec=vesktop %U
```

Change it to:

```ini
Exec=vesktop --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto %U
```

Then save and exit.

---

## Initialize local bin

```bash
cp .local/bin ~/.local/bin
```

---

## My custom wallpaper manager

Initialize the wallpaper folder

```bash
cp Pictures/wallpapers ~/Pictures/wallpapers -r
```

And run:

```bash
wallpaper
```

---

## Setting up github SSH

```bash
sudo pacman -S openssh
```

### Step 1: Generate SSH key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted:
- Press Enter to accept the default file location (~/.ssh/id_ed25519)
- Optionally, enter a secure passphrase or leave empty for no passphrase

---

### Step 2: Start the SSH agent and add your key

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

---

### Step 3: Copy your public key to clipboard

```bash
wl-copy < ~/.ssh/id_ed25519.pub
```

If not, just display it and copy manually:

```bash
cat ~/.ssh/id_ed25519.pub
```

---

### Step 4: Add the SSH public key to your Git provider

- For GitHub: https://github.com/settings/keys
- For GitLab: https://gitlab.com/-/profile/keys
- For Bitbucket: https://bitbucket.org/account/settings/ssh-keys/

Click "New SSH key" (or equivalent) and paste the copied key.

---

### Step 5: Test your SSH connection

```bash
ssh -T git@github.com
```

You should see a message like:

> Hi username! You've successfully authenticated, but GitHub does not provide shell access.

---

### Step 6: Use SSH URL for your repositories

Example:

```bash
git clone git@github.com:username/repository.git
```

---

---

## Installing steam

### Step 1: Enable multilib repository

Open `/etc/pacman.conf` with your favorite editor:

```bash
sudo vim /etc/pacman.conf
```

Uncomment these lines by removing the `#`:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

---

### Step 2: Update package database

```bash
sudo pacman -Sy
```

---

### Step 3: Install Steam and dependencies

```bash
sudo pacman -S steam steam-native-runtime lib32-nvidia-utils lib32-mesa lib32-vulkan-radeon lib32-vulkan-intel
```

If you use Nvidia GPU, `lib32-nvidia-utils` is needed. For AMD or Intel, install appropriate `lib32` Vulkan packages.

---

### Step 4: Launch Steam

Simply run:

```bash
steam
```

Steam will update itself on first launch.

---

## Discord Screen Share on Arch Linux (Hyprland + Vesktop)

---

### Step 1: Install Required Dependencies

```bash
sudo pacman -S xdg-desktop-portal xdg-desktop-portal-hyprland pipewire wireplumber
sudo pacman -S xdg-desktop-portal-wlr xdg-desktop-portal-gtk
```

Enable WirePlumber (audio/session manager):

```bash
systemctl --user enable --now wireplumber
```

---

### Step 2: Configure `xdg-desktop-portal`

```bash
sudo vim /etc/xdg/xdg-desktop-portal/xdg-desktop-portal.conf
```

Add or edit the following:

```ini
[preferred]
default=hyprland
```

Then restart the portal services:

```bash
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland
```

---

### Step 3: Launch Vesktop with Wayland Support

Run Vesktop like this:

```bash
vesktop --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto
```

To make it permanent via `.desktop` launcher:

```bash
cp /usr/share/applications/vesktop.desktop ~/.local/share/applications/
vim ~/.local/share/applications/vesktop.desktop
```

Edit the `Exec` line:

```ini
Exec=vesktop --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto %U
```

---

### Step 4: Use Screen Share in Discord (Vesktop)

1. Join a voice call
2. Click **Share Your Screen**
3. Select a window or monitor (via portal)
4. Done

---

### Troubleshooting

**Issue:** No windows/monitors show
**Fix:** Restart portal services:

```bash
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland
```

---

## Clone bare repository

```bash
git clone --bare https://github.com/ZT-Things/dotfiles $HOME/.dotfiles
```

```ini
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

```bash
rm ~/.config/hypr/hyprland.conf
dotfiles checkout

dotfiles config --local status.showUntrackedFiles no
```

---

## Using LINE Messenger on Linux (Arch)

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

```bash
cp /usr/share/applications/google-chrome.desktop ~/.local/share/applications/
```

```ini
~/.local/share/applications/google-chrome.desktop
```

---

## Disabling IPv6

Add this to `/etc/sysctl.d/99-disable-ipv6.conf`

```ini
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

Then reload sysctl or reboot

```bash
sudo sysctl --system
```

---

## Installing man pages

```bash
sudo pacman -S man man-db man-pages
```

---

## Roblox

```bash
flatpak install flathub org.vinegarhq.Sober
```

## Roblox studio with rojo

```bash
sudo pacman -S xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr
```

```bash
flatpak install flathub org.vinegarhq.Vinegar
```

```bash
yay -S rojo-bin
```

In your roblox-projects directory
```bash
rojo init my-project
```

```bash
rojo serve
```

Then go into roblox studio, click rojo and connect to the server

---

## Setting up music player

```bash
sudo pacman -S mpd mpc ncmpcpp mpdscribble mpv yt-dlp fzf
```

```bash
mkdir -p ~/.config/mpd ~/.local/share/mpd/playlists ~/.cache/mpd ~/Music
```

```bash
systemctl --user enable mpd
systemctl --user start mpd
```

---

## Setting up ssh

```bash
sudo pacman -S openssh
sudo systemctl enable --now sshd
```

Edit this `sudo vim /etc/ssh/sshd_config`

```ini
PermitRootLogin no
PasswordAuthentication yes   # or "no" if using only keys
Port 22                      # can change to 2222 for security
```

Then restart

```bash
sudo systemctl restart sshd
```

---

## Setting up blackarch

The BlackArch database provides a repository of security and hacking tools that can be installed via `pacman`

```bash
curl -O https://blackarch.org/strap.sh

sha1sum strap.sh
# Should match the SHA1 on https://blackarch.org/downloads.html#install-repo

chmod +x strap.sh

sudo ./strap.sh
```

You can cancel the installation if you only want the database

```bash
sudo pacman -Syu
```

---

## Using custom quickshare script

Script for sharing files with other device quickly either locally or through ngrok

You'll need blackarch for this

```bash
sudo pacman -S python-pyngrok
```

Head to `https://dashboard.ngrok.com/get-started/your-authtoken`

Find your auth token

```bash
ngrok config add-authtoken YOUR_AUTH_TOKEN
```

---

## Setting up telegram bot to notify your local ip on startup

### Initialization

Initialize script folder
```bash
cp ~/dotfiles/scripts ~/scripts
```

```bash
mv ~/dotfiles/scripts/sendip
vim .env
```

In here add your BOT_TOKEN and CHAT_ID

```ini
BOT_TOKEN=123456789:ABCDefGHIjkLMnoPQRstUVwxyZ
CHAT_ID=123456789
```

### Getting BOT_TOKEN and CHAT_ID

Getting BOT_TOKEN

1. Open Telegram and search for BotFather

2. Start a chat with BotFather and send: `/newbot`

3. Give your bot a username ending with bot (e.g., MyIPBot).

4. BotFather will reply with a bot token, which looks like: `123456789:ABCDefGHIjkLMnoPQRstUVwxyZ`

Getting CHAT_ID

1. Start a chat with your bot, and send it a message

2. Open a browser and visit `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
  For example https://api.telegram.org/bot<123456789:ABCDefGHIjkLMnoPQRstUVwxyZ>/getUpdates

3. Look for "id" in "chat" and that is your CHAT_ID

### Setting the script up

Run script on startup
```bash
mkdir -p ~/.config/systemd/user
vim ~/.config/systemd/user/ip_monitor.service
```

Make sure to change HOST-NAME to your hostname
```ini
[Unit]
Description=IP Monitor Telegram Notification
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /home/HOST-NAME/scripts/sendip/main.py
Restart=on-failure
Environment=PYTHONUNBUFFERED=1
WorkingDirectory=/home/HOST-NAME/scripts/sendip/

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable ip_monitor.service
systemctl --user start ip_monitor.service
```

Check status and make sure it's running
```bash
systemctl --user status ip_monitor.service
```

To restart
```bash
systemctl --user restart ip_monitor.service
```

---
