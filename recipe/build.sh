#!/bin/bash

set -e # Abort on error.

# Get rid of any `.la` from defaults.
find $PREFIX/lib -name '*.la' -delete

# Force python bindings to not be built.
unset PYTHON

if [ $(uname) != Darwin ]; then
  export CFLAGS="-O2 -Wl,-S $CFLAGS"
  export CXXFLAGS="-O2 -Wl,-S $CXXFLAGS"
fi
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

# Filter out -std=.* from CXXFLAGS as it disrupts checks for C++ language levels.
re='(.*[[:space:]])\-std\=[^[:space:]]*(.*)'
if [[ "${CXXFLAGS}" =~ $re ]]; then
    export CXXFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

# `--without-pam` was removed.
# See https://github.com/conda-forge/gdal-feedstock/pull/47 for the discussion.

./configure --prefix=$PREFIX \
            --host=$HOST \
            --with-curl \
            --with-dods-root=$PREFIX \
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
            --with-liblzma=yes \
            --with-netcdf=$PREFIX \
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
            --verbose \
            $OPTS

make -j $CPU_COUNT ${VERBOSE_AT}

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

# We can remove this when we start using the new conda-build.
find $PREFIX -name '*.la' -delete
