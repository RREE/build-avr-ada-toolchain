# -*- mode: shell-script -*-

#---------------------------------------------------------------------------
# utility functions
#---------------------------------------------------------------------------

# print date/time in ISO format
function print_time () {
    date +"%Y-%m-%d_%H:%M:%S"
}

function display_noeol () {
    printf "$@"
    printf "$@" >> $AVR_BUILD/build.log
}

function display () {
    echo "$@"
    echo "$@" >> $AVR_BUILD/build.log
}

function log () {
    echo "$@" >> $AVR_BUILD/build.log
}

function header () {
    display
    display       "--------------------------------------------------------------"
    display_noeol `print_time`
    display "  $@"
    display       "--------------------------------------------------------------"
    display
}

function check_return_code () {
    if [ $? != 0 ]; then
        echo
        echo " **** The last command failed :("
        echo "Please check the generated log files for errors and warnings."
        echo "Exiting.."
        exit 2
    fi
}

function unpack_package ()
{
    local PKG="$1_TAR"
    local X="$1_X"
    
    echo "  >> Unpacking ${!PKG}..."
        
    tar -x${!X}pf $DOWNLOAD/${!PKG}

    check_return_code
}

function apply_patches ()
{
    local PKG="$1"
    local VER="VER_$1"
    local V=${!VER}
    local PATCH_DIR="$PATCHES/${PKG,,}/$V"

    if [ -d $PATCH_DIR ]; then
	echo "  >> Patching $PKG..."
	SERIES=`(cd $PATCH_DIR; ls -1 *.patch)`
	local STRIP=`cat $PATCH_DIR/strip`

	for p in $SERIES; do
 	    display "   $p"
	    patch --verbose --strip=$STRIP --input=$PATCH_DIR/$p
	    check_return_code
	done
    fi
}
