#!/bin/bash

setup_path=$(mktemp -dt "$(basename "$0").XXXXXXXXXX")

cd $setup_path
initrd_path=$1
if [ -z "$initrd_path" ];then
    echo "Usage: $0 <initrd path>"
    exit 1
fi

if echo $initrd_path | grep -qE '^(http|ftp)' ; then
    wget $initrd_path
    initrd_path=$(ls initrd.*)
fi

if [ -e "$initrd_path" ];then
    echo "Invalid path: $initrd_path"    
    exit 1
fi

filetype=$(file $initrd_path | grep -Po ".*: \K\w+ \w+")
case $filetype in
    "LZMA compressed")
        xz -dc < $initrd_path | cpio -idmv        
        ;;
    "gzip compressed")
        zcat $initrd_path | cpio -idmv
        ;;
    *)
        echo "Invalid filetype: $filetype"
        exit 1
        ;;
esac

echo "---> You can inspect initrd in $setup_path"
