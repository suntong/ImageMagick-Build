# Dockerfile to build ImageMagick from Ubuntu/Debian (or BASE_IMAGE)

#ARG BASE_IMAGE=debian
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE} AS builder

ARG t=/tmp/imei.sh # $(mktemp)
ARG p="--use-checkinstall --build-only --skip-aom --skip-jpeg-xl"

RUN --mount=type=cache,target=/var/cache/apt apt update && apt install -y less wget

RUN wget 'https://dist.1-2.dev/imei.sh' -qO "$t"
RUN --mount=type=cache,target=/var/cache/apt bash "$t" $p || true && ls -l /usr/local/src/ || true

FROM ${BASE_IMAGE}

ARG CLOUDSMITH_API_KEY

COPY --from=builder /usr/local/src/ /tmp
#RUN ls -l /tmp /tmp/src/ || true
RUN --mount=type=cache,target=/var/cache/apt apt update && apt install -y less libxml2
RUN --mount=type=cache,target=/var/cache/apt apt install -y --no-install-recommends /tmp/imei-*.deb

RUN identify --version && convert -version && magick -version
#RUN identify /usr/*/go*/src/image/testdata/video-001.jpeg
RUN identify /usr/share/pixmaps/debian-logo.png
RUN convert /usr/share/pixmaps/debian-logo.png /tmp/debian-logo.jpg && \
  identify /tmp/debian-logo.jpg

# https://linuxize.com/post/how-to-install-pip-on-ubuntu-20.04/
RUN --mount=type=cache,target=/var/cache/apt apt install -y python3-pip && pip install --upgrade cloudsmith-cli

RUN [ ${CLOUDSMITH_API_KEY:+T} ] && cloudsmith push deb suntong/repo/any-distro/any-version /tmp/imei-*.deb || true
