#!/bin/bash
###
### Final packaging steps on CentOS6    (Last updated: 3/5/17)
###
### Uses our own modified 'carta-distro' template (taken from the NRAO casa-pkg)
### (Including the 'desktop' to 'CARTA' name update from the 28th April 2017
### develop branch commit)
###
### Note: Some paths may need to be adjusted for your system. 
###       So please check every line carefully.
###


# 0. Define the installed location of your Qt 5.3 and CARTA source code (for grabing the latest html):
CARTABUILDHOME=~/cartabuild      
qtpath=/Qt5.3.2/5.3/gcc_64       ## location of your Qt installation
dependencies=~/dependencies      ## location of your gcc4.8.2 installation
casapath=/casa/trunk/linux       ## location of your casacore/code installation
cartapath=~/cartabuild/CARTAvis  ## location of your CARTA source code
packagepath=/tmp/carta
version=6.6.8                    ## version number to be put on the dmg

# 1. Export the location of the successfully built casacore/casacode library files
export LD_LIBRARY_PATH=$casapath/lib


# 2. Download and run the make-app-carta script using the 'carta-distro' template
svn export https://github.com/CARTAvis/deploytask/trunk/make-app-carta
chmod 755 make-app-carta
rm -rf $packagepath-$version
svn export https://github.com/CARTAvis/deploytask/trunk/carta-distro
./make-app-carta -ni -v version=$version out=/tmp ws=$CARTABUILDHOME/build/cpp/desktop template=carta-distro


# 3. Fix a few things
cp $dependencies/gcc-4.8.2/lib64/libstdc++.so.6 $packagepath-$version/lib/

cp -r $qtpath/plugins/platforms $packagepath-$version/bin/

cp -r $qtpath/lib/libQt5DBus.so.5.3.2  $packagepath-$version/lib/
mv $packagepath-$version/lib/libQt5DBus.so.5.3.2 $packagepath-$version/lib/libQt5DBus.so.5

chrpath -c -r '$ORIGIN/../../lib/:$ORIGIN/../../plugins/CasaImageLoader/' $packagepath-$version/plugins/ImageStatistics/libplugin.so

cp /usr/lib64/libcfitsio.so $packagepath-$version/lib/
mv $packagepath-$version/lib/libcfitsio.so $packagepath-$version/lib/libcfitsio.so.4


# 4. Copy over the html and qooxdoo
cp -r $cartapath/carta/html5 $packagepath-$version/etc/
rm  $packagepath-$version/etc/html5/common/qooxdoo-3.5-sdk
cp -r $CARTABUILDHOME/CARTAvis-externals/ThirdParty/qooxdoo-3.5-sdk  $packagepath-$version/etc/html5/common/qooxdoo-3.5-sdk


# 5. Setup geodetic and ephemerides data
curl -O -L http://www.asiaa.sinica.edu.tw/~ajm/carta/measures_data.tar.gz
tar -xvf measures_data.tar.gz
mv measures_data $packagepath-$version/etc/
rm measures_data.tar.gz


# 6. Copy over the sample images
curl -O -L http://www.asiaa.sinica.edu.tw/~ajm/carta/images.tar.gz
tar -xvf images.tar.gz
mkdir $packagepath-$version/etc/images
mv images $packagepath-$version/etc/
rm images.tar.gz


# 7. Fix for QtSql; copy the library file to the correct location
mkdir $packagepath-$version/bin/sqldrivers
cp $qtpath/plugins/sqldrivers/libqsqlite.so $packagepath-$version/bin/sqldrivers


# Finish

