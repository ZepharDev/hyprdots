# ZepharDev Dotfiles

Welcome to my personal dotfiles repository! This collection contains my configuration files for various tools and environments to personalize my development and desktop experience. These dotfiles are tailored for a Linux environment, primarily focused on Hyprland, a dynamic tiling window manager, and other CLI tools like Neovim, Zsh, and more.

---

## Overview

This repository includes configuration files for:

- **Hyprland:** A lightweight and highly customizable Wayland compositor.
- **Neovim:** My preferred text editor with plugins and custom settings.
- **Zsh:** Shell configuration with plugins like Oh My Zsh or Zinit, and custom aliases.
- **Other Tools:** Configurations for tools like tmux, rofi, and hyprlock to enhance productivity and aesthetics.

These dotfiles are designed to work on Arch Linux or Fedora-based distributions but may be adapted for other Linux systems with some tweaks.

---

## Prerequisites

Before installing these dotfiles, ensure you have the following dependencies installed:

- `git` - For cloning the repository
- `zsh` - For shell configurations
- `hyprland` - For the window manager
- `neovim` - For the editor setup
- `grim` and `slurp` - For screenshot capabilities
- `yay` (or another AUR helper for Arch Linux) - For installing additional packages
- `hyprlock` - For lock screen configurations

You can install these on Arch Linux with:

```bash sudo pacman -S git zsh hyprland neovim grim slurp or yay -S hyprlock``

# Screenshot

**This is the main Rofi configuration:**

- Simple and minimal
- Located at `~/.config/rofi/zephar.rasi`

![2025-07-02-190322_hyprshot](https://github.com/user-attachments/assets/9d7b85d9-294d-4fe4-b485-9a733885c9fd)

**This is the PowerMenu configuration, built using Rofi and Bash:**

- Script: `~/.config/scripts/power-menu.sh`
- General Rasi theme configuration: `~/.config/rofi/power-menu.rasi`

![2025-07-02-190332_hyprshot](https://github.com/user-attachments/assets/bb2fac1b-27c5-4f71-82ac-1b4dba4b8d31)

**This is the Waybar configuration:**

- A blur effect is applied via `layerrule` in `~/.config/hypr/windowrulev2.conf`
- Main configuration: `~/.config/waybar/config.jsonc`
- Style sheet: `~/.config/waybar/style.css
 
![2025-07-02-232713_hyprshot](https://github.com/user-attachments/assets/8db94c8a-551e-4550-9970-30e0b27490e2)

 **This is the fastfetch system information tool output:**

- Displays detailed system info like OS, kernel, uptime, packages, shell, resolution, WM, etc.
- Command to run: `fastfetch`
- You can capture its output as text or screenshot for your README

![2025-07-02-190352_hyprshot](https://github.com/user-attachments/assets/2e7d3568-37af-4b65-b31a-1361b25981ae)

# Installation

## Warning: The installation script isn't polished yet and may fail up to 90%. If you want to test the settings, you'll have to do it manually. Thanks. 
    
  

# Requirements
 
    -  Hyprlock
    -  Kitty
    -  Waybar
    -  FastCat
    -  alacritty
    -  rofi
    -  dmenu
    -  zsh
    -  powerlevel10k 
    -  FastFetch
    -  hyprshot
    -  hypr
    -  hypridle
    -  wlogout
    -  clipse
    -  SwayOSD
    -  nm-applet
    -  hyprpaper
    -  dunst
    -  swaync (alternative to Dusnt)
    -  Papirus Icon
    -  git
    -  Yay (alternative a Pacman)
    -  mako (alternative to Dunst or swaync)
    

# **Setup is still in progress. If you'd like to help, please write to me on Discord. Thanks.**

## 
      
      
     
