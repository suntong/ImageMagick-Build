# Dockerfile to build ImageMagick from Ubuntu/Debian (or BASE_IMAGE)

#ARG BASE_IMAGE=debian
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

ARG CLOUDSMITH_API_KEY

RUN apt update && apt install -y wget
RUN t=$(mktemp) && wget 'https://dist.1-2.dev/imei.sh' -qO "$t" && \
    bash "$t" --use-checkinstall --skip-aom --skip-jpeg-xl && \
    ls -l /usr/local/src/

# https://linuxize.com/post/how-to-install-pip-on-ubuntu-20.04/
RUN apt install -y python3-pip && pip install --upgrade cloudsmith-cli && \
    [ ${CLOUDSMITH_API_KEY:+T} ] && cloudsmith push deb suntong/repo/any-distro/any-version /usr/local/src/imei-imagemagick_*.deb
