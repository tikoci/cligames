# RouterOS /container with CLI games

The command-line games come from two collections, [bsdgames](https://wiki.linuxquestions.org/wiki/BSD_games) and [nbsdgames](https://github.com/abakh/nbsdgames) and packed into Alpine container with a telnet server for use on Mikrotik RouterOS.

### Installing Container

1. Use https://ghcr.io as regitry-url to pull image from GitHub: 
```
/container/config/set registry-url=https://ghcr.io
```
> _Note: This will replace your existing registry such as DockerHub so the GitHub container will load. After install `cligames` you can reset to DockerHub using_  `registry-url=https://registry-1.docker.io`

2. Create a VETH for use with `cligames` containers: 
```
/interface/veth/add address=172.18.70.1/24 gateway=172.18.70.254 name=veth-cligames
/ip/address/add address=172.18.70.254/24 interface=veth-cligames
```
3. Create a /container with `cligames`, changing the `root-dir=` as needed:
```
/container/add remote-image=ghcr.io/tikoci/cligames:latest interface=veth-cligames root-dir=disk1/cligamesg1 logging=yes hostname=WOPR
```
> _Note: No mounts or environment varaibles are strickly needed.  However `TERM` can be set in `/container/envs` to control the termcap used by the games, `vt100` (the default) or `xterm` would typical._

4. Wait a few moments, then start the container:
```
/container/start [find tag~"cligames"]
```
5. Use `telnet` to access the games:
```
/system/telnet 172.18.70.1
```
6. Finally, to play a game, type the game name at the telnet `login:` prompt, such as `adventure`, with no password.


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
WOPR > help battleship
```

### Security Note
By default, the container should be accessible only via the local RouterOS device.  While a `dst-nat` in `/ip/firewall/nat` could be used to map 23/tcp port of `cligames` telnet server at 172.18.70.1 — this would not be advisable without additional protections in `/ip/firewall/filter` so as not expose the container on the internet.

**Use at your own risk.**
