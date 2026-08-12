FROM ghcr.io/containerpak/mesa-sdk:main AS build

ARG SCUMMVM_COMMIT=fed42f2068dcafc6aafa1c28c77e4c88def74b66

RUN apt update && \
    apt install -y --no-install-recommends git libasound2-dev libcurl4-openssl-dev libfluidsynth-dev libflac-dev libfreetype-dev libjpeg-dev libpng-dev libsdl2-dev libtheora-dev libvorbis-dev && \
    git clone --depth 1 --branch v2026.3.0 https://github.com/scummvm/scummvm.git /src/scummvm && \
    cd /src/scummvm && \
    git checkout "$SCUMMVM_COMMIT" && \
    test "$(git rev-parse HEAD)" = "$SCUMMVM_COMMIT" && \
    ./configure --prefix=/usr --enable-release && \
    make -j"$(nproc)" && \
    DESTDIR=/staging make install

FROM ghcr.io/containerpak/mesa:main

COPY --from=build /staging/usr/ /usr/

RUN apt update && \
    apt install -y --no-install-recommends libasound2t64 libcurl4t64 libfluidsynth3 libflac14 libfreetype6 libjpeg-turbo8 libpng16-16 libsdl2-2.0-0 libtheora0 libvorbis0a && \
    cpak-clean-junk
