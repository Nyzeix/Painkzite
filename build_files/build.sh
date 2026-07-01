#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /


# RELEASE="$(rpm -E %fedora)"

log() {
	echo "=== $* ==="
}


#######################################################################
# Setup Repositories
#######################################################################

log "Enable Copr repos..."
COPR_REPOS=(
	erikreider/SwayNotificationCenter # for swaync
	errornointernet/packages
	heus-sueh/packages                # for matugen/swww, needed by hyprpanel
	leloubil/wl-clip-persist
	# pgdev/ghostty
	tofik/sway
	ulysg/xwayland-satellite
	#yalter/niri

	che/nerd-fonts
	
	# Caelestia
	#errornointernet/quickshell
	#celestelove/libcava
	#celestelove/app2unit
	#brycensranch/gpu-screen-recorder-git
	#celestelove/caelestia

	lionheartp/Hyprland
	quadratech188/vicinae # Raycast inspired launcher 
)

for repo in "${COPR_REPOS[@]}"; do
	# Try to enable the repo, but don't fail the build if it doesn't support this Fedora version
	if ! dnf5 -y copr enable "$repo" 2>&1; then
		log "Warning: Failed to enable COPR repo $repo (may not support Fedora $RELEASE)"
	fi
done

# log "Enable native terra repositories..."
# Bazzite disabled this for some reason so lets re-enable it again
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1

#log "Enable Terra repository..."
# Ajout indispensable pour Noctalia
# dnf5 -y install --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$(rpm -E %fedora)" terra-release

#######################################################################
## Install Packages
#######################################################################

# Note that these fedora font packages are preinstalled in the
# bluefin-dx image, along with the SymbolsNerdFont which doesn't
# have an associated fedora package:
#
#   adobe-source-code-pro-fonts
#   google-droid-sans-fonts
#   google-noto-sans-cjk-fonts
#   google-noto-color-emoji-fonts
#   jetbrains-mono-fonts
#
# Because the nerd font symbols are mapped correctly, we can get
# nerd font characters anywhere.
FONTS=(
	nerd-fonts
)
 
# Hyprland dependencies to be installed, based on
# https://github.com/JaKooLit/Fedora-Hyprland/ with additions
# from ml4w and other sources.
HYPR_DEPS=(
	aquamarine
	ags # A framework for crafting Wayland Desktop Shells
	blueman
	bluez
	bluez-tools
	brightnessctl
	btop
	cava
	cliphist # Historique presse papier
	#eog # Image viewer
	# fuzzel # App launcher
	gnome-bluetooth
	grim
	grimblast
	matugen
	mpv # VLC Like
	network-manager-applet
	nodejs
	nwg-look
	pamixer
	pavucontrol # Volume controller
	slurp
	swappy
	swaync
	# swww # Wallpaper manager (animation etc...)
	wallust # Adaptative color
	waybar
	wl-clipboard
	wl-clip-persist
	wlogout
	xarchiver
	xwayland-satellite
	yad
)

# Hyprland ecosystem packages
HYPR_PKGS=(
	hyprland
	hyprcursor
	hyprpaper
	hyprpicker
	hypridle
	hyprlock
	hyprshot
	xdg-desktop-portal-hyprland
	hyprsunset
	hyprshutdown
	hyprpwcenter
	hyprqt6engine
	hyprutils
	hyprsysteminfo
	hyprland-plugins
	hyprland-contrib
	hyprland-guiutils
	hyprpolkitagent
)

CAEL_DEPS=(
	quickshell-git
	libcava-devel
	app2unitlog "Enabling services..."
	gpu-screen-recorder-ui
)


# chrome etc are installed as flatpaks. We generally prefer that
# for most things with GUIs, and homebrew for CLI apps. This list is
# only special GUI apps that need to be installed at the system level.
ADDITIONAL_SYSTEM_APPS=(
	wireplumber
	qt6-qtwayland
	qt5-qtwayland
)

COOL_APPS=(
	zsh
	udiskie
	kitty
	vicinae
	#noctalia-shell
	#caelestia-shell caelestia-cli
)

# we do all package installs in one rpm-ostree command
# so that we create minimal layers in the final image
log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=True -y \
	"${FONTS[@]}" \
	"${SDDM_PACKAGES[@]}" \
	"${ADDITIONAL_SYSTEM_APPS[@]}" \
        "${COOL_APPS[@]}" \
	"${HYPR_DEPS[@]}" \
	"${HYPR_PKGS[@]}" \

#######################################################################
### Disable repositories so they aren't cluttering up the final image

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
	dnf5 -y copr disable "$repo"
done

log "Enabling services..."
ENABLED_SERVICES=(
	vicinae
	hyprpolkitagent
	hypridle
	hyprsunset
	hyprpaper
	waybar
)

#log "Enabling hyprpn plugins..."
#hyprpm add https://github.com/fedsfarm/gloview
#hyprpm enable gloview


for serv in "${ENABLED_SERVICES[@]}"; do
	systemctl --user --global enable "$serv"
done


