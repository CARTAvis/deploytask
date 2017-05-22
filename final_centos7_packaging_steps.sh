#!/bin/bash
###
### Final packaging steps on CentOS7    (Last updated: 4/5/17)
###
### Uses our own modified 'carta-distro' template (taken from the NRAO casa-pkg)
### (Including the 'desktop' to 'CARTA' name update from the 28th April 2017
### develop branch commit)
###
### Note: Some paths may need to be adjusted for your system. 
###       So please check every line carefully.
###

# 0. Define the installed location of your Qt 5.3 and CARTA source code (for grabing the latest html):
CARTABUILDHOME=~/cartawork
qtpath=/opt/Qt/5.3/gcc_64                               ## location of your Qt installation
casapath=~/cartawork/CARTAvis-externals/ThirdParty/casa ## location of casacore/code installation
cartapath=~/cartawork/CARTAvis                          ## location of your CARTA source code
thirdparty=~/cartawork/CARTAvis-externals/ThirdParty    ## location where qooxdoo is installed 
packagepath=/tmp/carta
version=7.7.7                                           ## version number to be put on the final package

# 1. Export the location of the successfully built casacore/casacode library files
export LD_LIBRARY_PATH=$casapath/trunk/linux/lib


# 2. Download and run the latest make-app-carta script using the 'carta-distro' template
svn export https://github.com/CARTAvis/deploytask/trunk/make-app-carta
chmod 755 make-app-carta
rm -rf $packagepath-$version
svn export https://github.com/CARTAvis/deploytask/trunk/carta-distro
./make-app-carta -ni -v version=$version out=/tmp ws=$CARTABUILDHOME/build/cpp/desktop template=carta-distro


# 3. Fix a few things
cp -r $qtpath/plugins/platforms $packagepath-$version/bin/

cp $qtpath/lib/libQt5DBus.so.5 $packagepath-$version/lib/

chrpath -c -r '$ORIGIN/../lib:$ORIGIN/../plugins/CasaImageLoader' $packagepath-$version/plugins/ImageStatistics/libplugin.so

cp $thirdparty/cfitsio/lib/libcfitsio.so.5 $packagepath-$version/lib/

rm -f $packagepath-$version/include/python2.7

# 4. Copy over the html and qooxdoo
cp -r $cartapath/carta/html5 $packagepath-$version/etc
rm  $packagepath-$version/etc/html5/common/qooxdoo-3.5.1-sdk
cp -r $thirdparty/qooxdoo-3.5.1-sdk $packagepath-$version/etc/html5/common/qooxdoo-3.5.1-sdk

rm -f $packagepath-$version/etc/html5/html5.iml
rm -f $packagepath-$version/etc/html5/._html5.iml
rm -f $packagepath-$version/etc/html5/.idea

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


#Finished

