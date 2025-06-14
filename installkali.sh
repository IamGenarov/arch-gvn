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
sudo apt update -y
sudo apt install -y curl git

# 1. Xorg y entorno gráfico mínimo
echo "[+] Instalando Xorg y Xinit..."
sudo apt install -y xorg xinit

# 2. Terminal: Alacritty
echo "[+] Instalando Alacritty..."
sudo apt install -y alacritty

# 3. LightDM
echo "[+] Instalando y habilitando LightDM..."
sudo apt install -y lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm

# .xinitrc
echo "exec i3" > ~/.xinitrc

# 4. i3-gaps
echo "[+] Instalando i3-gaps..."
sudo apt remove -y i3
sudo apt install -y i3-wm i3-gaps

# 5. Polybar
echo "[+] Instalando Polybar..."
sudo apt install -y polybar

# 6. Fuentes necesarias
echo "[+] Instalando fuentes..."
sudo apt install -y \
    fonts-font-awesome \
    fonts-powerline \
    fonts-hack-ttf \
    fonts-jetbrains-mono \
    fonts-terminus \
    fonts-noto-color-emoji

# 7. Zsh y mejoras visuales
echo "[+] Instalando Zsh..."
sudo apt install -y zsh
chsh -s /bin/zsh

# 8. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Instalando Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 9. Powerlevel10k
echo "[+] Instalando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 10. Plugins Zsh
echo "[+] Instalando plugins Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 11. Utilidades adicionales
echo "[+] Instalando utilidades: rofi, feh, nano..."
sudo apt install -y rofi feh nano flameshot xclip network-manager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

echo "[✔] Todo listo. Dependencias y utilidades instaladas correctamente."

# -------------------------
# CLONACIÓN Y CONFIGURACIÓN
# -------------------------

CONFIG_DIR="$HOME/.config/i3naro_temp"
if [ -d "$CONFIG_DIR" ]; then
    echo "[!] El directorio temporal $CONFIG_DIR ya existe. Eliminando..."
    rm -rf "$CONFIG_DIR"
fi

echo "[+] Clonando repositorio i3naro..."
git clone https://github.com/IamGenarov/i3naro.git "$CONFIG_DIR"

echo "[+] Copiando configuración a ~/.config/ ..."
mkdir -p "$HOME/.config"
cp -r "$CONFIG_DIR/HOME/.config/"* "$HOME/.config/" 2>/dev/null

echo "[+] Copiando archivos ocultos de HOME..."
cp "$CONFIG_DIR/HOME/."* "$HOME/" 2>/dev/null

cp "$CONFIG_DIR/i3/"* "$HOME/.config/i3/" 2>/dev/null

# Crear carpetas estándar
echo "[+] Creando carpetas estándar..."
mkdir -p "$HOME/Documents" "$HOME/Pictures/.wallpapers" "$HOME/Downloads" "$HOME/Music" "$HOME/Videos" "$HOME/Pictures/Clipboard"

echo "[+] Copiando wallpapers a ~/Pictures/.wallpapers ..."
cp -r "$CONFIG_DIR/wallpapers/"* "$HOME/Pictures/.wallpapers/" 2>/dev/null

echo "[+] Limpieza del directorio temporal..."
rm -rf "$CONFIG_DIR"

echo "[+] Copiando fuentes locales..."
mkdir -p "$HOME/.local/share/"
cp -r "$CONFIG_DIR/fonts" "$HOME/.local/share/" 2>/dev/null

# Dar permisos de ejecución a scripts 
echo "[+] Dando permisos de ejecución a launch.sh y cambiar_pantalla.sh..."
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null
chmod +x "$HOME/.config/polybar/scripts/ip-detect.sh" 2>/dev/null

# Recargar configuración de zsh si está instalada
if [ -f "$HOME/.zshrc" ]; then
    echo "[+] Ejecutando source ~/.zshrc..."
    source "$HOME/.zshrc"
fi

# Si existe configuración de Powerlevel10k
if [ -f "$HOME/.p10k.zsh" ]; then
    echo "[+] Ejecutando source ~/.p10k.zsh..."
    source "$HOME/.p10k.zsh"
fi

echo -e "${GREEN}[✔] Configuración copiada correctamente. ¡Listo para usar!${RESET}"
