# dapper

Small command-line tools for keeping a music SD card tidy on a budget DAP
(digital audio player) — built for a [Snowsky Echo Mini](https://www.linsoul.com/products/fiio-snowsky-echo-mini)
with an exFAT card laid out as `Artist/Album/track`, sourced from an Apple
Music library plus older iPod rips.

The player has no WiFi, no app, and writes nothing back to the card, so these
run on a Mac (Python 3, standard library only) against the mounted card.

## Tools

| Command | What it does |
|---|---|
| `music-sync-check` | Reports which albums are **new or incomplete** on the card vs. your library, and optionally copies them over. |
| `music-disc-merge` | Merges **multi-disc albums** split across sibling folders (`Time Disc 1/2/3`) into one folder. |
| `music-listens` | **Experimental.** Detects what was played on the device by reading the card's per-file access timestamps. |

### `music-sync-check`

Compares a source library against the card at **Artist/Album folder**
granularity — not by filename, because the same track is named differently in
each library (Apple Music `1-04 Voices.mp3` vs. an iPod rip
`Artist - Album - 04. Title.mp3`), so a filename diff would flag everything as
new. For albums present on both sides it compares track counts to catch
partial copies. Unicode (NFC), curly quotes, and dashes are normalized so
typographic differences don't cause false mismatches.

```sh
music-sync-check                 # report new / incomplete albums (read-only)
music-sync-check --show-extra    # also list card-only albums (old rips)
music-sync-check --copy          # rsync the new albums to the card
```

Defaults: source `~/Music/Music/Media.localized/Music`, dest `/Volumes/MUSIC`
(override with `-s` / `-d`). `--copy` excludes macOS AppleDouble files and runs
`dot_clean` afterward.

### `music-disc-merge`

Finds sibling folders that differ only by a disc marker (`Album Disc 1`,
`Album [Disc 2]`, `Album CD3`) and merges them into a single `Album` folder.
**Dry-run by default** — pass `--apply` to move files.

```sh
music-disc-merge /Volumes/MUSIC              # preview
music-disc-merge /Volumes/MUSIC --apply      # do it
```

- Adds a `d#-` filename prefix **only** when two discs have a colliding
  filename (`--prefix auto`); otherwise leaves names untouched.
- Skips single-disc "orphan" groups (incomplete rips, or discs whose folder
  names don't match) unless you pass `--include-orphans`.

### `music-listens` (experimental)

The player can't run a script and doesn't log plays. The one possible signal:
exFAT stores a **last-accessed time** per file, and macOS mounts the card
`noatime` so reads on the Mac don't disturb it. *If* the player's firmware
updates access-time on playback, a file whose atime advanced since the last
snapshot was played on the device. Whether the Echo Mini actually does this is
unproven — `snapshot` + `check` are the experiment.

```sh
music-listens snapshot           # record current access-times
#   ...play tracks on the DAP, reinsert the card...
music-listens check              # files whose atime advanced (= played?)
music-listens check --commit     # add to cumulative counts, re-snapshot
music-listens top                # cumulative most-played
```

## Install

Requires Python 3 (uses only the standard library). Clone and symlink the
scripts onto your `PATH`:

```sh
git clone git@github.com:EnriqueGalindo/dapper.git
cd dapper && ./install.sh        # symlinks bin/* into ~/.local/bin
```

## Notes

Paths default to the author's setup but are overridable via flags/arguments.
There are no credentials or secrets — everything resolves paths from `$HOME`.

## License

MIT — see [LICENSE](LICENSE).
