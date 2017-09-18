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
   echo "rename existing folder"
   mv $root_path/Carta $root_path/CartaOld
fi

mkdir $root_path/Carta
mv $app_path $root_path/Carta

#( cd $root_path/Carta && ln -s /Applications )

cartaver=0.9.0 #$(cat $root_path/Carta/$name/Contents/Resources/VERSION | cut -d ' ' -f 1  | cut -d '.' -f 3 )
hdiutil create -srcfolder $root_path/Carta -volname "Carta_${OS_X_VERSION}_${cartaver}" $root_path/c1
hdiutil convert -format UDRW -o $root_path/c2 $root_path/c1.dmg && rm $root_path/c1.dmg

echo "Setting up the installer"
open /tmp/c2.dmg
sleep 5

echo "Copying the hidden background image folder in place"

application_name=CARTA_0.9_preview

mkdir -p /Volumes/Carta_${OS_X_VERSION}_${cartaver}/.background
curl -O https://raw.githubusercontent.com/CARTAvis/deploytask/master/background.png
cp background.png /Volumes/Carta_${OS_X_VERSION}_${cartaver}/.background

echo "Setting up the size, icon positions, and background image of the dmg window" 
echo '
   tell application "Finder"
     tell disk "'Carta_${OS_X_VERSION}_${cartaver}'"
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
           delay 5
           set position of item "'${application_name}.app'" of container window to {370, 70}
           delay 5
           set position of item "Applications" of container window to {670, 80}
           delay 5
           update without registering applications
           delay 5
           close
     end tell
   end tell
   tell application "Finder"
     eject disk  "'Carta_${OS_X_VERSION}_${cartaver}'"
   end tell
' | osascript

echo "Modifying the Info.plist file to set the App name and version number"
open /tmp/c2.dmg
sleep 5
sed -i '' -e 's|<string>1.0</string>|<string>'$version_number'</string>|g' /Volumes/"Carta_${OS_X_VERSION}_${cartaver}"/"${application_name}.app"/Contents/Info.plist     ## replaces 5th occurrence of 1.0
sed -i '' -e 's|<string>Carta</string>|<string>'$application_name'</string>|g' /Volumes/"Carta_${OS_X_VERSION}_${cartaver}"/"${application_name}.app"/Contents/Info.plist ## replaces 2nd occurrence of Carta
echo '
  tell application "Finder"
   eject disk  "'Carta_${OS_X_VERSION}_${cartaver}'"
  end tell
' | osascript

sleep 5
echo "Creating and compressing final dmg file"

hdiutil convert -format UDBZ -o Carta $root_path/c2.dmg
#osascript -e 'tell application "Finder" to activate'
rm $root_path/c2.dmg

echo "Packaging complete"
