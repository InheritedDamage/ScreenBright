#!/bin/bash

 ########################################################################
 #                                                                      #
 #                         install - screenbright                       #
 #                                                                      #
 #  Description: Installing scripts from the /src folder to your        #
 #               machine. You can also add entries to /sudoer.d/user    #
 #               file to run the scripts without typing you superuser   #
 #               password everytime.                                    #
 #                                                                      #
 #  Important:   Take a look at the two variables INSTALL_PATH and      #
 #               ROOT_PRIV_CONFIG. Maybe you have to change their       #
 #               value before executing the install script.             #
 #                                                                      #
 #  Disclaimer:  The author does not take any responsibility for any    #
 #               damage on your machine or operating system by using    #
 #               this script or just a single line of code!             #
 #                                                                      #
 #  Author:      Dennis Zajonz (InheritedDamage)                        #
 #                                                                      #
 #  Version:     1.0.0 (15-03-2021)                                     #
 #                                                                      #
 #  Parameter:   -s  install screenbright only (if no -s or -k argument #
 #                   is set, the script will install at least the       #
 #                   screenbright script.                               #
 #               -k  install kbbright only                              #
 #               -r  create/change sudoers.d/user file to run the       #
 #                   scripts without root password (but sudo needed).   #
 #                   Needs the username of the user who will use the    #
 #                   scripts.                                           #
 #                                                                      #
 #  Usage:       install [-s|-k|-r username]                            #
 #                                                                      #
 ########################################################################


# Modify path if needed!
INSTALL_PATH=/usr/bin
ROOT_PRIV_CONFIG=/etc/sudoers.d


SOURCE_PATH=$(dirname $(realpath $0))/src

# Check for root privileges
if [ $UID -ne 0 ]; then
        echo "Error: need to be root!"
        exit 1
fi

screen=0
keyboard=0
rootpriv=0
USR=root

# Get commandline arguments
if [ $# -eq 0 ]; then screen=1; fi 
while [ ! -z "$1" ]; do
	case $1 in
		-s)
			screen=1
			;;
		-k)
			keyboard=1
			;;
		-r)
			rootpriv=1
			shift
			USR="$1"
			;;
		*)
			echo "Error: Unknown argument(s)!"
			echo "       Nothing installed"
			exit 1
			;;
	esac
shift
done

# Install the screenbright script
if [ screen ]; then
	echo " install screenbright script ..."
	cp $SOURCE_PATH/screenbright.sh $INSTALL_PATH/screenbright
	chmod +x $INSTALL_PATH/screenbright
	echo "   -> done"
fi

# Install the kbbright script
if [ keyboard ]; then
	echo " install kbbright script ..."
	cp $SOURCE_PATH/kbbright.sh $INSTALL_PATH/kbbright
	chmod +x $INSTALL_PATH/screenbright
	echo "   -> done"
fi

if [ rootpriv ]; then
	FILE="$ROOT_PRIV_CONFIG/$USR"
	echo " create sudoers.d/user file if not exists ..."
	if [ -f "$FILE" ]; then echo "" > "$FILE"; fi
	echo " writing rules to file"
	if [ screen ]; then 
		echo "$USR ALL=(root) NOPASSWD:$INSTALL_PATH/screenbright" >> "$FILE"
	fi
	if [ keyboard ]; then
		echo "$USR ALL=(root) NOPASSWD:$INSTALL_PATH/kbbright" >> "$FILE"
	fi
	echo "   -> done"
fi

echo " all done!"
