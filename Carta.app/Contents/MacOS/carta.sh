#!/bin/bash
####################################################################################################
# Title      :	cartavisOSX.sh
# Author     :	Alex Strilets, strilets@ualberta.ca
# Date       :	May 21, 2015
# Description:  this is shell script to start carta visualization viewer on Mac OS X
####################################################################################################

PN=`basename "$0"`

unset DYLD_LIBRARY_PATH
unset DYLD_FALLBACK_LIBRARY_PATH

appname=CARTA
dirname=`dirname $0`

tmp="${dirname#?}"

if [ "${dirname%$tmp}" != "/" ]; then
dirname=$PWD/$dirname
fi

logfilename=$HOME/.cartavis/log/$(date +"%Y%m%d_%H%M%S_%Z").log


if [ ! -d $HOME/.cartavis/log  -o\
     ! -f $HOME/.cartavis/config.json -o\
     ! -d $HOME/CARTA/Images  -o\
     ! -d $HOME/CARTA/cache  -o\
     ! -d $HOME/CARTA/snapshots/data ]; then
    $dirname/setupcartavis.sh 2>&1  > /dev/null
fi

export CASARCFILES=$dirname/casarc

cd $dirname
./$appname --html $dirname/../Resources/html/desktop/desktopIndex.html --scriptPort 9999 >> $logfilename   2>&1 &
#./$appname --html $dirname/VFS/DesktopDevel/desktop/desktopIndex.html --scriptPort 9999 $imagefile 2>&1 &
