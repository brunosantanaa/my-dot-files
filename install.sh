#!/bin/sh
BSA_DIR="$HOME/.bsa"

if [ -d $BSA_DIR ]; then
	echo "BSA dotFiles is installed"
else
	# Install dependencies
	sudo apt install git neovim tmux clangd-14 clang-format-14 -y

    # Symbolic links
    ln -s /bin/clangd-14 /usr/bin/clangd
    ln -s /bin/clang-format-14 /usr/bin/clang-format
    python -m pip install pylin
	# Install BSA-dotFiles
	git clone --depth=1 https://github.com/brunosantanaa/my-dot-files.git $BSA_DIR
    $BSA_DIR/scripts/./nvim.sh
    $BSA_DIR/scripts/./prezto.sh

fi
