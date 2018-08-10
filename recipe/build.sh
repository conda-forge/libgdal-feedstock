#!/bin/bash

set -e # Abort on error.

# Get rid of any `.la` from defaults.
rm -rf $PREFIX/lib/*.la

# Force python bindings to not be built.
unset PYTHON

export CFLAGS="-O2 -Wl,-S $CFLAGS"
export CXXFLAGS="-O2 -Wl,-S $CXXFLAGS"

if [ $(uname) == Darwin ]; then
    COMP_CC=clang
    COMP_CXX=clang++
else
    # OPTS="--disable-rpath"
    COMP_CC=gcc
    COMP_CXX=g++
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

# `--without-pam` was removed.
# See https://github.com/conda-forge/gdal-feedstock/pull/47 for the discussion.

# drop dods (libdap4) until we can build it with the new syntax:
#  https://github.com/conda-forge/libdap4-feedstock/pull/23
# --with-dods-root=$PREFIX \
./configure CC=$COMP_CC \
            CXX=$COMP_CXX \
            --prefix=$PREFIX \
            --with-curl \
            --with-expat=$PREFIX \
            --with-freexl=$PREFIX \
            --with-geos=$PREFIX/bin/geos-config \
            --with-hdf4=$PREFIX \
            --with-hdf5=$PREFIX \
            --with-jpeg=$PREFIX \
            --with-kea=$PREFIX/bin/kea-config \
            --with-libjson-c=$PREFIX \
            --with-libz=$PREFIX \
            --with-libkml=$PREFIX \
            --with-libtiff=$PREFIX \
            --with-geotiff=$PREFIX \
            --with-liblzma=yes \
            --with-netcdf=$PREFIX \
            --with-libiconv-prefix=$PREFIX \
            --with-openjpeg=$PREFIX \
            --with-poppler=$PREFIX \
            --with-pcre \
            --with-pg=$PREFIX/bin/pg_config \
            --with-png=$PREFIX \
            --with-spatialite=$PREFIX \
            --with-sqlite3=$PREFIX \
            --with-static-proj4=$PREFIX \
            --with-xerces=$PREFIX \
            --with-xml2=$PREFIX \
            --without-python \
            $OPTS

make -j $CPU_COUNT
make install

# Make sure GDAL_DATA and set and still present in the package.
# https://github.com/conda/conda-recipes/pull/267
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/gdal-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/gdal-deactivate.sh
