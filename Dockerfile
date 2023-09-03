FROM alpine

# since games use ncurses libary for colors/control, a TERM must be set 
ENV TERM vt100
ENV HOSTNAME WOPR
# note: this may need to change on a running container depending on terminal

# add hostname & packages, specifically add "bsd-games"
RUN apk update \
 && apk add --no-cache busybox-extras gawk mandoc mandoc-apropos ncurses \
 && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing bsd-games bsd-games-doc nbsdgames nbsdgames-doc 

# add users that map various games in bsd-games games 
RUN adduser -D joshua && echo -e "\n\n" | passwd joshua \
  && for game in `apk info -L bsd-games | awk -F "/" '/bin/ {print $3}'`; do adduser -D $game -s /usr/bin/$game && echo -e "\n\n" | passwd $game; done \
  && for game in `apk info -L nbsdgames | awk -F "/" '/bin/ {print $3}'`; do adduser -D $game -s /usr/bin/$game && echo -e "\n\n" | passwd $game; done

# create "help" alias to man & add command for "list-games"
RUN echo 'PS1="WOPR > "' >> /etc/profile \
    && echo 'alias help=man' >> /etc/profile \
    && echo 'alias list=list-games' >> /etc/profile \
    && echo "#!/bin/sh" > /usr/bin/list-games \
    && echo "/usr/bin/apropos -s 6 ." >> /usr/bin/list-games \ 
    && chmod +x /usr/bin/list-games

# update the "message-of-the-day" shown at login
RUN echo "" > /etc/motd \
  && echo "GREETINGS PROFESSOR FALCON!" >> /etc/motd \
  && echo "DO YOU WANT TO PLAY A GAME?" >> /etc/motd \
  && /usr/bin/apropos -s 6 . >> /etc/motd \
  && echo "" >> /etc/motd

# listen for telnet to make games "network aware"
CMD /usr/sbin/telnetd -p 23 -b 0.0.0.0 -l /bin/login -F 
