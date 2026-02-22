#!/bin/zsh

DOTFILES_DIR="$HOME/.dotfiles"
OS="$(uname -s)"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "dotfiles not found at $DOTFILES_DIR. Run install.zsh first."
    exit 1
fi

# ─── Load brew PATH (macOS) ───────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# ─── Update dotfiles repo ─────────────────────────────────────────────────────
echo "==> Updating dotfiles..."
git -C "$DOTFILES_DIR" pull --rebase

# ─── Update packages ──────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
    echo "==> Updating Homebrew packages..."
    brew update && brew upgrade
    brew upgrade --cask visual-studio-code iterm2 2>/dev/null || true

elif [[ "$OS" == "Linux" ]]; then
    echo "==> Updating apt packages..."
    sudo apt-get update && sudo apt-get upgrade -y
fi

# ─── Update Rust ──────────────────────────────────────────────────────────────
if command -v rustup &>/dev/null; then
    echo "==> Updating Rust..."
    rustup update
fi

# ─── Update/Install zprezto ───────────────────────────────────────────────────
ZPREZTO="${ZDOTDIR:-$HOME}/.zprezto"
if [ -d "$ZPREZTO" ]; then
    echo "==> Updating zprezto..."
    git -C "$ZPREZTO" pull --rebase
    git -C "$ZPREZTO" submodule update --init --recursive
else
    echo "==> Installing zprezto..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO"
fi

# ─── Re-apply zprezto runcoms symlinks ────────────────────────────────────────
echo "==> Re-linking zprezto runcoms..."
setopt EXTENDED_GLOB
for rcfile in "$DOTFILES_DIR/zprezto/runcoms/"^README.md(.N); do
    target="${ZDOTDIR:-$HOME}/.${rcfile:t}"
    [ -L "$target" ] && rm "$target"
    [ -f "$target" ] && mv "$target" "${target}.backup"
    ln -s "$rcfile" "$target"
    echo "  linked: .${rcfile:t}"
done

# ─── Re-apply Neovim config symlinks ──────────────────────────────────────────
echo "==> Re-linking Neovim config..."
NVIM_CONFIG="$HOME/.config/nvim"
mkdir -p "$NVIM_CONFIG"

for target_src in \
    "init.vim:$DOTFILES_DIR/vim/init.vim" \
    "coc-settings.json:$DOTFILES_DIR/vim/lint/coc-settings.json"; do
    name="${target_src%%:*}"
    src="${target_src##*:}"
    dest="$NVIM_CONFIG/$name"
    [ -L "$dest" ] && rm "$dest"
    [ -f "$dest" ] && mv "$dest" "${dest}.backup"
    ln -s "$src" "$dest"
    echo "  linked: $name"
done

# ─── Update Neovim plugins ────────────────────────────────────────────────────
if command -v nvim &>/dev/null; then
    echo "==> Updating Neovim plugins..."
    nvim --headless +PlugUpdate +qall
fi

# ─── Re-apply Git config symlink ──────────────────────────────────────────────
echo "==> Re-linking Git config..."
[ -L "$HOME/.gitconfig" ] && rm "$HOME/.gitconfig"
[ -f "$HOME/.gitconfig" ] && mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
ln -s "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

# ─── KiCad Tools ──────────────────────────────────────────────────────────────
PIP=$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null)
if [[ -n "$PIP" ]] && "$PIP" show easyeda2kicad &>/dev/null; then
    echo "==> Updating KiCad tools..."
    "$PIP" install --upgrade -r "$DOTFILES_DIR/kicad/requirements.txt"
fi

# ─── Meslo Nerd Fonts (Linux only) ────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
    [ -L "$HOME/.fonts/Meslo" ] && rm "$HOME/.fonts/Meslo"
    mkdir -p "$HOME/.fonts"
    ln -s "$DOTFILES_DIR/fonts/Meslo" "$HOME/.fonts/Meslo"
    fc-cache -fv
fi

echo ""
echo "==> Update complete! Restart your terminal (or run: exec zsh)"
