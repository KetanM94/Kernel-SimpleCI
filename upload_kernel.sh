#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# This script serves for purpose downloading kernel from CI and booting it on the device using fastboot

if [ -z $1 ]; then
	echo Missing branch parameter!
	exit
fi

BRANCH=$1

GITHUB_REPO="KetanM94/Kernel-SimpleCI" # customize for your set up repository name
WORKDIR=`grep work ~/.config/pmbootstrap.cfg | cut -d" " -f3`

# Setup for your device from deviceinfo & rest of pmaports information
DEVICE="xiaomi-ferrari"
KERNEL="mainline-ferrari"
DTB_NAME=""
FILENAME="linux-$BRANCH"
CMDLINE="console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive buildvariant=eng"
BOOTSIZE="32000000" # 10M, always set it bigger than it was before, but has to fit into your boot partition

echo ":: Working with branch $BRANCH"

echo ":: NOw DOWNLOADING NEW KERNEL!!!"
curl -L -O "https://github.com/${GITHUB_REPO}/releases/download/${BRANCH}/${FILENAME}.tar"

rm linux -rf
mkdir linux
cp $FILENAME.tar linux/
cd linux
tar xf $FILENAME.tar

gunzip Image.gz
tar xfJ dtbs.tar.xz

pmbootstrap export
pmbootstrap chroot -- apk add abootimg android-tools mkbootimg dtbtool

export DEVICE="$(pmbootstrap config device)"
export WORK="$(pmbootstrap config work)"
export TEMP="$WORK/chroot_native/tmp/mainline/"
mkdir -p "$TEMP"
cp Image  "$TEMP"/zImage

pmbootstrap chroot -- mkbootimg-osm0sis \
    --kernel "/tmp/mainline/zImage" \
    --ramdisk "/tmp/mainline/initramfs" \
    --dt "/tmp/mainline/dt.img" \
    --base "0x80000000" \
    --second_offset "0x00f00000" \
    --cmdline "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive buildvariant=eng" \
    --kernel_offset "0x00008000" \
    --ramdisk_offset "0x01000000" \
    --tags_offset "0x00000100" \
    --pagesize "2048" \
    -o "/tmp/mainline/boot.img"
fastboot --cmdline "${CMDLINE}" boot ${WORKDIR}/chroot_native//tmp/mainline/boot.img || exit

echo ":: Waiting for device getting online..."
i=0
while ! ping -q -n -c 1 172.16.42.1 > /dev/null
do
	sleep 1
	i=`expr $i + 1`
done

echo ":: Device is online after $i seconds from fastboot!"
