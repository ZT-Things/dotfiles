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

