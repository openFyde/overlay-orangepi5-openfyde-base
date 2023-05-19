#!/bin/bash

m2=""
NVME_MAGIC='NVME'
SATA_MAGIC='SATA'
SECTOR_SIZE=512
# should be sam as write location
MAGIC_SECTOR=65598
rootdev=""

rootdev="$(findmnt -n -o source / | sed 's/p[0-9]//g')"
m2="$(dd if="$rootdev" bs=1 skip=33586176 count=4 2>/dev/null)"

mkdir /mnt/stateful_partition/fyde || true

if [ "$m2" == "SATA" ]; then
    echo 'overlays=rk3588-ssd-sata' >> /mnt/stateful_partition/fyde/Env.txt
    reboot
elif [ "$m2" == "EMMC" ]; then
    echo 'fdtfile=rk3588s-orangepi-5b.dtb' >> /mnt/stateful_partition/fyde/Env.txt
    reboot
fi
