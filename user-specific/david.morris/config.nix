{ pkgs, ... }:

{
  system.defaults.dock.persistent-apps = [
    { app = "/Applications/Zen.app"; }
    { app = "/Applications/Zed.app"; }
    { app = "/System/Applications/Reminders.app"; }
    { app = "/Applications/Notion.app"; }
    { app = "/Applications/Slack.app"; }
    { app = "/Applications/Microsoft Teams.app"; }
    { app = "/System/Applications/Music.app"; }
    { app = "/Applications/Plexamp.app"; }
    { app = "/System/Applications/Utilities/Terminal.app"; }
    { app = "/Applications/Bitwarden.app"; }
  ];

  environment.systemPackages = [
    pkgs.gnupg # GNU Privacy Guard
    pkgs.pinentry_mac # Pinentry for GPG on macOS
    pkgs.trivy # Simple and comprehensive vulnerability scanner for containers
  ];

  homebrew = {
    casks = [
      "openvpn-connect"
    ];
  };
}
