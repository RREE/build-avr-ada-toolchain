#!/bin/bash
#
# download the necessary source files
#

source bin/config.inc
source bin/versions.inc
source bin/utilities.inc

function download_package()
{
    local PKG="$1_TAR"
    local PKG_MIRROR="$1_MIRROR"
    
    if [ ! -f $DOWNLOAD/${!PKG} ]; then
        display "  >> Downloading ${!PKG}..."
        wget --continue --directory-prefix=$DOWNLOAD ${!PKG_MIRROR}/${!PKG}

        check_return_code
    else
        display "  (x) Already have ${!PKG}"
    fi
}


header "downloading archives"

download_package "BINUTILS"
download_package "GCC"
download_package "GMP"
download_package "MPC"
download_package "MPFR"
download_package "LIBC"
download_package "AVRDUDE"
download_package "AVRADA"
