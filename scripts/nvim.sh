	## NeoVim
	ln -s /bin/nvim /usr/bin/v

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
