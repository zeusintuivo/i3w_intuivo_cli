#!/bin/bash
# wifi-menu

echo <<-EOF
Neo t, let’s verify that our Wi-Fi card supports AP mode:

$ nmcli -f WIFI-PROPERTIES.AP device show wlan0

create an access point with the name testpot and a password 12345678:

$ nmcli d wifi hotspot ifname wlan0 ssid testspot password 12345678

 view all the connections we have in the system:

$ nmcli con show
NAME                UUID                                  TYPE      DEVICE
Hotspot             149d0e97-0958-46ff-a748-e71ccc21d0cd  wifi      wlan0
Wired connection 1  7fb46fdc-3505-49f6-aeb7-edb17e26611c  ethernet  usb0
lo                  3dcbbd88-d7f0-4426-b87c-9c7ab3ae0e37  loopback  lo



4. Creating the Access Point Sequentially

Alternatively, we can create a wireless access point sequentially running one command after another.

Let’s begin by running the following command to create the SSID for our hotspot on the wlan0 interface:

$ sudo nmcli connection add type wifi ifname wlan0 con-name testhotspot autoconnect yes ssid testhotspot
Connection 'testhotspot' (23429383-f83f-4fbe-bbcc-9d64fcf5c7b9) successfully added.

Next, let’s add more properties to our connection:

$ sudo nmcli connection modify testhotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared

Then, we must configure WPA2-PSK security for our access point:

$ sudo nmcli connection modify testhotspot wifi-sec.key-mgmt wpa-psk
$ sudo nmcli connection modify testhotspot wifi-sec.psk 12345678

Lastly, let’s activate the access point we’ve created:

$ sudo nmcli connection up testhotspot
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/7)

We must note that for the access point to start automatically on boot, we must enable ‘autoconnect‘:

$ sudo nmcli connection modify testhotspot connection.autoconnect yes

To turn it down, we run:

$ sudo nmcli connection down testhotspot
Connection 'testhotspot' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/7)

We can also view the active connection on our system:

$ nmcli con show --active
NAME                UUID                                  TYPE      DEVICE
testhotspot         23429383-f83f-4fbe-bbcc-9d64fcf5c7b9  wifi      wlan0
Wired connection 1  7fb46fdc-3505-49f6-aeb7-edb17e26611c  ethernet  usb0
lo                  3dcbbd88-d7f0-4426-b87c-9c7ab3ae0e37  loopback  lo




5. Creating a Wireless Access Point in a Redhat System

Finally, in Redhat systems, we can use the following approach to create an access point.

First, we create the access point and its properties:

$ nmcli device wifi hotspot ifname wlan0 con-name RedHotspot ssid RedHotspot password 12345678
Device 'wlan0' successfully activated with '31adcef4-6d35-4727-844d-06934a3d5f56'.
Hint: "nmcli dev wifi show-password" shows the Wi-Fi name and password.

Optionally, we can set the security protocol:

$ nmcli connection modify RedHotspot 802-11-wireless-security.key-mgmt wpa-psk

If we don’t set the security protocol, nmcli will automatically set it.

In some configurations, sae (Simultaneous Authentication of Equals) is used instead of wpa-psk. The danger of using this option is that not all interfaces support it. So if we set it and our Wi-Fi card doesn’t support wpa3-sae, we’ll experience an error.

Next, let’s run:

$ nmcli connection modify RedHotspot ipv4.addresses 192.0.1.254/24

By default, the NetworkManager uses the 10.24.0.0/24 network to assign addresses. Using the above command, we can specify a network range of our choice. This command will work in both Debian and RedHat systems.

Lastly, let’s activate the connection profile:

$ sudo nmcli connection up RedHotspot
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/9)





6. Shared Connection in NetworkManager

One of the Network Manager’s key features is its ability to create shared connections, occasionally referred to as Internet Connection Sharing (ICS).

Through this functionality, a device with an active internet connection, such as a computer connected to Ethernet or Wi-Fi, can share its internet connection with other devices. This virtually turns the host device into an access point or router.

For illustration, if we check the network configuration, we’ll realize that we have two networks (network 192.0.1.0/24 and 192.168.40.0/24):

$ ip addr show
2: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 60:67:20:7a:a6:8c brd ff:ff:ff:ff:ff:ff
    inet 192.0.1.254/24 brd 192.0.1.255 scope global noprefixroute wlan0
       valid_lft forever preferred_lft forever
    inet6 fe80::6267:20ff:fe7a:a68c/64 scope link
       valid_lft forever preferred_lft forever
4: usb0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/ether 16:8a:99:9f:07:99 brd ff:ff:ff:ff:ff:ff
    inet 192.168.40.153/24 brd 192.168.40.255 scope global dynamic noprefixroute usb0
       valid_lft 2675sec preferred_lft 2675sec
    inet6 fe80::148a:99ff:fe9f:799/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

This difference results from the NetworkManager utilizing NAT (Network address translation). It ensures that IP forwarding and masquerading are set effectively and we don’t have to worry about it:

$ sudo nft list ruleset
table ip nm-shared-wlan0 {
  chain nat_postrouting {
    type nat hook postrouting priority srcnat; policy accept;
    ip saddr 192.0.1.0/24 ip daddr != 192.0.1.0/24 masquerade
  }
  chain filter_forward {
    type filter hook forward priority filter; policy accept;
    ip daddr 192.0.1.0/24 oifname "wlan0" ct state { established, related } accept
    ip saddr 192.0.1.0/24 iifname "wlan0" accept
    iifname "wlan0" oifname "wlan0" accept
    iifname "wlan0" reject
    oifname "wlan0" reject
  }
}

The NetworkManager also starts the dnsmasq service which listens on ports 67 and 53 (DHCP and DNS respectively):

$ sudo ss -tulpn | egrep ":53|:67"
udp   UNCONN 0      0        192.0.1.254:53        0.0.0.0:*    users:(("dnsmasq",pid=5077,fd=6))
udp   UNCONN 0      0            0.0.0.0:67        0.0.0.0:*    users:(("dnsmasq",pid=5077,fd=4))
tcp   LISTEN 0      32       192.0.1.254:53        0.0.0.0:*    users:(("dnsmasq",pid=5077,fd=7))

The dnsmasq service provides DHCP and DNS services to the clients connected to the access point.





How to show password


f you want to do this with the command line, the wireless network configuration files are saved in the /etc/NetworkManager/system-connections/ directory. You can get them all at once like this:

sudo grep -r '^psk=' /etc/NetworkManager/system-connections/

This will give you output like this:

/etc/NetworkManager/system-connections/MyExampleSSID:psk=12345
/etc/NetworkManager/system-connections/AnotherSSID:psk=password

You can suppress the filename with the -h flag:

sudo grep -hr '^psk=' /etc/NetworkManager/system-connections/

The output is easier to read at a glance:

psk=12345
psk=password





 24

In the command line:

nmcli dev wifi show-password
EOF





declare -i _err=0

titleactivity="Getting WiFi networks"
notify-send -t 1000 "${titleactivity}..." &
# SHOW ACTIVE WIFI
# nmcli -g SSID device wifi show
declare current_qr_wifi=""
declare current_name=""
declare current_password=""
declare current_type=""
declare current_device=""
declare -i _err=0
  current_qr_wifi="$(nmcli -g SSID device wifi show)"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    notify-send "Caffeine" "Warning loading current connected wifi  : _err:$_err _msg:${current_qr_wifi}" &
  }
  fi
  if [[ -n "${current_qr_wifi}" ]] ; then
  {
    current_name="$(grep "^SSID:" <<< "${current_qr_wifi}" | cut -d: -f2 | xargs)"
    current_type="$(grep "^Security:" <<< "${current_qr_wifi}" | cut -d: -f2 | xargs)"
    current_password="$(grep "^Password:" <<< "${current_qr_wifi}" | cut -d: -f2 | xargs)"
  }
  fi

	current_device=$(nmcli device show | grep -E 'GENERAL.DEVICE' | grep -vE 'lo$|enp0s|p2p-dev|enp1s' | head -1 | cut -d: -f2 | xargs)

# Wifi visible list without current connection
# raw_list_of_networks="$(grep -v "^*"<<<nmcli dev wifi list)"
# Wifi visitble list including current connection
raw_list_of_networks="$(nmcli dev wifi list)"
# list_of_networks="$(nmcli -g SSID device wifi)"
_err=$?
if [ ${_err} -gt 0 ] ; then
{
  notify-send "Caffeine" "Failed command <nmcli dev wifi list> : _err:${_err} _msg:${raw_list_of_networks}" &
  exit 1
}
fi


if [[ -z "${raw_list_of_networks:-}" ]] ; then
{
  notify-send "Caffeine" "Failed and got empty list of networks <nmcli dev wifi list>" &
  exit 1
}
fi

# Teaching script 1
# 1st attempt but it uses SSD interaction
# count_response=$(wc -l <<< "${raw_list_of_networks:-}")
# _err=$?
# if [ ${_err} -gt 0 ] ; then
# {
#   notify-send "Caffeine" "Failed command <wc -l >: _err:$_err _msg:$count_response " &
#   exit 1
# }
# fi
# if [ ${count_response} -lt 2 ] ; then
# {
#   notify-send "Caffeine" "Failed count seems networks are empty <count_response=${count_response}> :list_of_networks:${list_of_networks:-}  _err:$_err _msg:$count_response " &
#   exit 1
# }
# fi
# (( count_response-- ))
# list_of_networks="$(tail -${count_response} <<< "${raw_list_of_networks:-}" )"
# _err=$?
# if [ ${_err} -gt 0 ] ; then
# {
#   notify-send "Caffeine" "Failed 2nd  command <nmcli dev wifi list> : _err:$_err _msg:$list_of_networks" &
#   exit 1
# }
# fi
# if [[ -z "${list_of_networks:-}" ]] ; then
# {
#   notify-send "Caffeine" "Failed 2nd and got empty list of networks <nmcli dev wifi list>" &
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
#   notify-send "Caffeine" "Failed command <wc -l >: _err:$_err _msg:$count_response " &
#   exit 1
# }
# fi
# if [ ${count_response} -lt 2 ] ; then
# {
#   notify-send "Caffeine" "Failed count seems networks are empty <count_response=${count_response}> :list_of_networks:${list_of_networks:-}  _err:$_err _msg:$count_response " &
#   exit 1
# }
# fi
# (( count_response-- ))
# list_of_networks="$(tail -${count_response} <<< "${raw_list_of_networks:-}" )"
# _err=$?
# if [ ${_err} -gt 0 ] ; then
# {
#   notify-send "Caffeine" "Failed 2nd  command <nmcli dev wifi list> : _err:$_err _msg:$list_of_networks" &
#   exit 1
# }
# fi
# if [[ -z "${list_of_networks:-}" ]] ; then
# {
#   notify-send "Caffeine" "Failed 2nd and got empty list of networks <nmcli dev wifi list>" &
#   exit 1
# }
# fi


# Teaching script 3
# 3rd attemp crop from the start no counting
declare current_network=""
declare current_bssid=""
declare -i count_response=0
list_of_networks=""
while read -r line; do
{
  [[ -z "${line:-}" ]] && continue # skip empty
  (( count_response++ ))
  [ ${count_response} -eq 1 ] && continue # skip first
  [ ${count_response} -gt 5000 ] && break # overun
  if grep -q "^\*" <<< "${line}" ; then
	{
		current_bssid=$(cut -d* -f2- <<< "${line}" | xargs | cut -d' ' -f1)
		current_network="${line}"
		continue # skip current network
	}
	fi
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
  notify-send "Caffeine" "Failed command <while loop raw_list_of_networks:- >: _err:${_err} _msg:${count_response} " &
  exit 1
}
fi
if [[ -z "${list_of_networks:-}" ]] ; then
{
  notify-send "Caffeine" "Failed 3rd clean and got empty list of networks <nmcli dev wifi list>" &
  exit 1
}
fi

declare list_saved_wifi_passwords=""
# Fetch saved wifis async while person chooses wifi
list_saved_wifi_passwords="$(nmcli -g NAME connection)"


declare title="Wifi networks available sorted by strength"
if [[ -n "${current_name}" ]] ; then
{
  title="Connected:${current_bssid:-} ${current_name} PASS:${current_password:-}"
  # if ( command -v xclip  >/dev/null 2>&1; )  ; then
  # {
	# 	(
	#     echo "${current_password}" | xclip
	# 	) &
	# }
  # fi
}
fi




escape() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [\\\"\;:\,]) printf "%s"  "\\$c" ;;
      *) printf "%s" "$c" ;;
    esac
  done
}



current_qr_wifi="$(qrencode  -t UTF8 'WIFI:S:'"${current_name}"';T:'"${current_type}"';P:'"${current_password}"';;')"
# current_qr_wifi="
# $(qrencode  -t ASCII 'WIFI:S:<${current_name}>;T:WPA;P:<${current_password}>;;')"

if ( command -v ~/bin/wifi2qr  >/dev/null 2>&1; )  ; then
{
	~/bin/wifi2qr -i & # pop qr code on the screen
	current_qr_wifi="
${current_qr_wifi}
$(~/bin/wifi2qr )"
}
else
{
  >&2 echo "Attempting to install is from REF: https://github.com/dlenski/wifi2qr"
	curl https://raw.githubusercontent.com/dlenski/wifi2qr/HEAD/wifi2qr > ~/bin/wifi2qr
  # chmod +x !$
	chmod +x ~/bin/wifi2qr
	~/bin/wifi2qr
}
fi

# chosen_network=$(echo -n "${list_of_networks:-}"  | rofi -dmenu -i -p "Wifi network" -no-custom)
chosen_network=$(echo -n "${list_of_networks:-}${current_qr_wifi:-}"  | rofi -dmenu -i -p "${title}" -no-custom -style "${HOME}/.config/wofi/style.css" )
# chosen_network=$(nmcli -g SSID device wifi | rofi -dmenu -i -p "Wifi network" -no-custom)
if [[ -z $chosen_network ]]; then
    # If we have not chosen a network, the previous command will return an empty string
    # and we can exit right away
    exit 1
fi
echo "chosen_network:${chosen_network}"
# echo "chosen_network:${chosen_network}" |sed 's/  /█/g'
# echo "${chosen_network}"|sed 's/  /█/g' | hexdump -C

# DEBUG
notify-send "Caffeine" "Choosen Wifi: $chosen_network" &
chosen_network_name=$(echo "${chosen_network}" |sed 's/  /█/g' | cut -d'█' -f2 )
echo "chosen_network_name:${chosen_network_name}"

chosen_network_bssid=$(echo "${chosen_network}" |sed 's/  /█/g' | cut -d'█' -f1 )
echo "chosen_network_bssid:${chosen_network_bssid}"

# nmcli --fields ACTIVE,NAME,BSSID,SSID,DBUS-PATH dev wifi list

notify-send "Caffeine" "Choosen Wifi name: $chosen_network_name" &
if grep -q "${chosen_network_name}" <<< "${list_saved_wifi_passwords}" ; then
{
	# Currently there is no way to connect to a router based on BSSID we need to create a virtual connection
	# Virutal con to target mac BSSID
	nmcli connection delete  "ChoosenOne"
	_err=$?
	if [ ${_err} -eq 10 ] ; then
	{
		>&2 echo "There was no chosen one saved from before. Carry on"
	}
	fi
	declare secrets=""
	secrets="$(nmcli connection show "${chosen_network_name}" --show-secrets)"

	declare selected_name="${chosen_network_name}"
	declare selected_bssid="${chosen_network_bssid}"
  declare selected_psk=""
	selected_psk="$(grep 802-11-wireless-security.key-mgmt: <<<"${secrets}" | cut -d: -f2 |xargs)"
  declare selected_pass=""
	selected_pass="$(grep 802-11-wireless-security.psk: <<<"${secrets}" | cut -d: -f2 |xargs)"
   >&2 echo "
	nmcli connection add \
      type wifi \
      ifname ${current_device} \
      con-name ChoosenOne \
      802-11-wireless.ssid ${chosen_network_name} \
      802-11-wireless.bssid  ${chosen_network_bssid} \
      802-11-wireless-security.key-mgmt ${selected_psk} \
      802-11-wireless-security.psk ${selected_pass}

	"
	nmcli connection add \
      type wifi \
      ifname "${current_device}" \
      con-name "ChoosenOne" \
      802-11-wireless.ssid "${chosen_network_name}" \
      802-11-wireless.bssid  "${chosen_network_bssid}" \
      802-11-wireless-security.key-mgmt "${selected_psk}" \
      802-11-wireless-security.psk  "${selected_pass}"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
		>&2 echo "Caffeine 1 Failed adding custom ChoseOne:   _err:${_err} _msg:${_msg} "
    notify-send "Caffeine" "1 Failed adding custom ChoseOne: _err:${_err} _msg:${_msg} " &
    exit 1
  }
  fi


	# known wifi
	# Connect using name known
	# >&2 echo "nmcli connection up id ${chosen_network_bssid}"
	>&2 echo "nmcli connection up  'ChoosenOne"
  # _msg=$(nmcli connection up id "${chosen_network_name}")
  _msg=$(nmcli connection up "ChoosenOne")
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
		>&2 echo "Caffeine 2 Failed command <nmcli connection up ChoosenOne  ${chosen_network_bssid}  ${chosen_network_name}>:   _err:${_err} _msg:${_msg} "
    notify-send "Caffeine" "2 Failed command <nmcli connection up ChoosenOne ${chosen_network_bssid}  ${chosen_network_name}>: _err:${_err} _msg:${_msg} " &
    exit 1
  }
  fi
  notify-send "Caffeine" "2 Connected: ChoosenOne ${chosen_network_name}" &
  _msg=$(myip 1>&2)
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    notify-send "Caffeine" "3 Failed command <myip>: _err:${_err} _msg:${_msg} " &
    exit 1
  }
  fi
  notify-send "Caffeine" "3 My IP: ${_msg}" &
}
else
{
	# Connect when password is not known, password unknown
  (
		# Connect by name unknown
    # _msg=$(nmcli device wifi connect "${chosen_network_name}")
    # Connect to network by name ssid and  mac bssid password unknown
		# _msg=$(nmcli device wifi connect "${chosen_network_name}" "${chosen_network_bssid}" password "<PASSWORD>" bssid "${chosen_network_bssid}")
		_msg=$(nmcli device wifi connect "${chosen_network_name}" bssid "${chosen_network_bssid}")
    _err=$?
    if [ ${_err} -gt 0 ] ; then
    {
      notify-send "Caffeine" "4 Failed command <nmcli device wifi connect ${chosen_network_bssid} ${chosen_network_name}>: _err:${_err} _msg:${_msg} " &
      exit 1
    }
    fi
    notify-send "Caffeine" "4 Connected: ${chosen_network_bssid}  $chosen_network_name" &
  ) &
  _msg=$(myip 1>&2)
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    notify-send "Caffeine" "5 Failed command <myip>: _err:${_err} _msg:${_msg} " &
    exit 1
  }
  fi
  notify-send "Caffeine" "5 My IP: ${_msg}" &
}
fi


#
