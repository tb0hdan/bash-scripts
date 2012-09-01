#!/bin/bash

# Written by Bohdan Turkynewych <tb0hdan@gmail.com>, 2011-2012
# Complies with BSD License type.

# Please adjust accordingly.
KBD_BRIGHTNESS="/sys/class/leds/smc::kbd_backlight/brightness"
KBD_BRIGHTNESS_MAX="/sys/class/leds/smc::kbd_backlight/max_brightness"
#
LED_BRIGHTNESS="/sys/class/backlight/acpi_video0/brightness"
LED_BRIGHTNESS_MAX="/sys/class/backlight/acpi_video0/max_brightness"
#
BASENAME="$(basename $0)"
#
#
function check_brightness_path() {
	local BRIGHTNESS_PATH
	BRIGHTNESSPATH=$1
	if [ ! -f ${BRIGHTNESS_PATH} ]; then
		message="Brightness not found at ${BRIGHTNESS_PATH}"
		echo $"${message}"
		echo $"${message}"|logger -t "${BASENAME}"
		exit 1
		path_ok=`echo ${BRIGHTNESS_PATH}|egrep -v '\.\.'|egrep '^(/sys/class|/proc/acpi)'`
		if [ -z $"${path_ok}" ]; then
			message="Wrong/dangerous brightness path at ${BRIGHTNESS_PATH}"
			echo $"${message}"
			echo $"${message}"|logger -t "${BASENAME}"
			exit 3
		fi
	fi
}

function set_brightness() {
	local BRIGHTNESS_VAL
	local BRIGTHNESS_PATH
	BRIGHTNESS_VAL=$1
	BRIGHTNESS_PATH=$2
	check_brightness_path ${BRIGHTNESS_PATH}
	sudo su -l root -c $"echo ${BRIGHTNESS_VAL} > ${BRIGHTNESS_PATH}"
}

function get_brightness() {
	check_brightness_path $1
	cat $1
}

function brightness_up(){
	local BRIGHTNESS_PATH
	local BRIGHTNESS_MAX
	BRIGHTNESS_PATH=$1
	BRIGHTNESS_MAX=$2
	br=$(get_brightness ${BRIGHTNESS_PATH})
	br_max=$(get_brightness ${BRIGHTNESS_MAX})
	br_step=$((br_max / 10))
	brightness=$(( br + br_step ))
	if [ ${brightness} -ge ${br_max} ]; then
		brightness=${br_max}
	fi
	set_brightness $brightness ${BRIGHTNESS_PATH}

}

function brightness_down(){
	local BRIGHTNESS_PATH
	local BRIGHTNESS_MAX
	BRIGHTNESS_PATH=$1
	BRIGHTNESS_MAX=$2
	br=$(get_brightness ${BRIGHTNESS_PATH})
	br_max=$(get_brightness ${BRIGHTNESS_MAX})
	br_step=$((br_max / 10))
	brightness=$(( br - br_step ))
	if [ $brightness -le 0 ]; then
		brightness=0
	    fi
	set_brightness $brightness ${BRIGHTNESS_PATH}
}


function kbd_br_up() {
	brightness_up   ${KBD_BRIGHTNESS} ${KBD_BRIGHTNESS_MAX}

}

function kbd_br_down() {
	brightness_down ${KBD_BRIGHTNESS} ${KBD_BRIGHTNESS_MAX}

}

function led_br_up() {
	brightness_up   ${LED_BRIGHTNESS} ${LED_BRIGHTNESS_MAX}

}

function led_br_down() {
	brightness_down ${LED_BRIGHTNESS} ${LED_BRIGHTNESS_MAX}

}

case $1 in
	kbd-up)
		kbd_br_up
	;;
	kbd-down)
		kbd_br_down
	;;
	led-up)
		led_br_up
	;;
	led-down)
		led_br_down
	;;
	*)
		echo "Usage ${BASENAME}: {kbd-up|kbd-down|led-up|led-down}"
		exit
	;;
esac
