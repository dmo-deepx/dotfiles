{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      unstable,
      nix-homebrew,
    }:
    let
      userConfig = import ../user-specific/identity.nix;
      system = userConfig.user.system;
    in
    {
      darwinConfigurations."${userConfig.user.hostname}" = nix-darwin.lib.darwinSystem {
        system = system;
        # Make pkgs from unstable available to subsequent config files
        specialArgs = {
          unstablePkgs = import unstable {
            inherit system;
            config = {
              allowUnfree = true;
            };
            overlays = [
              (final: prev: {
                mactop = prev.mactop.overrideAttrs (_: {
                  doCheck = false;
                });
              })
            ];
          };
        };
        modules = [
          ./darwin.nix
          ../user-specific/identity.nix
          ../user-specific/${userConfig.user.name}/config.nix

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # Declarative tap management
              taps = {
              };

              # Enable fully-declarative tap management
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
          # Align homebrew taps config with nix-homebrew
          (
            { config, ... }:
            {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            }
          )
        ];
      };
    };
}
