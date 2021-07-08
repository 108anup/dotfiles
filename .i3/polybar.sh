#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch polybar
# polybar example -r >> /tmp/polybar.log 2>&1 &

# Depending on whether multiple monitors are there, launch polybar accordingly.
if type "xrandr"; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar example -r >> /tmp/polybar.log 2>&1 &
    done
else
    polybar example -r >> /tmp/polybar.log 2>&1 &
fi
