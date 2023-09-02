# Dockerfile to build ImageMagick from Ubuntu/Debian (or BASE_IMAGE)

#ARG BASE_IMAGE=debian
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

ARG t=/tmp/imei.sh # $(mktemp)
ARG p="--use-checkinstall --build-only --skip-aom --skip-jpeg-xl"

ARG CLOUDSMITH_API_KEY

# https://linuxize.com/post/how-to-install-pip-on-ubuntu-20.04/
RUN --mount=type=cache,target=/var/cache/apt apt update && apt install -y less wget python3-pip && pip install --upgrade cloudsmith-cli

RUN wget 'https://dist.1-2.dev/imei.sh' -qO "$t"
RUN --mount=type=cache,target=/var/cache/apt bash "$t" $p || true && ls -l /usr/local/src/ || true

RUN [ ${CLOUDSMITH_API_KEY:+T} ] && cloudsmith push deb suntong/repo/any-distro/any-version /usr/local/src/imei-imagemagick_*.deb || true
