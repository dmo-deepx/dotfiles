# Enable GNU Parallel to inherit this shell’s environment
if [[ -r /run/current-system/sw/bin/env_parallel.zsh ]]; then
  source /run/current-system/sw/bin/env_parallel.zsh
fi

# Apply zsh theme
source "$ZSH/oh-my-zsh.sh"

# Ensure local fasttext model
source $HOME/.dotfiles/languageTool/setup.sh
create_properties_file
download_fasttext_model

# Load user-specific settings, aliases, and functions
source "$HOME/.dotfiles/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/functions.zsh"
source "$HOME/.dotfiles/user-specific/$USER/profile.zsh"

# Prevent “too many open files”
ulimit -n 2048

# Enable direnv
eval "$(direnv hook zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
