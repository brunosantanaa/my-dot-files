#!/bin/zsh
BSA_DIR="$HOME/.bsa"

if [ -d $BSA_DIR ]; then
	echo "BSA dotFiles is installed"
else
	# Install dependencies
    #
    echo "Install - NeoVim | Tmux | Tilix | Node | asdf"
    # GitHub repo
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    # NeoVim repo
    sudo add-apt-repository ppa:neovim-ppa/unstable

    sudo apt-get update

	sudo apt install git neovim tmux tilix nodejs gh -y
    echo "Install asdf"
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2

    echo "Install pylint"
    python -m pip install pylint

	# Install BSA-dotFiles
    #
	echo "Make dir .bsa"
    git clone --depth=1 https://github.com/brunosantanaa/my-dot-files.git $BSA_DIR

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
fi
