#!/bin/zsh
# Install Prezto
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.bsa/zprezto/runcoms/^README.md(.N); do
    if [ -L  "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]; then
        rm  "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    fi

    if [ -f "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]; then
        mv  "${ZDOTDIR:-$HOME}/.${rcfile:t}"  "${ZDOTDIR:-$HOME}/.${rcfile:t}.backup"
    fi
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh
