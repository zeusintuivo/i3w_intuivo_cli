#!/bin/bash
#
#


function instalar() {
  local lista="alacritty
    autorandr
    dunst
    flameshot
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

  [[ -L "${HOME}/.config/install_i3wm_to_config.bash" ]] &&   unlink "${HOME}/.config/install_i3wm_to_config.bash"
  [[ -e "${HOME}/.config/install_i3wm_to_config.bash" ]] &&   rm -rf "${HOME}/.config/install_i3wm_to_config.bash"


  [[ -L "${HOME}/.config/i3" ]] &&   unlink "${HOME}/.config/i3"
  [[ -e "${HOME}/.config/i3" ]] &&   rm -rf "${HOME}/.config/i3"
  [[ ! -d "${HOME}/.config/i3" ]] &&  mkdir -p "${HOME}/.config/i3"
  if [[ -e "${HOME}/.config/i3/config" ]]; then
  {
    cp "${HOME}/.config/i3/config" "${HOME}/.config/i3/config.bk.${CURRENTDATE}${CURRENTTIME}"
    _err=$?
    if [ ${_err} -gt 0 ]; then
    {
      echo "$0:$LINENO error saving copy \"${HOME}/.config/i3/config.bk.${CURRENTDATE}${CURRENTTIME}\" err=$_err"
      return 1
    }
    fi
  }
  fi

  echo "$0:$LINENO  mkdir -p \"${HOME}/.local/share/i3status-rust\" "
  [[ -L "${HOME}/.local/share/i3status-rust" ]] && unlink "${HOME}/.local/share/i3status-rust"
  [[ -e "${HOME}/.local/share/i3status-rust" ]] && rm -rf "${HOME}/.local/share/i3status-rust"
  [[ ! -d "${HOME}/.local/share/" ]] &&  mkdir -p "${HOME}/.local/share/"
  [[ ! -L "${HOME}/.local/share/i3status-rust" ]] &&   ln -s "${cwd}/i3status-rust" "${HOME}/.local/share/i3status-rust"

  # if [[ -e "${HOME}/.local/share/i3status-rust/config.toml" ]]; then
  # {
  #   # cp -R "${cwd}/i3status-rust" "${HOME}/.local/share/"
  #   cp "${HOME}/.local/share/i3status-rust/config.toml" "${HOME}/.local/share/i3status-rust/config.toml.bk.${CURRENTDATE}${CURRENTTIME}"
  #   _err=$?
  #   if [ ${_err} -gt 0 ]; then
  #   {
  #     echo "$0:$LINENO error saving copy \"${HOME}/.local/share/i3status-rust/config.toml.bk.${CURRENTDATE}${CURRENTTIME}\"  err=$_err"
  #     return 1
  #   }
  #   fi
  # }
  # fi


  local _msg=""
  echo "$0:$LINENO cp \"${cwd}/i3/config\"  \"${HOME}/.config/i3/config\""
  _msg=$(cp "${cwd}/i3/config"  "${HOME}/.config/i3/config" 2>&1 )
  _err=$?
  if [ ${_err} -gt 0 ]; then
  {
    if [[ "${_msg}" == *"are the same file"*  ]] ; then
    {
      echo "$0:$LINENO ok "
    }
    else
    {
      echo "$0:$LINENO error making ${cwd}/i3/config  ${HOME}/.config/i3/config  err=$_err"
      return 1
    }
    fi
  }
  fi
  # chown -R "${USER}" "${HOME}/.config/i3"
  # file_exists_with_spaces
  sed -i -e 's@'"/home/zeus"'@'"$HOME"'@g' "${HOME}/.config/i3/config"
  _err=$?
   if [ ${_err} -gt 0 ]; then
  {
    echo "$0:$LINENO error changing ${HOME}/.config/i3/config text to /home/zeus to $HOME err=$_err"
    return 1
  }
  fi

  return 0
} # end instalar

instalar


