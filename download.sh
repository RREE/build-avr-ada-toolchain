#!/bin/bash

source base.sh

#actions
download_files="yes"
delete_obj_dirs="no"
delete_build_dir="yes"
delete_install_dir="no"   # Be carefull, will remove *all* software installed in $PREFIX!!!

source actions.sh
