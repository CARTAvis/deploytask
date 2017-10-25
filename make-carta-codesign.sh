#!/bin/bash
####
#### Script to sign the CARTA Application
#### (work in progress)
#### First let's experiment and sign the final dmg file as that is the simplest

echo "App signing script is running"

### Get the certifcicates
echo "Step 1: Getting the certificates from GitHub"

curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/development-key.p12.enc
curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/developerID_application.cer.enc
curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/AppleWWDRCA.cer

ls -sort ## to check the files

### Decrypt the certificates
echo "Step 2: Decypting the certificates"

openssl enc -aes-256-cbc -k "$encryption_password" -in developerID_application.cer.enc -d -a -out developerID_application.cer
openssl enc -aes-256-cbc -k "$encryption_password" -in development-key.p12.enc -d -a -out development-key.p12

ls -sort

### Create custom keychain
echo "Step 3: Creating custom keychain"

security list-keychains

security create-keychain -p $keychain_password acdc.carta.keychain
security default-keychain -s acdc.carta.keychain
security unlock-keychain -p $keychain_password acdc.carta.keychain
security set-keychain-settings -lut 3600 acdc.carta.keychain

security list-keychains

### Import Certificates
echo "Step 4: Importing keys"

security import AppleWWDRCA.cer -k acdc.carta.keychain -A
security import developerID_application.cer -k acdc.carta.keychain -A
security import development-key.p12 -k acdc.carta.keychain -P $security_password -A

security set-key-partition-list -S apple-tool:,apple: -s -k $keychain_password acdc.carta.keychain

security find-identity -v -p codesigning

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

codesign -s "2EE072130251C53A08E5ED956E4AA227CDF54D1A" Carta.dmg

codesign -v Carta.dmg # for checking it worked

echo "This is the end of the signing script"

