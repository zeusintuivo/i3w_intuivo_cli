#!/bin/bash
# rofi-power
# Use rofi to call systemctl for shutdown, reboot, etc
# 2016 Oliver Kraitschy - http://okraits.de


OPTIONS="Log out\nLock system\nReboot system\nPower-off system\nSuspend system\nHibernate system"

LAUNCHER="wofi --width 30 --lines 7 --dmenu -i -p  "
USE_LOCKER="false"
LOCKER="swaylock"

if [ ${#1} -gt 0 ]; then
  OPTIONS="Exit window manager\n$OPTIONS"
fi

option=$(echo -e "${OPTIONS}" | $LAUNCHER | awk '{print $1}' | tr -d '\r\n')
if [ ${#option} -gt 0 ]
then
    case $option in
      Log)
        swaymsg exit
        ;;
			Lock)
				swaylock -i /home/zeus/Pictures/gringo_come_ride_with_pancho_villa.png
				;;
      Reboot)
        notify-send "Caffeine" "Rebooting system"
        systemctl reboot
        ;;
      Power-off)
        notify-send "Caffeine" "Shutting down system"
        systemctl poweroff
        ;;
      Suspend)
        # "${USE_LOCKER}" && "$LOCKER"
			 	systemctl suspend
        ;;
      Hibernate)
        # "${USE_LOCKER}" && "$LOCKER"
			 	systemctl hibernate
        ;;
      *)
        ;;
    esac
fi
