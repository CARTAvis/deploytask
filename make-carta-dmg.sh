#!/bin/bash
#
# Creates the CARTA dmg file for MacOS.
# Modified from Ville's NRAO script.
# 

if [ $# -ne 3 ]; then
    echo "usage: make-dmg <path-to-app> <CARTA.app name> <dmg title name>"
	exit 1
fi

app_path=$1
applicationName=$2
dmg_title=$3

if [ ! -e $app_path ]; then
    echo "file $app_path not found..."
    exit 1
fi

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

hdiutil create -srcfolder $root_path/Carta -volname "${dmg_title}" $root_path/c1
hdiutil convert -format UDRW -o $root_path/c2 $root_path/c1.dmg && rm $root_path/c1.dmg

open /tmp/c2.dmg
sleep 5

echo "Copying the hidden background image folder in place"
mkdir -p /Volumes/"${dmg_title}"/.background
curl -O https://raw.githubusercontent.com/CARTAvis/deploytask/master/background.png
cp background.png /Volumes/"${dmg_title}"/.background

echo "Setting up the size, icon positions, and background image of the dmg window" 
echo '
   tell application "Finder"
     tell disk "'${dmg_title}'"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {400, 199, 1200, 400}
           set theViewOptions to the icon view options of container window
           set arrangement of theViewOptions to not arranged
           set icon size of theViewOptions to 128
           set background picture of theViewOptions to file ".background:background.png"
           make new alias file at container window to POSIX file "/Applications" with properties {name:"Applications"}
           set position of item "'${applicationName}'" of container window to {370, 80}
           set position of item "Applications" of container window to {670, 80}
           update without registering applications
           delay 5
           close
     end tell
   end tell
   tell application "Finder"
     eject disk  "'${dmg_title}'"
   end tell
' | osascript

sleep 5
echo "Creating and compressing final dmg file"
hdiutil convert -format UDBZ -o ${dmg_title}-${OS_X_VERSION} $root_path/c2.dmg
rm $root_path/c2.dmg

