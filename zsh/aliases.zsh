# Common aliases
alias dev="cd $HOME/code"
alias l='ls -lah --color=auto'
alias ll='ls -la --color=auto'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias nano='nano -c'
alias 7z='7zz'

# grc colourisers (needs `grc` + `iproute2mac`, installed via nix).
# `--colour=auto` => coloured in the terminal, plain when piped/redirected.
# Networking
alias ip='grc --colour=auto ip'             # Linux-style `ip a` via iproute2mac
alias ifconfig='grc --colour=auto ifconfig' # native macOS ifconfig
alias ping='grc --colour=auto ping'
alias ping6='grc --colour=auto ping6'
alias traceroute='grc --colour=auto traceroute'
alias traceroute6='grc --colour=auto traceroute6'
alias mtr='grc --colour=auto mtr'
alias netstat='grc --colour=auto netstat'
alias dig='grc --colour=auto dig'
alias whois='grc --colour=auto whois'
alias nmap='grc --colour=auto nmap'
alias tcpdump='grc --colour=auto tcpdump'
# System / disk
alias ps='grc --colour=auto ps'
alias df='grc --colour=auto df'
alias du='grc --colour=auto du'
alias mount='grc --colour=auto mount'
alias stat='grc --colour=auto stat'
alias id='grc --colour=auto id'
alias last='grc --colour=auto last'
alias uptime='grc --colour=auto uptime'
alias env='grc --colour=auto env'           # note: colours the KEY=VALUE listing; drop if `env FOO=bar cmd` looks odd
alias sysctl='grc --colour=auto sysctl'
alias iostat='grc --colour=auto iostat'
alias lsof='grc --colour=auto lsof'
# Dev / build
alias gcc='grc --colour=auto gcc'
alias make='grc --colour=auto make'
alias diff='grc --colour=auto diff'
alias curl='grc --colour=auto curl'         # note: colours headers/JSON; drop if download progress bars look odd

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
alias vm="ssh vml32"
alias spl="serial-port-list"
alias xlate="translate-gui"
alias hclean="zsh-history-clean"
alias ffs="fastfetch -c ~/.dotfiles/user-specific/david.morris/fastfetch.jsonc"
alias npl_bs="ssh -b 10.20.30.50 root@10.20.30.30"
alias npl_d6="ssh -b 10.20.30.50 field@10.20.30.42"
