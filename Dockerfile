FROM python:3.9-buster

# Install system dependencies for FUSE
RUN set -e; \
    apt-get update -y && apt-get install -y \
    tini \
    lsb-release; \
    gcsFuseRepo=gcsfuse-`lsb_release -c -s`; \
    echo "deb http://packages.cloud.google.com/apt $gcsFuseRepo main" | \
    tee /etc/apt/sources.list.d/gcsfuse.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key add -; \
    apt-get update; \
    apt-get install -y gcsfuse \
    && apt-get clean

ENV MNT_DIR /devpi
ENV BUCKET evident_packages

# Install devpi and dependencies
COPY devpi-requirements.txt /
RUN pip install -r /devpi-requirements.txt

# Set default server root
ENV DEVPI_SERVER_ROOT=/devpi

# Add entrypoint
COPY devpi-client /usr/local/bin/
COPY entrypoint.sh /

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
