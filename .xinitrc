#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
[ -f $sysresources ] && xrdb -merge $sysresources
[ -f $sysmodmap ] && xmodmap $sysmodmap
[ -f "$userresources" ] && xrdb -merge "$userresources"
[ -f "$usermodmap" ] && xmodmap "$usermodmap"

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

eval "$(dbus-launch --sh-syntax --exit-with-session)"

# Swap Esc and Caps Lock
setxkbmap -option caps:swapescape

# Gotta go fast
xset r rate 180 80

# don't make Qt programs huge
export QT_AUTO_SCREEN_SCALE_FACTOR=0

# Fixes https://github.com/ValveSoftware/steam-for-linux/issues/1025
export STEAM_FRAME_FORCE_CLOSE=1

# Required for physlock
sessreg -a -l tty7 "$USER"

# Start window manager
picom --experimental-backends -b &
conky &
redshift &
awesome

## Fallback
#xterm -geometry 80x50+494+51 &
#exec xterm -geometry 80x30+0+0 -name login

sessreg -d -l tty7 "$USER"
