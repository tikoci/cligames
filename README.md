# RouterOS /container with CLI games

The command-line games come from two collections, [bsdgames](https://wiki.linuxquestions.org/wiki/BSD_games) and [nbsdgames](https://github.com/abakh/nbsdgames) and packed into Alpine container with a telnet server for use on Mikrotik RouterOS.

![](https://i.ibb.co/9nFtwvz/Screenshot-2023-09-03-at-3-41-10-PM.png)


> **NOTE** /container on RouterOS needed to be setup first to use this container. See https://help.mikrotik.com/docs/display/ROS/Container 

### Installing Container

1. Using the [DockerHub image](https://hub.docker.com/r/ammo74/cligames), RouterOS registry-url must be set for DockerHub:
  ```
  /container/config/set registry-url=https://registry-1.docker.io
  ```
   
  > **TIP**  To pull image from GitHub's Container Registry (GHCR) instead of DockerHub, use: 
  > ```
  > /container/config/set registry-url=https://ghcr.io
  > ```
  > 
  > **NOTE** Only one container registry  can be set at a time RouterOS, so setting `registry-url` will override the previous one.  Existing containers are not effected by changing the registry.  
 

2. Create a VETH for use with `cligames` containers: 
```
/interface/veth/add address=172.18.70.1/24 gateway=172.18.70.254 name=veth-cligames
/ip/address/add address=172.18.70.254/24 interface=veth-cligames
```
3. Create a /container with `cligames`, changing the `root-dir=` as needed:
```
/container/add remote-image=ammo74/cligames:latest interface=veth-cligames root-dir=disk1/cligamesg1 logging=yes hostname=WOPR
```
  > **TIP** For ghcr.io, use `ghcr.io/tikoci/cligames:latest` in `remote-image=`.
  
  > **NOTE**  No mounts or environment varaibles are strickly needed.  However `TERM` can be set in `/container/envs` to control the termcap used by the games, `vt100` or `xterm` would typical.  Other values like `ansi` or `vte` may also work, depending on the game_

4. Wait a few moments, then start the container:
```
/container/start [find tag~"cligames"]
```
5. Use `telnet` to access the games:
```
/system/telnet 172.18.70.1
```
6. Finally, to play a game, type the game name at the telnet `login:` prompt, such as `adventure` or `snake`, with no password.

>.  
> **IMPORTANT**
>
> Consider limiting access to the container using RouterOS firewall.  See details below.



### Games Available

The following games are installed in the `cligames` container.  You can use any of the short names on left side below as the `login:` (again with no password) to play that particular games.

```
WOPR > list
adventure - an exploration game
arithmetic - quiz on simple arithmetic
atc - air traffic controller game
battleship - nbbattleship
battlestar - a tropical adventure game
caesar, rot13 - decrypt caesar ciphers
checkers - nbcheckers
cribbage - Cribbage card game
dab - Dots and Boxes game
darrt - nbdarrt
drop4 - the game of drop4
fifteen - nbfifteen
fisher - nbfisher
gofish - play Go Fish
gomoku - game of 5 in a row
hangman - computer version of the game hangman
jewels, nbjewels - j,l-Move k-Rotate p-Pause q-Quit
klondike - Klondike solitaire card game
memoblocks - nbmemoblocks
miketron - nbmiketron
mines - nbmines
muncher - nbmuncher
pipes - nbpipes
rabbithole - nbrabbithole
redsquare - nbredsquare
reversi - nbreversi
robots - fight off villainous robots
sail - naval combat under sail
snake - display chase game
snakeduel - nbsnakeduel
sos - nbsos
spirhunt - space combat game
sudoku - nbsudoku
worm - Play the growing worm game
wump - hunt the wumpus in an underground cave

```


### Special Login — `joshua`

Instead of game name, the container's telnet server will accept a `login: joshua` with no password to provide access to a shell.  At the shell prompt after login, you can run any of the above list of games.  `^C` (ctrl-c) will exist a game and return to the shell.

To see a list of games, use `list`:
```
WOPR > list
adventure - an exploration game
 [...]
wump - hunt the wumpus in an underground cave
```

Help files can be viewed using `help` (which is aliased to `man`) to see any instructions for a particular game:
```
WOPR > help atc
```

### Game Picker Login – `nbsdgames`

Using `nbsdgames` as `login:` presents a menu to select various games.  _Only games with the "new" bsdgames are selectable_

![](https://i.ibb.co/XssyyS7/Screenshot-2023-09-03-at-4-31-54-PM.png)

![](https://i.ibb.co/zGgVgNm/Screenshot-2023-09-03-at-4-32-31-PM.png)

![](https://i.ibb.co/JRgXygw/Screenshot-2023-09-03-at-4-34-20-PM.png)

### Examples

`atc` - air traffic control simulator

![](https://i.ibb.co/23KqMJN/Screenshot-2023-09-03-at-3-48-38-PM.png)

`worm` - "snake" like game

![](https://i.ibb.co/9ZfZLjR/Screenshot-2023-09-03-at-3-52-57-PM.png)



### Colors and Formatting Problems?

UNIX, and it's ncurses library, uses "termcaps" to display special chars and control screen redraw, controlled by an env var called `TERM`.  While Mikrotik's console is "close" to `TERM=xterm`, which has colors support, some games may still have troubles.  By default, `cligames` assume TERM=vt100.

The default can be overriden by using setting the "TERM" environment variable via /container/envs for the `cligames` container. 

The TERM can be also be specified using `TERM=<terminal> <game_name>` syntax when logged as `joshua`.  For example, with `cribbage`, the TERM= type will change the display to adapt:

`TERM=vt100 cribbage` looks like:
![](https://i.ibb.co/wJV80zL/Screenshot-2023-09-03-at-4-18-46-PM.png)

while `TERM=xterm cribbage` looks like:
![](https://i.ibb.co/hdsVs12/Screenshot-2023-09-03-at-3-59-13-PM.png)

#### What values are valid in TERM=...

The `toe` command can be used from the ncurses will display the allowed terminal types.  
```
WOPR > toe
gnome           GNOME Terminal
gnome-256color  GNOME Terminal with xterm 256-colors
dumb            80-column dumb tty
vte             VTE aka GNOME Terminal
vte-256color    VTE with xterm 256-colors
vt220           DEC VT220
vt102           DEC VT102
vt52            DEC VT52
vt100           DEC VT100 (w/advanced video)
terminology-1.8.1       EFL-based terminal emulator (1.8.1)
tmux-256color   tmux with 256 colors
tmux            tmux terminal multiplexer
terminator      Terminator no line wrap
terminology-1.0.0       EFL-based terminal emulator (1.0.0)
terminology     EFL-based terminal emulator
terminology-0.6.1       EFL-based terminal emulator (0.6.1)
konsole-256color        KDE console window with xterm 256-colors
konsole-linux   KDE console window with Linux keyboard
konsole         KDE console window
xterm-color     generic color xterm
xterm-xfree86   xterm terminal emulator (XFree86)
xterm-kitty     KovIdTTY
xterm           xterm terminal emulator (X Window System)
xterm-256color  xterm with 256 colors
ansi            ansi/pc-term compatible with color
alacritty       alacritty terminal emulator
linux           Linux console
st-0.8          simpleterm 0.8
st-0.6          simpleterm 0.6
st-0.7          simpleterm 0.7
screen-256color GNU Screen with 256 colors
screen          VT 100/ANSI X3.64 virtual terminal
st-direct       simpleterm with direct-color indexing
st-16color      simpleterm with 16-colors
st-256color     simpleterm with 256 colors
sun             Sun Microsystems Inc. workstation console
putty           PuTTY terminal emulator
putty-256color  PuTTY 0.58 with xterm 256-colors
rxvt            rxvt terminal emulator (X Window System)
rxvt-256color   rxvt 2.7.9 with xterm 256-colors
```

If any game does not draw correctly or has other formmating issue.  You can try another terminal type like `TERM=vte` or `TERM=ansi`...or even `TERM=dumb` to turn off most formatting (although some games do not like "dumb").


### Security Considerations

`telnet` is exposed to keep a "retro" feel.  But this is not the most secure approach.  Some considering when using this container.  

- Games launch with the game as the login process, so shell access should not be exposed by the password-less logins.  At some level, this is same as a web server (i.e. unauthenticed access) 

- The "special" `joshua` telnet login provides shell access - so this may require attention.  In most cases, the account should be removed.  To remove the `joshua` login:
  1. Use `/container/shell [find tag~"cligames"]` to access shell from RouterOS running the cligames container.
  2. The at the Alpine shell prompt, use  `
 deluser --remove-home joshua`

- Using a default firewall, the container should be accessible only from the local RouterOS LAN.  It be advisable to consider additional protections in `/ip/firewall/filter` so as not expose the container more broadly.  The specifics depend on your network topology and router config.  

- Stop the container if not using it using:
  ```
  /container/stop [find tag~"cligames"]
  ```
  To restart it, use:  `/container/start [find tag~"cligames"]`
   

**Use at your own risk.**
