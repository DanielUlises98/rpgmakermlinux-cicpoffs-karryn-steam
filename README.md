# Steam achievements fix for Karryn's Prison (Steam Deck / Linux)

> **This is an unofficial fork** of [bakustarver/rpgmakermlinux-cicpoffs](https://github.com/bakustarver/rpgmakermlinux-cicpoffs) (rpgmaker-linux).
> It adds one fix to the launcher so that **Steam achievements and the Steam overlay work** for
> [Karryn's Prison](https://store.steampowered.com/app/1619750/) when it runs natively on Linux
> instead of through Proton. Please don't report problems with this fix to the original project.
> All credit for rpgmaker-linux goes to bakustarver. The original README is below.

Achievements come from the real Steam client; nothing is faked or unlocked for you.

## Why achievements don't work without this fix

- **Wrong NW.js version.** The game ships its own Linux Steam plugin (Greenworks), which only loads in
  the NW.js version the game was built with (0.53.1). rpgmaker-linux normally picks the newest NW.js,
  so the plugin fails to load, silently.
- **Too many open files.** NW.js 0.53.1 sets a low limit on open files, and Karryn's Prison gets stuck
  while loading.
- **Steam overlay removed.** The Steam compatibility tool removes the overlay before the game starts
  and never puts it back.

The fixed launcher detects games that ship Linux Greenworks, downloads and uses the matching NW.js
version, raises the open-file limit, passes the Steam app ID, and gives the overlay back. Other games
are not affected. Only one file changes: `nwjs/packagefiles/nwjsstart-cicpoffs.sh`.

## Install on a Steam Deck

Do this in **Desktop Mode** (Steam button → Power → Switch to Desktop).
A "terminal" is the app called **Konsole** (app launcher at the bottom left → System → Konsole).
To run a command, copy it, paste it into Konsole with **Ctrl+Shift+V**, and press **Enter**.

1. **Back up your saves.** In Steam, right-click Karryn's Prison → Manage → Browse local files.
   Open the `www` folder and copy the `save` folder somewhere safe (for example your Documents folder).
2. **Install rpgmaker-linux** (skip this if you already have it):
   ```
   wget -qO- "https://raw.githubusercontent.com/bakustarver/rpgmakermlinux-cicpoffs/main/installgithub.sh" | bash
   ```
3. **Install this fix:**
   ```
   wget -qO- "https://raw.githubusercontent.com/DanielUlises98/rpgmakermlinux-cicpoffs-karryn-steam/steam-greenworks/karryn-steam-fix.sh" | bash
   ```
   It should end with `Done! The Steam achievements fix is installed.`
4. **Restart Steam** (Steam menu → Exit, then open Steam again) so it sees the new compatibility tool.
5. **Switch the game from Proton to rpgmaker-linux.** In Steam, right-click Karryn's Prison →
   Properties → Compatibility → tick "Force the use of a specific Steam Play compatibility tool" →
   choose **RPG Maker MV/MZ (cicpoffs mount) Tool**.
6. **Skip the launcher's menu when starting from Steam:**
   ```
   rpgmaker-linux --steamskipgui true
   ```
7. **Play** from Steam. The first start takes longer because NW.js 0.53.1 is downloaded once.
   Achievements show up in your Steam profile as you unlock them.

### If the Steam overlay causes problems

In Steam, right-click the game → Properties → General → Launch options, and enter:
```
RPGM_NOSTEAMOVERLAY=1 %command%
```
Achievements still unlock, but no pop-up appears in the game.

### Checking what's going on

Start the game from Konsole with extra information about Steam:
```
rpgmaker-linux --steamdebug --gamepath "PATH-TO-THE-GAME-FOLDER"
```
(Use the folder that "Browse local files" opens.) Lines starting with `[steamdebug]` show the Steam
files found, the NW.js version the game needs, missing libraries, and the Steam app ID.

### Updating rpgmaker-linux removes the fix

`rpgmaker-linux --fullupdate` or reinstalling rpgmaker-linux puts the original launcher back.
Run the command from step 3 again afterwards. If rpgmaker-linux has a newer version than this fix
was made for (1.1.9), the script stops without changing anything.

### Undo the fix

```
wget -qO- "https://raw.githubusercontent.com/DanielUlises98/rpgmakermlinux-cicpoffs-karryn-steam/steam-greenworks/karryn-steam-fix.sh" | bash -s -- --restore
```
To go back to Proton, choose a Proton version again in step 5.

### Status

- Tested on a Steam Deck in Desktop Mode: achievements unlock and show in the Steam profile.
- Not tested yet: the Steam overlay in Game Mode, and whether saves made under Proton carry over
  (that's why step 1 backs them up).

### License

GPL-3.0, the same as the original project. See [LICENSE](LICENSE).

---

#  RPG Maker Launcher for Linux 
The bash wrapper uses [native Linux libraries](DEPENDENCIES.md) to run Windows games. It creates a local port of the Linux version from the Windows port and then executes it.
Initially, it supported only RPG Maker MV and MZ, but now it also supports RPG Maker XP, VX, VX Ace, MV, MZ, TyranoBuilder, Godot, Construct 2/3, and Nscripter.

Priority is primarily on RPG Maker MV/MZ. (if you have errors with XP, VX, Vx Ace address this [link](https://github.com/mkxp-z/mkxp-z)).

#### Contains the following features (RPG Maker MV / MZ):
- Sharp increase in FPS (2 to 4 times more compared to Wine, viewable by pressing the F2 key).
- Download and select any version of NW.js (using the command line and GUI).
- Install the Text Hooker plug-in, which automatically copies the game's dialogues to your clipboard.
- Update Pixi 5 libraries for RPG Maker MV games to enhance performance.
- Launch a game using the command line.
- Display the NW.js, Node.js, and Chromium versions of your game.
- Can be used as compatibility tool in steam for Windows games.
- Native support for four architectures: x86-64, i386, armhf, and arm64.


 
After installing the program you can run the game using an application - "RPG Maker MV/MZ (cicpoffs mount)"

#
![img](https://github.com/bakustarver/rpgmakermlinux-cicpoffs/assets/66978329/4d55e52a-fe6d-44a5-a7bb-9380218d16f1)
![1123](https://github.com/bakustarver/rpgmakermlinux-cicpoffs/assets/66978329/58e47de8-3cce-47a8-a183-544c4ce1a624)

## Installation || Update
```
wget -qO- "https://raw.githubusercontent.com/bakustarver/rpgmakermlinux-cicpoffs/main/installgithub.sh" | bash
```


## Custom path
If you want to change the default installation directory, use the following command before installation
```
echo "$HOME/somedirpath/" > "$HOME/.config/defrpgmakerlinuxpath.txt"
```

## Uninstall
```
wget -qO- "https://raw.githubusercontent.com/bakustarver/rpgmakermlinux-cicpoffs/main/uninstallgithub.sh" | bash
```
or 
```
rm -rf "$HOME/desktopapps/nwjs" && rm "$HOME/.local/share/applications/nwjstest.desktop" && rm "$HOME/.local/bin/rpgmaker-linux"
```

## Command line Commands

#### To start the RPG Maker game, use the following command
```
rpgmaker-linux 
```

```
rpgmaker-linux --gamepath /path/rpg-maker-game/
```
#### Show version of the program
```
rpgmaker-linux --version
```

#### Update the nwjs to the latest version
```
rpgmaker-linux --updatenwjs
```

#### To show the versions of the RPG Maker game libraries
```
rpgmaker-linux --gamepath /path/rpg-maker-game/ --printrpgmakerlibversions
```

#### Choose the version of NWJS you want to use:
```
rpgmaker-linux --nwjsversion 0.40.0 --gamepath /path/rpg-maker-game/
```
####  Send an anonymous report to developer about game data, system information, engine for fixing bugs and errors :
```
rpgmaker-linux --bugreport
```
#### Show donation links:
```
rpgmaker-linux --sourcelinks
```
####  Disable the GUI menu in steam :
```
rpgmaker-linux --steamskipgui true
```

### Interesting projects

- [mkxp-z](https://github.com/mkxp-z/mkxp-z) - Open-source cross-platform player for (some) RPG Maker XP / VX / VX Ace games. A very heavily modified fork of mkxp. RGSS on steroids with a stupid name. 
- [easyrpg](https://easyrpg.org/) - EasyRPG is a community project to create a free, open source, role playing game creation tool, compatible with RPG Maker 2000/2003 games.
- [Painless-Porter-CLI](https://github.com/m5kro/Painless-Porter-CLI) - A tool to quickly port RPG Maker MV and MZ games to Linux and MacOS and upload to file hosters. 
- [ruffle](https://github.com/ruffle-rs/ruffle) - A Flash Player emulator written in Rust 
- [RPGMaker MV/MZ Save Editor](https://www.appimagehub.com/p/2166407/) - This is a offile tool for editing RPGMaker save files. It currently supports save files written by RPG Maker MV (.rpgsave) & MZ (.rmmzsave).
- [Kawariki](https://github.com/Orochimarufan/Kawariki) - An alternative tool for launching games focused on Steam.
- [Game2Text](https://github.com/mathewthe2/Game2Text) -  Complete toolbox for gamifying language learning.
##### If anyone is interested in the macOS version
- [RPG Maker MacOS Launcher](https://github.com/m5kro/RPG-Maker-MacOS-Launcher)
- [Xenolauncher macOS](https://github.com/m5kro/Xenolauncher)

### Professional version:
<a href="https://bakurpg.itch.io/rpg-maker-mv-mz-for-linux"><img src="https://github.com/user-attachments/assets/ed684afc-9959-4eb1-892b-f48236bd091e" width="600"></a>

For limited [Linux Gaming celebration days](proversion/DISCOUNTSLISTPROVERSION.md), you can get the professional version at a reduced price.

  
## Support me:
[Patreon](https://www.patreon.com/user/about?u=121421184)
[Buymeacoffee](https://www.buymeacoffee.com/rpgmakerlinux)




















##















