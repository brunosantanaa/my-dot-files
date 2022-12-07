#!/bin/zsh

BSA_HOME="$HOME/.bsa"
# Backup
mv $BSA_HOME $BSA_HOME.backup

# Install
zsh -c "`curl -fsSL https://raw.githubusercontent.com/brunosantanaa/my-dot-files/main/install.zsh`"

# Test

# Clean
rm -rf $BSA_HOME.backup
