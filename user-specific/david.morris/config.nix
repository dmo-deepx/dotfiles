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
      app = "/Users/david.morris/Library/Application Support/Autodesk/webdeploy/production/42b8d7cb7630f307bd514d9fc6eca5f495fa798c/Autodesk Fusion.app";
    }
    { app = "/Applications/KiCad/KiCad.app"; }
    { app = "/Applications/QCAD-Pro.app"; }
    { app = "/Applications/QGIS-final-4_0_0.app"; }

  ];

  environment.systemPackages = [
    bcc # Rajant BC|Commander launcher (see let-block above)
    pkgs.gnupg # GNU Privacy Guard
    pkgs.pinentry_mac # Pinentry for GPG on macOS
    pkgs.trivy # Simple and comprehensive vulnerability scanner for containers

    #pkgs.slack # Slack is a communication platform with a desktop application based on Electron
    pkgs.localsend
    pkgs.alt-tab-macos
    pkgs.exiftool # Tool to read, write and edit EXIF meta information
    pkgs.ffmpeg-full # Includes all optional features including libfreetype
    # pkgs.obs-studio
    #
    pkgs.gcc-arm-embedded # GNU Arm toolchain (gcc, gdb, newlib, etc.)

    # Not compatible yet with darwin:
    #
    # pkgs.mucommander
    # pkgs.multivnc
    # pkgs.qgis-ltr
  ];

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

      #"mac-mouse-fix"
    ];

    casks = [
      "appcleaner" # App Cleaner and Uninstaller
      "bitwarden" # Password manager
      "docker-desktop" # Docker Desktop
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

      # Doesn't work, probably blocked:
      # "jordanbaird-ice" # Menu bar manager
      # "zen" # web browser
      # "openmtp"
    ];
  };
}
