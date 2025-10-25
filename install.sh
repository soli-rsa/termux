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
termux-wake-lock && termux-setup-storage
termux-change-repo && yes | pkg upgrade
yes | pkg install --install-suggests \
                  build-essential \
                  lux-cli \
                  atuin \
                  zoxide \
                  shellcheck \
                  shfmt \
                  esbuild \
                  deno \
                  luarocks \
                  lua-language-server \
                  stylua \
                  nushell \
                  termux-api \
                  fzf \
                  neovim \
                  python-pynvim \
                  termux-services \
                  bat \
                  carapace \
                  elvish \
                  eza \
                  fish \
                  git \
                  age \
                  openssh \
                  gnupg \
                  git-delta \
                  gh \
                  lazygit \
                  glow \
                  gum \
                  golang \
                  gopls \
                  helix \
                  helix-grammars \
                  jq \
                  python \
                  ripgrep \
                  fd \
                  sd \
                  ollama \
                  starship \
                  tig \
                  vivid \
                  which \
                  wget \
                  zellij \
                  zsh

# starship
mkdir --parents ~/.config ~/.cache ~/.local/{bin,share,state}

curl -SsL https://github.com/basecamp/omarchy/archive/refs/tags/v3.1.3.tar.gz | tar -xz -C .local/share
curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sh -s -- --to $PREFIX/bin

curl -fsSL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/termux/tokyonight_night.properties" -o ~/.termux/colors.properties
curl -o ~/.termux/font.ttf -fL https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts%2FJetBrainsMono%2FNoLigatures%2FRegular%2FJetBrainsMonoNLNerdFont-Regular.ttf

# curl -fLO https://github.com/skim-rs/skim/releases/download/v0.20.5/skim-aarch64-unknown-linux-musl.tgz

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

# bash
cat <<'EOF' > ~/.bashrc
source ~/.profile

export SHELL=bash
export STARSHIP_SHELL=bash

eval "$(starship init bash)"

source <(argc --argc-completions bash)
source <(carapace _carapace bash)
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
  # the cursor. For example, when the current line is "cd ~/src/mozil", and
  # the cursor is on the "z", pressing Tab will not autocomplete it to "cd
  # ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
  # Readline used by Bash 4.)
  set skip-completed-text on

  # Coloring for Bash 4 tab completions.
  set colored-stats on
$endif

EOF

# elvish
mkdir --parents ~/.config/elvish
cat <<'EOF' > ~/.config/elvish/rc.elv
set-env SHELL elvish
set-env STARSHIP_SHELL elvish

set edit:prompt = { starship prompt }
set edit:rprompt = { echo '' }

set edit:completion:matcher[argument] = {|seed| edit:match-prefix $seed &ignore-case=$true }
eval (carapace _carapace elvish|slurp)
EOF

# fish
mkdir --parents ~/.config/fish
cat <<'EOF' > ~/.config/fish/config.fish
set SHELL fish
set STARSHIP_SHELL fish

starship init fish | source

mkdir --parents ~/.config/fish/completions
carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish
carapace _carapace fish | source
EOF

# zsh
# shellcheck disable=SC2028
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

# helix
mkdir --parents ~/.config/helix
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

[keys.normal]
# Quick iteration on config changes
C-o = ":config-open"
C-r = ":config-reload"

# Some nice Helix stuff
C-h = "select_prev_sibling"
C-j = "shrink_selection"
C-k = "expand_selection"
C-l = "select_next_sibling"

# Personal preference
o = ["open_below", "normal_mode"]
O = ["open_above", "normal_mode"]

# Muscle memory
"{" = ["goto_prev_paragraph", "collapse_selection"]
"}" = ["goto_next_paragraph", "collapse_selection"]
0 = "goto_line_start"
"$" = "goto_line_end"
"^" = "goto_first_nonwhitespace"
G = "goto_file_end"
"%" = "match_brackets"
V = ["select_mode", "extend_to_line_bounds"]
C = ["extend_to_line_end", "yank_main_selection_to_clipboard", "delete_selection", "insert_mode"]
D = ["extend_to_line_end", "yank_main_selection_to_clipboard", "delete_selection"]
S = "surround_add" # Would be nice to be able to do something after this but it isn't chainable

# Clipboards over registers ye ye
x = "delete_selection"
p = ["paste_clipboard_after", "collapse_selection"]
P = ["paste_clipboard_before", "collapse_selection"]
# Would be nice to add ya and yi, but the surround commands can't be chained
Y = ["extend_to_line_end", "yank_main_selection_to_clipboard", "collapse_selection"]

# Uncanny valley stuff, this makes w and b behave as they do Vim
w = ["move_next_word_start", "move_char_right", "collapse_selection"]
W = ["move_next_long_word_start", "move_char_right", "collapse_selection"]
e = ["move_next_word_end", "collapse_selection"]
E = ["move_next_long_word_end", "collapse_selection"]
b = ["move_prev_word_start", "collapse_selection"]
B = ["move_prev_long_word_start", "collapse_selection"]

# If you want to keep the selection-while-moving behaviour of Helix, this two lines will help a lot,
# especially if you find having text remain selected while you have switched to insert or append mode
#
# There is no real difference if you have overridden the commands bound to 'w', 'e' and 'b' like above
# But if you really want to get familiar with the Helix way of selecting-while-moving, comment the
# bindings for 'w', 'e', and 'b' out and leave the bindings for 'i' and 'a' active below. A world of difference!
i = ["insert_mode", "collapse_selection"]
a = ["append_mode", "collapse_selection"]

# Undoing the 'd' + motion commands restores the selection which is annoying
u = ["undo", "collapse_selection"]

# Escape the madness! No more fighting with the cursor! Or with multiple cursors!
esc = ["collapse_selection", "keep_primary_selection"]

# Search for word under cursor
"*" = ["move_char_right", "move_prev_word_start", "move_next_word_end", "search_selection", "search_next"]
"#" = ["move_char_right", "move_prev_word_start", "move_next_word_end", "search_selection", "search_prev"]

# Make j and k behave as they do Vim when soft-wrap is enabled
j = "move_line_down"
k = "move_line_up"

# Extend and select commands that expect a manual input can't be chained
# I've kept d[X] commands here because it's better to at least have the stuff you want to delete
# selected so that it's just a keystroke away to delete
[keys.normal.d]
d = ["extend_to_line_bounds", "yank_main_selection_to_clipboard", "delete_selection"]
t = ["extend_till_char"]
s = ["surround_delete"]
i = ["select_textobject_inner"]
a = ["select_textobject_around"]
j = ["select_mode", "extend_to_line_bounds", "extend_line_below", "yank_main_selection_to_clipboard", "delete_selection", "normal_mode"]
down = ["select_mode", "extend_to_line_bounds", "extend_line_below", "yank_main_selection_to_clipboard", "delete_selection", "normal_mode"]
k = ["select_mode", "extend_to_line_bounds", "extend_line_above", "yank_main_selection_to_clipboard", "delete_selection", "normal_mode"]
up = ["select_mode", "extend_to_line_bounds", "extend_line_above", "yank_main_selection_to_clipboard", "delete_selection", "normal_mode"]
G = ["select_mode", "extend_to_line_bounds", "goto_last_line", "extend_to_line_bounds", "yank_main_selection_to_clipboard", "delete_selection", "normal_mode"]
w = ["move_next_word_start", "yank_main_selection_to_clipboard", "delete_selection"]
W = ["move_next_long_word_start", "yank_main_selection_to_clipboard", "delete_selection"]
g = { g = ["select_mode", "extend_to_line_bounds", "goto_file_start", "extend_to_line_bounds", "yank_main_selection_to_clipboard", "delete_selection", "normal_mode"] }

[keys.normal.y]
y = ["extend_to_line_bounds", "yank_main_selection_to_clipboard", "normal_mode", "collapse_selection"]
j = ["select_mode", "extend_to_line_bounds", "extend_line_below", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"]
down = ["select_mode", "extend_to_line_bounds", "extend_line_below", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"]
k = ["select_mode", "extend_to_line_bounds", "extend_line_above", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"]
up = ["select_mode", "extend_to_line_bounds", "extend_line_above", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"]
G = ["select_mode", "extend_to_line_bounds", "goto_last_line", "extend_to_line_bounds", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"]
w = ["move_next_word_start", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"]
W = ["move_next_long_word_start", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"]
g = { g = ["select_mode", "extend_to_line_bounds", "goto_file_start", "extend_to_line_bounds", "yank_main_selection_to_clipboard", "collapse_selection", "normal_mode"] }

[keys.insert]
# Escape the madness! No more fighting with the cursor! Or with multiple cursors!
esc = ["collapse_selection", "normal_mode"]

[keys.select]
# Muscle memory
"{" = ["extend_to_line_bounds", "goto_prev_paragraph"]
"}" = ["extend_to_line_bounds", "goto_next_paragraph"]
0 = "goto_line_start"
"$" = "goto_line_end"
"^" = "goto_first_nonwhitespace"
G = "goto_file_end"
D = ["extend_to_line_bounds", "delete_selection", "normal_mode"]
C = ["goto_line_start", "extend_to_line_bounds", "change_selection"]
"%" = "match_brackets"
S = "surround_add" # Basically 99% of what I use vim-surround for
u = ["switch_to_lowercase", "collapse_selection", "normal_mode"]
U = ["switch_to_uppercase", "collapse_selection", "normal_mode"]

# Visual-mode specific muscle memory
i = "select_textobject_inner"
a = "select_textobject_around"

# Some extra binds to allow us to insert/append in select mode because it's nice with multiple cursors
tab = ["insert_mode", "collapse_selection"] # tab is read by most terminal editors as "C-i"
C-a = ["append_mode", "collapse_selection"]

# Make selecting lines in visual mode behave sensibly
k = ["extend_line_up", "extend_to_line_bounds"]
j = ["extend_line_down", "extend_to_line_bounds"]

# Clipboards over registers ye ye
d = ["yank_main_selection_to_clipboard", "delete_selection"]
x = ["yank_main_selection_to_clipboard", "delete_selection"]
y = ["yank_main_selection_to_clipboard", "normal_mode", "flip_selections", "collapse_selection"]
Y = ["extend_to_line_bounds", "yank_main_selection_to_clipboard", "goto_line_start", "collapse_selection", "normal_mode"]
p = "replace_selections_with_clipboard" # No life without this
P = "paste_clipboard_before"

# Escape the madness! No more fighting with the cursor! Or with multiple cursors!
esc = ["collapse_selection", "keep_primary_selection", "normal_mode"]
EOF

# .gitconfig
mkdir -p ~/.config/git
touch ~/.config/git/config
git config --global user.email "soli_rsa@outlook.com"
git config --global user.name "soli-rsa"
git config --global init.defaultBranch "main"
git config --global url."https://github.com/".insteadOf "gh:"
git config --global url."https://gitlab.com/".insteadOf "gl:"
git config --global url."https://github.com/termux/".insteadOf "termux:"
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

# eza alias
mkdir --parents ~/.config/carapace/specs
cat <<'EOF' > ~/.config/carapace/specs/ls.yaml
# yaml-language-server: $schema=https://carapace.sh/schemas/command.json
name: ls
run: "[eza]"
EOF


# lazyvim
# required
mv ~/.config/nvim{,.bak}
# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo 'TERMUX SETUP: COMPLETE!'
