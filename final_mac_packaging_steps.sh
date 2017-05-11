#!/bin/bash
####
#### Script to be run after CARTA 'make' for MacOS/OSX
#### Please check every line carefully, including commented-out lines.
#### 
#### For CARTA develop branch after 28 May 2017.
#### (at that point the 'desktop' executable was renamed to 'CARTA')
####

# 0. Define the installed location of your Qt 5.7.1 and CARTA source code (for latest html):
CARTABUILDHOME=~/cartabuild
qtpath=/Users/ajm/Qt/5.7/clang_64
cartapath=/Users/ajm/cartabuild/CARTAvis
packagepath=/tmp/Carta.app
version=8.8.9  ## A version number to be put on the dmg

# 1. Fix paths (Based on Ville's NRAO instructions)
mkdir $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks
cd $CARTABUILDHOME/build

cp ./cpp/core/libcore.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/
cp ./cpp/CartaLib/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/

install_name_tool -change qwt.framework/Versions/6/qwt $CARTABUILDHOME/CARTAvis-externals/ThirdParty/qwt-6.1.2/lib/qwt.framework/Versions/6/qwt $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change qwt.framework/Versions/6/qwt $CARTABUILDHOME/CARTAvis-externals/ThirdParty/qwt-6.1.2/lib/qwt.framework/Versions/6/qwt $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib
install_name_tool -change libplugin.dylib $CARTABUILDHOME/build/cpp/plugins/CasaImageLoader/libplugin.dylib $CARTABUILDHOME/build/cpp/plugins/ImageStatistics/libplugin.dylib
install_name_tool -change libcore.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $CARTABUILDHOME/build/cpp/plugins/ImageStatistics/libplugin.dylib

install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/plugins/ImageStatistics/libplugin.dylib
install_name_tool -change libcore.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib

for f in `find . -name libplugin.dylib`; do install_name_tool -change libcore.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $f; done
for f in `find . -name libplugin.dylib`; do install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $f; done
for f in `find . -name "*.dylib"`; do install_name_tool -change libwcs.5.15.dylib  $CARTABUILDHOME/CARTAvis-externals/ThirdParty/wcslib/lib/libwcs.5.15.dylib $f; echo $f; done
for f in `find . -name libplugin.dylib`; do install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $f; done


# 2. Download and run the latest make-app-carta script
svn export https://github.com/CARTAvis/deploytask/trunk/make-app-carta
sed -i '' 's|\/Users\/rpmbuild\/Qt5.7.0\/5.7\/clang_64|'"${qtpath}"'|g' make-app-carta
chmod 755 make-app-carta
rm -rf $packagepath 
svn export https://github.com/CARTAvis/deploytask/trunk/Carta.app
./make-app-carta -ni -v out=/tmp  ws=$CARTABUILDHOME/build/cpp/desktop/CARTA.app template=Carta.app

# 3. Remove .prl files and fix some things
for f in `find $packagepath/Contents/Frameworks -name "*.prl"`;
do
 echo $f;
 rm $f;
done

install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui @loader_path/QtGui.framework/Versions/5/QtGui $packagepath/Contents/Frameworks/libCartaLib.1.dylib

install_name_tool -change @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport @loader_path/../../../QtPrintSupport.framework/Versions/5/QtPrintSupport $packagepath/Contents/Frameworks/qwt.framework/Versions/Current/qwt

# 4. Add  @rpath to desktop executable
install_name_tool -add_rpath @loader_path/../Frameworks $packagepath/Contents/MacOS/CARTA


# 5. Copy over libqcocoa.dylib (no need to change @rpath to @loader_path as we will add @rpath to the desktop exectuable)
mkdir $packagepath/Contents/MacOS/platforms/
cp $qtpath/plugins/platforms/libqcocoa.dylib $packagepath/Contents/MacOS/platforms/libqcocoa.dylib


# 6. Copy the html to the application directory
cp -r $cartapath/carta/VFS/DesktopDevel $packagepath/Contents/Resources/html


# 7. Setup geodetic and ephemerides data in the measures_directory
curl -O -L http://www.asiaa.sinica.edu.tw/~ajm/carta/measures_data.tar.gz
tar -xvf measures_data.tar.gz
mv measures_data $packagepath/Contents/Resources/
rm measures_data.tar.gz



# 8. Copy over the sample images
curl -O -L http://www.asiaa.sinica.edu.tw/~ajm/carta/images.tar.gz
tar -xvf images.tar.gz
mkdir $packagepath/Contents/Resources/images 
mv images $packagepath/Contents/Resources/images/
rm images.tar.gz


# 9. Copy the new app icon
cp $extra/applet.icns $packagepath/Contents/Resources/


# 10. Fix for QtSql; copy its dylib file to the executable folder
mkdir $packagepath/Contents/MacOS/sqldrivers
cp $qtpath/plugins/sqldrivers/libqsqlite.dylib $packagepath/Contents/MacOS/sqldrivers/


# 11. Rename Carta.app inot CARTA.app
#mv /tmp/Carta.app /tmp/CARTA_$version.app


# 12. Download and run the dmg creation script
###
### Until further notice, need to add the following to the script if using MacOS 10.12 Sierra 
###  "16")
###      readonly OS_X_VERSION="10.12"
###      ;;
###
#curl -O -L https://open-bitbucket.nrao.edu/projects/CASA/repos/casa-pkg/raw/packaging/scripts/make-carta-dmg.sh
#chmod 755 make-carta-dmg.sh
#./make-carta-dmg.sh /tmp/CARTA_$version.app

