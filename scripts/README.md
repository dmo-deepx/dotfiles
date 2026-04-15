# Scripts
Collection of Python scripts that are packaged as executable binaries by Nix.

Change, remove, or add more in `~/.dotfiles/nix-configs/python-binaries.nix`.

## `securepass.py`
A simple script to generate secure passwords in the terminal.
The packaged binary is named `securepass`, while `pwgen` and `pwgens` are defined as zsh aliases for convenience.

## `update_ssh_config.py`
This script fetches any items (Secure Note) in your Bitwarden vault that start with `ssh-config-` and writes them to `~/.ssh/config` to enable easy logins like e.g., `ssh host`.

Required fields are:
- `Host`
- `HostName`

Optional fields are:
- `IdentityFile`
- `AddressFamily`
- `Port`
- `User`

If `User` is not defined, the script will fall back to `root`.

See `VALID_SSH_OPTIONS` if you want to add additional fields.

## `serial_port_list.py`
Output a list of available serial ports and their descriptions.
