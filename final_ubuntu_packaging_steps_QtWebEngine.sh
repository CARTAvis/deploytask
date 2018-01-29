#!/bin/bash
###
### Final packaging steps for CARTA QtWebEngine version on ubuntu    (Last updated: 23/9/17)
###
### Note: Some paths may need to be adjusted for your system. 
###       So please check every line carefully.
###

# 0. Define the installed location of your Qt and CARTA source code (for grabing the latest html):
CARTABUILDHOME=~/cartahome
qtpath=/opt/Qt5.9.1/5.9.1/gcc_64                        ## location of your Qt installation
casapath=~/cartahome/CARTAvis-externals/ThirdParty/casa ## location of casacore/code installation
cartapath=~/cartahome/CARTAvis                          ## location of your CARTA source code
thirdparty=~/cartahome/CARTAvis-externals/ThirdParty    ## location where qooxdoo is installed 
packagepath=/tmp/carta
version=1.2.4                                           ## version number to be put on the final package

# 1. Export the location of the successfully built casacore/casacode library files
export LD_LIBRARY_PATH=$casapath/trunk/linux/lib


# 2. Download and run the latest make-app-carta script using the 'carta-distro' template
svn export https://github.com/CARTAvis/deploytask/trunk/make-app-carta
chmod 755 make-app-carta
rm -rf $packagepath-$version
svn export https://github.com/CARTAvis/deploytask/trunk/carta-distro
./make-app-carta -ni -v version=$version out=/tmp ws=$CARTABUILDHOME/CARTAvis/build/cpp/desktop template=carta-distro


# 3. Fix a few things
cp -r $qtpath/plugins/platforms $packagepath-$version/bin/

cp $qtpath/lib/libQt5DBus.so.5 $packagepath-$version/lib/

chrpath -c -r '$ORIGIN/../../lib:$ORIGIN/../../plugins/CasaImageLoader' $packagepath-$version/plugins/ImageStatistics/libplugin.so

cp $thirdparty/cfitsio/lib/libcfitsio.so.5 $packagepath-$version/lib/


# 4. Copy over the html and qooxdoo
cp -r $cartapath/carta/html5 $packagepath-$version/etc
rm  $packagepath-$version/etc/html5/common/qooxdoo-3.5.1-sdk
cp -r $thirdparty/qooxdoo-3.5.1-sdk $packagepath-$version/etc/html5/common/qooxdoo-3.5.1-sdk

rm -f $packagepath-$version/etc/html5/html5.iml
rm -f $packagepath-$version/etc/html5/._html5.iml
rm -f $packagepath-$version/etc/html5/.idea


# 5. Setup geodetic and ephemerides data
curl -O -L http://alma.asiaa.sinica.edu.tw/_downloads/measures_data.tar.gz
tar -xvf measures_data.tar.gz
mv measures_data $packagepath-$version/etc/
rm measures_data.tar.gz


# 6. Copy over the sample images
curl -O -L http://alma.asiaa.sinica.edu.tw/_downloads/images.tar.gz
tar -xvf images.tar.gz
mkdir $packagepath-$version/etc/images
mv images $packagepath-$version/etc/
rm images.tar.gz


# 7. Fix for QtSql; copy the library file to the correct location
mkdir $packagepath-$version/bin/sqldrivers
cp $qtpath/plugins/sqldrivers/libqsqlite.so $packagepath-$version/bin/sqldrivers


# 8. Copy NSS libraries
cp -rf /usr/lib/x86_64-linux-gnu/nss $packagepath-$version/lib/


# 9. Fixes for xcb
cp $qtpath/lib/libQt5XcbQpa.so.5 $packagepath-$version/lib/
cp -r $qtpath/plugins/xcbglintegrations $packagepath-$version/bin/


# 10. Copy the QtWebEngine files
cp $qtpath/libexec/QtWebEngineProcess $packagepath-$version/bin/
cp -r $qtpath/translations/qtwebengine_locales $packagepath-$version/bin/
cp $qtpath/resources/* $packagepath-$version/bin/
mkdir $packagepath-$version/bin/imageformats
cp -r $qtpath/plugins/imageformats/libqjpeg.so $packagepath-$version/bin/imageformats/


# 10. Remove PYTHONPATH from carta.sh as Ubuntu comes with Python2.7 by default
sed --in-place '/export PYTHONHOME=$dirname/d' $packagepath-$version/bin/carta.sh 


# 12. Make the symbolic link so that the HTML can be found
cd $packagepath-$version/bin/
ln -s ../etc etc
cd -


# 13. Remove libEGL.so.1 otherwise there would be a conflict with a 
#     libmirclient.so.9 on a different Ubuntu distribution
rm $packagepath-$version/lib/libEGL.so.1


#Finished

