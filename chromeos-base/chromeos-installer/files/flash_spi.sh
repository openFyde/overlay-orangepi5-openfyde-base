#!/bin/bash

LOADER_DIR=/usr/share/orangepi5

main() {
 local target="$1"
 local type="$2"
 local loader=""

 [ "$type" == "EMMC" ] && return 0

 if [ "$type" == "SATA" ]; then
    loader="${LOADER_DIR}/rkspi_loader_sata.img"
 else
    loader="${LOADER_DIR}/rkspi_loader.img"
 fi

 local target_md5="$(md5sum ${target} | awk '{print $1}')"
 local loader_md5="$(md5sum ${loader} | awk '{print $1}')"

 if [ "$target_md5" != "$loader_md5" ]; then
    echo "installing $loader to $target"
    dd if=$loader of=$target status=progress bs=1024 conv=fdatasync
    echo "done"
 fi
}

main "$@"
