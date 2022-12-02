#!/bin/sh

backup_files() {
	if [ -e "$HOME/.$1" ]; then
		echo "O arquivo $1 existe"
	else
		echo "O arquivo $1 nao existe"
	fi
}

backup_files "vim"
