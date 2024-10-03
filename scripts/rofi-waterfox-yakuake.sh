#!/bin/bash
titleactivity="waterfox profiles"
notify-send -t 1000 "${titleactivity}..." &

function get_uniq_by_touch() {
  set -u
  local -i _err=0
	local targetfolder1="${HOME}/.cache/waterfox"
  local targetfolder2="${HOME}/.waterfox"
  local listwaterfoxes1=$(ls -ct1 "${targetfolder1}" | cut -d. -f2 | cut -d- -f1 )
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
  	notify-send "caffeine" "failed to get list from ls -1 targetfolder:${targetfolder1:-}" &
  }
  fi


	[[ ${DEBUG-} ]] && echo "listwaterfoxes1:$listwaterfoxes1"
  local listwaterfoxes2=$(ls -ct1 "${targetfolder2}" | cut -d. -f2 | cut -d- -f1 )
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
  	notify-send "caffeine" "failed to get list from ls -1 targetfolder:${targetfolder2:-}" &
  }
  fi

  [[ ${DEBUG-} ]] && echo "listwaterfoxes2:$listwaterfoxes2"

  local listwaterfoxes="${listwaterfoxes1-}"
  local one two passvalue=""
  local -i found
  local -i counter=0
  while read -r two; do
  {
    [[ -z "${two-}" ]] && continue
    found=0
    passvalue=""
    (( counter ++ ))
    while read -r one; do
    {
      [[ -z "${one-}" ]] && continue
      [[ ${DEBUG-} ]] && echo "${two}" == "${one}"
      if [[ "${two}" == "${one}" ]] ; then
      {
        [[ ${DEBUG-} ]] && echo "match"
        found=1
        break
      }
      fi
      passvalue="${two}"
      (( counter ++ ))
      if [ ${counter} -gt 5000 ] ; then
      {
        notify-send "caffeine" "warning list too long, exiting loop :${0}:${LINENO}" &
        break
      }
      fi
    }
    done <<< "${listwaterfoxes1-}"
    [[ ${DEBUG-} ]] && echo "${passvalue}"
    if [ ${found} -eq 0 ] ; then
    {
      listwaterfoxes="${listwaterfoxes}
${passvalue}"
    }
    fi
    if [ ${counter} -gt 5000 ] ; then
    {
        notify-send "caffeine" "warning list too long, exiting loop :${0}:${LINENO}" &
        break
    }
    fi
  }
  done <<< "${listwaterfoxes2-}"

	if [[ -z "${listwaterfoxes:-}" ]]; then
  {
    notify-send "caffeine" "failed and got empty list from ls -1 targetfolders \n 1.${targetfolder1:-} \n 2.${targetfolder2:-}" &
  	exit 1
  }
  fi



  echo "${listwaterfoxes}" | grep -v "ini" |  uniq

} # end get_uniq_by_touch

titleactivity="waterfox profiles"
notify-send -t 1000 "${titleactivity}..." &
listwaterfoxes="$(get_uniq_by_touch)"
  _err=$?
	if [ ${_err} -gt 0 ] ; then
	{
		notify-send "caffeine" "failed to run ${HOME}/_/software/waterfox/waterfox -p ${chosen} "
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
