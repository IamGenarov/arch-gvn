#!/bin/bash

# Definición de colores
GREEN='\033[1;32m'
RESET='\033[0m'

# Humo animado (frames cíclicos)
smoke_frames=(
"   (   )"
"   (    )"
"   (     )"
"   (    )"
"   (   )"
"   ."
"    "
)

print_train() {
    clear
    local pos=$1
    local frame=$2
    local space=$(printf "%${pos}s" "")

    echo "${space}${smoke_frames[$frame]}"
    cat <<EOF
${space}   ___     ____       
${space}  |_ _|   |__ /   _ _     __ _      _ _    ___
${space}   | |     |_ \  | ' \   / _\` |    | '_|  / _ \ 
${space}  |___|   |___/  |_||_|  \__,_|   _|_|_   \___/
${space} _|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|
${space} "\`-0-0-'"\`-0-0-'"\`-0-0-'"\`-0-0-'"\`-0-0-'"\`-0-0-' 
EOF
}

for i in {0..20}; do
    frame=$((i % ${#smoke_frames[@]}))
    print_train "$i" "$frame"
    sleep 0.1
done

for ((i=20; i>=0; i--)); do
    frame=$((i % ${#smoke_frames[@]}))
    print_train "$i" "$frame"
    sleep 0.1
done

clear
echo -e "${GREEN}[✔] Animación finalizada. Iniciando el script...${RESET}"

# -------------------------
# DEPENDENCIAS Y CONFIGURACIÓN
# -------------------------

echo "[+] Iniciando instalación de dependencias..."

sudo apt update
sudo apt install -y xorg xinit i3 alacritty \
    lightdm lightdm-gtk-greeter polybar \
    fonts-font-awesome fonts-hack-ttf fonts-noto-color-emoji \
    zsh curl git rofi feh nano flameshot xclip network-manager || true

# Habilitar servicios
sudo systemctl enable lightdm || true
sudo systemctl enable NetworkManager || true
sudo systemctl start NetworkManager || true

# Establecer Zsh por defecto
chsh -s /bin/zsh || true

# Instalar Oh My Zsh si no existe
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Instalando Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
fi

# Plugins Zsh
echo "[+] Instalando plugins Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

# Configuración básica de xinit
echo "exec i3" > ~/.xinitrc || true

# -------------------------
# CLONACIÓN Y CONFIGURACIÓN
# -------------------------

CONFIG_DIR="$HOME/.config/i3naro_temp"
if [ -d "$CONFIG_DIR" ]; then
    echo "[!] El directorio temporal $CONFIG_DIR ya existe. Eliminando..."
    rm -rf "$CONFIG_DIR" || true
fi

echo "[+] Clonando repositorio i3naro..."
git clone https://github.com/IamGenarov/i3naro.git "$CONFIG_DIR" || true

echo "[+] Copiando configuración a ~/.config/ ..."
mkdir -p "$HOME/.config" || true
cp -r "$CONFIG_DIR/HOME/.config/"* "$HOME/.config/" 2>/dev/null || true

echo "[+] Copiando archivos ocultos de HOME..."
cp "$CONFIG_DIR/HOME/."* "$HOME/" 2>/dev/null || true

cp "$CONFIG_DIR/i3/"* "$HOME/.config/i3/" || true

echo "[+] Creando carpetas estándar..."
mkdir -p "$HOME/Documents" "$HOME/Pictures/.wallpapers" "$HOME/Downloads" \
         "$HOME/Music" "$HOME/Videos" "$HOME/Pictures/Clipboard" || true

echo "[+] Copiando wallpapers a ~/Pictures/.wallpapers ..."
cp -r "$CONFIG_DIR/wallpapers/"* "$HOME/Pictures/.wallpapers/" 2>/dev/null || true

echo "[+] Copiando fuentes locales..."
mkdir -p "$HOME/.local/share/fonts" || true
cp -r "$CONFIG_DIR/fonts/"* "$HOME/.local/share/fonts/" || true
fc-cache -fv || true

echo "[+] Limpieza del directorio temporal..."
rm -rf "$CONFIG_DIR" || true

echo "[+] Dando permisos de ejecución a launch.sh y scripts..."
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true
chmod +x "$HOME/.config/polybar/scripts/ip-detect.sh" 2>/dev/null || true

# Recargar Zsh si aplica
if [ -f "$HOME/.zshrc" ]; then
    echo "[+] Ejecutando source ~/.zshrc..."
    source "$HOME/.zshrc" || true
fi

echo -e "${GREEN}[✔] Configuración copiada correctamente. ¡Listo para usar!${RESET}"
