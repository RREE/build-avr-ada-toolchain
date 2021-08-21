#---------------------------------------------------------------------------
# build script
#---------------------------------------------------------------------------

export PATH=$PREFIX/bin:$PATH

echo "--------------------------------------------------------------"
echo "GCC AVR-Ada build script: all output is saved in log files"
echo "--------------------------------------------------------------"
echo

GCC_MIN_VERSION='4.7.0'
GCC_VERSION=`$CC -dumpversion`
# GCC_MAJOR=`echo $GCC_VERSION | awk -F. ' { print $1; } '`
# GCC_MINOR=`echo $GCC_VERSION | awk -F. ' { print $2; } '`
# GCC_PATCH=`echo $GCC_VERSION | awk -F. ' { print $3; } '`

printf -v versions '%s\n%s' "$GCC_VERSION" "$GCC_MIN_VERSION"
if [[ $versions = "$(sort -V <<< "$versions")" ]]; then
	echo "($GCC_VERSION) is too old"
	echo "AVR-Ada V2 requires at least gcc-8 as build compiler"
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

cd $AVR_BUILD

#---------------------------------------------------------------------------

if test "x$build_binutils" = "xyes" ; then

    header "Building Binutils"

    if test "x$no_extract" != "xyes" ; then
	unpack_package BINUTILS
    fi

    if test "x$no_patch" != "xyes" ; then
        cd $AVR_BUILD/$FILE_BINUTILS
        apply_patches BINUTILS > $AVR_BUILD/step10_bin_patch.log
    fi

    mkdir $AVR_BUILD/binutils-obj
    cd $AVR_BUILD/binutils-obj

    display "Configure binutils ... (log in $AVR_BUILD/step11_bin_configure.log)"

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
        --disable-shared \
        --disable-threads \
        --enable-cloog-backend=isl \
        --disable-cloog-version-check \
        --disable-isl-version-check \
        --disable-ppl-version-check \
        --with-gcc \
        --with-gnu-as \
        --with-gnu-ld \
        --enable-multilib \
        --enable-doc \
        --disable-werror \
        $BINUTILS_OPS \
        &>$AVR_BUILD/step11_bin_configure.log
    check_return_code


    display "Make binutils bfd-headers ... (log in $AVR_BUILD/step12_bin_make.log)"
    make all-bfd TARGET-bfd=headers &>$AVR_BUILD/step12_bin_make_bfd_headers.log
    rm -f bfd/Makefile
    make configure-host             &>$AVR_BUILD/step13_bin_configure.log
    check_return_code

    make all                        &>$AVR_BUILD/step14_bin_make_all.log
    check_return_code

    display "Install binutils ...   (log in $AVR_BUILD/step18_bin_install.log)"
    make install &>$AVR_BUILD/step18_bin_install.log
    check_return_code
fi

#---------------------------------------------------------------------------

if test "$build_gcc" = "yes" ; then

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
        cd $AVR_BUILD/$FILE_GCC
        apply_patches GCC        >& $AVR_BUILD/step20_gcc_patch.log
    fi

    mkdir $AVR_BUILD/gcc-obj
    cd $AVR_BUILD/gcc-obj

    display "Configure GCC-AVR ... (log in $AVR_BUILD/step21_gcc_configure.log)"

    echo "AVR-Ada V$VER_AVRADA" > ../$FILE_GCC/gcc/PKGVERSION

    ../$FILE_GCC/configure --prefix=$PREFIX \
        --target=avr \
        --enable-languages=ada,c,c++ \
        --with-avrlibc \
        --with-dwarf2 \
        --disable-nls \
        --disable-libssp \
        --disable-libada \
        --with-bugurl=http://avr-ada.sourceforge.net \
	--with-gmp=$WITHGMP \
	--with-mpfr=$WITHMPFR \
        &>$AVR_BUILD/step21_gcc_configure.log
    check_return_code

    display "Make GCC/GNAT ...     (log in $AVR_BUILD/step22_gcc_gcc_obj.log)"
    make &> $AVR_BUILD/step22_gcc_gcc_obj.log
    check_return_code

    display "Make GNAT Tools ...   (log in $AVR_BUILD/step23_gcc_tools_obj.log)"
    make -C gcc cross-gnattools ada.all.cross &> $AVR_BUILD/step23_gcc_gcc_obj.log
    check_return_code

    #display "Make RTS ...          (log in $AVR_BUILD/step24_gcc_rts_obj.log)"
    #make -C gcc gnatlib &> $AVR_BUILD/step24_gcc_rts_obj.log
    #check_return_code

    display "Install GCC ...       (log in $AVR_BUILD/step28_gcc_install.log)"

    cd $AVR_BUILD/gcc-obj
    make install &>$AVR_BUILD/step28_gcc_install.log
    check_return_code

    display "Adding GCC symlinks..."
    ln -sf $PREFIX/bin/avr-gcc $PREFIX/bin/avr-gnatgcc
    ln -sf $PREFIX/bin/avr-ar $PREFIX/bin/avr-elf-ar
fi

#---------------------------------------------------------------------------

if test "x$build_libc" = "xyes" ; then
    #########################################################################
    header "Building AVR libc"
    export CPATH=

    cd $AVR_BUILD

    unpack_package LIBC

    cd $AVR_BUILD/$FILE_LIBC

    apply_patches LIBC &> $AVR_BUILD/step30_libc_patch.log

    display "bootstrapping AVR-LIBC ... (log in $AVR_BUILD/step30_libc_bootstrap.log)"
    ./bootstrap &>$AVR_BUILD/step30_libc_bootstrap.log
    
    display "configure AVR-LIBC ... (log in $AVR_BUILD/step31_libc_conf.log)"
    CC=avr-gcc ./configure --build=`./config.guess` --host=avr --prefix=$PREFIX &>$AVR_BUILD/step31_libc_conf.log
    check_return_code

    display "Make AVR-LIBC ...       (log in $AVR_BUILD/step32_libc_make.log)"
    make &>$AVR_BUILD/step32_libc_make.log
    check_return_code

    display "Install AVR-LIBC ...    (log in $AVR_BUILD/step38_libc_install.log)"
    make install &>$AVR_BUILD/step38_libc_install.log
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

    apply_patches AVRDUDE &> $AVR_BUILD/step40_avrdude_patch.log
       
    display "configure avrdude ... (log in $AVR_BUILD/step41_avrdude_conf.log)"
    ./configure --prefix=$PREFIX &>$AVR_BUILD/step41_avrdude_conf.log
    check_return_code

    display "Make avrdude ...       (log in $AVR_BUILD/step42_avrdude_make.log)"
    make &>$AVR_BUILD/step42_avrdude_make.log
    check_return_code

    display "Install avrdude ...    (log in $AVR_BUILD/step48_avrdude_install.log)"
    make install &>$AVR_BUILD/step48_avrdude_install.log
    check_return_code
fi
print_time >> $AVR_BUILD/time_run.log

#---------------------------------------------------------------------------

if test "x$build_avradarts" = "xyes" ; then
    #########################################################################
    header "Building AVR-Ada RTS"

    AVRGCC_VERSION=`avr-gcc -dumpversion`
    AVRGCC_MAJOR=`echo $AVRGCC_VERSION | awk -F. ' { print $1; } '`
    FILE_AVRADARTS=avr-ada-rts-gcc-$AVRGCC_MAJOR
    # mkdir -p $AVR_BUILD/$FILE_AVRADARTS
    cp -a $AVRADA_RTS/gcc-$AVRGCC_MAJOR $AVR_BUILD/$FILE_AVRADARTS
    cd $AVR_BUILD/$FILE_AVRADARTS
    
    display "build AVR-Ada RTS ... (log in $AVR_BUILD/step62_avrada_rts_make.log)"
    make -d build_rts >& ../step62_avrada_rts_make.log
    check_return_code
    
    display "install AVR-Ada RTS ... (log in $AVR_BUILD/step68_avrada_rts_install.log)"
    make install_rts >& ../step68_avrada_rts_install.log
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
