#!/bin/zsh

GIT_USER=$HOME/.gitconfig.user

echo 'Config your Git Glbal user'
echo '------------------------------'
if [ ! -e $GIT_USER ]; then
    echo 'Enter your name: '
    read NAME
    echo 'Enter your e-mail: '
    read EMAIL
    echo "[user]" > $GIT_USER
	echo "\tname = \"${NAME}\"" >> $GIT_USER
	echo "\temail = \"${EMAIL}\"" >> $GIT_USER
else
    echo 'Current settings: '
    cat $HOME/.gitconfig.user
    echo 'To update your settings you can run the following command: '
    echo 'rm ~/.gitconfig.user && ~/.bsa/git/./config_user.zsh '
fi
