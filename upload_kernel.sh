#!/bin/dash
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
BOOTSIZE="64000000" # 10M, always set it bigger than it was before, but has to fit into your boot partition

echo ":: Working with branch $BRANCH"

#echo :: NOT DOWNLOADING NEW KERNEL!!!
curl -L -O "https://github.com/${GITHUB_REPO}/releases/download/${BRANCH}/${FILENAME}.tar"

rm linux -rf
mkdir linux
cp $FILENAME.tar linux/
cd linux
tar xf $FILENAME.tar

tar xfJ dtbs.tar.xz

cat zImage dtbs/${DTB_NAME} > zImage-dtbs || exit

sudo abootimg \
	-u ${WORKDIR}/chroot_rootfs_${DEVICE}/boot/boot.img-postmarketos-${KERNEL} \
	-k zImage-dtbs \
	-c "bootsize=$BOOTSIZE" || exit
fastboot --cmdline "${CMDLINE}" boot ${WORKDIR}/chroot_rootfs_${DEVICE}/boot/boot.img-postmarketos-${KERNEL} || exit

echo ":: Waiting for device getting online..."
i=0
while ! ping -q -n -c 1 172.16.42.1 > /dev/null
do
	sleep 1
	i=`expr $i + 1`
done

echo ":: Device is online after $i seconds from fastboot!"
