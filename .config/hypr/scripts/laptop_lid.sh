#!/bin/bash
LID_STATE=$(cat /proc/acpi/button/lid/LID/state | grep -o 'open\|closed')
if [ "$LID_STATE" = "closed" ]; then
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprctl keyword monitor "eDP-1, preferred, auto, auto"
fi
