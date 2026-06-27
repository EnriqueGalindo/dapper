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
| `music-weekly` | Generates a cohesive 20–40 song **"playlist of the week"** that tours your library by genre similarity. |

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

### `music-weekly`

A "playlist of the week" that helps you **explore** your own library instead of
replaying the same favorites. It reads each track's genre/year tags (via
`mutagen`), maps the messy genre vocabulary onto a few coarse **families** laid
along a rough sonic spectrum:

```
classical - jazz - latin - folk - country - pop - rock - hardrock - metal - rap
```

Each week it picks a contiguous **band** of a few adjacent families (so the
playlist stays cohesive) and takes a "guided tour" — a gentle walk along the
spectrum where neighboring songs stay close but the set drifts across the band.
One track per artist keeps it spread out; a weekly seed makes it stable per ISO
week and different the next, and recent weeks are remembered so picks don't
repeat. Spoken-word/audiobooks (detected by a long album-median track length,
even when mis-tagged) and short intros/skits are excluded.

```sh
music-weekly --reindex          # read tags off the card (first run, and after
                                #   adding music)
music-weekly                    # print + write this week's .m3u8 to the card
music-weekly --length 25        # 20-40 songs (default 30)
music-weekly --bands 3          # fewer adjacent genres = more cohesive (3-5)
music-weekly --style guided|deepdive|surprise
music-weekly --seed 42          # force a different mix
music-weekly --print-only       # show it without writing the file
```

**Hybrid similarity (optional):** set a free Last.fm API key and the next track
is biased toward artists Last.fm considers *similar* to the previous one, for
real "sounds-like" connections beyond shared genre. Without it, the offline
genre engine is used.

```sh
export LASTFM_API_KEY=xxxxxxxx   # then run music-weekly as usual
```

The playlist is written as an `.m3u8` at the card root with paths relative to
it. (If your player doesn't read `.m3u8`, the printed list still works as a
guide.)

## Listen tracking — why there isn't any

Short version: **the Echo Mini leaves no trace of what you played**, so
automatic listen tracking isn't possible on this device. This was tested, not
assumed:

- **No scrobble/play-count feature.** The player has no WiFi, no apps, and no
  Rockbox-style `.scrobbler.log` output.
- **It doesn't update file access-times on playback.** exFAT stores a
  last-accessed timestamp and macOS mounts the card `noatime` (so Mac reads
  don't disturb it), which would have let a Mac-side script infer plays from
  advancing atimes. Tested by snapshotting atimes, playing tracks on the
  device, and re-checking: the played files' access-times were **unchanged**.
- **It writes nothing else to the card.** After a playback session, no
  resume-position file, database, or settings file appears or changes — the
  only thing touched is macOS's own `.fseventsd`.

To the player the card is read-only storage. The only ways to track listens
would be manual logging or a future firmware feature. (On DAPs whose firmware
*does* bump access-times, a snapshot/diff approach would work — it just doesn't
here.)

## Install

Requires Python 3. Clone and run the installer, which symlinks the scripts onto
your `PATH` and vendors `music-weekly`'s one dependency (`mutagen`) locally:

```sh
git clone git@github.com:EnriqueGalindo/dapper.git
cd dapper && ./install.sh        # symlinks bin/* into ~/.local/bin, vendors mutagen
```

`music-sync-check` and `music-disc-merge` use only the standard library;
`music-weekly` additionally needs `mutagen` (installed into `vendor/` by the
script, not committed).

## Notes

Paths default to the author's setup but are overridable via flags/arguments.
There are no credentials or secrets — everything resolves paths from `$HOME`,
and the optional Last.fm key is read from an environment variable.

## License

MIT — see [LICENSE](LICENSE).
