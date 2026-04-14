# dotfiles

This repository contains the dotfiles I use to configure my macOS systems.
They are highly opinionated and designed around my personal workflow and environment.
They may not be suitable for your system without modification, so use them at your own risk.

## Install Nix

**1. Install Nix (https://nixos.org/download/)**
```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

**2. Remove any existing files before starting on a fresh system. Create backups otherwise.**
```bash
sudo rm /etc/bashrc /etc/zshrc /etc/zshenv
```

**3. Install Rosetta to allow compiling Intel binaries (assuming Apple Silicon Mac).**
```bash
softwareupdate --install-rosetta --agree-to-license
```

**4. Install xcode command line tools**
```bash
xcode-select --install 
```

**5. Install brew**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


## Clone the repo and rebuild the system

**1. Clone the repo**
```bash
git clone https://github.com/dmo-deepx/dotfiles.git ~/.dotfiles
```

**2. Add symlinks to set things up**
```bash
ln -sv ~/.dotfiles/.zshrc ~/
ln -sv ~/.dotfiles/.hushlogin ~/
ln -sv ~/.dotfiles/.direnvrc ~/
```

Optional: Additional symlinks if you use the Zed editor.
```bash
[[ -d ~/.config/zed ]] || mkdir -p ~/.config/zed
ln -sv ~/.dotfiles/zed/settings.json ~/.config/zed/settings.json
ln -sv ~/.dotfiles/zed/keymap.json ~/.config/zed/keymap.json
ln -sv ~/.dotfiles/zed/ruff.toml ~/.config/zed/ruff.toml
```

**3. Add your own username and desired computer/host name**
```bash
nano ~/.dotfiles/user-specific/identity.nix
```

**4. Rebuild the system (takes a few minutes the first time)**

First time, use this command and replace `ComputerName` with the computer name you set in `identity.nix`.
```bash
sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/.dotfiles/nix-configs#ComputerName
```

For subsequent rebuilds, simply use the alias.
```bash
nixrb
```

## Optional: Personal Binary Cache

If you run a [personal binary cache](https://nix.dev/tutorials/nixos/binary-cache-setup.html), store the settings in `/etc/nix/local.conf`.

Bootstrap the file by running the command below.

```bash
sudo tee /etc/nix/local.conf >/dev/null <<EOF
extra-substituters = https://binary-cache.tld
extra-trusted-public-keys = binary-cache.tld:PUBLIC_KEY_HERE
extra-secret-key-files = /etc/nix/binary-cache.tld.priv
EOF
```

Make sure the private key is at the expected location.
E.g.,

```bash
sudo cp ~/.ssh/binary-cache.tld.priv /etc/nix/binary-cache.tld.priv
```
