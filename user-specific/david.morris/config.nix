{ pkgs, ... }:

{
  system.defaults.dock.persistent-apps = [
    { app = "/Applications/Microsoft Teams.app"; }
    { app = "/Applications/muCommander.app"; }
    { app = "/Applications/Nix Apps/iTerm2.app"; }
    { app = "/Applications/Nix Apps/Slack.app"; }
    { app = "/Applications/Google Chrome.app"; }
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

    # Not compatible yet with darwin:
    #
    # pkgs.mucommander
    # pkgs.multivnc
    # pkgs.qgis-ltr
  ];

  homebrew = {
    casks = [
      "appcleaner"
      "bitwarden"
      "docker-desktop"
      "gimp"
      "hot"
      "keka"
      "languagetool-desktop"
      "logi-options+"
      "maccy"
      "megasync"
      "notion"
      "openvpn-connect"
      "phoenix-slides"
      "qgis"
      "tiles"
      "vlc"
      "visual-studio-code"
      "zed"
      "zen"
    ];
  };
}
