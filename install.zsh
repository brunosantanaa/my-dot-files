#!/bin/zsh
BSA_DIR="$HOME/.bsa"

if [ -d $BSA_DIR ]; then
	echo "BSA dotFiles is installed"
    read "REPLY?Would you like to run the update file? (y/N)"
    if [[ $REPLY != "y" ]]; then
        echo "BSA dotFiles is installed"
        exit 0
    fi
fi

# Install dependencies
#
echo "Install - NeoVim | Tmux | Tilix | Node | Rust | asdf | QEMU"
# GitHub repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
# NeoVim repo
sudo add-apt-repository ppa:neovim-ppa/unstable

sudo apt-get update
sudo apt install git neovim xsel tmux tilix nodejs gh qemu -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "Install asdf"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2

echo "Install pylint"
/bin/python -m pip install pylint

# Install BSA-dotFiles
#
echo "Make .bsa dir and .localrc.zsh file"
LOCAL_RC="${HOME}/.localrc.zsh"
if [[ ! -e $LOCAL_RC ]]; then
    echo "###################################################################" > $LOCAL_RC
    echo "# Profile definitions" >> $LOCAL_RC
    echo "# asdf\n. \$HOME/.asdf/asdf.sh" >> $LOCAL_RC
    echo "fpath=(\${ASDF_DIR}/completions \$fpath)" >> $LOCAL_RC
    echo "# Go\nexport PATH=\$PATH:/usr/local/go/bin" >> $LOCAL_RC
    echo "# Rust\n export PATH=\$PATH:/\$HOME/.cargo/bin"
fi

git clone --depth=1 https://github.com/brunosantanaa/my-dot-files.git $BSA_DIR

# Clang
echo "Install Clang AND Clangd"
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
CLANG_VERSION=$(ls /bin | grep clang-cpp- | cut -f3 -d'-')
sudo apt install clang-format-$CLANG_VERSION -y
sudo apt install gcc-12 gcc-12-base gcc-12-doc g++-12 -y
echo "Config NeoVim"
## NeoVim
sudo ln -s /bin/nvim /usr/bin/v

### Configuration Files

NVIM_CONFIG="$HOME/.config/nvim"
if [ ! -d $NVIM_CONFIG ]; then
    mkdir $NVIM_CONFIG
fi
if [ -e "$NVIM_CONFIG/init.vim" ]; then
    mv "$NVIM_CONFIG/init.vim" "$NVIM_CONFIG/init.vim.before"
    rm  "$NVIM_CONFIG/init.vim"
else
    touch "$NVIM_CONFIG/init.vim.before"
fi
if [ -L "$NVIM_CONFIG/init.vim" ]; then
    rm "$NVIM_CONFIG/init.vim"
fi
ln -s "$HOME/.bsa/vim/init.vim" "$NVIM_CONFIG/init.vim"

### CoC - Config
ln -s "$HOME/.bsa/vim/lint/coc-settings.json" "$NVIM_CONFIG/coc-settings.json"

### Install VimPlug
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
    --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

### Install Plugins
v -c PlugInstall -c q -c q
echo "Config Prezto"
# Install Prezto
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.bsa/zprezto/runcoms/^README.md(.N); do
    echo "Create ${rcfile:t}"
    if [ -L  "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]; then
        rm  "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    fi

    if [ -f "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]; then
        mv  "${ZDOTDIR:-$HOME}/.${rcfile:t}"  "${ZDOTDIR:-$HOME}/.${rcfile:t}.backup"
    fi
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh

# Install Meslo Nerd Fonts
#
echo "Install NerdFonts-Meslo"
if [ ! -d "${HOME}/.fonts" ]; then
    mkdir "${HOME}/.fonts"
fi
MESLO=$HOME/.fonts/Meslo

if [ -d $MESLO ]; then
    rm -rf $MESLO
fi
ln -s $BSA_DIR/fonts/Meslo $MESLO

# Git
echo "Configure Git"
GIT_IGNORE=$HOME/.gitconfig
if [ -e $GIT_IGNORE ]; then
    rm $GIT_IGNORE
fi
ln -s $BSA_DIR/git/gitconfig $HOME/.gitconfig

# Login GitHub
gh auth login
$BSA_DIR/git/./config_user.zsh

#kicad
sudo add-apt-repository ppa:kicad/kicad-9.0-releases
sudo apt update
sudo apt install kicad --install-suggests -y

python3 -m venv $BSA_DIR/kicad/.venv
source $BSA_DIR/kicad/.venv/bin/activate && pip install -r $BSA_DIR/kicad/requirements.txt && deactivate
cp $BSA_DIR/kicad/Bruno_KicadTheme.json $HOME/.config/kicad/9.0/colors/Bruno_KicadTheme.json

echo "Complete!"

