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

## `serial_hexdump.py`
Open a serial port and hexdump the incoming bytes as they arrive, unbuffered.

The packaged binary is named `serial-hexdump`, with `shd` as a zsh alias.

Defaults to 115200 8N1 and to the only attached port, so `shd` on its own is
usually enough. `shd -l` lists the ports. A quiet gap of `--idle` seconds (0.25
by default) ends the current row, which keeps framed traffic readable one frame
per row group. `--save FILE` tees the raw bytes to disk while you watch.
