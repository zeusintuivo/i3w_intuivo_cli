#!/bin/bash

titleactivity="Firefox profiles"
notify-send -t 1000 "${titleactivity}..."
targetfolder="${HOME}/.cache/mozilla/firefox"
listfirefoxes=$(ls -ct1 "${targetfolder}" | cut -d. -f2 | cut -d- -f1 )
_err=$?
if [ ${_err} -gt 0 ] ; then
{
	notify-send "Caffeine" "Failed to get list from ls -1 targetfolder:${targetfolder:-}"
  exit 1
}
fi
if [[ -z "${listfirefoxes:-}" ]]; then
{
  notify-send "Caffeine" "Failed and got empty list from ls -1 targetfolder:${targetfolder:-}"
	exit 1
}
fi

chosen=$(echo -n "${listfirefoxes:-}" | rofi -dmenu -i -p "${titleactivity}" -no-custom)
if [[ -z "${chosen}" ]]; then
{
  # If we have not chosen a network, the previous command will return an empty string
  # and we can exit right away
  exit 1
}
fi
  firefox_path_executable="firefox"
  "${firefox_path_executable}" -P "${chosen}"
  _err=$?
	if [ ${_err} -gt 0 ] ; then 
	{
		notify-send "Caffeine" "Failed to run ${firefox_path_executable} -P ${chosen} "
		exit 1
	}
  else
	{
		exit 0
	}
	fi

