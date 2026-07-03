#!/bin/bash

# This script is used to allow a "theme rebuild" when the wallpaper is updated.
# To update wallpaper, only use this script.


current_wp_sl="$HOME/.local/state/current-wallpaper"
current_wp_index_file="$HOME/.local/state/current-wallpaper.index"


SCI=1

if [ $# -eq 1 ]; then
    WALLPAPER="$1"

    # UPDATE SYMLINK
    ln -sfn "$WALLPAPER" "$current_wp_sl"
    SCI=$(cat "$current_wp_index_file")
fi

if [ $# -eq 2 ]; then
    WALLPAPER="$1"

    # UPDATE SYMLINK
    ln -sfn "$WALLPAPER" "$current_wp_sl"
    # Update color index
    echo -n "$SCI" > "$current_wp_index_file"

    SCI=$2
fi
if [ $# -gt 2 ]; then
    echo "Only one or two argument is required"
fi

# CALL MATUGEN
matugen image "$(readlink -f $current_wp_sl)" \
    -c /usr/share/desktop-config/matugen/config.toml \
    --source-color-index "$SCI"

# MATUGEN DOES ALL
# Update wallpaper
# generate theme