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

# Función para mostrar el tren con humo en una posición
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

# Animación hacia la derecha
for i in {0..20}; do
    frame=$((i % ${#smoke_frames[@]}))
    print_train "$i" "$frame"
    sleep 0.1
done

# Y hacia la izquierda
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

# 1. Xorg y xinit
echo "[+] Instalando Xorg..."
sudo pacman -S --noconfirm xorg xorg-xinit || true

# 2. Terminal gráfico: Alacritty
echo "[+] Instalando Alacritty..."
sudo pacman -S --noconfirm alacritty || true

# 3. Instalación de LightDM sin preguntar
echo "[+] Instalando y habilitando LightDM..."
sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter || true
sudo systemctl enable lightdm || true

# Fallback en caso se use startx
echo "exec i3" > ~/.xinitrc || true

# 4. Reemplazo de i3-wm con i3-gaps
echo "[+] Reemplazando i3-wm con i3-gaps..."
sudo pacman -Rns --noconfirm i3-wm || true
sudo pacman -S --noconfirm i3-gaps || true

# 5. Polybar
echo "[+] Instalando Polybar..."
sudo pacman -S --noconfirm polybar || true

# 6. Fuentes necesarias
echo "[+] Instalando fuentes..."
sudo pacman -S --noconfirm \
    terminus-font \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono \
    ttf-hack-nerd \
    ttf-jetbrains-mono-nerd \
    ttf-font-awesome || true

# 7. Zsh y mejoras visuales
echo "[+] Instalando Zsh..."
sudo pacman -S --noconfirm zsh || true
chsh -s /bin/zsh || true

# 10. Plugins Zsh
echo "[+] Instalando plugins Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

# 11. Utilidades adicionales
echo "[+] Instalando utilidades: rofi, feh, nano..."
sudo pacman -S --noconfirm rofi feh nano || true
sudo pacman -S --noconfirm flameshot || true
sudo pacman -S --noconfirm xclip || true
sudo pacman -S --noconfirm networkmanager || true
sudo systemctl enable NetworkManager.service || true
sudo systemctl start NetworkManager.service || true

echo "[✔] Todo listo. Dependencias y utilidades instaladas correctamente."

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

cp "$CONFIG_DIR/i3/*" "$HOME/.config/i3/" || true

# Crear carpetas estándar
echo "[+] Creando carpetas estándar..."
mkdir -p "$HOME/Documents" "$HOME/Pictures/.wallpapers" "$HOME/Downloads" "$HOME/Music" "$HOME/Videos" "$HOME/Pictures/Clipboard"|| true




echo "[+] Copiando wallpapers a ~/Pictures/.wallpapers ..."
cp -r "$CONFIG_DIR/wallpapers/"* "$HOME/Pictures/.wallpapers/" 2>/dev/null || true

echo "[+] Limpieza del directorio temporal..."
rm -rf "$CONFIG_DIR" || true


echo "[+] Copiando fuentes locales..."
mkdir -p "$HOME/.local/share/" || true
cp -r "$CONFIG_DIR/fonts" "$HOME/.local/share/" >

# Dar permisos de ejecución a scripts 
echo "[+] Dando permisos de ejecución a launch.sh y cambiar_pantalla.sh..."
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true
chmod +x "$HOME/.config/polybar/scripts/ip-detect.sh" 2>/dev/null || true

# Recargar configuración de zsh si está instalada
if [ -f "$HOME/.zshrc" ]; then
    echo "[+] Ejecutando source ~/.zshrc..."
    source "$HOME/.zshrc" || true
fi

# Si existe configuración de Powerlevel10k
if [ -f "$HOME/.p10k.zsh" ]; then
    echo "[+] Ejecutando source ~/.p10k.zsh..."
    source "$HOME/.p10k.zsh" || true
fi

echo -e "${GREEN}[✔] Configuración copiada correctamente. ¡Listo para usar!${RESET}"
