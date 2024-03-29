#!/bin/bash
# Env variable for Android SDK.
# export ANDROID="$HOME/Library/Android/sdk"
# export ANDROID_HOME="$HOME/Library/Android/sdk"
# Env variable for Android NDK.
# export ANDROID_NDK="$HOME/Library/Android/sdk/ndk-bundle"
# export ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk-bundle"
# Env variable for Android cmake.
if [[ -z "${ANDROID_SDK}" ]]; then
  echo "need env: ANDROID_SDK"
  exit 1
fi
if [[ -z "${ANDROID_NDK}" ]]; then
  echo "need env: ANDROID_NDK"
  exit 1
fi

ANDROID_SDK_CMAKE="$ANDROID_SDK/cmake/3.6.4111459/bin/cmake"
ANDROID_NDK_TOOLCHAIN_CMAKE=$ANDROID_NDK/build/cmake/android.toolchain.cmake
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

echo "git submodule update --init --recursive"
git submodule update --init --recursive

if [[ $? -ne 0 ]]; then
    echo "git clone failed"
    exit 1
fi

ANDROID_ABI=x86
ANDROID_API_LEVEL=16

rm -rf build
mkdir build
cd build

echo "$ANDROID_SDK_CMAKE:"

$ANDROID_SDK_CMAKE \
    -Dprotobuf_BUILD_SHARED_LIBS=false \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_TOOLCHAIN_CMAKE \
    -DCMAKE_INSTALL_PREFIX=./protobuf \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_TOOLCHAIN=clang \
    -DANDROID_ABI=$ANDROID_ABI \
    -DANDROID_NATIVE_API_LEVEL=$ANDROID_API_LEVEL \
    -DANDROID_STL=c++_shared \
    -DANDROID_LINKER_FLAGS="-landroid -llog" \
    -DANDROID_CPP_FEATURES="rtti exceptions" \
    $SCRIPT_DIR/protobuf-v3.7.0/cmake

if [[ $? -ne 0 ]]; then
    echo "android_cmake config failed"
    exit 1
fi

echo "make build ..."
# $ANDROID_SDK_CMAKE --build .
make -j8

if [[ $? -ne 0 ]]; then
    echo "build failed"
    exit 1
fi

make install
