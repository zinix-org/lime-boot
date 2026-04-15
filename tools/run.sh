#!/usr/bin/env bash

BUILD_DIR=${BUILD_DIR:-build}

function error {
    echo -e "\x1b[1;31merror\x1b[0m: $1"
}

if [[ "$#" != "1" ]]; then
    error "wrong parameters"
fi

case $1 in
    floppy-bootsector)
        qemu-system-i386 -cpu 486,fpu=off -fda $BUILD_DIR/floppy/stage1.bin
        ;;
    
    *)
        error "unkown target"
        ;;
esac
