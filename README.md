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

```bash sudo pacman -S git zsh hyprland neovim grim slurp yay -S hyprlock``

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

## Installation

To set up these dotfiles on your system, follow these steps:

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/ZepharDev/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    ```

2. **Run the Installation Script:**

    The repository includes an `install.sh` script to automate the setup process, creating symlinks for configuration files.

    ```bash
    ./install.sh
    ```

    If you want to include GUI-related configurations (e.g., Hyprland, rofi), use:

    ```bash
    ./install.sh --gui
    ```

3. **Install Zsh Plugins:**

    After installation, initialize Zsh plugins (e.g., Oh My Zsh or Zinit):

    ```bash
    exec zsh
    ```

4. **Install Neovim Plugins:**

    If using Neovim with a plugin manager like Lazy.nvim, sync the plugins:

    ```bash
    nvim --headless -c 'Lazy! sync' -c 'qall'
    ```

5. **Optional: Configure Hyprlock:**

    If you use `hyprlock`, ensure it’s configured correctly in `~/.config/hypr/hyprlock.conf`.  
    Note that taking screenshots of hyprlock may require tools like `grim` and `slurp`.

