#!/bin/sh
# Copyright (C) 2009-2014 nomadnt.com

# . /lib/wifi/mac80211.sh

iw_get_devices(){
	ls /sys/class/ieee80211/ 2> /dev/null | xargs
	#iw list | awk '$0 ~ /^Wiphy phy[0-9]$/ {print $2}' 2>&1 | sort
}

iw_get_ssid(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "SSID"`; echo $SSID
		return 0
	}
	return 1
}

iw_get_bssid(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "BSSID"`; echo $BSSID
		return 0
	}
	return 1
}

iw_get_mode(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "MODE"`; echo $MODE
		return 0
	}
	return 1
}

iw_get_hwmode(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "HW_MODE"`; echo $HW_MODE
		return 0
	}
	return 1
}

iw_get_channel(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "CHANNEL"`; echo $CHANNEL
		return 0
	}
	return 1
}

iw_get_frequency(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "FREQUENCY"`; echo $FREQUENCY
		return 0
	}
	return 1
}

iw_get_frequency_offset(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "FREQUENCY_OFFSET"`; echo $FREQUENCY_OFFSET
		return 0
	}
	return 1
}

iw_get_txpower(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "TXPOWER"`; echo $TXPOWER
		return 0
	}
	return 1
}

iw_get_txpower_offset(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "TXPOWER_OFFSET"`; echo $TXPOWER_OFFSET
		return 0
	}
	return 1
}

iw_get_country(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "COUNTRY"`; echo $COUNTRY
		return 0
	}
	return 1
}

iw_get_signal(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "SIGNAL"`; echo $SIGNAL
		return 0
	}
	return 1
}

iw_get_noise(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "NOISE"`; echo $NOISE
		return 0
	}
	return 1
}

iw_get_bitrate(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "BITRATE"`; echo $BITRATE
		return 0
	}
	return 1
}

iw_get_link_quality(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "LINK_QUALITY"`; echo $LINK_QUALITY
		return 0
	}
	return 1
}

iw_get_link_quality_max(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "LINK_QUALITY_MAX"`; echo $LINK_QUALITY_MAX
		return 0
	}
	return 1
}

iw_get_encryption(){
	[ -n "$1" ] && {
		eval `iwget $1 info | grep "ENCRYPTION"`; echo $ENCRYPTION
		return 0
	}
	return 1
}