#!/bin/bash

titleactivity="Session list configurations"
notify-send -t 1000 "${titleactivity}..." &
targetfolder="${HOME}/yakuake_sessions_*_list"
# ls -ct1 "${HOME}/yakuake_sessions_*_list" | cut -d_ -f3
# list_of_files=$(ls -ct1 "${targetfolder}" | cut -d_ -f3 )
list_of_files=""
list_of_files=$(ls -ct1 "${HOME}"/yakuake_sessions_*_list | sed 's/_list//g' | cut -d_ -f3-  )
_err=$?
if [ ${_err} -gt 0 ] ; then
{
  notify-send "Caffeine" "Failed to get list from ls -1 targetfolder:${targetfolder:-}" &
  exit 1
}
fi
if [[ -z "${list_of_files:-}" ]] ; then
{
  notify-send "Caffeine" "Failed and got empty list from ls -1 targetfolder:${targetfolder:-}" &
  exit 1
}
fi

title="Yakuake session config"
chosen=$(echo -n "${list_of_files:-}"  |wofi --dmenu -i -p "${title}" --no-actions --gtk-dark --style "${HOME}/.config/wofi/style.css" -no-custom  )
if [[ -z "${chosen:-}" ]]; then
{
  # If we have not chosen a network, the previous command will return an empty string
  # and we can exit right away
  exit 1
}
fi
file_list="${HOME}/yakuake_sessions_${chosen}_list"
if [[ -e "${file_list}" ]]; then
{
  touch "${file_list}"
  yakuake_sessions "${file_list}" &
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    notify-send "Caffeine" "Failed to run ${file_list}" &
    exit 1
  }
  else
  {
    exit 0
  }
  fi
}
else
{
  notify-send "Caffeine" "Did not find ${file_list}" &
  exit 1
}
fi
