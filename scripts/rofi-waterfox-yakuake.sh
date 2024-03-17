#!/bin/bash

titleactivity="Waterfox profiles"
notify-send -t 1000 "${titleactivity}..."
targetfolder="${HOME}/.waterfox"
listwaterfoxes=$(ls -ct1 "${targetfolder}" | cut -d. -f2)
_err=$?
if [ ${_err} -gt 0 ] ; then
{
	notify-send "Caffeine" "Failed to get list from ls -1 targetfolder:${targetfolder:-}"
  exit 1
}
fi
if [[ -z "${listwaterfoxes:-}" ]]; then
{
  notify-send "Caffeine" "Failed and got empty list from ls -1 targetfolder:${targetfolder:-}"
	exit 1
}
fi

chosen=$(echo -n "${listwaterfoxes:-}" | rofi -dmenu -i -p "${titleactivity}" -no-custom)
if [[ -z "${chosen}" ]]; then
{
  # If we have not chosen a network, the previous command will return an empty string
  # and we can exit right away
  exit 1
}
fi
  "${HOME}/_/software/waterfox/waterfox" -P "${chosen}"
  _err=$?
	if [ ${_err} -gt 0 ] ; then 
	{
		notify-send "Caffeine" "Failed to run ${HOME}/_/software/waterfox/waterfox -P ${chosen} "
		exit 1
	}
  else
	{
		exit 0
	}
	fi

