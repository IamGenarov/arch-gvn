#!/bin/dash
. ~/.config/chadwm/scripts/bar-themes/chiwiwi

battery() {
    cap="$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)"
    icon=""
    printf "^c$red_icon_fg^^b$red_icon_bg^ $icon "
    printf "^c$red_value_fg^^b$red_value_bg^ %s%% " "$cap"
}

clock() {
    icon="󱑆"
    time="$(date '+%H:%M')"
    printf "^c$red_icon_fg^^b$red_icon_bg^ $icon "
    printf "^c$red_value_fg^^b$red_value_bg^ %s " "$time"
}

while :; do
    xsetroot -name "$(battery) $(clock)"
    sleep 1
done
