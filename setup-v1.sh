#!/usr/bin/env bash

# Defining Catppuccin Mocha colors in ANSI escape format
mocha_rosewater="\e[38;2;245;224;220m"
mocha_flamingo="\e[38;2;242;205;205m"
mocha_pink="\e[38;2;245;194;231m"
mocha_mauve="\e[38;2;203;166;247m"
mocha_red="\e[38;2;243;139;168m"
mocha_peach="\e[38;2;250;179;135m"
mocha_yellow="\e[38;2;249;226;175m"
mocha_green="\e[38;2;166;227;161m"
mocha_teal="\e[38;2;148;226;213m"
mocha_blue="\e[38;2;137;180;250m"
mocha_lavender="\e[38;2;180;190;254m"
mocha_text="\e[38;2;205;214;244m"
mocha_subtext1="\e[38;2;186;200;222m"
mocha_subtext0="\e[38;2;147;153;178m"
mocha_overlay2="\e[38;2;147;153;178m"
mocha_overlay1="\e[38;2;127;132;156m"
mocha_overlay0="\e[38;2;108;112;134m"
mocha_surface2="\e[38;2;88;91;112m"
mocha_surface1="\e[38;2;69;71;90m"
mocha_surface0="\e[38;2;49;50;68m"
mocha_base="\e[38;2;30;30;46m"
mocha_mantle="\e[38;2;24;24;37m"
mocha_crust="\e[38;2;17;17;27m"

# Setting up TUI styles
bold=$(tput bold)
reset="\e[0m"
underline=$(tput smul)

# Defining repository details
repo_url="https://github.com/zephardev/hyprdots.git"
repo_dir="$HOME/hyprdots"
backup_dir="$HOME/.hyprdots.bak"
config_src="$repo_dir/configs/config"
config_dest="$HOME/.config"

# Defining components for selective installation
components=(
  "alacritty"
  "waybar"
  "rofi"
  "wlogout"
  "fastfetch"
  "kitty"
  "nvim"
  "cava"
  "btop"
  "swayosd"
  "swaync"
  "dunst"
  "hypr"
)

# Function to display the header
display_header() {
  clear
  echo -e "${bold}${mocha_mauve}============================================================${reset}"
  echo -e "${bold}${mocha_rosewater}       Hyprdots Zephardev - Installation Script${reset}"
  echo -e "${bold}${mocha_mauve}============================================================${reset}"
  echo -e "${mocha_yellow}Warning: This script may overwrite existing configurations.${reset}"
  echo -e "${mocha_yellow}A backup will be created at ~/.hyprdots.bak${reset}"
  echo -e "${mocha_overlay2}Please select an option below:${reset}\n"
}

# Function to display the menu
display_menu() {
  echo -e "${bold}${mocha_lavender}1) Install Setup${reset} - Full installation with backup"
  echo -e "${bold}${mocha_blue}2) Check Dependencies${reset} - Verify required packages"
  echo -e "${bold}${mocha_peach}3) Install Manual${reset} - Select specific components"
  echo -e "${bold}${mocha_green}4) Backup Selective${reset} - Backup specific configurations"
  echo -e "${bold}${mocha_red}5) Uninstall${reset} - Remove Hyprdots and restore backup"
  echo -e "${bold}${mocha_teal}6) Help${reset} - Display help information"
  echo -e "${bold}${mocha_flamingo}7) Rescue${reset} - Restore from backup in case of failure"
  echo -e "${bold}${mocha_pink}8) Exit${reset} - Exit the installer\n"
  echo -e "${mocha_subtext1}Enter your choice (1-8): ${reset}"
}

# Function to check dependencies
check_dependencies() {
  local deps=("git" "hyprland" "alacritty" "waybar" "rofi" "wlogout" "fastfetch" "kitty" "nvim" "cava" "btop" "swayosd" "swaync" "dunst")
  local missing=()

  echo -e "${bold}${mocha_blue}Checking dependencies...${reset}"
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      missing+=("$dep")
    fi
  done

  if [ ${#missing[@]} -eq 0 ]; then
    echo -e "${mocha_green}All dependencies are installed!${reset}"
  else
    echo -e "${mocha_red}Missing dependencies:${reset}"
    for dep in "${missing[@]}"; do
      echo -e "${mocha_overlay0} - $dep${reset}"
    done
    echo -e "${mocha_yellow}Please install the missing dependencies and try again.${reset}"
  fi
  read -p "Press Enter to continue..."
}

# Function to create backup
create_backup() {
  local target_dir="$1"
  local backup_target="$backup_dir/$(date +%F_%H-%M-%S)"
  
  echo -e "${bold}${mocha_green}Creating backup at $backup_target...${reset}"
  mkdir -p "$backup_target"
  
  for component in "${components[@]}"; do
    if [ -d "$config_dest/$component" ]; then
      cp -r "$config_dest/$component" "$backup_target/"
      echo -e "${mocha_overlay2}Backed up $component${reset}"
    fi
  done
}

# Function to perform full installation
install_setup() {
  echo -e "${bold}${mocha_lavender}Starting full installation...${reset}"
  
  # Clone repository if not exists
  if [ ! -d "$repo_dir" ]; then
    echo -e "${mocha_overlay2}Cloning repository...${reset}"
    git clone "$repo_url" "$repo_dir"
  fi
  
  # Create backup
  create_backup
  
  # Copy configurations
  echo -e "${mocha_overlay2}Installing configurations...${reset}"
  for component in "${components[@]}"; do
    if [ -d "$config_src/$component" ]; then
      mkdir -p "$config_dest"
      cp -r "$config_src/$component" "$config_dest/"
      echo -e "${mocha_green}Installed $component${reset}"
    fi
  done
  
  echo -e "${bold}${mocha_green}Installation complete!${reset}"
  read -p "Press Enter to continue..."
}

# Function to display manual installation menu
manual_install_menu() {
  while true; do
    clear
    display_header
    echo -e "${bold}${mocha_peach}Manual Installation - Select Components${reset}"
    for i in "${!components[@]}"; do
      echo -e "${bold}${mocha_blue}$((i+1))) ${components[i]}${reset}"
    done
    echo -e "${bold}${mocha_pink}$(( ${#components[@]} + 1 ))) Back${reset}\n"
    echo -e "${mocha_subtext1}Enter component number (1-$(( ${#components[@]} + 1 ))): ${reset}"
    
    read choice
    if [ "$choice" -eq $(( ${#components[@]} + 1 )) ]; then
      break
    elif [ "$choice" -ge 1 ] && [ "$choice" -le ${#components[@]} ]; then
      component=${components[$((choice-1))]}
      echo -e "${mocha_overlay2}Installing $component...${reset}"
      if [ -d "$config_src/$component" ]; then
        mkdir -p "$config_dest"
        cp -r "$config_src/$component" "$config_dest/"
        echo -e "${mocha_green}Installed $component${reset}"
      else
        echo -e "${mocha_red}Component $component not found in repository${reset}"
      fi
      read -p "Press Enter to continue..."
    else
      echo -e "${mocha_red}Invalid choice${reset}"
      read -p "Press Enter to continue..."
    fi
  done
}

# Function to perform selective backup
backup_selective() {
  while true; do
    clear
    display_header
    echo -e "${bold}${mocha_green}Selective Backup - Select Components${reset}"
    for i in "${!components[@]}"; do
      echo -e "${bold}${mocha_blue}$((i+1))) ${components[i]}${reset}"
    done
    echo -e "${bold}${mocha_pink}$(( ${#components[@]} + 1 ))) Back${reset}\n"
    echo -e "${mocha_subtext1}Enter component number (1-$(( ${#components[@]} + 1 ))): ${reset}"
    
    read choice
    if [ "$choice" -eq $(( ${#components[@]} + 1 )) ]; then
      break
    elif [ "$choice" -ge 1 ] && [ "$choice" -le ${#components[@]} ]; then
      component=${components[$((choice-1))]}
      backup_target="$backup_dir/$(date +%F_%H-%M-%S)/$component"
      if [ -d "$config_dest/$component" ]; then
        mkdir -p "$(dirname "$backup_target")"
        cp -r "$config_dest/$component" "$backup_target"
        echo -e "${mocha_green}Backed up $component to $backup_target${reset}"
      else
        echo -e "${mocha_red}Component $component not found in $config_dest${reset}"
      fi
      read -p "Press Enter to continue..."
    else
      echo -e "${mocha_red}Invalid choice${reset}"
      read -p "Press Enter to continue..."
    fi
  done
}

# Function to uninstall
uninstall() {
  echo -e "${bold}${mocha_red}Starting uninstallation...${reset}"
  
  # Find latest backup
  latest_backup=$(ls -td "$backup_dir"/* 2>/dev/null | head -n 1)
  if [ -z "$latest_backup" ]; then
    echo -e "${mocha_yellow}No backup found. Removing configurations without restoring.${reset}"
  else
    echo -e "${mocha_overlay2}Restoring from $latest_backup...${reset}"
    for component in "${components[@]}"; do
      if [ -d "$latest_backup/$component" ]; then
        cp -r "$latest_backup/$component" "$config_dest/"
        echo -e "${mocha_green}Restored $component${reset}"
      fi
    done
  fi
  
  # Remove configurations
  for component in "${components[@]}"; do
    if [ -d "$config_dest/$component" ]; then
      rm -rf "$config_dest/$component"
      echo -e "${mocha_overlay2}Removed $component${reset}"
    fi
  done
  
  echo -e "${bold}${mocha_green}Uninstallation complete!${reset}"
  read -p "Press Enter to continue..."
}

# Function to display help
display_help() {
  clear
  display_header
  echo -e "${bold}${mocha_teal}Help - Hyprdots Zephardev Installer${reset}"
  echo -e "${mocha_text}This script helps you install and manage Hyprdots configurations."
  echo -e "Options:"
  echo -e "${mocha_lavender}Install Setup:${reset} Performs a full installation with backup"
  echo -e "${mocha_blue}Check Dependencies:${reset} Verifies required packages"
  echo -e "${mocha_peach}Install Manual:${reset} Allows selective component installation"
  echo -e "${mocha_green}Backup Selective:${reset} Backs up specific configurations"
  echo -e "${mocha_red}Uninstall:${reset} Removes configurations and restores backup"
  echo -e "${mocha_flamingo}Rescue:${reset} Restores configurations from latest backup"
  echo -e "${mocha_pink}Exit:${reset} Exits the installer\n"
  echo -e "${mocha_yellow}Note: Ensure you have git and required dependencies installed."
  echo -e "Repository: $repo_url${reset}"
  read -p "Press Enter to continue..."
}

# Function to perform rescue
rescue() {
  echo -e "${bold}${mocha_flamingo}Starting rescue operation...${reset}"
  
  latest_backup=$(ls -td "$backup_dir"/* 2>/dev/null | head -n 1)
  if [ -z "$latest_backup" ]; then
    echo -e "${mocha_red}No backup found. Cannot perform rescue.${reset}"
  else
    echo -e "${mocha_overlay2}Restoring from $latest_backup...${reset}"
    for component in "${components[@]}"; do
      if [ -d "$latest_backup/$component" ]; then
        cp -r "$latest_backup/$component" "$config_dest/"
        echo -e "${mocha_green}Restored $component${reset}"
      fi
    done
    echo -e "${bold}${mocha_green}Rescue complete!${reset}"
  fi
  read -p "Press Enter to continue..."
}

# Main loop
while true; do
  clear
  display_header
  display_menu
  read choice
  
  case $choice in
    1)
      install_setup
      ;;
    2)
      check_dependencies
      ;;
    3)
      manual_install_menu
      ;;
    4)
      backup_selective
      ;;
    5)
      uninstall
      ;;
    6)
      display_help
      ;;
    7)
      rescue
      ;;
    8)
      echo -e "${bold}${mocha_pink}Exiting installer...${reset}"
      exit 0
      ;;
    *)
      echo -e "${mocha_red}Invalid choice. Please select 1-8.${reset}"
      read -p "Press Enter to continue..."
      ;;
  esac
done
