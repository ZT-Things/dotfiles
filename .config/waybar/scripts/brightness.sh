#!/bin/bash

path="/sys/class/backlight/nvidia_wmi_ec_backlight"

if [[ -r "$path/brightness" && -r "$path/max_brightness" ]]; then
    current=$(<"$path/brightness")
    max=$(<"$path/max_brightness")

    if [[ $max -gt 0 ]]; then
        percent=$(( 100 * current / max ))
        echo "{\"text\": \"  ${percent}%\", \"tooltip\": \"Brightness: $current / $max\"}"
    else
        echo "{\"text\": \"  --\", \"tooltip\": \"Invalid max brightness\"}"
    fi
else
    echo "{\"text\": \"  --\", \"tooltip\": \"No brightness info\"}"
fi

