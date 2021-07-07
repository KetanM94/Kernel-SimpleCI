#!/bin/dash
# SPDX-License-Identifier: GPL-3.0-only
echo :: Running tests...
cd linux
make defconfig
status=0
echo :: Building dtb
make -j3 dtbs || status=1
echo :: Running dt_binding_check
make -j3 dtbs_check || status=1

exit $status

