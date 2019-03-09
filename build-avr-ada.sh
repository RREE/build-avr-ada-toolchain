#!/bin/bash

#--------------------------------------------------------------------------
#-                AVR-Ada - A GCC Ada environment for AVR-Atmel          --
#-                                      *                                --
#-                                 AVR-Ada 2.0.0                         --
#-               Copyright (C) 2005, 2007, 2012, 2016, 2019 Rolf Ebert   --
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

#--------------------------------------------------------------------------
# Under Windows XP, you need :
#
# MinGW-5.1.6.exe (Windows installer).
# MSYS-1.0.10.exe (Windows installer).
# msysCORE-1.0.11-<latestdate>
# msysDTK-1.0.1.exe (Windows installer).
# flex-2.5.35-MSYS-1.0.11-1
# bison-2.4.2-MSYS-1.0.11-1
# regex-0.12-MSYS-1.0.11-1
# gettext-0.16.1-1
# tar-1.13.19-MSYS-2005.06.08
# autoconf 2.59
# automake 1.8.2
# wget
# cvs
#
#---------------------------------------------------------------------------
#
# $DOWNLOAD  : should point to directory which contains the files
#              specified by : FILE_BINUTILS, FILE_GCC and FILE_LIBC
# $AVR_BUILD : the temporary directory used to build AVR-Ada
# $PREFIX    : the root of the installation directory
# $FILE_...  : filenames of the source distributions without extension
# $BIN_PATCHES : blank separated list of binutils patch files
# $GCC_PATCHES : blank separated list of patch files for gcc
#
#---------------------------------------------------------------------------

BASE_DIR=$PWD
OS=`uname -s`
case "$OS" in
    "Linux" )
        PREFIX="/opt/avr_83_gnat"
        WITHGMP="/usr"
        WITHMPFR="/usr";;
    "Darwin" )
        PREFIX="/opt/avr_83_gnat"
        WITHGMP="/opt/local"
        WITHMPFR="/opt/local";;
    * )
        PREFIX="/mingw/avr_83_gnat"
        WITHGMP="/mingw"
        WITHMPFR="/mingw";;
esac

# add PREFIX/bin to the PATH
# Be sure to have the local directory very late in your PATH, best at the
# very end.
export PATH="${PREFIX}/bin:${PATH}"

# Only on MinGW:
# export PATH=/mingwRE/bin:${PATH}
# export LIBRARY_PATH=/mingwRE/lib:/mingw/lib
# export CPATH=/mingw/include
# !! unset CPATH before compiling avr-libc !!

source bin/versions.inc
source bin/config.inc


#AVRADA_PATCHES=$AVR_BUILD/avr-ada-$VER_AVRADA/patches
AVRADA_PATCHES=/home/re/Devel/AVR-Ada.git/avr-ada/patches
AVRADA_GCC_DIR="$AVRADA_PATCHES/gcc/$VER_GCC"
AVRADA_BIN_DIR="$AVRADA_PATCHES/binutils/$VER_BINUTILS"
AVRADA_LIBC_DIR="$AVRADA_PATCHES/avr-libc/$VER_LIBC"


# actions:
download_files="yes"
delete_obj_dirs="no"
delete_build_dir="no"
delete_install_dir="no"
build_binutils="no"
build_gcc="no"
build_mpfr="no"
build_mpc="no"
build_gmp="no"
build_libc="no"
build_avrada="no"
build_avrdude="yes"

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

source bin/utilities.inc

#---------------------------------------------------------------------------
# build script
#---------------------------------------------------------------------------

export PATH=$PREFIX/bin:$PATH

echo "--------------------------------------------------------------"
echo "GCC AVR-Ada build script: all output is saved in log files"
echo "--------------------------------------------------------------"
echo

GCC_VERSION=`$CC -dumpversion`
# GCC_MAJOR=`echo $GCC_VERSION | awk -F. ' { print $1; } '`
# GCC_MINOR=`echo $GCC_VERSION | awk -F. ' { print $2; } '`
# GCC_PATCH=`echo $GCC_VERSION | awk -F. ' { print $3; } '`

if [[ "$GCC_VERSION" < "4.7.0" ]] ; then  # string comparison (?)
    echo "($GCC_VERSION) is too old"
    echo "AVR-Ada V2 requires gcc-8 as build compiler"
    exit 2
else
    echo "Found native compiler gcc-"$GCC_VERSION
fi

if test "x$delete_build_dir" = "xyes" ; then
    echo
    echo "--------------------------------------------------------------"
    echo "Deleting previous build and source files"
    echo "--------------------------------------------------------------"
    echo

    echo "Deleting :" $AVR_BUILD
    rm -fr $AVR_BUILD

else
    if test "x$delete_obj_dirs" = "xyes" ; then
        echo
        echo "--------------------------------------------------------------"
        echo "Deleting previous obj dirs"
        echo "--------------------------------------------------------------"
        echo

        echo "Deleting :" $AVR_BUILD/binutils-obj
        rm -fr $AVR_BUILD/binutils-obj

        echo "Deleting :" $AVR_BUILD/gcc-obj
        rm -fr $AVR_BUILD/gcc-obj

    fi
fi

mkdir $AVR_BUILD

rm -f $AVR_BUILD/build.sum; touch $AVR_BUILD/build.sum
rm -f $AVR_BUILD/build.log; touch $AVR_BUILD/build.log


if test $delete_install_dir = "yes" ; then
    echo "Deleting :" $PREFIX
    rm -fr $PREFIX
fi


if test "x$download_files" = "xyes" ; then
    bin/download.sh
fi
print_time > $AVR_BUILD/time_run.log

#---------------------------------------------------------------------------

#
# unpack AVR-Ada first to get access to the patches
#

# cd $AVR_BUILD

# unpack_package AVRADA
# display "Extracting $DOWNLOAD/$FILE_AVRADA.tar.bz2 ..."
# bunzip2 -c $DOWNLOAD/$FILE_AVRADA.tar.bz2 | tar xf -

#
# set the list of patches after downloading
#
BIN_PATCHES=`(cd $AVRADA_BIN_DIR; ls -1 [0-9][0-9][0-9]-*binutils-*.patch)`
GCC_PATCHES=`(cd $AVRADA_GCC_DIR; ls -1 [0-9][0-9]-*gcc-*.patch)`
LIBC_PATCHES=`(cd $AVRADA_LIBC_DIR; ls -1 [0-9][0-9][0-9]-*libc-*.patch)`


#---------------------------------------------------------------------------

cd $AVR_BUILD

#---------------------------------------------------------------------------

if test "x$build_binutils" = "xyes" ; then
   #########################################################################
    header "Building Binutils"

    if test "x$no_extract" != "xyes" ; then
	unpack_package BINUTILS
    fi


    if test "x$no_patch" != "xyes" ; then

        display "patching binutils"

        cd $AVR_BUILD/$FILE_BINUTILS
        for p in $BIN_PATCHES; do
            display "   $p"
            patch --verbose --strip=0 --input=$AVRADA_BIN_DIR/$p  2>&1 >> $AVR_BUILD/build.log
            check_return_code
        done
    fi

    mkdir $AVR_BUILD/binutils-obj

    cd $AVR_BUILD/binutils-obj

    display "Configure binutils ... (log in $AVR_BUILD/step01_bin_configure.log)"

    case "$OS" in
        "Linux" | "Darwin" )
            BINUTILS_OPS=;;
        * )
            BINUTILS_OPS=--build=x86-winnt-mingw32;;
    esac
    ../$FILE_BINUTILS/configure \
        --prefix=$PREFIX \
        --target=avr \
        --disable-nls \
        --enable-doc \
        --disable-werror \
        $BINUTILS_OPS \
        &>$AVR_BUILD/step01_bin_configure.log
    check_return_code


    display "Make binutils bfd-headers ... (log in $AVR_BUILD/step02_bin_make.log)"
    make all-bfd TARGET-bfd=headers &>$AVR_BUILD/step02.0_bin_make_bfd_headers.log
    rm -f bfd/Makefile
    make configure-host             &>$AVR_BUILD/step02.1_bin_configure.log
    check_return_code

    make all                        &>$AVR_BUILD/step02.2_bin_make_all.log
    check_return_code

    display "Install binutils ...   (log in $AVR_BUILD/step03_bin_install.log)"

    make install &>$AVR_BUILD/step03_bin_install.log
    check_return_code
fi

#---------------------------------------------------------------------------

if test "$build_gcc" = "yes" ; then
    #########################################################################
    header "Building gcc cross compiler for AVR"

    cd $AVR_BUILD

    if test "x$no_extract" = "xyes" ; then
        true
        # do nothing
    else
        unpack_package GCC

	if test "x$build_mpfr" = "xyes" ; then
	    unpack_package MPFR
	    mv $FILE_MPFR $FILE_GCC/mpfr
	else
	    GCC_OPS="$GCC_OPS --with-mpfr=$PREFIX"
	fi
	if test "x$build_mpc" = "xyes" ; then
	    unpack_package MPC
	    mv $FILE_MPC $FILE_GCC/mpc
	else
	    GCC_OPS="$GCC_OPS --with-mpc=$PREFIX"
	fi
	if test "x$build_gmp" = "xyes" ; then
	    unpack_package GMP
	    mv $FILE_GMP $FILE_GCC/gmp
	else
	    GCC_OPS="$GCC_OPS --with-gmp=$PREFIX"
	fi
    fi


    if test x$no_patch = "xyes" ; then
        true
        # do nothing
    else
        display "patching gcc"

        cd $AVR_BUILD/$FILE_GCC
        for p in $GCC_PATCHES; do
            display "   $p"
            if test -f $AVRADA_GCC_DIR/$p ; then
                PDIR=$AVRADA_GCC_DIR
            else
                display "cannot find $p in any of the patch directories"
                exit 2
            fi
            patch --verbose --strip=0 --input=$PDIR/$p  2>&1 >> $AVR_BUILD/build.log
            check_return_code
        done
    fi

    mkdir $AVR_BUILD/gcc-obj
    cd $AVR_BUILD/gcc-obj

    display "Configure GCC-AVR ... (log in $AVR_BUILD/step04_gcc_configure.log)"

    echo "AVR-Ada V$VER_AVRADA" > ../$FILE_GCC/gcc/PKGVERSION

    ../$FILE_GCC/configure --prefix=$PREFIX \
        --target=avr \
        --enable-languages=ada,c,c++ \
        --with-dwarf2 \
        --disable-nls \
        --disable-libssp \
        --disable-libada \
        --with-bugurl=http://avr-ada.sourceforge.net \
	--with-gmp=$WITHGMP \
	--with-mpfr=$WITHMPFR \
        &>$AVR_BUILD/step04_gcc_configure.log
    check_return_code

    display "Make GCC/GNAT ...     (log in $AVR_BUILD/step05_gcc_gcc_obj.log)"
    make &> $AVR_BUILD/step05_gcc_gcc_obj.log
    check_return_code

    display "Make GNAT Tools ...   (log in $AVR_BUILD/step06_gcc_tools_obj.log)"
    make -C gcc cross-gnattools ada.all.cross &> $AVR_BUILD/step06_gcc_gcc_obj.log
    check_return_code

    #display "Make RTS ...          (log in $AVR_BUILD/step06_gcc_rts_obj.log)"
    #make -C gcc gnatlib &> $AVR_BUILD/step06_gcc_rts_obj.log
    #check_return_code

    display "Install GCC ...       (log in $AVR_BUILD/step08_gcc_install.log)"

    cd $AVR_BUILD/gcc-obj
    make install &>$AVR_BUILD/step08_gcc_install.log
    check_return_code
fi

#---------------------------------------------------------------------------

if test "x$build_libc" = "xyes" ; then
    #########################################################################
    header "Building AVR libc"
    export CPATH=

    cd $AVR_BUILD

    display "Extracting $DOWNLOAD/$FILE_LIBC.tar.bz2 ..."
    bunzip2 -c $DOWNLOAD/$FILE_LIBC.tar.bz2 | tar xf -

    cd $AVR_BUILD/$FILE_LIBC

    display "configure AVR-LIBC ... (log in $AVR_BUILD/step09_libc_conf.log)"
    CC=avr-gcc ./configure --build=`./config.guess` --host=avr --prefix=$PREFIX &>$AVR_BUILD/step09_libc_conf.log
    check_return_code

    display "Make AVR-LIBC ...       (log in $AVR_BUILD/step10_libc_make.log)"
    make &>$AVR_BUILD/step10_libc_make.log
    check_return_code

    display "Install AVR-LIBC ...    (log in $AVR_BUILD/step11_libc_install.log)"
    make install &>$AVR_BUILD/step11_libc_install.log
    check_return_code
fi
print_time >> $AVR_BUILD/time_run.log

#---------------------------------------------------------------------------

if test "x$build_avrdude" = "xyes" ; then
    #########################################################################
    header "Building avrdude"

    cd $AVR_BUILD

    unpack_package AVRDUDE

    cd $AVR_BUILD/$FILE_AVRDUDE

    apply_patches AVRDUDE > $AVR_BUILD/step12_avrdude_patch.log)"
       
    display "configure avrdude ... (log in $AVR_BUILD/step12_avrdude_conf.log)"
    ./configure --prefix=$PREFIX &>$AVR_BUILD/step12_avrdude_conf.log
    check_return_code

    display "Make avrdude ...       (log in $AVR_BUILD/step13_avrdude_make.log)"
    make &>$AVR_BUILD/step13_avrdude_make.log
    check_return_code

    display "Install avrdude ...    (log in $AVR_BUILD/step14_avrdude_install.log)"
    make install &>$AVR_BUILD/step14_avrdude_install.log
    check_return_code
fi
print_time >> $AVR_BUILD/time_run.log

#---------------------------------------------------------------------------

if test "x$build_avradarts" = "xyes" ; then
    #########################################################################
    header "Building AVR-Ada RTS"

    cd $AVR_BUILD

    display "Extracting $DOWNLOAD/$FILE_AVRADA.tar.bz2 ..."
    bunzip2 -c $DOWNLOAD/$FILE_AVRADA.tar.bz2 | tar xf -

    cd $AVR_BUILD/$FILE_AVRADA

    display "configure AVR-Ada ... (log in $AVR_BUILD/step12_avrada_conf.log)"
    ./configure >& ../step12_avrada_conf.log
    check_return_code
    display "build AVR-Ada RTS ... (log in $AVR_BUILD/step13_avrada_rts.log)"
    make build_rts >& ../step13_avrada_rts.log
    check_return_code
    make install_rts >& ../step13_avrada_rts_inst.log
    check_return_code
fi

if test "x$build_avrada" = "xyes" ; then
    #########################################################################
    header "Building AVR-Ada libraries"

    cd $AVR_BUILD/$FILE_AVRADA

    display "build AVR-Ada libs ... (log in $AVR_BUILD/step14_avrada_libs.log)"
    make build_libs >& ../step14_avrada_libs.log
    check_return_code
    make install_libs >& ../step14_avrada_libs_inst.log
    check_return_code
fi

cd ..

#########################################################################
header  "Build end"

display
display "Build logs are located in $AVR_BUILD"
display "Programs are in the $PREFIX hierarchy"
display "You may remove $AVR_BUILD directory"

#---------------------------------------------------------------------------
# eof
#---------------------------------------------------------------------------
