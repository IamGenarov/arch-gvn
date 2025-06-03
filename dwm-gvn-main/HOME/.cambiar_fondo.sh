#!/bin/bash

CARPETA="$HOME/Pictures/.wallpapers"
IMAGENES=("fp1.png" "fp2.png" "fp3.png" "fp4.png")

while true; do
  for img in "${IMAGENES[@]}"; do
    feh --bg-scale "$CARPETA/$img"
    sleep 10
  done
done
