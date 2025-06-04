#!/bin/bash

# Clonar genxwm si no existe
if [ ! -d "$HOME/.config/genxwm" ]; then
    git clone https://github.com/IamGenarov/genxwm.git --depth 1 "$HOME/.config/genxwm"
fi

# Crear carpetas necesarias
mkdir -p "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/neofetch"
mkdir -p "$HOME/.config/rofi/themes"
mkdir -p "$HOME/.config/bar/bar-themes"
mkdir -p "$HOME/Pictures/.wallpapers"

# Mover archivos de configuración
mv -v "$HOME/alacritty.toml" "$HOME/.config/alacritty/" 2>/dev/null
mv -v "$HOME/config.conf" "$HOME/.config/neofetch/" 2>/dev/null
mv -v "$HOME/config.rasi" "$HOME/.config/rofi/themes/" 2>/dev/null

# Mover scripts y config personales
mv -v "$HOME/.cambiar_fondo.sh" "$HOME/.p10k.zsh" "$HOME/.zshrc" "$HOME/" 2>/dev/null

# Mover bar y scripts
mv -v "$HOME/bar.sh" "$HOME/run.sh" "$HOME/.config/bar/" 2>/dev/null

# Mover temas de barra
if [ -d "$HOME/bar-themes" ]; then
    mv -v "$HOME/bar-themes/"* "$HOME/.config/bar/bar-themes/" 2>/dev/null
    rm -r "$HOME/bar-themes"
fi

# Mover fondo de pantalla
mv -v "$HOME/fp"*.png "$HOME/Pictures/.wallpapers/" 2>/dev/null

# Mover otros archivos
[ -f "$HOME/gvn.txt" ] && mv -v "$HOME/gvn.txt" "$HOME/Documentos/" 2>/dev/null

echo "✅ Organización completada."
