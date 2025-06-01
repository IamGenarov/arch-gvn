#!/bin/dash
. ~/.config/chadwm/scripts/bar-themes/chiwiwi

battery() {
    cap="$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)"
    icon=""
    printf "^c$red_icon_fg^^b$red_icon_bg^ $icon "
    printf "^c$red_value_fg^^b$red_value_bg^ %s%% " "$cap"
}

clock() {
    printf "^c$red_icon_fg^^b$red_icon_bg^ 󱑆 "
    printf "^c$red_value_fg^^b$red_value_bg^ %s " "$(date '+%H:%M')"
}

while :; do
    sleep 1
    xsetroot -name "\
$(battery)\
$(clock)"
done
