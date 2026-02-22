#!/bin/zsh

DOTFILES_DIR="$HOME/.dotfiles"

# ─── Guard ────────────────────────────────────────────────────────────────────
if [ -d "$DOTFILES_DIR" ]; then
    echo "dotfiles already installed at $DOTFILES_DIR"
    read "REPLY?Run update instead? (y/N) "
    if [[ $REPLY == "y" ]]; then
        zsh "$DOTFILES_DIR/update.zsh"
    fi
    exit 0
fi

# ─── OS Detection ─────────────────────────────────────────────────────────────
OS="$(uname -s)"

# ─── Package Installation ─────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
    echo "==> macOS detected"

    if ! command -v brew &>/dev/null; then
        echo "==> Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Load brew into PATH for the current session
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "==> Installing packages via Homebrew..."
    brew install git neovim tmux gh gcc llvm wget node go
    brew install --cask visual-studio-code iterm2

    echo "==> Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

elif [[ "$OS" == "Linux" ]]; then
    echo "==> Ubuntu detected"

    sudo apt-get update

    # GitHub CLI
    echo "==> Adding GitHub CLI repo..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    # Neovim unstable PPA
    echo "==> Adding Neovim PPA..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable

    # Latest GCC via ubuntu-toolchain-r
    echo "==> Adding ubuntu-toolchain-r PPA..."
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

    sudo apt-get update

    # Detect latest gcc version available
    GCC_VERSION=$(apt-cache search "^gcc-[0-9]" | awk '{print $1}' | grep -E "^gcc-[0-9]+$" | sort -V | tail -1 | cut -d- -f2)
    echo "==> Latest GCC version: $GCC_VERSION"

    sudo apt-get install -y \
        git neovim tmux tilix gh \
        build-essential \
        gcc-${GCC_VERSION} g++-${GCC_VERSION} \
        wget nodejs golang

    # Latest Clang via llvm.sh
    echo "==> Installing latest Clang..."
    wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh
    sudo bash /tmp/llvm.sh
    rm /tmp/llvm.sh

    # Detect installed clang version and install clang-format
    CLANG_VERSION=$(ls /usr/bin/clang-* 2>/dev/null | grep -E "clang-[0-9]+$" | sort -V | tail -1 | grep -oE "[0-9]+$")
    if [[ -n "$CLANG_VERSION" ]]; then
        sudo apt-get install -y clang-format-${CLANG_VERSION} clangd-${CLANG_VERSION}
    fi

    # VSCode
    echo "==> Installing VSCode..."
    wget -qO /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt install -y /tmp/vscode.deb
    rm /tmp/vscode.deb

    # Rust
    echo "==> Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# ─── Clone Dotfiles ───────────────────────────────────────────────────────────
echo "==> Cloning dotfiles to $DOTFILES_DIR..."
git clone --depth=1 https://github.com/brunosantanaa/my-dot-files.git "$DOTFILES_DIR"

# ─── Zprezto (official) ───────────────────────────────────────────────────────
echo "==> Installing zprezto..."
if [ -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    rm -rf "${ZDOTDIR:-$HOME}/.zprezto"
fi
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

echo "==> Linking custom zprezto runcoms..."
setopt EXTENDED_GLOB
for rcfile in "$DOTFILES_DIR/zprezto/runcoms/"^README.md(.N); do
    target="${ZDOTDIR:-$HOME}/.${rcfile:t}"
    [ -L "$target" ] && rm "$target"
    [ -f "$target" ] && mv "$target" "${target}.backup"
    ln -s "$rcfile" "$target"
    echo "  linked: .${rcfile:t}"
done

# ─── Neovim Config ────────────────────────────────────────────────────────────
echo "==> Configuring Neovim..."
NVIM_CONFIG="$HOME/.config/nvim"
mkdir -p "$NVIM_CONFIG"

for target_src in \
    "init.vim:$DOTFILES_DIR/vim/init.vim" \
    "coc-settings.json:$DOTFILES_DIR/vim/lint/coc-settings.json" \
    "coc.vim:$DOTFILES_DIR/vim/lint/coc.vim"; do
    name="${target_src%%:*}"
    src="${target_src##*:}"
    dest="$NVIM_CONFIG/$name"
    [ -L "$dest" ] && rm "$dest"
    [ -f "$dest" ] && mv "$dest" "${dest}.backup"
    ln -s "$src" "$dest"
    echo "  linked: $name"
done

echo "==> Installing VimPlug..."
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" \
    --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "==> Installing Neovim plugins..."
nvim --headless +PlugInstall +qall

# ─── Git Config ───────────────────────────────────────────────────────────────
echo "==> Configuring Git..."
[ -L "$HOME/.gitconfig" ] && rm "$HOME/.gitconfig"
[ -f "$HOME/.gitconfig" ] && mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
ln -s "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

zsh "$DOTFILES_DIR/git/config_user.zsh"

# ─── Meslo Nerd Fonts (Linux only) ────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
    echo "==> Installing Meslo Nerd Fonts..."
    mkdir -p "$HOME/.fonts"
    [ -L "$HOME/.fonts/Meslo" ] && rm "$HOME/.fonts/Meslo"
    ln -s "$DOTFILES_DIR/fonts/Meslo" "$HOME/.fonts/Meslo"
    fc-cache -fv
fi

# ─── VSCode Settings & Profiles ───────────────────────────────────────────────
read "REPLY?Configure VSCode settings and profiles? (y/N) "
if [[ $REPLY == "y" ]]; then
    zsh "$DOTFILES_DIR/vscode/install.zsh" "$DOTFILES_DIR"
fi

# ─── KiCad Tools ──────────────────────────────────────────────────────────────
read "REPLY?Install KiCad tools (easyeda2kicad)? (y/N) "
if [[ $REPLY == "y" ]]; then
    PIP=$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null)
    if [[ -n "$PIP" ]]; then
        echo "==> Installing KiCad tools..."
        "$PIP" install -r "$DOTFILES_DIR/kicad/requirements.txt"
    else
        echo "  pip not found, skipping KiCad tools"
    fi
fi

# ─── GitHub Login ─────────────────────────────────────────────────────────────
echo "==> GitHub login..."
gh auth login

# ─── Set shell to zsh ─────────────────────────────────────────────────────────
if [[ "$SHELL" != */zsh ]]; then
    echo "==> Setting zsh as default shell..."
    chsh -s /bin/zsh
fi

echo ""
echo "==> Done! Restart your terminal (or run: exec zsh)"
