{ config, ... }:

# https://nix-darwin.github.io/nix-darwin/manual/

{
  imports = [
    ./apps.nix
    ./nix-settings.nix
    ./python.nix
    ./python-binaries.nix
    ./user-options.nix
  ];

  # macOS services
  launchd.user.agents.languageToolServer = {
    command = "/run/current-system/sw/bin/languagetool-server --config ${./..}/languageTool/server.properties --allow-origin '*'";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/languageToolServer.log";
      StandardErrorPath = "/tmp/languageToolServer.err.log";
    };
  };

  # macOS settings
  # Ref: https://nix-darwin.github.io/nix-darwin/manual/index.html
  # NSGlobalDomain = all users
  networking = {
    hostName = config.user.hostname;
    localHostName = config.user.hostname;
    computerName = config.user.hostname;
    # make sure firewall is up & running
    applicationFirewall.enable = true;
    applicationFirewall.enableStealthMode = true;
  };

  system.defaults = {
    iCal."first day of week" = "Monday";

    smb.NetBIOSName = config.user.hostname;

    dock = {
      autohide = false;
      orientation = "bottom";
      tilesize = 32;
      minimize-to-application = true;
      show-recents = false;
      # Disable hot corners
      wvous-tl-corner = 6;
      wvous-tr-corner = 2;
      wvous-bl-corner = 3;
      wvous-br-corner = 12;
    };

    finder = {
      _FXShowPosixPathInTitle = true;
      # Auto-resize columns to fit filenames
      _FXEnableColumnAutoSizing = true;
      AppleShowAllExtensions = true;
      # Restrict searches in Finder to current folder
      FXDefaultSearchScope = "SCcf";
      # Default to List view in Finder
      FXPreferredViewStyle = "Nlsv";
      NewWindowTarget = "Home";
      ShowPathbar = true;
      ShowStatusBar = true;
      # Keep folders on top when sorting by name
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      # Allow quitting Finder
      QuitMenuItem = true;
    };

    # What happens when you press the Fn key
    hitoolbox.AppleFnUsageType = "Do Nothing";

    menuExtraClock = {
      # Flash clock colon separator on and off each second
      FlashDateSeparators = false;
      ShowSeconds = true;
      Show24Hour = true;
    };

    NSGlobalDomain = {
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      AppleTemperatureUnit = "Celsius";
      # Disable double space = period.
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      # Force 24-hour clock
      AppleICUForce24HourTime = true;
      # Enable natural scrolling direction
      "com.apple.swipescrolldirection" = true;
      # Two-finger tap to right click
      "com.apple.trackpad.enableSecondaryClick" = true;
      # Enable trackpad tap to click
      "com.apple.mouse.tapBehavior" = 1;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

    trackpad.Clicking = true;

    WindowManager = {
      # Click wallpaper to reveal desktop -> false = "Only in Stage Manager".
      EnableStandardClickToShowDesktop = false;
      # Disable macOS tiling manager
      EnableTilingByEdgeDrag = false;
      EnableTiledWindowMargins = false;
      EnableTilingOptionAccelerator = false;
      EnableTopTilingByEdgeDrag = false;
    };

    CustomSystemPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Mission Control → CMD+SHIFT+X
          "32" = {
            enabled = true;
            value = {
              parameters = [
                120
                7
                917504
              ]; # 'x' keycode, CMD+SHIFT
              type = "standard";
            };
          };

          # Notification Centre → CMD+SHIFT+A
          "163" = {
            enabled = true;
            value = {
              parameters = [
                97
                12
                917504
              ]; # 'a' keycode fixed: kVK_ANSI_A = 12
              type = "standard";
            };
          };

          # Show Desktop (F11) → DISABLE
          "36" = {
            enabled = false;
            value = {
              parameters = [
                65535
                103
                0
              ];
              type = "standard";
            };
          };

          # Quick Note → DISABLE
          "190" = {
            enabled = false;
            value = {
              parameters = [
                65535
                255
                0
              ];
              type = "standard";
            };
          };

          # Game Overlay (Cmd+Tab in Game mode) → DISABLE
          "233" = {
            enabled = false;
            value = {
              parameters = [
                65535
                255
                0
              ];
              type = "standard";
            };
          };
        };
      };
    };
    CustomUserPreferences = {
      "com.google.Chrome" = {
        NSUserKeyEquivalents = {
          "Open Location…" = "@d"; # CMD+D
          "Bookmark This Tab…" = "@b"; # CMD+B
          "Reload This Page" = ""; # F5, I think
        };
      };
    };
  };

  # Enable TouchID and Apple Watch unlock for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
