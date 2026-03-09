#!/usr/bin/env python3

"""
serial_port_list.py - List available serial (COM/TTY) ports

README
------
A small command-line utility to enumerate and display available serial ports
on the host system using the pyserial library. The script prints a human-
readable list of ports, descriptions, manufacturer and serial numbers (when
available), and a summary count.

"""

import sys

try:
    from serial.tools import list_ports
except ImportError as e:
    print(f"Error: Required library not found: {e}")
    print("\nPlease install required dependencies:")
    print("  pip install pyserial")
    sys.exit(1)


def list_serial_ports():
    """List all available serial ports"""
    ports = list_ports.comports()

    if not ports:
        print("\nNo serial ports found.")
        return

    print("\nAvailable serial ports:")
    print("-" * 60)

    for port in sorted(ports):
        print(f"  {port.device:20s} - {port.description}")
        if port.manufacturer:
            print(f"    Manufacturer: {port.manufacturer}")
        if port.serial_number:
            print(f"    Serial: {port.serial_number}")

    print("-" * 60)
    print(f"Total: {len(ports)} port(s)")


def main():
    list_serial_ports()


if __name__ == "__main__":
    sys.exit(main())
