#!/bin/bash
#
#


function instalar() {
	local lista="alacritty
autorandr
dunst
flameshot
i3
i3-dot-files
i3-keyboard-layout
i3status
install_i3wm_to_config.bash
kitty
mpd
mpv
pipewire-media-session
polybar
rofi
scripts
Thunar"
  local one=""
	local cwd="$(pwd)"
  local CURRENTDATE=$(date +%Y%m%d%H%M)
	local CURRENTTIME="$(date +%H:%M)"
	while read -r one ; do 
	{
		[[ -z "${one}" ]] && continue
		[[ -e "${HOME}/.config/${one}" ]] && continue
		[[ -f "${HOME}/.config/${one}" ]] && continue
		[[ -s "${HOME}/.config/${one}" ]] && continue
		[[ -L "${HOME}/.config/${one}" ]] && continue
		[[ -d "${HOME}/.config/${one}" ]] && continue
    ln -s "${cwd}/${one}"  "${HOME}/.config/${one}"
	} done <<< "${lista}"
  local -i _err=0
  if [[ -e "${HOME}/.config/i3/config" ]]; then 
	{
		cp "${HOME}/.config/i3/config" "${HOME}/.config/i3/config.bk.${CURRENTDATE}${CURRENTTIME}"
    _err=$?
		if [ ${_err} -gt 0 ]; then 
		{
      echo "error saving copy err=$_err"
			return 1
		}
		fi
	}
	fi
  
	cp "${cwd}/i3/config"  "${HOME}/.config/i3/config"
	_err=$?
  if [ ${_err} -gt 0 ]; then
  {
    echo "error making ${cwd}/i3/config  ${HOME}/.config/i3/config  err=$_err"
    return 1
  }
  fi
  # chown -R "${USER}" "${HOME}/.config/i3"
  # file_exists_with_spaces 
  sed -i -e 's@'"/home/zeus"'@'"$HOME"'@g' "${HOME}/.config/i3/config"
  _err=$?
 	if [ ${_err} -gt 0 ]; then
  {
    echo "error changing ${HOME}/.config/i3/config text to /home/zeus to $HOME err=$_err"
    return 1
  }
  fi
  
	return 0 
} # end instalar

instalar 


