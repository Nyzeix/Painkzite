#!/bin/bash

# Status in Min:Sec 
current_status="$(date -u -d @$(playerctl position) +"%M:%S" | head -c -1)"

playerctl_metadata="$(echo $(($(playerctl metadata mpris:length)/1000000)) | head -c -1)"
total="$(date -u -d @$playerctl_metadata +"%M:%S" | head -c -1)"

tooltip="$(echo -n $current_status / $total | jq -R -s '.')"

# Audio played
audio_played="$(playerctl metadata --format '{{ artist }} - {{ title }}' | head -c -1 | jq -R -s '.')"

echo "{\"text\":$audio_played, \"tooltip\":$tooltip}"