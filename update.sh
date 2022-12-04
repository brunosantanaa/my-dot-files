#!/bin/zsh

BSA_HOME="$HOME/.bsa"
# Backup
cd $HOME && mv $BSA_HOME $BSA_HOME.backup

# Install
curl -fsSL https://raw.githubusercontent.com/brunosantanaa/my-dot-files/main/install.sh

# Test

# Clean
rm -rf $BSA_HOME.backup
