#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: make-dmg <path-to-app>"
	exit 1
fi

app_path=$1

if [ ! -e $app_path ]; then
    echo "file $app_path not found..."
    exit 1
fi


###
### Until further notice, need to add the following to the script if using MacOS 10.12 Sierra
###  "16")
###      readonly OS_X_VERSION="10.12"
###      ;;
###

readonly OS_VERSION=$(uname -r | awk -F. '{print $1}')
case $OS_VERSION in
"10")
    readonly OS_X_VERSION="10.6"
    ;;
"11")
    readonly OS_X_VERSION="10.7"
    ;;
"12")
    readonly OS_X_VERSION="10.8"
    ;;
"13")
    readonly OS_X_VERSION="10.9"
    ;;
"14")
    readonly OS_X_VERSION="10.10"
;;
"15")
    readonly OS_X_VERSION="10.11"
;;
"16")
    readonly OS_X_VERSION="10.12"
;;
*)
    echo "ERROR: Unknown OS X version."
    exit -1
    ;;
esac

root_path=`dirname $app_path`
name=`basename $app_path`

if [ -e $root_path/Carta ]; then
   echo "cannot create dmg folder $root_path/Carta (it already exists)"
   exit 1
fi

mkdir $root_path/Carta
mv $app_path $root_path/Carta

#( cd $root_path/Carta && ln -s /Applications )

cartaver=0.9.0 #$(cat $root_path/Carta/$name/Contents/Resources/VERSION | cut -d ' ' -f 1  | cut -d '.' -f 3 )
hdiutil create -srcfolder $root_path/Carta -volname "Carta_${OS_X_VERSION}_${cartaver}" $root_path/c1
hdiutil convert -format UDRW -o $root_path/c2 $root_path/c1.dmg && rm $root_path/c1.dmg
#open c2.dmg
echo
echo "Fix the Finder window of the Carta disk image (icon size and position)"
echo "and then run this command:"
hdiutil convert -format UDBZ -o Carta-${OS_X_VERSION}-${cartaver} $root_path/c2.dmg
#osascript -e 'tell application "Finder" to activate'
rm $root_path/c2.dmg
