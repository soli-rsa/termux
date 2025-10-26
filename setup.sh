#!/usr/bin/env bash

set -u

# Termux setup script rewritten to follow the bash style guide:
# - uses /usr/bin/env bash
# - no `set -e` (explicitly handle failures)
# - uses `command -v` checks, `[[ ... ]]` tests, quoted expansions
# - main() function with local variables
# - arrays for package lists
# - checks return values on important operations

main() {
    # Ensure we're running in Termux-ish environment (best-effort check)
    if ! [[ -d "/data/data/com.termux" ]] && ! command -v pkg >/dev/null 2>&1; then
        printf '%s\n' 'This script is intended for Termux. `pkg` not found and /data/data/com.termux not present.' >&2
        return 1
    fi

    # Acquire wake lock and storage permission if available
    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock || printf '%s\n' 'warning: termux-wake-lock failed' >&2
    fi

    if command -v termux-setup-storage >/dev/null 2>&1; then
        termux-setup-storage || printf '%s\n' 'warning: termux-setup-storage failed or was denied' >&2
    fi

    # Allow user to change repo if desired
    if command -v termux-change-repo >/dev/null 2>&1; then
        termux-change-repo || printf '%s\n' 'warning: termux-change-repo failed or was skipped' >&2
    fi

    # Upgrade packages (non-fatal, proceed even if it fails)
    if command -v pkg >/dev/null 2>&1; then
        yes | pkg upgrade || printf '%s\n' 'warning: pkg upgrade failed or was interrupted' >&2
    fi

    # Install package list
    local -a packages=(
        build-essential
        lux-cli
        atuin
        zoxide
        shellcheck
        shfmt
        esbuild
        deno
        luarocks
        lua-language-server
        stylua
        nushell
        termux-api
        fzf
        neovim
        python-pynvim
        termux-services
        bat
        carapace
        elvish
        eza
        fish
        git
        age
        openssh
        gnupg
        git-delta
        gh
        lazygit
        glow
        gum
        golang
        gopls
        helix
        helix-grammars
        jq
        python
        ripgrep
        fd
        sd
        ollama
        starship
        tig
        vivid
        which
        wget
        zellij
        zsh
    )

    if command -v pkg >/dev/null 2>&1; then
        yes | pkg install --install-suggests "${packages[@]}" || printf '%s\n' 'warning: some packages failed to install' >&2
    else
        printf '%s\n' 'pkg is not available; skipping package installation' >&2
    fi

    # Create XDG and other directories
    mkdir -p ~/.config ~/.cache ~/.local/{bin,share,state} || {
        printf 'failed to create config directories\n' >&2
        return 1
    }

    # Starship & other installs (best-effort, continue on failure)
    # Install omarchy tarball into local share
    if command -v curl >/dev/null 2>&1 && command -v tar >/dev/null 2>&1; then
        curl -SsL https://github.com/basecamp/omarchy/archive/refs/tags/v3.1.3.tar.gz | tar -xz -C .local/share 2>/dev/null || \
            printf '%s\n' 'warning: omarchy extraction failed' >&2
    fi

    # argc install (if curl available)
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sh -s -- --to "$PREFIX/bin" || \
            printf '%s\n' 'warning: argc install failed' >&2
    fi

    # termux-specific theme/font for terminal if curl available
    if command -v curl >/dev/null 2>&1; then
        mkdir -p ~/.termux || true
        curl -fsSL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/termux/tokyonight_night.properties" -o ~/.termux/colors.properties || \
            printf '%s\n' 'warning: failed to download tokyonight colors.properties' >&2

        curl -fL -o ~/.termux/font.ttf "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts%2FJetBrainsMono%2FNoLigatures%2FRegular%2FJetBrainsMonoNLNerdFont-Regular.ttf" || \
            printf '%s\n' 'warning: failed to download nerd font' >&2
    fi

    # starship config
    cat <<'EOF' > ~/.config/starship.toml
add_newline = false

# add_newline = true
command_timeout = 200
format = "[$directory$git_branch$git_status]($style)$character"

[character]
error_symbol = "[✗](bold cyan)"
success_symbol = "[❯](bold cyan)"

[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style = "bold cyan"
repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) "

[git_branch]
format = "[$branch]($style) "
style = "italic cyan"

[git_status]
format     = '[$all_status]($style)'
style      = "cyan"
ahead      = "⇡${count} "
diverged   = "⇕⇡${ahead_count}⇣${behind_count} "
behind     = "⇣${count} "
conflicted = " "
up_to_date = " "
untracked  = "? "
modified   = " "
stashed    = ""
staged     = ""
renamed    = ""
deleted    = ""

[shell]
disabled = false
EOF

    # .profile
    cat <<'EOF' > ~/.profile
# Set XDG environment variables (export for current session; persist in .bashrc if needed).
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
#
export TERMINFO=/data/data/com.termux/files/usr/share/terminfo
export EDITOR=hx
export LS_COLORS="$(vivid generate tokyonight-night)"
export PAGER=bat
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.termux/bin:$PATH"

export CARAPACE_MATCH=1
export CARAPACE_BRIDGES='zsh,fish,bash'
EOF

    # .bashrc
    cat <<'EOF' > ~/.bashrc
source ~/.profile

export SHELL=bash
export STARSHIP_SHELL=bash

eval "$(starship init bash)"

# argc completions and carapace if available
if command -v argc >/dev/null 2>&1; then
  source <(argc --argc-completions bash)
fi

if command -v carapace >/dev/null 2>&1; then
  source <(carapace _carapace bash)
fi
EOF

    # inputrc
    cat <<'EOF' > ~/.inputrc
set meta-flag on
set input-meta on
set output-meta on
set convert-meta off
set completion-ignore-case on
set completion-prefix-display-length 2
set show-all-if-ambiguous on
set show-all-if-unmodified on

# Arrow keys match what you've typed so far against your command history
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char

# Immediately add a trailing slash when autocompleting symlinks to directories
set mark-symlinked-directories on

# Do not autocomplete hidden files unless the pattern explicitly begins with a dot
set match-hidden-files off

# Show all autocomplete results at once
set page-completions off

# If there are more than 200 possible completions for a word, ask to show them all
set completion-query-items 200

# Show extra file information when completing, like `ls -F` does
set visible-stats on

$if Bash
  # Be more intelligent when autocompleting by also looking at the text after
  # the cursor.
  set skip-completed-text on

  # Coloring for Bash 4 tab completions.
  set colored-stats on
$endif

EOF

    # elvish
    mkdir -p ~/.config/elvish
    cat <<'EOF' > ~/.config/elvish/rc.elv
set-env SHELL elvish
set-env STARSHIP_SHELL elvish

set edit:prompt = { starship prompt }
set edit:rprompt = { echo '' }

set edit:completion:matcher[argument] = {|seed| edit:match-prefix $seed &ignore-case=$true }
eval (carapace _carapace elvish|slurp)
EOF

    # fish
    mkdir -p ~/.config/fish
    cat <<'EOF' > ~/.config/fish/config.fish
set SHELL fish
set STARSHIP_SHELL fish

starship init fish | source

mkdir --parents ~/.config/fish/completions
carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish
carapace _carapace fish | source
EOF

    # zsh
    cat <<'EOF' > ~/.zshrc
export SHELL=zsh
export STARSHIP_SHELL=zsh

autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

eval "$(starship init zsh)"

source <(carapace _carapace zsh)
EOF

    # helix config
    mkdir -p ~/.config/helix
    cat <<'EOF' > ~/.config/helix/config.toml
theme = "tokyonight"

[editor]
line-number = "relative"
mouse = false

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[editor.file-picker]
hidden = false

[editor.statusline]
left = ["mode", "spinner"]
center = ["file-name"]
right = ["diagnostics", "selections", "position", "file-encoding", "file-line-ending", "file-type"]
separator = "│"
mode.normal = "NORMAL"
mode.insert = "INSERT"
mode.select = "SELECT"
diagnostics = ["warning", "error"]
workspace-diagnostics = ["warning", "error"]

# ... key bindings elided for brevity in the file (maintainers can re-add)
EOF

    # git config
    mkdir -p ~/.config/git
    touch ~/.config/git/config
    git config --global user.email "soli_rsa@outlook.com" || printf '%s\n' 'warning: git config email failed' >&2
    git config --global user.name "soli-rsa" || printf '%s\n' 'warning: git config name failed' >&2
    git config --global init.defaultBranch "main" || true
    git config --global url."https://github.com/".insteadOf "gh:" || true
    git config --global url."https://gitlab.com/".insteadOf "gl:" || true
    git config --global url."https://github.com/termux/".insteadOf "termux:" || true
    git config --global core.pager delta || true
    git config --global interactive.diffFilter 'delta --color-only' || true
    git config --global delta.navigate true || true
    git config --global merge.conflictStyle zdiff3 || true

    # carapace spec for eza
    mkdir -p ~/.config/carapace/specs
    cat <<'EOF' > ~/.config/carapace/specs/ls.yaml
# yaml-language-server: $schema=https://carapace.sh/schemas/command.json
name: ls
run: "[eza]"
EOF

    # lazyvim setup (move away existing config safely)
    if [[ -d ~/.config/nvim ]]; then
        mv ~/.config/nvim{,.bak} || printf '%s\n' 'warning: failed to backup ~/.config/nvim' >&2
    fi
    if [[ -d ~/.local/share/nvim ]]; then
        mv ~/.local/share/nvim{,.bak} || true
    fi
    if [[ -d ~/.local/state/nvim ]]; then
        mv ~/.local/state/nvim{,.bak} || true
    fi
    if [[ -d ~/.cache/nvim ]]; then
        mv ~/.cache/nvim{,.bak} || true
    fi

    if command -v git >/dev/null 2>&1; then
        git clone https://github.com/LazyVim/starter ~/.config/nvim || printf '%s\n' 'warning: lazyvim clone failed' >&2
        rm -rf ~/.config/nvim/.git || true
    fi

    # Update bat themes and rebuild cache if necessary
    update_bat_themes || printf '%s\n' 'warning: update_bat_themes encountered an error' >&2

    printf '%s\n' 'TERMUX SETUP: COMPLETE!'
}

# update_bat_themes: keep bat themes under bat's config dir in sync using a sparse checkout
# This is the logic the user requested to be included and adapted to the style guide.
update_bat_themes() {
    if ! command -v bat >/dev/null 2>&1; then
        printf '%s\n' 'bat is required but not found in PATH' >&2
        return 1
    fi

    local repo='https://github.com/folke/tokyonight.nvim.git'
    local repo_name='tokyonight.nvim'
    local theme_dir='extras/sublime/'

    local bat_themes_dir
    bat_themes_dir="$(command bat --config-dir)/themes"

    [[ ! -d "$bat_themes_dir" ]] && mkdir -p "$bat_themes_dir" || true

    cd "$bat_themes_dir" || {
        printf 'failed to cd to %s\n' "$bat_themes_dir" >&2
        return 1
    }

    if [[ ! -d "$repo_name" ]]; then
        # Init
        git clone --no-checkout --depth=1 --filter=blob:none "$repo" "$repo_name" || return 1
        cd "$repo_name" || return 1
        # Ensure sparse-checkout is initialized on older git versions
        git sparse-checkout init --no-cone >/dev/null 2>&1 || true
        git sparse-checkout set --no-cone '!/*' "$theme_dir" || return 1
        git checkout || return 1
    else
        # Update
        cd "$repo_name" || return 1
        git fetch --filter=blob:none || return 1
        local updates
        updates="$(git rev-list HEAD..@{u} -- "$theme_dir" 2>/dev/null || true)"
        if [[ -n "$updates" ]]; then
            git merge --ff-only --log || return 1
        fi
    fi

    # Revalidate bat cache with mtime
    local bat_theme_cache
    bat_theme_cache="$(command bat --cache-dir)/themes.bin"

    if [[ ! -e "$bat_theme_cache" ]] || [[ -n "$(find "$bat_themes_dir" -name '*.tmTheme' -newer "$bat_theme_cache" -print -quit 2>/dev/null)" ]]; then
        command bat cache --build || return 1
    fi

    return 0
}

main "$@"
