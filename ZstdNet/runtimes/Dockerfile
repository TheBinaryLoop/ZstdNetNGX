# syntax=docker/dockerfile:1.9

#############################
# Shared: fetch zstd sources
#############################
FROM alpine:3.20 AS src
ARG ZSTD_VERSION=1.5.7
WORKDIR /work
RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache curl tar ca-certificates \
 && curl -fsSL "https://github.com/facebook/zstd/archive/refs/tags/v${ZSTD_VERSION}.tar.gz" -o zstd.tgz \
 && tar -xzf zstd.tgz \
 && mv "zstd-${ZSTD_VERSION}" /src


#############################
# musl targets (native builds)
#############################

# linux-musl-x64
FROM --platform=linux/amd64 alpine:3.20 AS linux-musl-x64
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/src/lib/.objs \
    apk add --no-cache build-base \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/

# linux-musl-x86
FROM --platform=linux/386 alpine:3.20 AS linux-musl-x86
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/src/lib/.objs \
    apk add --no-cache build-base \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/

# linux-musl-arm64
FROM --platform=linux/arm64 alpine:3.20 AS linux-musl-arm64
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/src/lib/.objs \
    apk add --no-cache build-base \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/

# linux-musl-arm (armv7, hard-float)
FROM --platform=linux/arm/v7 alpine:3.20 AS linux-musl-arm
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/src/lib/.objs \
    apk add --no-cache build-base \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -mfloat-abi=hard -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -mfloat-abi=hard -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/


#############################
# glibc builds (Debian)
#############################

# linux-glibc-x64
FROM --platform=linux/amd64 debian:bookworm-slim AS linux-glibc-x64
ARG TARGETPLATFORM=linux-amd64
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/var/cache/apt,id=apt-${TARGETPLATFORM},sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists-${TARGETPLATFORM},sharing=locked \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential make \
 && rm -rf /var/lib/apt/lists/* \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/

# linux-glibc-x86 (i386)
FROM --platform=linux/386 i386/debian:bookworm-slim AS linux-glibc-x86
ARG TARGETPLATFORM=linux-386
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/var/cache/apt,id=apt-${TARGETPLATFORM},sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists-${TARGETPLATFORM},sharing=locked \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential make \
 && rm -rf /var/lib/apt/lists/* \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/

# linux-glibc-arm64
FROM --platform=linux/arm64 arm64v8/debian:bookworm-slim AS linux-glibc-arm64
ARG TARGETPLATFORM=linux-arm64
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/var/cache/apt,id=apt-${TARGETPLATFORM},sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists-${TARGETPLATFORM},sharing=locked \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential make \
 && rm -rf /var/lib/apt/lists/* \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/

# linux-glibc-arm (armv7, hard-float)
FROM --platform=linux/arm/v7 arm32v7/debian:bookworm-slim AS linux-glibc-arm
ARG TARGETPLATFORM=linux-armv7
ARG MAKE_TARGET=libzstd-mt
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/var/cache/apt,id=apt-${TARGETPLATFORM},sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists-${TARGETPLATFORM},sharing=locked \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential make \
 && rm -rf /var/lib/apt/lists/* \
 && make -C /src/lib clean || true \
 && CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -mfloat-abi=hard -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -mfloat-abi=hard -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" ${MAKE_TARGET} \
 && mkdir -p /app \
 && strip --strip-unneeded /src/lib/libzstd.so \
 && cp -L /src/lib/libzstd.so /app/


#############################
# Windows (MinGW-w64)
#############################

# win-x64
FROM debian:bookworm-slim AS win-x64
ARG TARGETPLATFORM=windows-amd64
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/var/cache/apt,id=apt-${TARGETPLATFORM},sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists-${TARGETPLATFORM},sharing=locked \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends make mingw-w64 \
 && rm -rf /var/lib/apt/lists/* \
 && make -C /src/lib clean CC="x86_64-w64-mingw32-gcc" CXX="x86_64-w64-mingw32-g++" || true \
 && CC="x86_64-w64-mingw32-gcc" CXX="x86_64-w64-mingw32-g++" OS="Windows_NT" \
    CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" libzstd-mt \
 && mkdir -p /app \
 && x86_64-w64-mingw32-strip --strip-unneeded /src/lib/dll/libzstd.dll \
 && cp -L /src/lib/dll/libzstd.dll /app/libzstd.dll

# win-x86
FROM debian:bookworm-slim AS win-x86
ARG TARGETPLATFORM=windows-386
WORKDIR /src/lib
COPY --from=src /src /src
RUN --mount=type=cache,target=/var/cache/apt,id=apt-${TARGETPLATFORM},sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,id=apt-lists-${TARGETPLATFORM},sharing=locked \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends make mingw-w64 \
 && rm -rf /var/lib/apt/lists/* \
 && make -C /src/lib clean CC="i686-w64-mingw32-gcc" CXX="i686-w64-mingw32-g++" || true \
 && CC="i686-w64-mingw32-gcc" CXX="i686-w64-mingw32-g++" OS="Windows_NT" \
    CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
    LDFLAGS="-flto" \
    make -C /src/lib -j"$(nproc)" libzstd-mt \
 && mkdir -p /app \
 && i686-w64-mingw32-strip --strip-unneeded /src/lib/dll/libzstd.dll \
 && cp -L /src/lib/dll/libzstd.dll /app/libzstd.dll


#############################
# (Optional) macOS via osxcross
# Enable if you have an osxcross image with an SDK.
#############################
#FROM ghcr.io/tpoechtrager/osxcross:latest AS osx-x64
#WORKDIR /src/lib
#COPY --from=src /src /src
#RUN echo '#!/bin/sh\necho Darwin' > /bin/uname && chmod +x /bin/uname \
# && make -C /src/lib clean || true \
# && CC="o64-clang" CXX="o64-clang++" \
#    CFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
#    CXXFLAGS="-g0 -O3 -pipe -flto -fvisibility=hidden -fno-rtti -fvisibility-inlines-hidden -DZSTD_MULTITHREAD -DZSTD_LEGACY_SUPPORT=0 -pthread -s" \
#    LDFLAGS="-flto" \
#    make -C /src/lib -j"$(nproc)" libzstd-mt \
# && mkdir -p /app \
# && x86_64-apple-darwin*-strip -S /src/lib/libzstd.dylib \
# && cp -L /src/lib/libzstd.dylib /app/


#############################
# Final collector
#############################
FROM alpine:3.20 AS finale
WORKDIR /out

# musl
COPY --from=linux-musl-x64    /app/ ./linux-musl-x64/native/
COPY --from=linux-musl-x86    /app/ ./linux-musl-x86/native/
COPY --from=linux-musl-arm64  /app/ ./linux-musl-arm64/native/
COPY --from=linux-musl-arm    /app/ ./linux-musl-arm/native/
# glibc
COPY --from=linux-glibc-x64   /app/ ./linux-x64/native/
COPY --from=linux-glibc-x86   /app/ ./linux-x86/native/
COPY --from=linux-glibc-arm64 /app/ ./linux-arm64/native/
COPY --from=linux-glibc-arm   /app/ ./linux-arm/native/
# windows
COPY --from=win-x64           /app/ ./win-x64/native/
COPY --from=win-x86           /app/ ./win-x86/native/
# macOS (if enabled)
# COPY --from=osx-x64        /app/ ./osx-x64/native/

ENTRYPOINT ["/bin/sh"]


# Export-only stage: contains ONLY the files from /out
FROM scratch AS artifacts
COPY --from=finale /out/ /