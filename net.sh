#!/bin/sh
# Copyright (C) 2009-2014 nomadnt.com

type -t json_load > /dev/null || . /usr/share/libubox/jshn.sh

net_get_device(){
	local network="$1"
	local device __old_ns
	[ -n "$network" ] && {
		json_set_namespace "__nnt_network" __old_ns
		json_load "$(ubus call network.interface.$network status)"
		json_get_var device l3_device
		json_cleanup
		json_set_namespace "$__old_ns"

		echo $device
		return 0
	}
	return 1
}

net_get_macaddr(){
	local device="${1//[:.]*/}"
	[ -n "$device" ] && {
		case "$device" in
			phy[0-9])
				[ -e /sys/class/ieee80211/$device/macaddress ] && {
					cat /sys/class/ieee80211/$device/macaddress
				}
			;;
			*)
				[ -e /sys/class/net/$device/address ] && {
					cat /sys/class/net/$device/address
				}
			;;
		esac
		return 0
	}
	return 1
}

net_get_ipaddr(){
	local interface="$1"
	local inet="ipv${2:-4}"
	local index="${3:-1}"
	local up address mask __old_ns
	
	[ -n "$interface" ] && {
		json_set_namespace "__nnt_network" __old_ns
		json_load "$(ubus call network.interface.$interface status)"
		json_get_var up up
		[ $up -eq 1 ] && json_select "$inet-address" > /dev/null && {
			json_select $index > /dev/null && {
				json_get_vars address mask
				echo "$address/$mask"
			}
		
		}
		json_cleanup
		json_set_namespace "$__old_ns"
		return 0
	}
	return 1
}

net_get_route(){
	local interface="$1"
	local index="${2:-1}"
	local up target mask nexthop __old_ns
	
	[ -n "$interface" ] && {
		json_set_namespace "__nnt_network" __old_ns
		json_load "$(ubus call network.interface.$interface status)"
		json_get_var up up
		[ $up -eq 1 ] && json_select "route" > /dev/null && {
			json_select $index > /dev/null && {
				json_get_vars target mask nexthop
				echo "$target/$mask $nexthop"
			}
			json_select ..
			json_select ..
		}
		json_cleanup
		json_set_namespace "$__old_ns"
		return 0
	}
	return 1
}

net_get_bytes(){
	local interface="$1"
	local device rx_bytes tx_bytes __old_ns
	
	[ -n "$interface" ] && {
		json_set_namespace "__nnt_network" __old_ns
		json_load "$(ubus call network.interface.$interface status)"
		json_get_var device device
		[ -n "$device" ] && {
			json_load "$(ubus call network.device status "{ \"name\": \"$device\" }")"
			json_get_var up up
			[ $up -eq 1 ] && json_select "statistics" > /dev/null && {
				json_get_vars rx_bytes tx_bytes
				echo $rx_bytes/$tx_bytes
			}
			json_select ..
		}
		json_cleanup
		json_set_namespace "$__old_ns"
	}
	return 1
}

net_get_default_gateway(){
	ip ${1:-"-4"} route show | awk '$0 ~ /default/ { print $3 }'
}

net_get_public_ipaddr(){
	wget -q "${1:-http://checkip.dyndns.org}" -O - | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
}
