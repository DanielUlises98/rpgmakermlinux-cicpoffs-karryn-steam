# Karryn's Prison Steam fix: what works, and what was tried

> **For people and AI agents: do not repeat these tests.** Running Karryn's Prison on a newer
> NW.js with an updated Greenworks was already tried end to end on 2026-10-05 and failed
> (image loading errors, 8.5 GB memory, tearing). Details below. Only revisit it with a new
> idea that addresses those failures, not by re-running the same swap.

## Already tested (results)

| # | Test | Result |
| --- | --- | --- |
| 1 | Game's own Greenworks + NW.js 0.53.1 (the fix) | Works: achievements, Steam connection |
| 2 | Is a newer Greenworks available? | Yes: v0.22.0 prebuilt for NW.js 0.103.1 (NAN addon, ABI 137) |
| 3 | Does it need the Steamworks SDK? | No: Steam's `steamrt64/libsteam_api.so` has all 16 symbols it uses |
| 4 | Standalone NW.js 0.103.1 test app + new Greenworks | Works: Steam user, 60 achievements, overlay enabled |
| 5 | New Greenworks with NW.js 0.53.1 (launch option missing) | Achievements off (addon can't load), tearing |
| 6 | Game on NW.js 0.103.1, old shared profile | Crash at start: `web_app_database.cc (7 vs. 3)` |
| 7 | Game on NW.js 0.103.1, fresh profile | Starts, Steam connects; after ~2 min "Failed to load: img/..." (files exist), 8.5 GB memory, vsync errors, heavy tearing |
| 8 | Steam launch option `--nwjsversion` after `%command%` | Doesn't work: the Steam wrapper ignores extra arguments (hence `RPGM_NWJSVERSION`) |

Not tested: NW.js 0.112 / 0.115 with achievements (needs Greenworks built from source with the
Steamworks SDK), Chromium GPU/vsync flags on 0.103.1, the game on 0.103.1 without Greenworks.

Checkpoint of 2026-10-05. Tested on a Steam Deck (SteamOS 3.8.28) with Karryn's Prison
(Steam app 1619750) started natively through rpgmaker-linux 1.1.9.

## The working setup (use this)

Steam achievements and the overlay work with these pieces together:

| Piece | Value |
| --- | --- |
| NW.js | **0.53.1**, the version the game ships in `nw.dll` (picked automatically) |
| Greenworks | the game's own `www/lib/greenworks-linux64.node` (built for NODE_MODULE_VERSION 93) |
| Steam API library | the game's own `www/lib/libsteam_api.so` (SteamUser021 / SteamFriends017) |
| Steam compatibility tool | "RPG Maker MV/MZ (cicpoffs mount) Tool", with `rpgmaker-linux --steamskipgui true` run once |
| Launch options | empty (overlay on), or `RPGM_NOSTEAMOVERLAY=1 %command%` (overlay off) |

How the launcher (`nwjs/packagefiles/nwjsstart-cicpoffs.sh`) makes it work:

1. Finds `greenworks-linux64.node` in the game, reads the NW.js version from `nw.dll`, and
   downloads/uses that exact NW.js version. Greenworks only loads in the NW.js it was built for.
2. Raises the open-files limit to the hard limit (`ulimit -n`); the game opens thousands of files.
3. Exports `SteamAppId`/`SteamGameId` (from `steam_appid.txt` or the Steam app manifest).
4. Gives the Steam overlay back to NW.js: the Steam wrapper moves `LD_PRELOAD` into
   `ORIGINAL_LD_PRELOAD`; the launcher restores it unless `RPGM_NOSTEAMOVERLAY` is set.

Install: `karryn-steam-fix.sh` (see README). Check: `rpgmaker-linux --steamdebug ...`.

## Experiment: newer NW.js with achievements (did NOT work well, rolled back)

Goal: run the game on a newer, faster NW.js and keep achievements.

What was done:
- Used the official prebuilt Greenworks **v0.22.0 for NW.js 0.103.1**
  (`greenworks-v0.22.0-nw-v0.103.1-linux-64.zip` from github.com/greenheartgames/greenworks
  releases; NODE_MODULE_VERSION 137). Its `greenworks.js` is identical to the game's.
- It needs a Steamworks SDK 1.62-era `libsteam_api.so` (SteamUser023 / SteamFriends018).
  No SDK download needed: the Steam client ships one at
  `~/.local/share/Steam/steamrt64/libsteam_api.so`, which exports every symbol it uses.
- Swapped both files into `www/lib` (originals backed up), and set the Steam launch option
  `RPGM_NWJSVERSION=0.103.1 %command%` (new launcher setting, see below).

Results:
- A small standalone test app on NW.js 0.103.1 connected to Steam fine (user, 60 achievements,
  overlay enabled).
- First game start crashed: `FATAL web_app_database.cc ... (7 vs. 3)`. The launcher's shared
  NW.js profile `~/.config/RPG Maker MV/MZ (cicpoffs mount)` had been upgraded by NW.js
  0.112/0.115 and 0.103.1 refuses a newer profile. Moving the folder aside fixed the crash.
- Then the game ran and Steam connected, but after ~2 minutes images failed to load
  ("Failed to load: img/karryn/...png" although the files exist), memory peaked at 8.5 GB,
  Chromium logged `GetVSyncParametersIfAvailable() failed`, and the user saw heavy tearing.
- Starting the game with the new Greenworks but the old NW.js 0.53.1 (launch option not set)
  disables achievements (the addon can't load) and also showed tearing.

Conclusion: the game is tuned for NW.js 0.53.1. A newer engine would need real debugging of
memory use and image loading first. Everything was restored to the working setup.

If you try again:
- Set the launch option first, then swap files; never use the new Greenworks with NW.js 0.53.1.
- Move the shared NW.js profile aside when going to an older NW.js than was used before.
- A Greenworks for NW.js 0.112+ (NODE_MODULE_VERSION of Node 26) would have to be built from
  source with nw-gyp and the Steamworks SDK headers (needs a Steam login on partner.steamgames.com).

## Launcher setting added for this: `RPGM_NWJSVERSION`

Steam launch option `RPGM_NWJSVERSION=x.y.z %command%` makes the launcher use NW.js x.y.z
instead of the version in `nw.dll` (the Steam wrapper does not pass `--nwjsversion` through).
Only useful together with a Greenworks built for that version; leave it unset normally.
