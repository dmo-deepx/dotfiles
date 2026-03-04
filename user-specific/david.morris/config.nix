{ pkgs, ... }:

{
  system.defaults.dock.persistent-apps = [
    { app = "/Applications/muCommander.app"; }
    { app = "/Applications/Nix Apps/iTerm2.app"; }

    { app = "/Applications/Nix Apps/Slack.app"; }
    { app = "/Applications/Google Chrome.app"; }
    { app = "/Applications/Zen.app"; }
    { app = "/Applications/Zed.app"; }
    { app = "/Applications/Notion.app"; }
    { app = "/Applications/Microsoft Teams.app"; }
  ];

  environment.systemPackages = [
    pkgs.gnupg # GNU Privacy Guard
    pkgs.pinentry_mac # Pinentry for GPG on macOS
    pkgs.trivy # Simple and comprehensive vulnerability scanner for containers

    pkgs.slack # Slack is a communication platform with a desktop application based on Electron
    pkgs.vscode-with-extensions
    pkgs.localsend

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
      "logi-options+"
      "maccy"
      "megasync"
      "notion"
      "openvpn-connect"
      #"qgis"
      "tiles"
      "vlc"
      "zed"
      "zen"
    ];
  };
}
