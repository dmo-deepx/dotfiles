# Needed for GPG to work in zsh
export GPG_TTY=$(tty)
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

fastfetch  -c neofetch.jsonc --logo ~/.dotfiles/user-specific/david.morris/explode.png
