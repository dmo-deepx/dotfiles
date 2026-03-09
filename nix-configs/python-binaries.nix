{ pkgs, ... }:

let

  # Create a binary inside /nix/store for securepass.py
  securepass = pkgs.stdenv.mkDerivation {
    name = "securepass";
    buildInputs = [ pkgs.python313 ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${../scripts/securepass.py} $out/bin/securepass
      chmod +x $out/bin/securepass
    '';
  };

  # Create a binary inside /nix/store for update-ssh-config.py
  update-ssh-config = pkgs.stdenv.mkDerivation {
    name = "update-ssh-config";
    buildInputs = [ pkgs.python313 ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${../scripts/update_ssh_config.py} $out/bin/update-ssh-config
      chmod +x $out/bin/update-ssh-config
    '';
  };

  # List all the available serial prots
  serial-port-list = pkgs.stdenv.mkDerivation {
    name = "serial-port-list";
    buildInputs = [ pkgs.python313 ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${../scripts/serial_port_list.py} $out/bin/serial-port-list
      chmod +x $out/bin/serial-port-list
    '';
  };
in

{
  environment.systemPackages = [
    securepass
    update-ssh-config
    serial-port-list
  ];
}
