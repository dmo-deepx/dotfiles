#!/usr/bin/env python3

"""
serial_hexdump.py - Stream a serial port as a live, unbuffered hexdump

README
------
Opens a serial port at a given baud rate and writes a hexdump of every byte
that arrives, as it arrives. Nothing waits for a full line: on a terminal the
current row is redrawn in place so a single byte shows up the moment it lands,
and when stdout is a pipe or file the row is emitted as soon as it fills or as
soon as the line goes quiet.

A gap of --idle seconds ends the current row, so framed traffic shows up as one
row group per frame rather than a continuous ribbon of bytes.

Examples:
  serial-hexdump                                   # sole attached port, 115200
  serial-hexdump /dev/tty.usbserial-1420 -b 9600
  serial-hexdump -l                                # list ports and exit
  serial-hexdump /dev/ttyUSB0 -b 921600 -t --save capture.bin

"""

import argparse
import sys
import time

try:
    import serial
    from serial.tools import list_ports
except ImportError as e:
    print(f"Error: Required library not found: {e}")
    print("\nPlease install required dependencies:")
    print("  pip install pyserial")
    sys.exit(1)

GROUP = 8  # blank column between every 8 bytes, as in `hexdump -C`
RULE = "-" * 60

DIM = "\x1b[2m"
RESET = "\x1b[0m"
CLEAR_EOL = "\x1b[K"


def _hex_width(count: int) -> int:
    """Visible width of the hex column for count bytes, separators included."""
    if count == 0:
        return 0
    return count * 3 - 1 + (count - 1) // GROUP


class HexDump:
    """Renders bytes as hexdump rows, flushing as early as the sink allows."""

    def __init__(self, stream, width=16, ascii_gutter=True, colour=False,
                 timestamps=False, live=False):
        self.stream = stream
        self.width = width
        self.ascii_gutter = ascii_gutter
        self.colour = colour
        self.timestamps = timestamps
        self.live = live
        self._row = bytearray()
        self._row_offset = 0
        self._drawn = False  # a partial row is on screen awaiting its newline
        self._start = time.monotonic()

    def feed(self, data: bytes) -> None:
        """Absorb data, emitting every row it completes."""
        for byte in data:
            self._row.append(byte)
            if len(self._row) == self.width:
                self._emit(final=True)
        # Show the leftovers now rather than holding them for the next byte.
        if self._row and self.live:
            self._emit(final=False)
        self.stream.flush()

    def finalize(self) -> None:
        """Close the current row so the next byte starts on a fresh line."""
        if self._row:
            self._emit(final=True)
            self.stream.flush()

    def _emit(self, final: bool) -> None:
        line = self._render()
        if self._drawn:
            line = "\r" + line
        if final:
            self.stream.write(line + "\n")
            self._drawn = False
            self._row_offset += len(self._row)
            self._row.clear()
        else:
            # Rows only grow, but clearing guards against a stale tail.
            self.stream.write(line + (CLEAR_EOL if self.live else ""))
            self._drawn = True

    def _render(self) -> str:
        dim, reset = (DIM, RESET) if self.colour else ("", "")
        parts = []

        if self.timestamps:
            parts.append(f"{dim}[{time.monotonic() - self._start:9.3f}]{reset} ")

        parts.append(f"{dim}{self._row_offset:08x}{reset}  ")

        for index, byte in enumerate(self._row):
            if index:
                parts.append("  " if index % GROUP == 0 else " ")
            # Dim the padding bytes so real payload stands out at a glance.
            parts.append(f"{dim}00{reset}" if byte == 0 else f"{byte:02x}")

        if self.ascii_gutter:
            parts.append(" " * (_hex_width(self.width) - _hex_width(len(self._row))))
            parts.append(f"  {dim}|{reset}")
            for byte in self._row:
                if 0x20 <= byte <= 0x7E:
                    parts.append(chr(byte))
                else:
                    parts.append(f"{dim}.{reset}")
            parts.append(" " * (self.width - len(self._row)))
            parts.append(f"{dim}|{reset}")

        return "".join(parts)


def print_ports(ports) -> None:
    """Print the available ports, in the style of serial-port-list."""
    if not ports:
        print("\nNo serial ports found.", file=sys.stderr)
        return
    print("\nAvailable serial ports:", file=sys.stderr)
    print(RULE, file=sys.stderr)
    for port in sorted(ports):
        print(f"  {port.device:20s} - {port.description}", file=sys.stderr)
    print(RULE, file=sys.stderr)
    print(f"Total: {len(ports)} port(s)", file=sys.stderr)


def resolve_port(requested):
    """Return the port to open, defaulting to the only USB device attached."""
    if requested:
        return requested

    ports = list_ports.comports()
    # macOS always carries Bluetooth-Incoming-Port and debug-console, which have
    # no USB vendor id; ignoring them makes a bare invocation useful again.
    usb = [p for p in ports if p.vid is not None]
    if len(usb) == 1:
        return usb[0].device

    if not ports:
        print("Error: no serial ports found — nothing to read.", file=sys.stderr)
    elif not usb:
        print("Error: no USB serial device attached; name a port explicitly.",
              file=sys.stderr)
        print_ports(ports)
    else:
        print("Error: several USB serial devices attached; name the one you want.",
              file=sys.stderr)
        print_ports(usb)
    return None


def stream(port, args) -> int:
    """Open the port and dump it until interrupted. Returns an exit status."""
    # A short read timeout keeps both idle detection and Ctrl-C responsive.
    poll = min(0.05, args.idle / 2) if args.idle else 0.05
    framing = f"{args.databits}{args.parity}{args.stopbits:g}"

    try:
        link = serial.Serial(
            port=port,
            baudrate=args.baud,
            bytesize=args.databits,
            parity=args.parity,
            stopbits=args.stopbits,
            rtscts=args.rtscts,
            xonxoff=args.xonxoff,
            timeout=poll,
        )
    except serial.SerialException as exc:
        print(f"Error: could not open {port}: {exc}", file=sys.stderr)
        return 1

    sink = None
    if args.save:
        try:
            sink = open(args.save, "wb")
        except OSError as exc:
            link.close()
            print(f"Error: could not open {args.save} for writing: {exc}",
                  file=sys.stderr)
            return 1

    live = sys.stdout.isatty()
    colour = args.color == "always" or (args.color == "auto" and live)
    dump = HexDump(
        sys.stdout,
        width=args.width,
        ascii_gutter=not args.no_ascii,
        colour=colour,
        timestamps=args.timestamp,
        live=live,
    )

    print(f"\nReading {port} at {args.baud} {framing} — Ctrl-C to stop",
          file=sys.stderr)
    if sink:
        print(f"Saving raw bytes to {args.save}", file=sys.stderr)
    print(RULE, file=sys.stderr)
    sys.stderr.flush()

    total = 0
    started = time.monotonic()
    status = 0
    last_byte = None

    try:
        while True:
            chunk = link.read(1)
            if chunk:
                # Drain whatever else landed while we were blocked.
                waiting = link.in_waiting
                if waiting:
                    chunk += link.read(waiting)
                total += len(chunk)
                if sink:
                    sink.write(chunk)
                    sink.flush()
                dump.feed(chunk)
                last_byte = time.monotonic()
            elif (args.idle and last_byte is not None
                  and time.monotonic() - last_byte >= args.idle):
                dump.finalize()
                last_byte = None
    except KeyboardInterrupt:
        pass
    except serial.SerialException as exc:
        dump.finalize()
        print(f"\nError: {port} went away: {exc}", file=sys.stderr)
        status = 1
    finally:
        dump.finalize()
        link.close()
        if sink:
            sink.close()

    elapsed = time.monotonic() - started
    rate = f", {total / elapsed:.0f} B/s" if elapsed > 0 and total else ""
    print(RULE, file=sys.stderr)
    print(f"Total: {total} byte(s) in {elapsed:.1f}s{rate}", file=sys.stderr)
    return status


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        prog="serial-hexdump",
        description="Stream a serial port as a live, unbuffered hexdump.",
    )
    parser.add_argument("port", nargs="?",
                        help="serial device (default: the only one attached)")
    parser.add_argument("-b", "--baud", type=int, default=115200,
                        help="baud rate (default: 115200)")
    parser.add_argument("-l", "--list", action="store_true",
                        help="list available serial ports and exit")
    parser.add_argument("-w", "--width", type=int, default=16, metavar="BYTES",
                        help="bytes per row (default: 16)")
    parser.add_argument("-t", "--timestamp", action="store_true",
                        help="prefix each row with seconds since start")
    parser.add_argument("--idle", type=float, default=0.25, metavar="SECONDS",
                        help="end a row after this quiet gap; 0 to never break early "
                             "(default: 0.25)")
    parser.add_argument("--databits", type=int, choices=[5, 6, 7, 8], default=8,
                        help="data bits (default: 8)")
    parser.add_argument("--parity", choices=["N", "E", "O", "M", "S"], default="N",
                        help="parity (default: N)")
    parser.add_argument("--stopbits", type=float, choices=[1, 1.5, 2], default=1,
                        help="stop bits (default: 1)")
    parser.add_argument("--rtscts", action="store_true",
                        help="enable RTS/CTS hardware flow control")
    parser.add_argument("--xonxoff", action="store_true",
                        help="enable XON/XOFF software flow control")
    parser.add_argument("--no-ascii", action="store_true",
                        help="drop the trailing ASCII column")
    parser.add_argument("--color", choices=["auto", "always", "never"], default="auto",
                        help="colourise the dump (default: auto)")
    parser.add_argument("--save", metavar="FILE",
                        help="also write the raw bytes to FILE")

    args = parser.parse_args(argv)
    if args.width < 1:
        parser.error("--width must be at least 1")
    if args.idle < 0:
        parser.error("--idle cannot be negative")
    if args.baud < 1:
        parser.error("--baud must be positive")
    return args


def main(argv=None) -> int:
    args = parse_args(argv)

    if args.list:
        print_ports(list_ports.comports())
        return 0

    port = resolve_port(args.port)
    if port is None:
        return 1

    return stream(port, args)


if __name__ == "__main__":
    sys.exit(main())
