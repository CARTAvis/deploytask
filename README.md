# deploytask
Temporary repo to put deploy scripts and stuff


# Miscellaneous files
These scripts make use of some miscellaneous files available from the following two archives: 

For Mac builds: http://www.asiaa.sinica.edu.tw/~ajm/carta/finish.tar.gz

For Linux builds: http://www.asiaa.sinica.edu.tw/~ajm/carta/finish_linux.tar.gz

They currently contain: 
1. `measures_data` directory containing the ephemerides and geodetic files.
2. `casarc` file that points towards the measures_data location
3. Latest `carta.sh`
4. Latest `setupcartavis.sh`

`casarc`, `carta.sh`, and `setupcartavis.sh`  are slightly different between Mac and Linux.

## To Do:
1. Unify the `casarc`, `carta.sh`, and `setupcartavis.sh` so that only one version is needed.
2. Have the the latest versions of them (without needing modifications) contained in the carta repository instead.
3. Make `setupcartavis.sh` obsolete.


## New method, thanks to Grimmer's idea:

We put the latest Mac `Carta.app` and the Linux `carta-distro` templates on this repository for now.
They can be downloaded with the following commands:
```
Mac: svn export https://github.com/CARTAvis/deploytask/trunk/Carta.app
Linux: svn export https://github.com/CARTAvis/deploytask/trunk/carta-distro
```
But these commands will be added to the packaging scripts.

Now there will be no need to download the entire casa-pkg template.

# Note:
After the 28th April 2017, the carta develop branch changed `desktop` to `CARTA`. 
We need to update the current casa-pkg template for this new change.
Meanwhile we can do it manually with a symbolic link (Here assuming casa-pkg is downloaded to /tmp/).

For Mac:
```
cd /tmp/casa-pkg/packaging/template/osx/Carta.app/Contents/MacOS
ln -s @@WS@@/Contents/MacOS/CARTA CARTA
rm desktop
```

For Linux:
```
cd /tmp/casa-pkg/packaging/template/linux/carta-distro/bin
ln -s @@WS@@/CARTA CARTA
rm desktop
```

Also, make sure the `carta.sh` you are using has updated the line `appname=desktop` to `appname=CARTA`

Any branches before 28th April 2017 still use `desktop`


