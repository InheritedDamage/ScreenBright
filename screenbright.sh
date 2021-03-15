#!/bin/bash

 ########################################################################
 #                                                                      #
 #                            screenbright                              #
 #                                                                      #
 #  Description: Useful script to change screen brightness by using a   #
 #               terminal. Use different parameters to set brightness   #
 #               to min or max, or just use a value represented as      #
 #               percentage.                                            #
 #               This script can also be used for changing the screen-  #
 #               brightness by pressing the function keys (you need to  #
 #               change some directorys, permissions and add this       #
 #               script to the function key config file.                #
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
 #               -inc increases the brightness by 10%                   #
 #               -dec decreases the brightness by 10%                   #
 #               min  set screen brightness to minimum                  #
 #               max  set screen brightness to maximum                  # 
 #                                                                      #
 #  Usage:       screenbright -h                                        #
 #               screenbright [value(min-max)|min|max|-p value(0-100)|  #
 #               -inc|-dec]                                             #
 #                                                                      #
 ########################################################################


# Modify variables if needed!
# Minimum value of the screen brightness. Won't recommend a min value lower than 100!
MIN=100
# Maximum value of the screen brightness.
MAX=2600
# Absolute path of the file to change the screen brightness by modifying the integer value.
BRIGHTNESSPATH=/sys/class/backlight/intel_backlight/brightness


DIFF=$(($MAX-$MIN))

function print_help {
	echo ""
	echo "                        screenbright - help"
	echo ""
	echo " Author: Dennis Zajonz (InheritedDamage)   Version: 1.0.0 (15-03-2021)"
	echo " Parameter:   -p    percentage flag, needs a value [0,100]%"
	echo "              -h    print this help"
	echo "              -inc  increases the brightness by 10%"
	echo "              -dec  decreases the brightness by 10%"
	echo "              min   set screen brightness to minimum"
	echo "              max   set screen brightness to maximum"
	echo " Usage:       screenbright -h"
	echo "              screenbright [value($MIN-$MAX)|min|max|-p value(0-100)|"
	echo "              -inc|-dec]"
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
	elif [ $1 = "-inc" -o $1 = "-dec" ]; then
		val=$(head -n 1 $BRIGHTNESSPATH)
		if [ $val -gt $MAX ]; then val=$MAX; fi
		step=$(($DIFF*10/100))
		if [ $1 = "-dec" ]; then
			newval=$(($val-$step))
			if [ $newval -lt $MIN ]; then newval=$MIN; fi
			echo $newval > $BRIGHTNESSPATH
		else
			newval=$(($val+$step))
			if [ $newval -gt $MAX ]; then newval=$MAX; fi
			echo $newval > $BRIGHTNESSPATH
		fi
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
		echo "Unknown parameter $1. Try screenbright -h for help."
		exit 1
	fi
elif [ $# -eq 2 ]; then
	if [[ "$2" =~ [a-zA-Z]+ ]]; then
                echo "Unknown parameter tuple $1 | $2. -p needs a value between 0 and 100."
                echo "Try screenbright -h for help."
                exit 1
	elif [[ "$2" =~ [0-9]+ ]]; then # Argument is an integer?
		if [ $1 = "-p" -a $2 -lt 101 -a $2 -gt -1 ]; then
			perc=$(($DIFF*$2/100))
			echo $(($perc+$MIN)) > $BRIGHTNESSPATH
		else
			echo "Unknown parameter tuple $1 | $2. -p needs a value between 0 and 100."
			echo "Try screenbright -h for help."
			exit 1
		fi
	else
		echo "Unknown parameter $2. Try screenbright -h for help."
	fi
elif [ $# -gt 3 ]; then
	echo "Too many arguments. Try screenbright -h for help."
	exit 1
else
	"Not enough arguments. Try screenbright -h for help."
	exit 1
fi

exit 0
