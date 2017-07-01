#!/bin/bash
# Source: https://gist.githubusercontent.com/myhau/91065e18110ef9f5b780b9c9b6bb4ea5/raw/59602c48d90c89d53bd5abeb2cfd7552c18b5bf8/install_mosh_locally.sh
# this script does absolutely ZERO error checking.   however, it worked
# for me on a RHEL 6.3 machine on 2012-08-08.  clearly, the version numbers
# and/or URLs should be made variables.  cheers,  zmil...@cs.wisc.edu

# exit on error
set -e

MOSH_VERSION=1.3.0
PROTOBUF_VERSION=3.3.0
mkdir mosh
cd mosh

ROOT=`pwd`

echo "==================================="
echo "about to set up everything in $ROOT"
echo "==================================="

mkdir build
mkdir install

cd build
wget -L -O https://github.com/google/protobuf/releases/download/v3.3.0/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz
wget -L -O https://mosh.mit.edu/mosh-${MOSH_VERSION}.tar.gz
wget -L -O ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz


echo "================="
echo "building protobuf"
echo "================="

tar zxvf protobuf-cpp-${PROTOBUF_VERSION}.tar.gz
export CXXFLAGS="$CXXFLAGS -fPIC"
cd $ROOT/build/protobuf-${PROTOBUF_VERSION}
./configure --prefix=$HOME/local --disable-shared
make install
cd ..

echo "================="
echo "building ncurses"
echo "================="

tar xvzf ncurses-6.0.tar.gz
cd $ROOT/build/ncurses-6.0
./configure --prefix=$HOME/local CPPFLAGS="-P"
make
make install
cd ..


echo "============="
echo "building mosh"
echo "============="

tar zxvf mosh-${MOSH_VERSION}.tar.gz
cd $ROOT/build/mosh-${MOSH_VERSION}
export PROTOC=$HOME/local/bin/protoc
export protobuf_CFLAGS=-I$HOME/local/include
export protobuf_LIBS=$HOME/local/lib/libprotobuf.so

./configure --prefix=$HOME/local CFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-L$HOME/local/lib -L$HOME/local/include/ncurses -L$HOME/local/include"
CPPFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-static -L$HOME/local/include -L$HOME/local/include/ncurses -L$HOME/local/lib" make install
cd $ROOT
cd ..

echo "==="
echo "if all was successful, binaries are now in $ROOT/install/mosh/bin"
echo "==="
