#!/bin/bash
####
#### Script to sign the CARTA Application
#### (work in progress)
#### First let's experiment and sign the final dmg file as that is the simplest

echo "App signing script is running"

### Get the certifcicates
echo "Step 1: Getting the certificates from GitHub"

curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/developer_ID_application.p12.enc
curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/developer_ID_installer.p12.enc
curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/developer_profile.developerprofile.enc
curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/AppleWWDRCA.cer

ls -sort ## to check the files

### Decrypt the certificates
echo "Step 2: Decypting the certificates"

openssl aes-256-cbc -k "$encyption_password" -in developer_ID_application.p12.enc -d -a -out developer_ID_application.p12
openssl aes-256-cbc -k "$encyption_password" -in developer_ID_installer.p12.enc -d -a -out developer_ID_installer.p12
openssl aes-256-cbc -k "$encyption_password" -in developer_profile.developerprofile.enc -d -a -out developer_profile.developerprofile

ls -sort 

### Create custom keychain
echo "Step 3: Creating custom keychain"

security create-keychain -p $keychain_password carta.build.keychain
security default-keychain -s carta.build.keychain
security unlock-keychain -p $keychain_password carta.build.keychain

### Import Certificates
echo "Step 4: Importing keys"

security import AppleWWDRCA.cer -k carta.build.keychain -A
security import developer_profile.developerprofile -k carta.build.keychain -A
security import developer_ID_application.p12 -k carta.build.keychain -p $keychain_password -A
security import developer_ID_installer.p12 -k  carta.build.keychain -p $keychain_password -A

### Do the codesign
echo "Step 5: Codesigning"

### For signing the App (Will need to change path location)
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/MacOS/casarc 
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/MacOS/CARTA 
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/MacOS/setupcartavis.sh 
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/MacOS/carta.sh 
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/MacOS/sqldrivers/*
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/MacOS/platforms/*
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/Frameworks/qwt.framework
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/Frameworks/Qt*
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/Frameworks/lib*
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app/Contents/Frameworks/.gitkeep 
#codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" CARTA.app

### Sign the dmg
codesign -v Carta.dmg

codesign -s "INSTITUTE OF ASTRONOMY AND ASTROPHYSICS, ACADEMIA SINICA" Carta.dmg

codesign -v Carta.dmg # for checking it worked

echo "This is the end of the signing script"

