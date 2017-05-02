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
extra=/Users/ajm/finish  ## location of extra files used to finish packaging (Download from http://www.asiaa.sinica.edu.tw/~ajm/carta/finish.tar.gz )
version=8.8.8  ## A version number to be put on the dmg

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
rm -rf Carta.app
svn export https://github.com/CARTAvis/deploytask/trunk/Carta.app
./make-app-carta -ni -v out=/tmp  ws=$CARTABUILDHOME/build/cpp/desktop/CARTA.app template=Carta.app


# 3. Add  @rpath to desktop executable
install_name_tool -add_rpath @loader_path/../Frameworks $packagepath/Contents/MacOS/CARTA


# 4. Copy over libqcocoa.dylib (no need to change @rpath to @loader_path as we will add @rpath to the desktop exectuable)
mkdir $packagepath/Contents/MacOS/platforms/
cp $qtpath/plugins/platforms/libqcocoa.dylib $packagepath/Contents/MacOS/platforms/libqcocoa.dylib


# 5. Copy the new config.json file (it includes lines to define the location for PCacheSqlite3 plugin cache file location)
mkdir $packagepath/Contents/Resources/config
cp $extra/config.json $packagepath/Contents/Resources/config/


# 6. Copy the html to the application directory
cp -r $cartapath/carta/VFS/DesktopDevel $packagepath/Contents/Resources/html


# 7. Setup geodetic and ephemerides data in the measures_directory and define new casarc file correctly
cp -r $extra/measures_data $packagepath/Contents/Resources/
cp $extra/casarc $packagepath/Contents/MacOS/


# 8. Copy modified carta.sh and setupcartavis.sh
cp $extra/carta.sh $packagepath/Contents/MacOS/
cp $extra/setupcartavis.sh $packagepath/Contents/MacOS/ 


# 9. Copy over the sample images
mkdir $packagepath/Contents/Resources/images 
cp -r $extra/carta_release_images/* $packagepath/Contents/Resources/images/


# 10. Copy the new app icon
cp $extra/applet.icns $packagepath/Contents/Resources/


# 11. Fix for QtSql; copy its dylib file to the executable folder
mkdir $packagepath/Contents/MacOS/sqldrivers
cp $qtpath/plugins/sqldrivers/libqsqlite.dylib $packagepath/Contents/MacOS/sqldrivers/


# 12. Rename Carta.app inot CARTA.app
mv /tmp/Carta.app /tmp/CARTA_$version.app

# 13. Download and run the dmg creation script
###
### Until further notice, need to add the following to the script if using MacOS 10.12 Sierra 
###  "16")
###      readonly OS_X_VERSION="10.12"
###      ;;
###
curl -O -L https://open-bitbucket.nrao.edu/projects/CASA/repos/casa-pkg/raw/packaging/scripts/make-carta-dmg.sh
chmod 755 make-carta-dmg.sh
./make-carta-dmg.sh /tmp/CARTA_$version.app

