#!/bin/bash
# filepath: ~/.config/scripts/menu-scripts.sh

# Carpeta donde tienes tus scripts
SCRIPTS_DIR="$HOME/.config/scripts"

# Listar solo scripts ejecutables (excluye este menú)
options=$(find "$SCRIPTS_DIR" -maxdepth 1 -type f -executable ! -name "menu-scripts.sh" -exec basename {} \;)

# Mostrar en rofi
selected=$(echo "$options" | rofi -show -config ~/.config/rofi/scripts.rasi -dmenu -p "Exec Script")
# Ejecutar el script seleccionado si no está vacío
if [[ -n "$selected" ]]; then
    bash "$SCRIPTS_DIR/$selected"
fi
