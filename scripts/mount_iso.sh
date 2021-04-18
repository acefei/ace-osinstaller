#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOUNTDIR=${MOUNTDIR:-$SCRIPTDIR}
DISTRO_DIRS=()

teardown() {
    for d in ${DISTRO_DIRS[@]}
    do
        sudo umount $MOUNTDIR/$d 
        sudo rm -rf $MOUNTDIR/$d
    done
}
trap 'teardown' EXIT

start_server() {
    cd $SCRIPTDIR
    for iso in $(find $SCRIPTDIR -name '*.iso')
    do
        echo $iso | grep 'ipxe-' && continue

        distro=$(basename $iso)
        distro_dir=${distro%%.iso}
        mkdir -p $distro_dir
        DISTRO_DIRS+=("$distro_dir")
        sudo mount -o loop $iso $MOUNTDIR/$distro_dir
    done

    echo "HTTP Server IP is $(ip a s $(ip r | sed -n '/^default/s/.*\(dev [^ ]*\).*/\1/p') | sed -n '/inet/s/.*inet \([^\/]*\).*/\1/p')"
    cd $MOUNTDIR && sudo python3 -m http.server 80
}

start_server
