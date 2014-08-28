#!/bin/sh
# Copyright (C) 2009-2014 nomadnt.com

sys_uptime(){
	awk -F. '{print $1}' /proc/uptime
}

sys_loadavg(){
	awk '{print $2}' /proc/loadavg
}

sys_memfree(){
	total=$(awk '$0 ~ /MemTotal/ {print $2}' /proc/meminfo)
	free=$(awk '$0 ~ /MemFree/ {print $2}' /proc/meminfo)
	echo $(((100 \* $free) / $total))
}

sys_hostname(){
	local hostname="$1"
	if [ -n "$hostname" ]; then
		echo "$hostname" > /proc/sys/kernel/hostname
	else
		cat /proc/sys/kernel/hostname
	fi
}

sys_timezone(){
	local tz="$1"
	if [ -n "$tz" ]; then
		echo "$tz" > /tmp/TZ
	else
		cat /tmp/TZ
	fi
}

sys_device_vendor(){
	local vendor
	[ -e /var/sysinfo/model ] && vendor="$(awk '{print tolower($1)}' /var/sysinfo/model)"
	[ -n "$vendor" ] || vendor="$(awk -F": " '$0 ~ /machine/ {print tolower($2)}' /proc/cpuinfo | awk '{print $1}')"
	[ -n "$vendor" ] || vendor="$(awk -F": " '$0 ~ /model name/ {print tolower($2)}' /proc/cpuinfo | awk '{print $1}')"
	[ -n "$vendor" ] || vendor=$(iwget phy0 info | awk -F'[][]' '$0 ~ /HW_INFO/{print tolower($2)}' | awk '{print $1}')
	echo ${vendor:-unknown}
}

sys_device_model(){
	local model
	[ -e /var/sysinfo/board_name ] && model="$(awk '{print tolower($1)}' /var/sysinfo/board_name)"
	[ -n "$model" ] || model="$(awk -F": " '$0 ~ /machine/ {print tolower($2)}' /proc/cpuinfo)"
	[ -n "$model" ] || model="$(awk -F": " '$0 ~ /Hardware/ {print $2}' /proc/cpuinfo)"
	[ -n "$model" ] || model="$(iwget phy0 info | awk -F'[][]' '$0 ~ /HW_INFO/{print tolower($2)}' | awk '{print $2}')"
	[ -n "$model" ] || model="$(uname -m)"
	echo ${model:-unknown}
}

sys_device(){
	echo "$(sys_device_vendor)" "$(sys_device_model)"
}

sys_user_passwd(){
	local user="$1"
	local pass="$2"

	grep -qs "$user" /etc/passwd && {
		[ -n "$pass" ] && {
			(echo $pass; sleep 1; echo $pass) | passwd  $user >/dev/null 2>&1
			return 0
		}
		return 1
	}
	return 1
}

sys_service(){
	local service="$1"
	local action="$2"
	
	[ -e /etc/init.d/$service ] || return 1
	echo $action | grep -qsE '^(start|restart|stop|reload|enable|disable|enabled)$' && {
		/etc/init.d/$service $action > /dev/null 2>&1
	}
	return $?
}

sys_version(){
	cat /etc/openwrt_release
}

sys_log(){
	local options="-s ${3:+-t $3}"
	logger $options -p ${2:-INFO} "$1"
}