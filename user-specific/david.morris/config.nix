{ pkgs, ... }:

{
  system.defaults.dock.persistent-apps = [
    { app = "/Applications/Google Chrome.app"; }
    { app = "/Applications/Microsoft Teams.app"; }
    { app = "/Applications/Nix Apps/Slack.app"; }
    { app = "/Applications/muCommander.app"; }
    { app = "/Applications/Nix Apps/iTerm2.app"; }
    { app = "/Applications/Zed.app"; }
    { app = "/Applications/Visual Studio Code.app"; }
    { app = "/Applications/Phoenix Slides.app"; }
    { app = "/Applications/Notion.app"; }

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
    pkgs.obs-studio

    # Not compatible yet with darwin:
    #
    # pkgs.mucommander
    # pkgs.multivnc
    # pkgs.qgis-ltr
  ];

  homebrew = {
    brews = [
      "yt-dlp"
      "git-lfs"
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
      "megasync"
      "notion"
      "openvpn-connect"
      "phoenix-slides"
      "qgis"
      "tiles"
      "visual-studio-code"
      "zed"
      "zen"
      "vlc"

      "foobar2000"
      # Doesn't work, probably blocked:
      # "openmtp"
    ];
  };
}
