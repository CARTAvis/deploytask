#!/bin/bash
###
### Final packaging steps on CentOS6    (Last updated: 26/4/17)
###
### Note: Some paths may need to be adjusted for your system. 
###       So please check every line carefully.
###

# 0. Define the installed location of your Qt 5.3 and CARTA source code (for grabing the latest html):
CARTABUILDHOME=~/cartabuild
qtpath=/Qt5.3.2/5.3/gcc_64/bin/
cartapath=~/cartabuild/CARTAvis
packagepath=/tmp/carta
extra=~/cartabuild/finish  ## location of extra files to finish packaging
version=6.6.6  ## version number to be put on the dmg

# 1. Export the location of the successfully built casacore/casacode library files
export LD_LIBRARY_PATH=/casa/trunk/linux/lib


# 2. Download and run the make-app-carta script
curl -O -L https://open-bitbucket.nrao.edu/projects/CASA/repos/casa-pkg/raw/packaging/scripts/make-app-carta
sed -i '' 's|\/Qt5.3.2\/5.3/gcc_64|'"${qtpath}"'|g' make-app-carta
chmod 755 make-app-carta
rm -rf $packagepath-$version

## Download a new casa-pkg template
#rm -rf /tmp/casa-pkg
#./make-app-carta -ni -v version=$version out=/tmp ws=$CARTABUILDHOME/build/cpp/desktop

## or

## Use an already downloaded casa-pkg template with 'template' flag
./make-app-carta -ni -v version=$version out=/tmp ws=$CARTABUILDHOME/build/cpp/desktop template=$CARTABUILDHOME/casa-pkg/packaging/template/linux/carta-distro


# 3. Fix a few things
cp ~/dependencies/gcc-4.8.2/lib64/libstdc++.so.6 $packagepath-$version/lib/

cp -r $qtpath/../plugins/platforms $packagepath-$version/bin/

cp -r $qtpath/../lib/libQt5DBus.so.5.3.2  $packagepath-$version/lib/
mv $packagepath-$version/lib/libQt5DBus.so.5.3.2 $packagepath-$version/lib/libQt5DBus.so.5

chrpath -c -r '$ORIGIN/../../lib/:$ORIGIN/../../plugins/CasaImageLoader/' $packagepath-$version/plugins/ImageStatistics/libplugin.so

cp /usr/lib64/libcfitsio.so $packagepath-$version/lib/
mv $packagepath-$version/lib/libcfitsio.so $packagepath-$version/lib/libcfitsio.so.4


# 4. Copy over the html and qooxdoo
cp -r ~/cartabuild/CARTAvis/carta/html5 $packagepath-$version/etc/
rm  $packagepath-$version/etc/html5/common/qooxdoo-3.5-sdk
cp -r ~/cartabuild/CARTAvis-externals/ThirdParty/qooxdoo-3.5-sdk  $packagepath-$version/etc/html5/common/qooxdoo-3.5-sdk

# 5. Copy modified setupcartavis.sh (to stop copying config.json to ~/.cartavis) and move config.json to correct internal location
cp $extra/setupcartavis.sh $packagepath-$version/bin/
cp -r $CARTABUILDHOME/build/config $packagepath-$version/etc/

# 6. Setup geodetic and ephemerides data in the measures_directory, define new casarc file correctly, and make carta.sh point to it correctly
cp -r $extra/measures_data $packagepath-$version/etc/
cp $extra/casarc $packagepath-$version/bin/
#sed -i 's|casarc|bin\/casarc|g' $packagepath-$version/bin/carta.sh
cp $extra/carta.sh $packagepath-$version/bin/

# 7. Copy over the sample images
mkdir $packagepath-$version/etc/images
cp -r $extra/carta_release_images/* $packagepath-$version/etc/images/

# 8. Fix for QtSql; copy the library file to the correct location
mkdir $packagepath-$version/bin/sqldrivers
cp $qtpath/../plugins/sqldrivers/libqsqlite.so $packagepath-$version/bin/sqldrivers


