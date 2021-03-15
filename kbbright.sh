#!/bin/bash

 ########################################################################
 #                                                                      #
 #                              kbbright                                #
 #                                                                      #
 #  Description: Useful script to change keyboard brightness by using   #
 #               a terminal. Use different parameters to set brightness #
 #               to min or max, or just use a value represented as      #
 #               percentage.                                            #
 #               This script can also be used for changing the key-     #
 #               board brightness by pressing the function keys (you    #
 #               need to change some directorys, permissions and add    #
 #               this script to the function key config file.           #
 #                                                                      #
 #  Disclaimer:  The author does not take any responsibility for any    #
 #               damage on your machine or operating system by using    #
 #               this script or just a single line of code!             #
 #                                                                      #
 #  Author:      Dennis Zajonz (InheritedDamage)                        #
 #                                                                      #
 #  Version:     1.0.0 (15-03-2021)                                     #
 #                                                                      #
 #  Parameter:   -p   percentage flag, needs a value [0,100]%           #
 #               -h   print help                                        #
 #               min  set keyboard backlight brightness to minimum      #
 #               max  set keyboard backlight brightness to maximum      # 
 #                                                                      #
 #  Usage:       kbbright -h                                            #
 #               kbbright [value(min-max)|min|max|-p value(0-100)]      #
 #                                                                      #
 ########################################################################


# Modify variables if needed!
# Minimum value of the keyboard backlight brightness.
MIN=0
# Maximum value of the keyboard backlight brightness.
MAX=250
# Absolute path of the file to change the keyboard backlight brightness by
# modifying the integer value.
BRIGHTNESSPATH=/sys/class/leds/smc\:\:kbd_backlight/brightness


DIFF=$(($MAX-$MIN))

function print_help {
	echo ""
	echo "                           kbbright - help"
	echo ""
	echo " Author: Dennis Zajonz (InheritedDamage)   Version: 1.0.0 (15-03-2021)"
	echo " Parameter:   -p    percentage flag, needs a value [0,100]%"
	echo "              -h    print this help"
	echo "              min   set keyboard background brightness to minimum"
	echo "              max   set keyboard background brightness to maximum"
	echo " Usage:       kbbright -h"
	echo "              kbbright [value($MIN-$MAX)|min|max|-p value(0-100)]"
	echo ""
}


# Check for root privileges
if [ $UID -ne 0 ]; then
	echo "Error: need to be root!"
	exit 1
fi

if [ $# -eq 1 ]; then
	if [ $1 = "min" ]; then echo $MIN > $BRIGHTNESSPATH
	elif [ $1 = "max" ]; then echo $MAX > $BRIGHTNESSPATH
	elif [ $1 = "-h" ]; then print_help
	elif [[ "$1" =~ [a-zA-Z]+ ]]; then
		echo "Error: Value $1 not a number."
		exit 1
	elif [[ "$1" =~ [0-9]+ ]]; then # Argument is an integer?
		if [ $1 -lt $(($MAX+1)) -a $1 -gt $(($MIN-1)) ]; then echo $1 > $BRIGHTNESSPATH
		else
			echo "Error: Value $1 out of bounds [$MIN, $MAX]."
			exit 1
		fi
	else
		echo "Unknown parameter $1. Try kbbright -h for help."
		exit 1
	fi
elif [ $# -eq 2 ]; then
	if [[ "$2" =~ [a-zA-Z]+ ]]; then
		echo "Unknown parameter tuple $1 | $2. -p needs a value between 0 and 100."
		echo "Try kbbright -h for help."
		exit 1
	elif [[ "$2" =~ [0-9]+ ]]; then # Argument is an integer?
		if [ $1 = "-p" -a $2 -lt 101 -a $2 -gt -1 ]; then
			perc=$(($DIFF*$2/100))
			echo $(($perc+$MIN)) > $BRIGHTNESSPATH
		else
			echo "Unknown parameter tuple $1 | $2. -p needs a value between 0 and 100."
			echo "Try kbbright -h for help."
			exit 1
		fi
	else
		echo "Unknown parameter $2. Try kbbright -h for help."
	fi
elif [ $# -gt 3 ]; then
	echo "Too many arguments. Try kbbright -h for help."
	exit 1
else
	"Not enough arguments. Try kbbright -h for help."
	exit 1
fi

exit 0
