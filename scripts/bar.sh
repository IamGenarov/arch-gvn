#!/bin/dash
. ~/.config/chadwm/scripts/bar_themes/onedark

battery() {
    cap="$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)"
    icon=""
    printf "^c$black^^b$darkblue^ $icon "
    printf "^c$black^^b$blue^ %s%% " "$cap"
}

clock() {
    printf "^c$black^^b$darkblue^ 󱑆 "
    printf "^c$black^^b$blue^ %s " "$(date '+%H:%M')"
}

while :; do
    sleep 1
    xsetroot -name "\
$(battery)\
$(clock)"
done
