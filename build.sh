#!/bin/sh

# Usage: build.sh sdXX

###
# Need to add a bit to unmask packages
###

DISK=$1
STAGE3_DATE="20130822"
ARCH="amd64"
FILELOC=`pwd`
MOUNTPOINT="/mnt/gentoo"

MSGPREFIX=" !!!"


if [ "$1" == '' ]; then
    echo "Specify disk"
    exit 0;
fi
if [ -e $DISK ]
    echo "Block device $DISK does not exist"
    exit
fi

echo "$MSGPREFIX Creating filesystem"
mkfs.ext4 -q $DISK

echo "$MSGPREFIX Mounting filesystem"
mount $DISK ${MOUNTPOINT}
cd ${MOUNTPOINT}

echo "$MSGPREFIX Fetching stage3"
wget http://distfiles.gentoo.org/releases/${ARCH}/current-stage3/stage3-${ARCH}-${STAGE3_DATE}.tar.bz2

echo "$MSGPREFIX Unpacking stage3"
tar -xf stage3*

echo "$MSGPREFIX Mounting system directories"
cd /
mount -t proc proc ${MOUNTPOINT}/proc
mount --rbind /dev ${MOUNTPOINT}/dev
mount --rbind /sys ${MOUNTPOINT}/sys
cp -L /etc/resolv.conf ${MOUNTPOINT}/etc/

echo "$MSGPREFIX Installing stage 2"
printf "DISK=${DISK}\n\n" > ${MOUNTPOINT}/build_stage2.sh
cat ${FILELOC}/build_stage2.sh >> ${MOUNTPOINT}/build_stage2.sh
chmod +x ${MOUNTPOINT}/build_stage2.sh

echo "$MSGPREFIX Creating another make.conf and patching"
cp ${MOUNTPOINT}/etc/portage/make.conf ${MOUNTPOINT}/etc/portage/make2.conf
cat $FILELOC/make >> ${MOUNTPOINT}/etc/portage/make2.conf

echo "$MSGPREFIX Chrooting"
echo "$MSGPREFIX Stage 1 complete. Please run build_stage2.sh to continue"
chroot ${MOUNTPOINT} /bin/bash
