#!/bin/sh
# Copyright (C) 2009-2014 nomadnt.com

ip4addr2int(){
	local ipaddr="$1"
	local a b c d
	
	valid ip4addr $ipaddr && {
		a=$(expr 1 \* $(echo $ipaddr | awk -F "." '{printf "%u", ($4)}'))
		b=$(expr 256 \* $(echo $ipaddr | awk -F "." '{printf "%u", ($3)}'))
		c=$(expr 256 \* 256 \* $(echo $ipaddr | awk -F "." '{printf "%u", ($2)}'))
		d=$(expr 256 \* 256 \* 256 \* $(echo $ipaddr | awk -F "." '{printf "%u", ($1)}'))
		printf "%u\n" $(($a + $b + $c + $d))
		return 0
	}

	return 1
}

int2ip4addr(){
	local int="$1"
	local a b c d
	valid number "$int" && {
		a=$((($int&255 << 24) >> 24))
		b=$((($int&255 << 16) >> 16))
		c=$((($int&255 << 8) >> 8))
		d=$((($int&255 << 0) >> 0))
		printf "%s.%s.%s.%s\n" "$a" "$b" "$c" "$d"
		return 0
	}
	return 1
}

netmask2cidr(){
	local netmask="${1:-255.0.0.0}"
	local cidr=0
	valid ip4addr $netmask && {
		for x in $(echo $netmask | awk -F. '{printf "%u %u %u %u", $1, $2, $3, $4}'); do
			case $x in
            	255) cidr=$((cidr + 8));;
            	254) cidr=$((cidr + 7));;
            	252) cidr=$((cidr + 6));;
            	248) cidr=$((cidr + 5));;
            	240) cidr=$((cidr + 4));;
            	224) cidr=$((cidr + 3));;
            	192) cidr=$((cidr + 2));;
            	128) cidr=$((cidr + 1));;
            	0);;
			esac
		done
		printf "%u\n" $cidr
		return 0
	}
	return 1
}

cidr2netmask(){
	local cidr="${1:-8}"
	local int=$((((((1 << 32)) - 1)) - ((((1 << ((32 - $cidr)))) - 1))))
	
	valid number $cidr && {
		a=$((($int&255 << 24) >> 24))
		b=$((($int&255 << 16) >> 16))
		c=$((($int&255 << 8) >> 8))
		d=$((($int&255 << 0) >> 0))
		printf "%s.%s.%s.%s\n" $a $b $c $d
		return 0
	}
	return 1
}

mac2ip4addr(){
	local prefix=$1
	local mac="$2"
	local suffix=${3:-0}
	
	valid macaddr $mac && {
		IFS=':'; set $mac; unset IFS
		if [ $suffix -gt 0 ]; then
			printf "%u.%u.%u.%u" $prefix 0x$5 0x$6 $suffix
		else
			if [ $(printf "%u" "0x$6") -gt 0 ]; then
				printf "%u.%u.%u.%u\n" $prefix 0x$4 0x$5 0x$6
			else
				printf "%u.%u.%u.1\n" $prefix 0x$4 0x$5
			fi
		fi
		return 0
	}
	return 1
}

mac2ip6addr(){
	local mac=$(echo "$1" | awk '{print tolower($0)}')
	valid macaddr $mac && {
		IFS=':'; set $mac; unset IFS
		printf "fe80::%x%x:%x:%x:%x\n" $((0x${1} ^ 0x02)) 0x${2} 0x${3}ff 0xfe${4} 0x${5}${6}
		return 0
	}
	return 1
}
