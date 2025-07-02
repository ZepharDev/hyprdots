#!/bin/bash
# filepath: /home/zephar/.config/scripts/selectpaper.sh

# Configuración
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CONFIG="$HOME/.config/hypr/hyprpaper.conf"
CACHE_DIR="$HOME/.cache/hypr"
LAST_WALL="$CACHE_DIR/last_wallpaper"

# Crear directorio cache si no existe
mkdir -p "$CACHE_DIR"

# Función para manejar errores
error_handler() {
    notify-send "Error" "No se pudo aplicar el wallpaper: $1" -u critical
    exit 1
}

# Verificar directorios y archivos necesarios
[ ! -d "$WALLPAPER_DIR" ] && error_handler "Directorio de wallpapers no encontrado"
[ ! -d "$(dirname "$CONFIG")" ] && error_handler "Directorio de configuración no encontrado"

# Seleccionar imagen con rofi
WALL=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -printf "%f\n" | \
     rofi -dmenu -config ~/.config/rofi/wallpaper.rasi -i -p "Wallpaper" -theme-str 'window {width: 50%;}')

# Verificar selección
[ -z "$WALL" ] && exit 0

# Construir ruta completa y verificar archivo
WALL_PATH="$WALLPAPER_DIR/$WALL"
[ ! -f "$WALL_PATH" ] && error_handler "Archivo no encontrado"

# Obtener monitores activos
MONITORS=$(hyprctl monitors -j | jq -r '.[].name') || error_handler "Error al obtener monitores"

# Generar nueva configuración
{
    echo "# Configuración generada automáticamente por selectpaper.sh"
    echo "preload = $WALL_PATH"
    echo ""
    for monitor in $MONITORS; do
        echo "wallpaper = $monitor,$WALL_PATH"
    done
} > "$CONFIG"

# Guardar última selección
echo "$WALL_PATH" > "$LAST_WALL"

# Aplicar wallpaper
if pgrep -x hyprpaper >/dev/null; then
    pkill -SIGUSR2 hyprpaper || {
        pkill hyprpaper
        sleep 1
        hyprpaper &
    }
else
    hyprpaper &
fi

# Verificar que hyprpaper esté corriendo
sleep 1
if ! pgrep -x hyprpaper >/dev/null; then
    hyprpaper &
    sleep 1
fi

# Verificar éxito y notificar
if pgrep -x hyprpaper >/dev/null; then
    notify-send "Wallpaper aplicado" "$(basename "$WALL_PATH")" -i "$WALL_PATH"
else
    error_handler "No se pudo iniciar hyprpaper"
fi
