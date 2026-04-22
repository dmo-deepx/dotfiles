{ pkgs, ... }:

{
  system.defaults.dock.persistent-apps = [
    { app = "/Applications/Google Chrome.app"; }
    { app = "/Applications/Microsoft Teams.app"; }
    { app = "/Applications/Nix Apps/Slack.app"; }
    { app = "/Applications/muCommander.app"; }
    { app = "/Applications/Zed.app"; }
    { app = "/Applications/Nix Apps/iTerm2.app"; }
    { app = "/Applications/Visual Studio Code.app"; }
    { app = "/Applications/Phoenix Slides.app"; }
    {
      app = "/Users/david.morris/Library/Application Support/Autodesk/webdeploy/production/a5622f4599acfbd64092660b8146f6dfac84b731/Autodesk Fusion.app";
    }
    { app = "/Applications/QCAD-Pro.app"; }
    { app = "/Applications/QGIS-final-4_0_0.app"; }

  ];

  environment.systemPackages = [
    pkgs.gnupg # GNU Privacy Guard
    pkgs.pinentry_mac # Pinentry for GPG on macOS
    pkgs.trivy # Simple and comprehensive vulnerability scanner for containers

    pkgs.slack # Slack is a communication platform with a desktop application based on Electron
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
      #"mac-mouse-fix"
    ];

    casks = [
      "appcleaner"
      "bitwarden"
      "disk-inventory-x"
      "docker-desktop"
      "gimp"
      "hot"
      "keka"
      "languagetool-desktop"
      "maccy"
      "notion"
      "openvpn-connect"
      "phoenix-slides"
      "qgis"
      "tiles" # window tile manager
      "visual-studio-code"
      "zed" # simple text editor
      "vlc"

      "foobar2000" # music manager
      "claude-code"
      "disk-inventory-x"

      # Doesn't work, probably blocked:
      # "jordanbaird-ice" # Menu bar manager
      # "zen" # web browser
      # "openmtp"
    ];
  };
}
