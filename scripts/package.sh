#!/bin/bash
# Automated package script for Android on BUG20.  This is a subset of build.sh

# Check depencencies
# install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev ia32-libs x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev
set -e
CMD=git
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=pg
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=flex
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=bison
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=gperf
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=gcc
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=gzip
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=curl
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }
CMD=repo
which $CMD &> /dev/null || { echo "Please install $CMD and re-run the script."; exit 1; }

# Variables to set
# 

if [ -z $BUG20_OUT_PATH ]; then
	BUG20_OUT_PATH=out/target/product/bug20/
fi

if [ -z $BUILD_BRANCH ]; then
	BUILD_BRANCH=froyo
fi

if [ -z $WORKSPACE ]; then
	WORKSPACE=`pwd`
fi

if [ -z $DIST_DIR ]; then
	DIST_DIR=$WORKSPACE/dist
fi

if [ -z $BUILD_TAG ]; then
	BUILD_TAG="`uname -n`-`date +'%m%d%y%H%M%S'`"	
fi

echo "################################"
echo "# BUILD_BRANCH: $BUILD_BRANCH"
echo "# WORKSPACE:    $WORKSPACE"
echo "# DIST_DIR:     $DIST_DIR"
echo "# BUILD_TAG:    $BUILD_TAG"
echo "################################"

# Create dir for compressed installation image
if [ ! -d $DIST_DIR/tmp ]; then
  mkdir -p $DIST_DIR/tmp
fi

# Create tarball of runnable image.
cp $BUG20_OUT_PATH/kernel $DIST_DIR/tmp/uImage
cd $BUG20_OUT_PATH/root
tar cfps $DIST_DIR/tmp/rootfs.tar ./*
cd ..
tar rfps $DIST_DIR/tmp/rootfs.tar system 
tar rfps $DIST_DIR/tmp/rootfs.tar data
cd $DIST_DIR/tmp
tar cfz $DIST_DIR/dist-$BUILD_TAG.tar.gz *
cd ..
if [ -h $DIST_DIR/current ]; then
  rm $DIST_DIR/current
fi
ln -s $DIST_DIR/dist-$BUILD_TAG.tar.gz $DIST_DIR/current
echo "Packaged distributable: $DIST_DIR/dist-$BUILD_TAG.tar.gz"
# Cleanup
cd $WORKSPACE
rm -Rf $DIST_DIR/tmp 
