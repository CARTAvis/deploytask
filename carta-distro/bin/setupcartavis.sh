#!/bin/bash
####################################################################################################
# Title       :	setupcartavis.sh
# Author      :	Alex Strilets, strilets@ualberta.ca
# Date        :	May 19, 2015
# Descritpion :	this is shell script to setup catsvis envirotnemt before running cartavis.sh
####################################################################################################
PN=`basename "$0"`

usage () {
    echo >&2 -e "$PN - shell script setup environment to run CARTAvis viewer\n"
    exit 1
}

if [ $# -gt 0 ]; then
    usage
fi

dirname=`dirname $0`
tmp="${dirname#?}"

if [ "${dirname%$tmp}" != "/" ]; then
dirname=$PWD/$dirname
fi

#  check for existance of $HOME/.cartavis directory
if [ ! -d $HOME/.cartavis ]; then
	echo "creating $HOME/.cartavis directory..."
	mkdir $HOME/.cartavis
fi

#  check for existance of $HOME/.cartavis/log directory
if [ ! -d $HOME/.cartavis/log ]; then
	echo "creating $HOME/.cartavis/log directory..."
	mkdir $HOME/.cartavis/log
fi

# want to make a local copy of config.json in the user's home 
# directory so they can easily modify it. 
# $HOME/.cartavis/config.json takes precedence over $dirname/../etc/config/config.json
# However, we want to delete any old versions of config.json left from earlier versions 
# of CARTA as it may cause conflicts with the new version.

### Note: If the user wishes to customise their config.json, please comment out the following 11 lines 
### so that any changes you make to config.json will not be overwritten:

### delete $HOME/.cartavis/config.json
if [ -e $HOME/.cartavis/config.json ]; then
        echo "Removing old config.json"
        rm $HOME/.cartavis/config.json
fi

### copy the new config.json
if [ ! -f $HOME/.cartavis/config.json ]; then
        echo "copying config.json file to  $HOME/.cartavis directory..."
        cp $dirname/../etc/config/config.json $HOME/.cartavis
fi

# create the cache directory if it does not already exist
if [ ! -d $HOME/CARTA/cache ]; then
        echo "creating $HOME/CARTA/cache directory..."
        mkdir -p $HOME/CARTA/cache
fi

# check that $HOME/CARTA/Images directory exists
if [ ! -d $HOME/CARTA/Images ]; then
	echo "creating $HOME/CARTA/Images directory..."
	mkdir -p $HOME/CARTA/Images
fi

# check that sample files exists
if [ ! -d $HOME/CARTA/Images/HD163296_CO_2_1_zoom.image ]; then
    echo "copying sample images to $HOME/CARTA/Images directory ..."
    cp -R $dirname/../etc/images/* $HOME/CARTA/Images
fi

# check that $HOME/CARTA/snapshots directory exists
if [ ! -d $HOME/CARTA/snapshots ]; then
	echo "creating $HOME/CARTA/snapshots directory..."
	mkdir $HOME/CARTA/snapshots
fi

# check that $HOME/CARTA/snapshots/data directory exists
if [ ! -d $HOME/CARTA/snapshots/data ]; then
	echo "creating $HOME/CARTA/snapshots/data directory..."
	mkdir $HOME/CARTA/snapshots/data
fi

# check that $HOME/CARTA/snapshots directory exists
if [ ! -d $HOME/CARTA/snapshots/layout ]; then
	echo "creating $HOME/CARTA/snapshots/layout directory..."
	mkdir $HOME/CARTA/snapshots/layout
fi

# check that $HOME/CARTA/snapshots/preferences directory exists
if [ ! -d $HOME/CARTA/snapshots/preferences ]; then
	echo "creating $HOME/CARTA/snapshots directory..."
	mkdir $HOME/CARTA/snapshots/preferences
fi

# Copy the carta icon to ~/.icon
if [ ! -e $HOME/.icons/carta.png ]; then
	        if [ ! -d $HOME/.icons ]; then
			echo "Creating .icons directory"
			mkdir $HOME/.icons
		fi
		echo "Copying CARTA logo"
		cp $dirname/../etc/carta.png $HOME/.icons/
fi

