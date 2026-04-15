# Common aliases
alias dev="cd $HOME/Development"
alias l='ls -lah --color=auto'
alias ll='ls -la --color=auto'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias nano='nano -c'
alias 7z='7zz'

# GitHub
alias gs='git status'
alias ga='git add -A'
alias gf='git fetch origin'
alias gr='git rebase origin/main'
alias grmaster='git rebase origin/master'
alias gcm='git checkout main'
alias gcmaster='git checkout master'
alias gca='git commit --amend'
alias gri='git rebase -i HEAD~10'
alias grs='git restore --staged'
alias gsu='git stash -u'
alias gsp='git stash pop'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbd='git branch -D'
alias gc='git checkout'
alias gitmagic='git commit --amend --allow-empty; git push --force-with-lease'
alias gitclean='git clean -f -d; git fetch origin main; git reset --hard origin/main'
alias gitcleanmaster='git clean -f -d; git fetch origin master; git reset --hard origin/master'
alias gittrack='_gittrack(){git branch --track "$1" origin/"$1" && gc "$1";}; _gittrack'

# Image compression
alias tinify='_tinify(){ cjpeg "$1" > "$1".tmp && mv "$1".tmp "$1";}; _tinify'
alias pngquant='pngquant --ext .png --force'

# Force secure passwords using securepass.py
alias pwgens='securepass --exclude-ambiguous'
alias pwgen='securepass --exclude-ambiguous --no-special'

# List users on macOS
alias listusers='dscl . list /Users | grep -v “^_”'

# Nix
alias nixrb="sudo darwin-rebuild switch --flake $HOME/.dotfiles/nix-configs"
alias nixupdate="nix flake update --flake $HOME/.dotfiles/nix-configs"
alias nixgc="nix-collect-garbage -d"

# Dmo aliases
alias vm="ssh vm067a"
alias spl="serial-port-list"
alias xlate="translate-gui"
