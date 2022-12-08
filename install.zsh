#!/bin/zsh
BSA_DIR="$HOME/.bsa"

if [ -d $BSA_DIR ]; then
	echo "BSA dotFiles is installed"
    read "REPLY?Would you like to run the update file? (y/N)"
    if [[ $REPLY = "y" ]]; then
        ./update.zsh
    fi
else
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
	sudo apt install git neovim tmux tilix nodejs gh qemu -y
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
    sudo apt install clang-format-$CLANG_VERSION

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

    # Nuttx Compile dependencies and ESP
    read -q "REPLY?Would you like to install Nuttx and ESP compile dependencies? (y/N)"
    if [[ $REPLY  = "y" ]]; then
        # Prerequisites
        sudo apt install  \
            bison flex gettext texinfo libncurses5-dev libncursesw5-dev \
            gperf automake libtool pkg-config build-essential gperf genromfs \
            libgmp-dev libmpc-dev libmpfr-dev libisl-dev binutils-dev libelf-dev \
            libexpat-dev gcc-multilib g++-multilib picocom u-boot-tools util-linux -y
            kconfig-frontends -y
        # KConfig frontend
        sudo apt install kconfig-frontends -y
        # Toolchain
        sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi -y
        # ESP-QEMU
        sudo apt install libglib2.0-dev libfdt-dev libpixman-1-dev \
            zlib1g-dev ninja-build libgcrypt-dev -y
        if [[ -d "${HOME}/Qemu/esp-qemu" ]]; then
            rm -rf "${HOME}/Qemu/esp-qemu"
        fi
        if [[ -d "${HOME}/nuttxspace" ]]; then
            rm -rf "${HOME}/nuttxspace"
        fi
        git clone https://github.com/apache/nuttx.git "${HOME}/nuttxspace/nuttx"
        git clone https://github.com/apache/nuttx-apps "${HOME}/nuttxspace/apps"
        git clone https://github.com/espressif/qemu "${HOME}/Qemu/esp-qemu"

        curl https://dl.espressif.com/dl/xtensa-esp32-elf-gcc8_2_0-esp-2020r2-linux-amd64.tar.gz | tar -xz
        sudo mkdir /opt/xtensa
        sudo mv xtensa-esp32-elf/ /opt/xtensa/
        echo "# Xtensa\nexport PATH=\$PATH:/opt/xtensa/xtensa-esp32-elf/bin" >> $LOCAL_RC
        /bin/python -m pip install esptool
        if [[ -d "${HOME}/nuttxspace/esp-bins" ]]; then
            rm -rf "${HOME}/nuttxspace/esp-bins"
        fi
        mkdir "${HOME}/nuttxspace/esp-bins"
        curl -L "https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32.bin" \
            -o "${HOME}/nuttxspace/esp-bins/bootloader-esp32.bin"
        curl -L "https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32.bin" \
            -o "${HOME}/nuttxspace/esp-bins/partition-table-esp32.bin"

        wget -qO- "https://github.com/espressif/binutils-gdb/releases/download/esp-gdb-v12.1_20221002/xtensa-esp-elf-gdb-12.1_20221002-x86_64-linux-gnu.tar.gz" | tar -xvz
        sudo mv xtensa-esp-elf-gdb/ /opt/xtensa/
        echo "export PATH=\$PATH:/opt/xtensa/xtensa-esp-elf-gdb/bin" >> $LOCAL_RC
        echo "export QEMU_XTENSA_CORE_REGS_ONLY=1" >> $LOCAL_RC
    fi

    # Yocto
    read "REPLY?Would you like to install dependencies to compile Yocto Projet? (y/N)"
    if [[ $REPLY = "y" ]]; then
        sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio \
            python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa \
            libsdl1.2-dev xterm python3-subunit mesa-common-dev zstd liblz4-tool -y
    fi

    echo "Complete!"
fi
