FFMPEG_EXT_PATH=$1
NDK_PATH=$2
HOST_PLATFORM=$3
EXPORT_LIBS_PATH=$4
ENABLED_DECODERS=("${@:5}")
COMMON_OPTIONS="
    --target-os=android
    --enable-static
    --disable-shared
    --disable-doc
    --disable-programs
    --disable-everything
    --disable-avdevice
    --disable-postproc
    --disable-avfilter
    --disable-symver
    --disable-debug
    --disable-avx
    --enable-version3
    --enable-pic
    --enable-asm
    --enable-inline-asm
    --enable-avresample
    --enable-swresample
    --enable-avformat
    --enable-swscale
    --enable-pthreads
    --enable-runtime-cpudetect
    --enable-hwaccels
    --enable-libwebp
    --enable-libvpx
    --enable-encoder=webp
    --enable-encoder=vp8
    --enable-encoder=vp9
    --enable-muxer=webp
    --enable-demuxer=gif
    --enable-demuxer=mov
    --enable-demuxer=webp
    --enable-demuxer=apng
    --enable-decoder=alac
    --enable-decoder=gif
    --enable-decoder=apng
    --enable-decoder=mpeg4
    --enable-decoder=h264
    --enable-protocol=file
    --extra-ldexeflags=-pie
    "
TOOLCHAIN_PREFIX="${NDK_PATH}/toolchains/llvm/prebuilt/${HOST_PLATFORM}/bin"
for decoder in "${ENABLED_DECODERS[@]}"
do
    COMMON_OPTIONS="${COMMON_OPTIONS} --enable-decoder=${decoder}"
done
cd "${FFMPEG_EXT_PATH}"
(git -C ffmpeg pull || git clone git://source.ffmpeg.org/ffmpeg ffmpeg)
cd ffmpeg
git checkout release/4.2
./configure \
    --libdir="$EXPORT_LIBS_PATH"/armv7-a \
    --arch=arm \
    --cpu=armv7-a \
    --ar="${TOOLCHAIN_PREFIX}/arm-linux-androideabi-ar" \
    --ranlib="${TOOLCHAIN_PREFIX}/arm-linux-androideabi-ranlib" \
    --cross-prefix="${TOOLCHAIN_PREFIX}/armv7a-linux-androideabi16-" \
    --nm="${TOOLCHAIN_PREFIX}/arm-linux-androideabi-nm" \
    --strip="${TOOLCHAIN_PREFIX}/arm-linux-androideabi-strip" \
    --extra-cflags="-Wl,-Bsymbolic -Os -DCONFIG_LINUX_PERF=0 -DANDROID -march=armv7-a -mfloat-abi=softfp -fPIE -pie --static -fPIC" \
    --extra-ldflags="-Wl,--fix-cortex-a8 -Wl,-Bsymbolic -Wl,-rpath-link=${NDK_PATH}/platforms/android-16/arch-arm/usr/lib -L${NDK_PATH}/platforms/android-16/arch-arm/usr/lib -nostdlib -lc -lm -ldl -fPIC" \
    ${COMMON_OPTIONS}
make -j8
make install-libs
make clean
./configure \
    --libdir="${EXPORT_LIBS_PATH}/arm64" \
    --arch=aarch64 \
    --cpu=armv8-a \
    --ar="${TOOLCHAIN_PREFIX}/aarch64-linux-android-ar" \
    --ranlib="${TOOLCHAIN_PREFIX}/aarch64-linux-android-ranlib" \
    --cross-prefix="${TOOLCHAIN_PREFIX}/aarch64-linux-android21-" \
    --nm="${TOOLCHAIN_PREFIX}/aarch64-linux-android-nm" \
    --strip="${TOOLCHAIN_PREFIX}/aarch64-linux-android-strip" \
    --extra-cflags="-Wl,-Bsymbolic -Os -DCONFIG_LINUX_PERF=0 -DANDROID -fPIE -pie --static -fPIC" \
    --extra-ldflags="-Wl,-rpath-link=${NDK_PATH}/platforms/android-21/arch-arm64 -L${NDK_PATH}/platforms/android-21/arch-arm64/usr/lib -nostdlib -lc -lm -ldl -fPIC" \
    ${COMMON_OPTIONS}
make -j8
make install-libs
make clean
./configure \
    --libdir="${EXPORT_LIBS_PATH}/i686" \
    --arch=x86 \
    --cpu=i686 \
    --ar="${TOOLCHAIN_PREFIX}/i686-linux-android-ar" \
    --ranlib="${TOOLCHAIN_PREFIX}/i686-linux-android-ranlib" \
    --cross-prefix="${TOOLCHAIN_PREFIX}/i686-linux-android16-" \
    --nm="${TOOLCHAIN_PREFIX}/i686-linux-android-nm" \
    --strip="${TOOLCHAIN_PREFIX}/i686-linux-android-strip" \
    --extra-cflags="-Wl,-Bsymbolic -Os -DCONFIG_LINUX_PERF=0 -DANDROID -march=1686 -fPIE -pie --static -fPIC" \
    --extra-ldflags="-Wl,-Bsymbolic -Wl,-rpath-link=${NDK_PATH}/platforms/android-16/arch-x86 -L${NDK_PATH}/platforms/android-16/arch-x86/usr/lib -nostdlib -lc -lm -ldl -fPIC" \
    ${COMMON_OPTIONS} \
    --disable-asm --disable-mmx --disable-inline-asm
make -j8
make install-libs
make clean
./configure \
    --libdir="$EXPORT_LIBS_PATH"/x86_64 \
    --arch=x86_64 \
    --cpu=x86_64 \
    --ar="${TOOLCHAIN_PREFIX}/x86_64-linux-android-ar" \
    --ranlib="${TOOLCHAIN_PREFIX}/x86_64-linux-android-ranlib" \
    --cross-prefix="${TOOLCHAIN_PREFIX}/x86_64-linux-android21-" \
    --nm="${TOOLCHAIN_PREFIX}/x86_64-linux-android-nm" \
    --strip="${TOOLCHAIN_PREFIX}/x86_64-linux-android-strip" \
      --extra-cflags="-Wl,-Bsymbolic -Os -DCONFIG_LINUX_PERF=0 -DANDROID -fPIE -pie --static -fPIC" \
    --extra-ldflags="-Wl,-Bsymbolic -Wl,-rpath-link=${NDK_PATH}/platforms/android-21/arch-x86_64 -L${NDK_PATH}/platforms/android-21/arch-x86_64/usr/lib -nostdlib -lc -lm -ldl -fPIC" \
    --x86asmexe="${TOOLCHAIN_PREFIX}/yasm" \
    ${COMMON_OPTIONS} \
    --disable-asm --disable-mmx --disable-inline-asm
make -j8
make install-libs
make clean
