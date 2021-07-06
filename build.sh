#!/bin/dash
# SPDX-License-Identifier: GPL-3.0-only
echo :: Compiling kernel...
tuxmake --directory linux --build-dir=cache/ --target-arch=arm -k $KBUILD_DEFCONFIG $TUXMAKE_EXTRA_OPTS

echo :: Exporting artefacts...
cd /home/runner/.cache/tuxmake/builds/1/
tar -cf linux-${BRANCH}.tar *
cd -
mv /home/runner/.cache/tuxmake/builds/1/linux-${BRANCH}.tar ./
