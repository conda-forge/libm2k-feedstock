#!/usr/bin/env bash
set -ex

mkdir build
cd build

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_SBINDIR=bin
    -DENABLE_PYTHON=ON
    -DENABLE_CSHARP=OFF
    -DENABLE_TOOLS=ON
    -DBUILD_EXAMPLES=OFF
    -DENABLE_PACKAGING=OFF
    -DPython_EXECUTABLE=$PYTHON
    -DENABLE_DOC=OFF
    -DENABLE_LOG=OFF
    -DENABLE_EXCEPTIONS=ON
)

if [[ $target_platform == linux* ]] ; then
    cmake_config_args+=(
        -DINSTALL_UDEV_RULES=ON
        -DUDEV_RULES_PATH=$PREFIX/lib/udev/rules.d
    )
else
    cmake_config_args+=(
        -DINSTALL_UDEV_RULES=OFF
        -DOSX_PACKAGE=OFF
    )
fi

cmake ${CMAKE_ARGS} .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install

# manually rename libpyuhd to have the proper extension suffix when cross-compiling
if [[ $python_impl == "pypy" && $build_platform == linux-64 ]] ; then
    if [[ $target_platform == linux-ppc64le || $target_platform == linux-aarch64 ]] ; then
        pushd $SP_DIR
        LIBM2K_PY_ORIGNAME=`basename _libm2k*.so`
        LIBM2K_PY_NAME=${LIBM2K_PY_ORIGNAME/x86_64-linux-gnu/linux-gnu}
        mv $LIBM2K_PY_ORIGNAME $LIBM2K_PY_NAME
    fi
fi
