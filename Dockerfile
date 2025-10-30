#FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye
#FROM kasmweb/core-debian-bullseye:1.17.0-rolling-daily
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Metatrader Docker:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="gmartin"

ENV TITLE=Metatrader5
ENV WINEPREFIX="/config/.wine"

# Update package lists and upgrade packages
RUN apt-get update && apt-get upgrade -y

# Install required packages
#RUN apt-get install -y \
#    python3-pip \
#    wget \
#    && pip3 install --upgrade pip
#

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends wget python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Upgrade pip with --break-system-packages
    pip3 install --upgrade pip --break-system-packages

# Add WineHQ repository key and APT source
#RUN wget -q https://dl.winehq.org/wine-builds/winehq.key \
#    && apt-key add winehq.key \
#    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main' \
#    && rm winehq.key

# (1) Chuẩn bị keyring & repo WineHQ kiểu mới
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends wget gnupg ca-certificates; \
    mkdir -pm755 /etc/apt/keyrings; \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key; \
    printf "Types: deb\nURIs: https://dl.winehq.org/wine-builds/debian\nSuites: bullseye\nComponents: main\nSigned-By: /etc/apt/keyrings/winehq-archive.key\n" \
      > /etc/apt/sources.list.d/winehq-bullseye.sources

# (2) Bật i386 (Wine cần thư viện 32-bit) + cài WineHQ stable
RUN set -eux; \
    dpkg --add-architecture i386; \
    apt-get update; \
    apt-get install -y --no-install-recommends winehq-stable; \
    rm -rf /var/lib/apt/lists/*


# Add i386 architecture and update package lists
RUN dpkg --add-architecture i386 \
    && apt-get update

# Install WineHQ stable package and dependencies
RUN apt-get install --install-recommends -y \
    winehq-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


COPY /Metatrader /Metatrader
RUN chmod +x /Metatrader/start.sh
COPY /root /

EXPOSE 3000 8001
VOLUME /config
