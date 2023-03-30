#!/bin/bash
#
shell_lines=131         # Adjust it if the script changes
version_string=r102-r1
targetdir=orangepi5-openfyde
TMPROOT=${TMPDIR:=./}
target=""
m2="nvme"
NVME_MAGIC='NVME'
SATA_MAGIC='SATA'
SECTOR_SIZE=512
# Write magic to the last sector of RESERVED partition of ChromiumOS
MAGIC_SECTOR=65598
self=$(realpath $0)
skip="false"
inplace="false"
src=""

usage()
{
    echo ""
    echo "$0 [options]"
    echo ""
    echo "options:"
    echo "  '--help/-h'"
    echo "      This message"
    echo "  '--src/-i [src]'"
    echo "      path of src image"
    echo "  '--target/-o [target]'"
    echo "      path of target image"
    echo "  '--skip/-s"
    echo "      src image is plain, skip uncompression"
    echo "  '--inplace/-p"
    echo "      do not copy src to target, modify it inplace"
    echo "  '--boot sata'"
    echo "      generates images supporting boot from SATA"
    echo "  '--boot nvme'"
    echo "      generates images supporting boot from NVME"
    exit 1;
}

err()
{
    echo "$@"
    exit 1
}

while [ "$1" ]; do
   case "$1" in
       "--help"|"-h")
           usage;
           ;;
       "--src"|"-i")
           if [ "$2" ]; then
               src="$2"
               shift;
           else
               err "ERROR: --src: no src specified."
           fi
           ;;
       "--target"|"-o")
           if [ "$2" ]; then
               target="$2"
               shift;
           else
               err "ERROR: --target: no target specified."
           fi
           ;;
       "--skip"|"-s")
           skip="true"
           ;;
       "--inplace"|"-p")
           inplace="true"
           ;;
       "--boot")
           if [ "$2" == "nvme" -o "$2" == "NVME" ]; then
               m2=nvme
               shift;
           elif [ "$2" == "sata" -o "$2" == "SATA" ]; then
               m2=sata
               shift;
           else
               err "--boot requires an argument"
           fi
           ;;
       *)
           usage
           ;;
    esac
    shift
done


cwd="$(pwd)"

if [ -z "$target" ] && [ "$inplace" != "true" ] && [ -z "$src" ]; then
   target="$(echo "$0" | sed s/.run/.img/g)"
   echo "$target" | grep -q '.img' || target="${target}.img"
fi

[ -f "$target" ] && err "$target already exists, please remove it first"
[ -d "$target" ] && berr "$target already exists, please remove it first"

command -v "unxz" > /dev/null 2>&1 || err "command unxz is not found"

if [ "$skip" == "false" ]; then
    cat $self | tail -n +${shell_lines} | unxz > $target

    if [ "$?" -ne 0 ]; then
        rm "$target"
        err "failed to unxz image"
    fi
else
    if [ "$inplace" == "false" ]; then
        cp $src $target || err "failed to cp $src $target"
    else
        target="$src"
    fi
fi


if [ "$m2" == "nvme" ]; then
    magic=$NVME_MAGIC
else
    magic=$SATA_MAGIC
fi

echo -n "$magic" | dd of="$target" bs=$SECTOR_SIZE seek="$MAGIC_SECTOR" conv=fdatasync,notrunc

exit 0
