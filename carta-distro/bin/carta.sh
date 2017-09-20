#!/bin/bash
####################################################################################################
# Title      :	cartavis.sh
# Author     :	Alex Strilets, strilets@ualberta.ca
# Date       :	May 19, 2015
# Usage      :	cartavis.sh [fits/carta file to view]
#               Examples:
#                   cartavis.sh - called with not paramters  will display sample 555wmos.fits file
#                   cartavis.sh /mypath/myfiletoview.fits - will display myfiletoview.fits
####################################################################################################

PN=`basename "$0"`

usage () {
    echo >&2 "$PN - shell script to launch CARTAvis viewer
usage: $PN [file to View ]

If no file name passed, default sample file 555wmos.fits will be displayed.

               Examples:
                   cartavis.sh - called with not paramters  will display sample 555wmos.fits file
                   cartavis.sh /mypath/myfiletoview.fits - will display myfiletoview.fits "
    exit 1
}

while [ $# -gt 0 ]
do
    case "$1" in
	--)	shift; break;;
	-h)	usage;;
	-*)	usage;;
	*) imagefile=$1;;			# image file name specified on the command line
    esac
    shift
done

appname=CARTA
dirname=`dirname $0`

tmp="${dirname#?}"
if [ "${dirname%$tmp}" != "/" ]; then
dirname=$PWD/$dirname/
fi

dirname=$dirname/../
echo "dirname $dirname"

logfilename=$HOME/.cartavis/log/$(date +"%Y%m%d_%H%M%S_%Z").log
#imagefile=$HOME/CARTA/Images/aJ.fits

if [ ! -e $HOME/data/ephemerides -o\
      ! -e $HOME/data/geodetic -o\
      ! -d $HOME/CARTA/Images -o\
      ! -d $HOME/CARTA/cache -o\
      ! -d $HOME/.cartavis/log  -o\
      ! -f $HOME/.cartavis/config.json -o\
      $dirname/config/config.json -nt $HOME/.cartavis/config.json -o\
      ! -f $HOME/.icons/carta.png -o \
      ! -d $HOME/CARTA/snapshots/data ]; then
	$dirname/bin/setupcartavis.sh 2>&1
fi

ulimit -n 2048
export CASARCFILES=$dirname/bin/casarc
export PYTHONHOME=$dirname

cd $dirname/bin
#./$appname --html $dirname/VFS/DesktopDevel/desktop/desktopIndex.html --scriptPort 9999  2>&1 &
#echo "./$appname --html $dirname/VFS/DesktopDevel/desktop/desktopIndex.html --scriptPort 9999 $imagefile >> $logfilename 2>&1 &"
#./$appname --html $dirname/VFS/DesktopDevel/desktop/desktopIndex.html --scriptPort 9999 $imagefile >> $logfilename 2>&1 &
./$appname --html $dirname/etc/html5/desktop/desktopIndex.html --scriptPort 9999 >> $logfilename 2>&1 &

