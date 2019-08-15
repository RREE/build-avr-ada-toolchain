# -*- mode: shell-script -*-
#
# versions of the different source packages
#

VER_BINUTILS=2.32
VER_GCC=9.2.0
VER_MPFR=4.0.2
VER_MPC=1.1.0
VER_GMP=6.1.2
VER_LIBC=2.0.0
VER_AVRADA=1.2.3
VER_AVRDUDE=6.3

FILE_BINUTILS="binutils-$VER_BINUTILS"
FILE_GCC="gcc-$VER_GCC"
FILE_MPFR="mpfr-$VER_MPFR"
FILE_MPC="mpc-$VER_MPC"
FILE_GMP="gmp-$VER_GMP"
FILE_LIBC="avr-libc-$VER_LIBC"
FILE_AVRADA="avr-ada-$VER_AVRADA"
FILE_AVRDUDE="avrdude-$VER_AVRDUDE"

BINUTILS_TAR="binutils-$VER_BINUTILS.tar.bz2"
BINUTILS_X="j"
BINUTILS_MIRROR=ftp://sourceware.org/pub/binutils/releases

GCC_TAR="gcc-$VER_GCC.tar.xz"
GCC_X=J
GCC_MIRROR="ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$VER_GCC"

MPFR_TAR="mpfr-$VER_MPFR.tar.xz"
MPFR_X=J
MPFR_MIRROR="https://www.mpfr.org/mpfr-current"

MPC_TAR="mpc-$VER_MPC.tar.gz"
MPC_X=z
MPC_MIRROR="https://ftp.gnu.org/gnu/mpc"

GMP_TAR="gmp-$VER_GMP.tar.xz"
GMP_X=J
GMP_MIRROR="https://gmplib.org/download/gmp"

LIBC_TAR="avr-libc-$VER_LIBC.tar.bz2"
LIBC_X=j
LIBC_MIRROR="http://download.savannah.gnu.org/releases/avr-libc"

AVRDUDE_TAR="avrdude-$VER_AVRDUDE.tar.gz"
AVRDUDE_X=z
AVRDUDE_MIRROR="http://download.savannah.gnu.org/releases/avrdude"

AVRADA_TAR="avr-ada-$VER_AVRADA.tar.bz2"
AVRADA_X=j
AVRADA_MIRROR="https://sourceforge.net/projects/avr-ada/files/avr-ada/Source%20Dist/avr-ada-1.2.2.tar.bz2/download"
