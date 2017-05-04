# deploytask
Temporary repo to put deploy scripts and stuff

# A summary of steps to build and package CARTA
(Assuming installation of all packages and libraries described on https://github.com/CARTAvis/carta is already done)

1. Export your Qt path e.g. `export PATH=/Qt5.3.2/5.3/gcc_64/bin:$PATH`

2. Download the latest CARTA source code `git clone https://github.com/CARTAvis/carta.git CARTAvis`

3. Build the html part `./CARTAvis/carta/scripts/buildUIfile.sh`

4. Prepare a build directory e.g. `mkdir build && cd build`

5. Run the Qt qmake e.g. `qmake NOSERVER=1 CARTA_BUILD_TYPE=dev ../CARTAvis/carta -r`

6. Build the code e.g. `make -j 4`

7. Download the appropriate packaging script from here e.g `svn export https://github.com/CARTAvis/deploytask/trunk/final_centos7_packaging_steps.sh`

8. Run that script `chmod 755 final_centos7_packaging_steps.sh && ./final_centos7_packaging_steps.sh`

# Miscellaneous files
These scripts automatically download two archives as follow: 
1. `measures_data` containing the ephemerides and geodetic files:
http://www.asiaa.sinica.edu.tw/~ajm/carta/measures_data.tar.gz

2. `images` containing a few sample images:
http://www.asiaa.sinica.edu.tw/~ajm/carta/images.tar.gz

They also download and use updated versions of the Mac `Carta.app` and Linux `carta-distro` templates that have been extracted from the original NRAO `casa-pkg` template. 
The `Carta.app` and `carta-distro` are on this repository.

The `casarc`, `carta.sh`, and `setupcartavis.sh` files are slightly different between Mac and Linux, and the latest versions have been put inside the appropriate templates for now.

## To Do:
1. Unify the `casarc`, `carta.sh`, and `setupcartavis.sh` so that only one version is needed between Mac and Linux.
2. Make `setupcartavis.sh` obsolete.
3. Unify the CentOS7 and CentOS6 scripts into a single Linux script.


# Note:
After the 28th April 2017, the carta develop branch changed the name of the main executable. Old executable name: `desktop`. New executable name: `CARTA`. 
We need to update the current casa-pkg template for this new change but the separate `Carta.app` and `carta-distro` templates on this repository already contain these changes.
If you really want to use the `casa-pkg` template, you can make the changes manually with a symbolic link (Here assuming casa-pkg is downloaded to /tmp/).

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

Any branches before 28th April 2017 still use the old `desktop` name.

