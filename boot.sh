#!/data/data/com.termux/files/usr/bin/bash
# set -e

clear 
echo " _____ ______________  ____   ___   __";
echo "|_   _|  ___| ___ \\  \\/  | | | \\ \\ / /";
echo "  | | | |__ | |_/ / .  . | | | |\\ V / ";
echo "  | | |  __||    /| |\\/| | | | |/   \\ ";
echo "  | | | |___| |\\ \\| |  | | |_| / /^\\ \\";
echo "  \\_/ \\____/\\_| \\_\\_|  |_/\\___/\\/   \\/";
echo "                                      ";
echo "                                      ";

# Set XDG environment variables (export for current session; persist in .bashrc if needed).
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
#
export TERMINFO=/data/data/com.termux/files/usr/share/terminfo
#
# curl -fLO https://github.com/skim-rs/skim/releases/download/v0.20.5/skim-aarch64-unknown-linux-musl.tgz
#
termux-wake-lock && termux-setup-storage
termux-change-repo && yes | pkg upgrade --install-suggests -y chezmoi openssh gnupg lazygit gum glow termux-services termux-api neovim lua-language-server luarocks lux-cli ripgrep

git config --global user.email "soli_rsa@outlook.com"
git config --global user.name "soli-rsa"
git config --global init.defaultBranch "main"
#
git config --global url."https://github.com/".insteadOf "gh:"
git config --global url."https://gitlab.com/".insteadOf "gl:"
#
git config --global url."https://github.com/termux/".insteadOf "termux:"
#
