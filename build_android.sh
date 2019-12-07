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
SCRIPT_DIR=$(pwd)

PB_VERSION="v3.7.0"
rm -rf $SCRIPT_DIR/protobuf-$PB_VERSION
git clone -b $PB_VERSION --recurse-submodules -j8 https://github.com/protocolbuffers/protobuf.git $SCRIPT_DIR/protobuf-$PB_VERSION

if [[ $? -ne 0 ]]; then
    echo "failed 2222222222"
    exit 1
fi

rm -rf build
mkdir build
cd build

$ANDROID_SDK_CMAKE \
    -Dprotobuf_BUILD_SHARED_LIBS=true \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_TOOLCHAIN_CMAKE \
    -DCMAKE_INSTALL_PREFIX=./protobuf \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_TOOLCHAIN=clang \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_NATIVE_API_LEVEL=16 \
    -DANDROID_STL=c++_shared \
    -DANDROID_LINKER_FLAGS="-landroid -llog" \
    -DANDROID_CPP_FEATURES="rtti exceptions" \
    $SCRIPT_DIR/protobuf-$PB_VERSION/cmake

if [[ $? -ne 0 ]]; then
    echo "failed 2222222222"
    exit 1
fi

$ANDROID_SDK_CMAKE --build .

if [[ $? -ne 0 ]]; then
    echo "failed 33333333333"
    exit 1
fi

make install
