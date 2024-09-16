#!/bin/bash
# wifi-menu

titleactivity="Getting WiFi networks"
notify-send -t 1000 "${titleactivity}..."
raw_list_of_networks="$(nmcli dev wifi list | grep -v "^*")"
# list_of_networks="$(nmcli -g SSID device wifi)"
_err=$?
if [ ${_err} -gt 0 ] ; then
{
  notify-send "Caffeine" "Failed command <nmcli dev wifi list> : _err:$_err _msg:$raw_list_of_networks"
  exit 1
}
fi


if [[ -z "${raw_list_of_networks:-}" ]] ; then
{
  notify-send "Caffeine" "Failed and got empty list of networks <nmcli dev wifi list>"
  exit 1
}
fi

# Teaching script 1
# 1st attempt but it uses SSD interaction
# count_response=$(wc -l <<< "${raw_list_of_networks:-}")
# _err=$?
# if [ ${_err} -gt 0 ] ; then
# {
#   notify-send "Caffeine" "Failed command <wc -l >: _err:$_err _msg:$count_response "
#   exit 1
# }
# fi
# if [ ${count_response} -lt 2 ] ; then
# {
#   notify-send "Caffeine" "Failed count seems networks are empty <count_response=${count_response}> :list_of_networks:${list_of_networks:-}  _err:$_err _msg:$count_response "
#   exit 1
# }
# fi
# (( count_response-- ))
# list_of_networks="$(tail -${count_response} <<< "${raw_list_of_networks:-}" )"
# _err=$?
# if [ ${_err} -gt 0 ] ; then
# {
#   notify-send "Caffeine" "Failed 2nd  command <nmcli dev wifi list> : _err:$_err _msg:$list_of_networks"
#   exit 1
# }
# fi
# if [[ -z "${list_of_networks:-}" ]] ; then
# {
#   notify-send "Caffeine" "Failed 2nd and got empty list of networks <nmcli dev wifi list>"
#   exit 1
# }
# fi


# Teaching script 2
# 2dn attempt count with while loop then tail, but tail still uses SSD interaction
# count_response=0
# while read -r line; do 
# {
#   [[ -z "${line:-}" ]] && continue
#   (( count_response++ ))
# }
# done <<< "${raw_list_of_networks:-}"
# _err=$?
# if [ ${_err} -gt 0 ] ; then
# {
#   notify-send "Caffeine" "Failed command <wc -l >: _err:$_err _msg:$count_response "
#   exit 1
# }
# fi
# if [ ${count_response} -lt 2 ] ; then
# {
#   notify-send "Caffeine" "Failed count seems networks are empty <count_response=${count_response}> :list_of_networks:${list_of_networks:-}  _err:$_err _msg:$count_response "
#   exit 1
# }
# fi
# (( count_response-- ))
# list_of_networks="$(tail -${count_response} <<< "${raw_list_of_networks:-}" )"
# _err=$?
# if [ ${_err} -gt 0 ] ; then
# {
#   notify-send "Caffeine" "Failed 2nd  command <nmcli dev wifi list> : _err:$_err _msg:$list_of_networks"
#   exit 1
# }
# fi
# if [[ -z "${list_of_networks:-}" ]] ; then
# {
#   notify-send "Caffeine" "Failed 2nd and got empty list of networks <nmcli dev wifi list>"
#   exit 1
# }
# fi


# Teaching script 3
# 3rd attemp crop from the start no counting
count_response=0
list_of_networks=""
while read -r line; do 
{
  [[ -z "${line:-}" ]] && continue
  (( count_response++ ))
	[ ${count_response} -eq 1 ] && continue
  if [[ -z "${list_of_networks:-}" ]] ; then
	{
		list_of_networks="${line}"
	}
  else
	{
		list_of_networks="${list_of_networks}
${line}"
	}
	fi
}
done <<< "${raw_list_of_networks:-}"
_err=$?
if [ ${_err} -gt 0 ] ; then
{
  notify-send "Caffeine" "Failed command <while loop raw_list_of_networks:- >: _err:$_err _msg:$count_response "
  exit 1
}
fi
if [[ -z "${list_of_networks:-}" ]] ; then
{
  notify-send "Caffeine" "Failed 3rd clean and got empty list of networks <nmcli dev wifi list>"
  exit 1
}
fi

list_saved_wifi_passwords=""
# Fetch saved wifis async while person chooses wifi
(
  list_saved_wifi_passwords="$(nmcli -g NAME connection)"
) &


chosen_network=$(echo -n "${list_of_networks:-}"  | rofi -dmenu -i -p "Wifi network" -no-custom)
# chosen_network=$(nmcli -g SSID device wifi | rofi -dmenu -i -p "Wifi network" -no-custom)
if [[ -z $chosen_network ]]; then
    # If we have not chosen a network, the previous command will return an empty string
    # and we can exit right away
    exit 1
fi

# DEBUG 
notify-send "Caffeine" "Choosen Wifi: $chosen_network"
chosen_network_name=$(echo ${chosen_network} | cut -d' ' -f2 )

notify-send "Caffeine" "Choosen Wifi name: $chosen_network_name"
if [[ -n $(grep $chosen_network_name <<< "${list_saved_wifi_passwords}") ]]; then
{
	_msg=$(nmcli connection up id $chosen_network_name)
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
		notify-send "Caffeine" "Failed command <nmcli connection up id $chosen_network_name>: _err:$_err _msg:$_msg "
    exit 1
  }
  fi
  notify-send "Caffeine" "Connected: $chosen_network_name"
}
else
{
	_msg=$(nmcli device wifi connect $chosen_network_name)
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
		notify-send "Caffeine" "Failed command <nmcli device wifi connect $chosen_network_name>: _err:$_err _msg:$_msg "
    exit 1
  } 
  fi
  notify-send "Caffeine" "Connected: $chosen_network_name"
}
fi


