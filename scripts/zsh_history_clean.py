#!/usr/bin/env python3

"""
zsh_history_clean.py - Remove multi-line `git commit` entries from zsh history

README
------
Cleans multi-line `git commit ...` commands out of your zsh history file
(default: ~/.zsh_history, extended-history format). zsh stores a multi-line
command as backslash-continuation lines (each non-final physical line ends with
`\\`, representing an embedded newline). This tool reconstructs whole entries,
drops the ones that are BOTH multi-line AND a `git commit`, and leaves every
other entry byte-for-byte.

Safe by default: it prints what it WOULD remove and writes nothing. Use --apply
to rewrite the file; a timestamped backup (<file>.bak-YYYYMMDD-HHMMSS) is made
first.

Usage:
  zsh-history-clean                 # dry-run: show what would be removed
  zsh-history-clean --apply         # back up, then remove them
  zsh-history-clean --file PATH     # target a different history file
"""

import argparse
import os
import re
import shutil
import sys
import time

DEFAULT_HISTFILE = os.environ.get("HISTFILE") or os.path.expanduser("~/.zsh_history")

# Extended-history line prefix: ": <start>:<elapsed>;"
PREFIX_RE = re.compile(r"^: \d+:\d+;")
# A `git commit` at a shell command position: the start of a (stripped) line, or
# right after a separator (; & && | ||). Applied to EVERY physical line of an
# entry, so compound pastes like `cd x` / `git add …` / `git commit -F- <<EOF`
# are caught even when the commit isn't the first command.
GIT_COMMIT_RE = re.compile(r"(?:^|[;&|])\s*git\s+commit\b")


def is_continuation(line):
    """True if the line continues onto the next physical line. zsh escapes each
    embedded newline with a trailing backslash and does NOT double literal
    backslashes, so ANY trailing backslash means "continues" — the final
    backslash is always the newline-escape. (Parity is wrong here: a shell
    line-continuation `... \\` is stored as `... \\\\` — the user's backslash
    plus zsh's escape — and is still a continuation.)"""
    return line.endswith("\\")


def command_of(first_line):
    """Strip the extended-history ': ts:elapsed;' prefix to get the command."""
    m = PREFIX_RE.match(first_line)
    return first_line[m.end():] if m else first_line


def group_entries(lines):
    """Group physical lines into entries, joining continuation runs."""
    buf = []
    for line in lines:
        buf.append(line)
        if not is_continuation(line):
            yield buf
            buf = []
    if buf:  # trailing entry with a dangling continuation
        yield buf


def commit_line_in(entry_lines):
    """Return the first physical line (as command text) that runs `git commit`,
    or None. Scans every line, so a git commit anywhere in a multi-line or
    compound entry is found -- not only when it is the first command."""
    for i, line in enumerate(entry_lines):
        cmd = command_of(line) if i == 0 else line
        if GIT_COMMIT_RE.search(cmd):
            return cmd
    return None


def is_target(entry_lines):
    """Removal target = multi-line AND contains a `git commit` command."""
    return len(entry_lines) >= 2 and commit_line_in(entry_lines) is not None


def main():
    p = argparse.ArgumentParser(
        description="Remove multi-line `git commit` entries from zsh history."
    )
    p.add_argument("--file", default=DEFAULT_HISTFILE,
                   help=f"history file (default: {DEFAULT_HISTFILE})")
    p.add_argument("-a", "--apply", action="store_true",
                   help="actually rewrite the file (default: dry-run only)")
    args = p.parse_args()

    # History can hold zsh-metafied (non-UTF-8) bytes, read via surrogateescape.
    # Printing those to a UTF-8 terminal would raise UnicodeEncodeError, so make
    # stdout render undecodable bytes as visible \xNN escapes instead of crashing.
    try:
        sys.stdout.reconfigure(errors="backslashreplace")
    except Exception:
        pass

    path = os.path.expanduser(args.file)
    if not os.path.isfile(path):
        print(f"Error: history file not found: {path}")
        return 1

    # surrogateescape preserves zsh's metafied (non-UTF-8) bytes round-trip.
    with open(path, "r", encoding="utf-8", errors="surrogateescape") as f:
        raw = f.read()

    had_trailing_nl = raw.endswith("\n")
    lines = raw.split("\n")
    if had_trailing_nl:
        lines = lines[:-1]  # drop the empty element after the final newline

    kept, removed = [], []
    for entry in group_entries(lines):
        (removed if is_target(entry) else kept).append(entry)

    def plural(n):
        return "entry" if n == 1 else "entries"

    print(f"History file : {path}")
    print(f"Entries      : {len(kept) + len(removed)} total")
    print(f"To remove    : {len(removed)} multi-line git-commit {plural(len(removed))}")

    if removed:
        print("-" * 60)
        for entry in removed:
            hit = commit_line_in(entry).strip().rstrip("\\").strip()
            print(f"  - {hit[:70]}…  ({len(entry)} lines)")
        print("-" * 60)
    else:
        print("Nothing to remove. ✔")
        return 0

    if not args.apply:
        print("Dry-run: nothing written. Re-run with --apply to remove them.")
        return 0

    backup = f"{path}.bak-{time.strftime('%Y%m%d-%H%M%S')}"
    shutil.copy2(path, backup)
    out_lines = [line for entry in kept for line in entry]
    with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write("\n".join(out_lines))
        if had_trailing_nl:
            f.write("\n")

    print(f"Backup saved : {backup}")
    print(f"Removed      : {len(removed)} {plural(len(removed))}. ✔")
    print("Note: open shells keep their own in-memory history; run `fc -R` "
          "or open a new shell to reload.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
