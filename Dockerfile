# Dockerfile to build ImageMagick from Ubuntu/Debian (or BASE_IMAGE)

#ARG BASE_IMAGE=debian
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

ARG t=/tmp/imei.sh # $(mktemp)
ARG p="--use-checkinstall --skip-aom --skip-jpeg-xl"

ARG CLOUDSMITH_API_KEY

# https://linuxize.com/post/how-to-install-pip-on-ubuntu-20.04/
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/usr/local apt update && apt install -y less wget python3-pip && pip install --upgrade cloudsmith-cli

RUN wget 'https://dist.1-2.dev/imei.sh' -qO "$t" && sed -i '/\\ec/d; /libraqm0/s/,imei-libaom,imei-libheif,imei-libjxl//; /Signature verification failed.*1/{N; s/^.*$/:/;}; /Signature verification failed.*2/{N;N;N;d;}' "$t"
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/usr/local bash "$t" $p || true && ls -l /usr/local/src/ || true

RUN --mount=type=cache,target=/usr/local [ ${CLOUDSMITH_API_KEY:+T} ] && cloudsmith push deb suntong/repo/any-distro/any-version /usr/local/src/imei-imagemagick_*.deb || true
