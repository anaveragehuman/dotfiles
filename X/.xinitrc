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

# Fcitx variables
eval "$(dbus-launch --sh-syntax --exit-with-session)"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Swap Esc and Caps Lock
setxkbmap -option caps:swapescape

# Gotta go fast
xset r rate 180 80

# Fixes https://github.com/ValveSoftware/steam-for-linux/issues/1025
export STEAM_FRAME_FORCE_CLOSE=1

# Required for physlock
sessreg -a -l tty7 "$USER"

# Start window manager
compton -b --no-dock-shadow --no-dnd-shadow --vsync none --sw-opti \
    --no-fading-openclose --backend glx --glx-no-stencil \
    --glx-use-copysubbuffermesa --glx-use-gpushader4 &
conky &
redshift &
exec awesome

## Fallback
#xterm -geometry 80x50+494+51 &
#exec xterm -geometry 80x30+0+0 -name login

sessreg -d -l tty7 "$USER"
