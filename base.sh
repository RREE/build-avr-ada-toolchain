#!/bin/bash

#--------------------------------------------------------------------------
#-     AVR-Ada - A GCC Ada environment for Microchip AVR8 (Ex-Atmel)     --
#-                                      *                                --
#-                                 AVR-Ada 2.0.0                         --
#-           Copyright (C) 2005, 2007, 2012, 2016, 2019 Rolf Ebert       --
#-                     Copyright (C) 2009 Neil Davenport                 --
#-                     Copyright (C) 2005 Stephane Riviere               --
#-                     Copyright (C) 2003-2005 Bernd Trog                --
#-                            avr-ada.sourceforge.net                    --
#-                                      *                                --
#-                                                                       --
#--------------------------------------------------------------------------
#- The AVR-Ada Library is free software;  you can redistribute it and/or --
#- modify it under terms of the  GNU General Public License as published --
#- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
#- option) any later version.  The AVR-Ada Library is distributed in the --
#- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
#- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
#- PURPOSE. See the GNU General Public License for more details.         --
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
#-                          AVR-Ada EasyBake Build script                --
#-                                      *                                --
#-  This script  will download,  prepare and build  AVR-Ada without      --
#-  any human interaction and is designed to make the build process      --
#-  easier for beginners and experts alike                               --
#-                                      *                                --
#-  To use simply create a directory and copy this script to it then     --
#-  cd into the directory and type ./build-avr-ada.sh                    --
#-
#-  N.B. This script was written for BASH. If you use another shell      --
#-  invoke with bash ./build-avr-ada.sh                                  --
#-                                                                       --
#--------------------------------------------------------------------------

#---------------------------------------------------------------------------
#
# $DOWNLOAD  : should point to directory which contains the files
#              specified by : FILE_BINUTILS, FILE_GCC and FILE_LIBC
# $AVR_BUILD : the temporary directory used to build AVR-Ada
# $PREFIX    : the root of the installation directory
# $FILE_...  : filenames of the source distributions without extension
#
#---------------------------------------------------------------------------

#
# ! ! ! ! ! !
#
# The script assumes write permissions to the installation
# directory. You can either run the script as root or provide a
# private installation path of the build user.
#
# ! ! ! ! ! !
#
BASE_DIR=$PWD
OS=`uname -s`
case "$OS" in
    "Linux" )
        PREFIX="/opt/avr_92_gnat"
        WITHGMP="/usr"
        WITHMPFR="/usr";;
    "Darwin" )
        PREFIX="/opt/avr_92_gnat"
        WITHGMP="/opt/local"
        WITHMPFR="/opt/local";;
    * )
        PREFIX="/mingw/avr_92_gnat"
        WITHGMP="/mingw"
        WITHMPFR="/mingw";;
esac

source bin/utilities.inc
source bin/versions.inc
source bin/config.inc

# Check if current user has write privileges to parent of $PREFIX
PREFIX_PARENT=$(dirname "$PREFIX")
check_privileges "$PREFIX_PARENT"

# add PREFIX/bin to the PATH
# Be sure to have the local directory very late in your PATH, best at the
# very end.
export PATH="${PREFIX}/bin:${PATH}"

# Only on MinGW:
# export PATH=/mingwRE/bin:${PATH}
# export LIBRARY_PATH=/mingwRE/lib:/mingw/lib
# export CPATH=/mingw/include
# !! unset CPATH before compiling avr-libc !!


# actions:
download_files="no"
delete_obj_dirs="no"
delete_build_dir="no"
delete_install_dir="no"   # Be carefull, will remove *all* software installed in $PREFIX!!!
build_binutils="no"
build_gcc="no"
build_mpfr="no"
build_mpc="no"
build_gmp="no"
build_libc="no"
build_avradarts="no"
build_avrdude="no"
build_avrada="no"

# The following are advanced options not required for a normal build
# either delete the build directory completely
#
#   delete_build_dir="yes"
#
# or delete only the obj directories.  You probably want to keep the
# extracted and patched sources
#
#   delete_build_dir="no"
#   delete_obj_dirs="yes"
#   no_extract="yes"
#   no_patch="yes"
#

#CC="gcc -mno-cygwin"
CC=gcc
export CC

#echo "Please adjust the variables above to your environment."
#echo "No need to change anything below."
#exit
