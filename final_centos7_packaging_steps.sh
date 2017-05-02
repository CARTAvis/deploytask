#!/bin/bash
####
#### Script to be run after CARTA 'make'
####
#### CentOS7 Linux version
#### 
#### make-app-carta will use a previously downloaded casa-pkg in /data/cartabuild
#### To get a new casa-pkg, remove the 'template' flag from the make-app-carta command 
#### and a new casa-pkg will be downloaded to /tmp
####
#### Last update: 2/5/17
####

# 0. Define the installed location of your Qt 5.3 and CARTA source code (for grabing the latest html):
CARTABUILDHOME=~/cartawork
qtpath=/opt/Qt/5.3/gcc_64/bin/
cartapath=~/cartawork/CARTAvis
thirdparty=~/cartawork/CARTAvis-externals/ThirdParty
packagepath=/tmp/carta
extra=~/cartawork/finish  ## location of extra files to finish packaging (Download from: http://www.asiaa.sinica.edu.tw/~ajm/carta/finish_linux.tar.gz)
version=7.7.7  ## version number to be put on the final package

# 1. Export the location of the successfully built casacore/casacode library files
export LD_LIBRARY_PATH=/home/acdc/cartawork/CARTAvis-externals/ThirdParty/casa/trunk/linux/lib

# 2. Download and run the latest make-app-carta script
curl -O -L https://open-bitbucket.nrao.edu/projects/CASA/repos/casa-pkg/raw/packaging/scripts/make-app-carta
sed -i '' 's|\/opt\/Qt5.3.2\/5.3/gcc_64|'"${qtpath}"'|g' make-app-carta
chmod 755 make-app-carta
rm -rf /tmp/casa-pkg 
rm -rf $packagepath-$version
./make-app-carta -ni -v version=$version out=/tmp  ws=$CARTABUILDHOME/build/cpp/desktop template=$CARTABUILDHOME/casa-pkg/packaging/template/linux/carta-distro

# 3. Fix a few things
chrpath -c -r '$ORIGIN/../lib:$ORIGIN/../plugins/CasaImageLoader' $packagepath-$version/plugins/ImageStatistics/libplugin.so
cp -r $qtpath/../plugins/platforms $packagepath-$version/bin/
cp $qtpath/../lib/libQt5DBus.so.5.3.2 $packagepath-$version/lib/
mv $packagepath-$version/lib/libQt5DBus.so.5.3.2 $packagepath-$version/lib/libQt5DBus.so.5
cp $thirdparty/cfitsio/lib/libcfitsio.so.4.3.38 $packagepath-$version/lib/
mv $packagepath-$version/lib/libcfitsio.so.4.3.38 $packagepath-$version/lib/libcfitsio.so.4

# 6. Copy the html to the application directory
cp -r $cartapath/carta/html5 /tmp/carta-$version/etc
rm  /tmp/carta-$version/etc/html5/common/qooxdoo-3.5-sdk
cp -r $thirdparty/qooxdoo-3.5-sdk $packagepath-$version/etc/html5/common/qooxdoo-3.5-sdk


# 7. Copy modified setupcartavis.sh (to stop copying config.json to ~/.cartavis) and move config.json to correct internal location
cp $extra/setupcartavis.sh $packagepath-$version/bin/
cp $extra/carta.sh $packagepath-$version/bin/
cp -r $CARTABUILDHOME/build/config $packagepath-$version/etc/
#cp $cartapath/carta/scripts/carta.sh $packagepath-$version/bin/


# 8. Setup geodetic and ephemerides data in the measures_directory, define new casarc file correctly, and make carta.sh point to it correctly
cp -r $extra/measures_data $packagepath-$version/etc/
cp $extra/casarc $packagepath-$version/bin/
#sed -i 's|casarc|bin\/casarc|g' $packagepath-$version/bin/carta.sh


# 9. Copy over the sample images
mkdir $packagepath-$version/etc/images
cp -r $extra/carta_release_images/* $packagepath-$version/etc/images/


# 10. Fix for QtSql; copy the library file to the correct location
mkdir $packagepath-$version/bin/sqldrivers
cp $qtpath/../plugins/sqldrivers/libqsqlite.so $packagepath-$version/bin/sqldrivers

#Finished

