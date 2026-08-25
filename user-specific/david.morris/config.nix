{ pkgs, ... }:

let
  # Rajant BC|Commander, extracted from rajant_bcc-11.28.3.0.deb.
  # The jar lives outside the nix store (licence-gated download, 87 MB).
  # Needs Java 17 (jar is class file version 61). JVM flags mirror the
  # .deb's own /usr/bin/bcc11 launcher; -H runs headless (no GUI/splash).
  bccHome = "/Users/david.morris/data/bin/bcc/opt/bcc";
  bcc = pkgs.writeShellScriptBin "bcc" ''
    if [ "$1" = "-H" ]; then
      exec ${pkgs.temurin-bin-17}/bin/java \
        -Djava.awt.headless=true \
        --add-exports=java.desktop/sun.awt=ALL-UNNAMED \
        -XX:+IgnoreUnrecognizedVMOptions -Xmx2048M -XX:+UseG1GC \
        -jar ${bccHome}/bcc-11.28.3.jar "$@"
    else
      exec ${pkgs.temurin-bin-17}/bin/java \
        --add-exports=java.desktop/sun.awt=ALL-UNNAMED \
        -XX:+IgnoreUnrecognizedVMOptions -Xmx2048M -Xss512k -XX:+UseG1GC \
        -splash:${bccHome}/lib/bcc_splash.jpg \
        -jar ${bccHome}/bcc-11.28.3.jar "$@"
    fi
  '';
in
{
  system.defaults.dock.persistent-apps = [
    { app = "/Applications/Google Chrome.app"; }
    { app = "/Applications/Microsoft Outlook.app"; }
    { app = "/Applications/Microsoft Teams.app"; }
    { app = "/Applications/Slack.app"; }
    { app = "/Applications/muCommander.app"; }
    { app = "/Applications/Zed.app"; }
    { app = "/Applications/Nix Apps/iTerm2.app"; }
    { app = "/Applications/Visual Studio Code.app"; }
    { app = "/Applications/Phoenix Slides.app"; }
    {
      app = "/Users/david.morris/Library/Application Support/Autodesk/webdeploy/production/5b508d94493ed3344e38945ffca1b03b713ee401/Autodesk Fusion.app";
    }
    { app = "/Applications/KiCad/KiCad.app"; }
    { app = "/Applications/QCAD-Pro.app"; }
    { app = "/Applications/QGIS-final-4_2_0.app"; }

  ];

  environment.systemPackages = [
    bcc # Rajant BC|Commander launcher (see let-block above)
    pkgs.gnupg # GNU Privacy Guard
    pkgs.pinentry_mac # Pinentry for GPG on macOS
    pkgs.trivy # Simple and comprehensive vulnerability scanner for containers

    pkgs.iproute2mac # provides the Linux-style `ip` command on macOS (maps to ifconfig/netstat)
    pkgs.grc # Generic colouriser — colorizes `ip`/`ifconfig`/`netstat`/etc. output

    #pkgs.slack # Slack is a communication platform with a desktop application based on Electron
    pkgs.localsend
    pkgs.alt-tab-macos
    pkgs.exiftool # Tool to read, write and edit EXIF meta information
    pkgs.ffmpeg-full # Includes all optional features including libfreetype
    # pkgs.obs-studio
    #
    pkgs.gcc-arm-embedded # GNU Arm toolchain (gcc, gdb, newlib, etc.)

    pkgs.wireviz # Document cables/wiring harnesses from YAML (graphviz bundled)


    # Not compatible yet with darwin:
    #
    # pkgs.mucommander
    # pkgs.multivnc
    # pkgs.qgis-ltr
    # pkgs.handbrake # Tool for converting video files and ripping DVDs.
  ];

  # --- SSH login notifier (Pushover) ---------------------------------------
  # Fires on interactive / remote-command SSH logins to this account: sshd runs
  # /etc/ssh/sshrc via /bin/sh for each session (unless ~/.ssh/rc exists, which
  # would override it, or a bare sftp/scp-only session, which skips sshrc).
  # The login keychain isn't reachable from an SSH session, so creds live in a
  # chmod-600 file OUTSIDE the nix store (the store is world-readable):
  #   ~/.config/pushover.env  ->  PUSHOVER_API_TOKEN=... / PUSHOVER_USER_KEY=...
  # The hook safely no-ops (exit 0) if that file is absent or its values empty.
  environment.etc."ssh/sshrc".text = ''
    # Managed by nix-darwin (user-specific/david.morris/config.nix) - do not edit.
    creds="$HOME/.config/pushover.env"
    [ -r "$creds" ] || exit 0
    . "$creds"
    [ -n "$PUSHOVER_API_TOKEN" ] && [ -n "$PUSHOVER_USER_KEY" ] || exit 0
    from="''${SSH_CONNECTION%% *}"
    host="$(hostname -s 2>/dev/null || hostname)"
    who="$(id -un 2>/dev/null || echo "$USER")"
    when="$(date '+%Y-%m-%d %H:%M:%S')"
    nohup /usr/bin/curl -s --connect-timeout 3 --max-time 8 \
      --form-string "token=$PUSHOVER_API_TOKEN" \
      --form-string "user=$PUSHOVER_USER_KEY" \
      --form-string "title=SSH login on $host" \
      --form-string "priority=1" \
      --form-string "message=SSH login: $who@$host from ''${from:-unknown} at $when" \
      https://api.pushover.net/1/messages.json >/dev/null 2>&1 &
    exit 0
  '';

  homebrew = {
    brews = [
      "yt-dlp"
      "gh" # Github command line tools
      "git-lfs" # Git Large File System
      "cmake"
      "libserialport"
      "tio" # Terminal IO
      "fzf" # Fuzzy Search
      "dfu-util"
      "libftdi"
      "pkgconf"
      "poppler" # pdf2text things
      "tmux"
      "deno" # Secure runtime for JavaScript and TypeScript
      "fastfetch" # Fastfetch is a neofetch-like tool for fetching system information and displaying it in a visually appealing way.
      "mactop" # Apple Silicon Monitor Top written in Go Lang
      "shellcheck" # Static analysis and lint tool, for (ba)sh scripts
      "pigz" # Parallel gzip
      "gerbv" # Gerber (RS-274X) viewer
      "ripgrep" # Search tool like grep and The Silver Searcher
      "socat"
      "glow" # Render markdown on the CLI
      "ninja"
      "nasm"
      "autoconf"
      "automake"
      "libtool"

      #"mac-mouse-fix"
    ];

    casks = [
      "appcleaner" # App Cleaner and Uninstaller
      "bitwarden" # Password manager
      "gimp" # Image editing
      "hot"
      "keka" # File archiving and backup tool
      "languagetool-desktop"
      "maccy" # Clipboard manager
      "notion" # Productivity and collaboration platform
      "openvpn-connect"
      "phoenix-slides"
      "qgis" # Geographic Information System
      "tiles" # window tile manager
      "visual-studio-code"
      "zed" # simple text editor
      "vlc" # Video Player

      "foobar2000" # music manager
      "claude-code" # Claude AI code assistant
      "disk-inventory-x" # Disk Inventory X
      "blender" # 3D Creation/Animation/Publishing System
      "kicad" # Electronic Design Automation (EDA) tool for schematic capture and PCB design

      "steipete/tap/codexbar" # CodexBar tracks usage windows, credit balances, and reset countdowns
      "menumeters" # Set of CPU, memory, disk, and network monitoring tools
      "stats" # System monitoring tool
      "vnc-viewer" # Remote desktop application focusing on security
      "raspberry-pi-imager" # Imaging utility to install operating systems to a microSD card

      "handbrake-app" # Tool for converting video files and ripping DVDs.
      "qlmarkdown"

      # Doesn't work, probably blocked:
      # "jordanbaird-ice" # Menu bar manager
      # "zen" # web browser
      # "openmtp"
    ];
  };
}
