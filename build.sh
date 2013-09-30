#!/bin/sh

# Usage: build.sh sdXX

###
# Need to add a bit to unmask packages
###

DISK=$1
STAGE3_DATE="20130822"
ARCH="amd64"
FILELOC=`pwd`


if ["$1" == '']; then
    echo "Specify disk"
    exit 0;
fi

echo "!!! Creating filesystem"
mkfs.ext3 -q /dev/$DISK

echo "!!! Mounting filesystem"
mount /dev/$DISK /mnt/gentoo
cd /mnt/gentoo

echo "!!! Fetching stage3"
wget http://distfiles.gentoo.org/releases/${ARCH}/current-stage3/stage3-${ARCH}-${STAGE3_DATE}.tar.bz2

echo "!!! Unpacking stage3"
tar -xf stage3*

echo "!!! Mounting system directories"
cd /
mount -t proc proc /mnt/gentoo/proc
mount --rbind /dev /mnt/gentoo/dev
mount --rbind /sys /mnt/gentoo/sys
cp -L /etc/resolv.conf /mnt/gentoo/etc/

echo "!!! Installing stage 2"
printf "DISK=${DISK}\n\n" > /mnt/gentoo/build_stage2.sh
cat ${FILELOC}/build_stage2.sh >> /mnt/gentoo/build_stage2.sh
chmod +x /mnt/gentoo/build_stage2.sh

echo "!!! Creating another make.conf and patching"
cp /mnt/gentoo/etc/portage/make.conf /mnt/gentoo/etc/portage/make2.conf
cat $FILELOC/make >> /mnt/gentoo/etc/portage/make2.conf

echo "!!! Chrooting"
echo "!!! Stage 1 complete. Please run build_stage2.sh to continue"
chroot /mnt/gentoo /bin/bash
