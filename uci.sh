#!/bin/sh
# Copyright (C) 2009-2014 nomadnt.com

type -t uci_load > /dev/null || . /lib/functions.sh

# overload of uci functions
uci_add_list(){
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	local VALUE="$4"
	
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} add_list "$PACKAGE.$CONFIG.$OPTION=$VALUE"
}

uci_set(){
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	local VALUE="$4"
	
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} set "$PACKAGE.$CONFIG.$OPTION=$VALUE"
}

uci_set_state(){
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	local VALUE="$4"
	
	[ "$#" = 4 ] || return 0
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} -P /var/state set "$PACKAGE.$CONFIG${OPTION:+.$OPTION}=$VALUE"
}

uci_remove(){
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} del "$PACKAGE.$CONFIG${OPTION:+.$OPTION}"
}

uci_reorder(){
	local PACKAGE="$1"
	local CONFIG="$2"
	local POSITION="$3"
	
	[ "$#" = 3 ] || return 0
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} reorder "$PACKAGE.$CONFIG=$POSITION"
}

uci_changes(){
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} changes $1
}

uci_batch(){
	local UCI_FILE="$1"

	[ -e $UCI_FILE ] || return 0
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} -f $UCI_FILE batch
}

uci_apply(){
	local services="$(uci_affected_services $@)"

	_apply_config(){
		config_get init "$1" init
		config_get exec "$1" exec
		config_get test "$1" test

		echo "$2" > "/var/run/uci-reload-status"

		[ -n "$init" ] && _reload_init "$2" "$init" "$test"
		[ -n "$exec" ] && _reload_exec "$2" "$exec" "$test"
	}

	_reload_exec() {
		local service="$1"
		local ok="$3"
		set -- $2
		local cmd="$1"; shift

		[ -x "$cmd" ] && {
			logger -s -t "${0##*/}" "Reloading $service..."
			( $cmd "$@" ) 2>/dev/null 1>&2
			[ -n "$ok" -a "$?" != "$ok" ] && logger -s -t "${0##*/}" "!!! Failed to reload $service !!!"
		}
	}

	_reload_init(){
		local service="$1"
		[ -x /etc/init.d/$2 ] && /etc/init.d/$2 enabled && {
			logger -s -t "${0##*/}" "Reloading $service..."
			/etc/init.d/$2 reload >/dev/null 2>&1
			[ -n "$3" -a "$?" != "$3" ] && logger -s -t "${0##*/}" "!!! Failed to reload $service !!!"
		}
	}

	lock "/var/run/uci-reload"

	config_clear
	config_load ucitrack
	for service in $services; do
		config_foreach _apply_config $service $service
	done

	rm -f "/var/run/uci-reload-status"
	lock -u "/var/run/uci-reload"
}

uci_affected_configs(){
	/sbin/uci -q ${UCI_CONFIG_DIR:+-c /sbin/uci_CONFIG_DIR} changes | \
		sed 's/^-//g' |  awk -F. '{print $1}' | sort -u
}

uci_affected_services(){
	local _PACKAGES="$@"
	local _SERVICES

	_resolve_deps(){
		local name="$1"
		local affects affected

		config_get affects $name affects

		for affected in $affects; do
			config_foreach _resolve_deps $affected
		done

		echo $_SERVICES | grep -qs "$cfgtype" || append _SERVICES "$cfgtype"
	}

	config_clear
	config_load ucitrack
	for package in $_PACKAGES; do
		config_foreach _resolve_deps $package
	done

	echo $_SERVICES
}