#!/bin/bash
####
#### Script to be run after CARTA 'make' for MacOS/OSX
#### Please check every line carefully, including commented-out lines.
#### 
#### For CARTA develop branch after 28 May 2017.
#### (at that point the 'desktop' executable was renamed to 'CARTA')
####

echo "0. Define the installed location of your Qt 5.7.1 and CARTA source code (for latest html):"
CARTABUILDHOME=~/cartahome/CARTAvis
qtpath=/usr/local/Cellar/qt@5.7/5.7.1
cartawork=~/cartahome
packagepath=/tmp/Carta.app
app_name=CARTA
version=8.9.9  ## A version number to be put on the dmg
dmg_title="CARTAtest" ## Bug... can't accept spaces in the name


echo "1. Fix paths (Based on Ville's NRAO instructions):"
mkdir $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks
cd $CARTABUILDHOME/build

cp ./cpp/core/libcore.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/
cp ./cpp/CartaLib/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/

install_name_tool -change qwt.framework/Versions/6/qwt $cartawork/CARTAvis-externals/ThirdParty/qwt-6.1.2/lib/qwt.framework/Versions/6/qwt $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change qwt.framework/Versions/6/qwt $cartawork/CARTAvis-externals/ThirdParty/qwt-6.1.2/lib/qwt.framework/Versions/6/qwt $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib
install_name_tool -change libplugin.dylib $cartawork/build/cpp/plugins/CasaImageLoader/libplugin.dylib $CARTABUILDHOME/build/cpp/plugins/ImageStatistics/libplugin.dylib
install_name_tool -change libcore.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $CARTABUILDHOME/build/cpp/plugins/ImageStatistics/libplugin.dylib

install_name_tool -change libCartaLib.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/plugins/ImageStatistics/libplugin.dylib
install_name_tool -change libcore.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change libCartaLib.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change libCartaLib.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib

for f in `find . -name libplugin.dylib`; do install_name_tool -change libcore.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $f; done
for f in `find . -name libplugin.dylib`; do install_name_tool -change libCartaLib.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $f; done
for f in `find . -name "*.dylib"`; do install_name_tool -change libwcs.5.15.dylib $cartawork/CARTAvis-externals/ThirdParty/wcslib/lib/libwcs.5.15.dylib $f; echo $f; done
for f in `find . -name libplugin.dylib`; do install_name_tool -change libCartaLib.1.dylib $cartawork/build/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $f; done


echo "2. Download and run the latest make-app-carta script:"
curl -O https://raw.githubusercontent.com/CARTAvis/deploytask/Qt5.8.0/make-app-carta
chmod 755 make-app-carta
export qtpath=$qtpath
rm -rf $packagepath 
svn export https://github.com/CARTAvis/deploytask/trunk/Carta.app
./make-app-carta -ni -v out=/tmp  ws=$CARTABUILDHOME/build/cpp/desktop/CARTA.app template=Carta.app


echo "3. Remove .prl files and fix some things:"
for f in `find $packagepath/Contents/Frameworks -name "*.prl"`;
do
 echo $f;
 rm -f $f;
done

install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui @loader_path/QtGui.framework/Versions/5/QtGui $packagepath/Contents/Frameworks/libCartaLib.1.dylib

install_name_tool -change @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport @loader_path/../../../QtPrintSupport.framework/Versions/5/QtPrintSupport $packagepath/Contents/Frameworks/qwt.framework/Versions/Current/qwt


echo "4. Add  @rpath to desktop executable:"
install_name_tool -add_rpath @loader_path/../Frameworks $packagepath/Contents/MacOS/CARTA


echo "5. Copy over libqcocoa.dylib, no need to change @rpath to @loader_path as we will add @rpath to the desktop exectuable:"
mkdir $packagepath/Contents/MacOS/platforms/
cp $qtpath/plugins/platforms/libqcocoa.dylib $packagepath/Contents/MacOS/platforms/libqcocoa.dylib


echo "6. Copy the html to the application directory:"
cp -r $cartawork/CARTAvis/carta/VFS/DesktopDevel $packagepath/Contents/Resources/html


echo "7. Setup geodetic and ephemerides data in the measures_directory:"
curl -O -L http://www.asiaa.sinica.edu.tw/~ajm/carta/measures_data.tar.gz
tar -xvf measures_data.tar.gz
mv measures_data $packagepath/Contents/Resources/
rm measures_data.tar.gz


echo "8. Copy over the sample images:"
curl -O -L http://www.asiaa.sinica.edu.tw/~ajm/carta/images.tar.gz
tar -xvf images.tar.gz
mv images $packagepath/Contents/Resources/
rm images.tar.gz


echo "9. Fix for QtSql; copy its dylib file to the executable folder:"
mkdir $packagepath/Contents/MacOS/sqldrivers
cp $qtpath/plugins/sqldrivers/libqsqlite.dylib $packagepath/Contents/MacOS/sqldrivers/


echo "10. Modify the directory structure of QtWebKit.framework and QtWebKitWidgets.framework:"
#     to be consistent with the other Qt*.framework directories
#     (The difference is due to the fact we are using pre-built QtWebKit binaries)
#     The changes are necessary so that the app can be signed and pass verification tests.
#     Note: Still need to confirm this works.

pwd=`pwd`

cd $packagepath/Contents/Frameworks/QtWebKit.framework
rm QtWebkit
rm -rf Headers
rm -rf Resources
ln -s Versions/Current/QtWebKit QtWebKit
ln -s Versions/Current/Headers Headers
ln -s Versions/Current/Resources Resources
cd Versions
mv 5.602.2 5
rm -rf Current
ln -s 5 Current
cd 5
chmod 644 QtWebKit

cd $packagepath/Contents/Frameworks/QtWebKitWidgets.framework
rm QtWebkitWidgets
rm -rf Headers
rm -rf Resources
ln -s Versions/Current/QtWebKitWidgets QtWebKitWidgets
ln -s Versions/Current/Headers Headers
ln -s Versions/Current/Resources Resources
cd Versions
mv 5.602.2 5
rm -rf Current
ln -s 5 Current
cd 5
chmod 644 QtWebKitWidgets

cd $pwd

echo "11. Download and run the dmg creation script:"
curl -O https://raw.githubusercontent.com/CARTAvis/deploytask/master/make-carta-dmg.sh
chmod 755 make-carta-dmg.sh
rm *.dmg
./make-carta-dmg.sh "${packagepath}" "${app_name}" "${version}" "${dmg_title}"
rm -rf /tmp/Carta

echo "Packaging complete"

