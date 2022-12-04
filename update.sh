#!/bin/zsh

BSA_HOME="$HOME/.bsa"
cd $HOME && rm -rf $BSA_HOME

curl -fsSL https://raw.githubusercontent.com/brunosantanaa/my-dot-files/main/install.sh
