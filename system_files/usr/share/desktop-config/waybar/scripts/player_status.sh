#!/bin/bash

if ! playerctl position >/dev/null 2>&1; then
    echo "Aucun média joué"
else
    # Status in MM:SS
    current_status=$(date -u -d "@$(playerctl position)" +"%M:%S")

    # Total nedai duration(converted in SS)
    playerctl_metadata=$(( $(playerctl metadata mpris:length) / 1000000 ))

    # Total media duration in MM:SS
    total=$(date -u -d "@$playerctl_metadata" +"%M:%S")

    # Final value to show in tooltip
    tooltip="$current_status / $total"

    # Média en cours
    audio_played=$(playerctl metadata --format '{{ artist }} - {{ title }}')

    # Data output
    jq -cn \
    --arg text "$audio_played" \
    --arg tooltip "$tooltip" \
    '{text: $text, tooltip: $tooltip}'
fi