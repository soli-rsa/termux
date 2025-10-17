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
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
#            │                │            └system installation (e.g. /usr/bin/carapace)
#            │                └selfupdate/go based installation ($GOBIN)
#            └user binaries

#
export TERMINFO=/data/data/com.termux/files/usr/share/terminfo
#
curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sh -s -- --to $PREFIX/bin

curl -fsSL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/termux/tokyonight_night.properties" -o ~/.termux/colors.properties

curl -o ~/.termux/font.ttf -fL https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts%2FJetBrainsMono%2FNoLigatures%2FRegular%2FJetBrainsMonoNLNerdFont-Thin.ttf

curl -fLO https://github.com/skim-rs/skim/releases/download/v0.20.5/skim-aarch64-unknown-linux-musl.tgz
#
termux-wake-lock && termux-setup-storage
termux-change-repo && yes | pkg upgrade --install-suggests -y bat carapace eza git git-delta gh golang gopls helix helix-grammars jq python ripgrep starship lazygit direnv chezmoi gum glow nodejs neovim shellcheck shfmt vivid which wget zsh fd fzf aichat ollama lua-language-server luajit luarocks stylua build-essential rust rust-analyzer esbuild man tealdeer uv ruff fastfetch zellij marksman nushell

git config --global user.email "soli_rsa@outlook.com"
git config --global user.name "soli-rsa"
git config --global init.defaultBranch "main"
#
git config --global url."https://github.com/".insteadOf "gh:"
git config --global url."https://gitlab.com/".insteadOf "gl:"
#
git config --global url."https://github.com/termux/".insteadOf "termux:"
#
echo "DONE!"
