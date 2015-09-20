FROM ubuntu:14.04
MAINTAINER Benjamin Böhmke

# set the version of the pebble sdk
ENV PEBBLE_VERSION PebbleSDK-3.4

# update system and get base packages
RUN apt-get update && \
    apt-get install -y curl python2.7-dev python-pip libfreetype6-dev bash-completion libsdl1.2debian libfdt1 libpixman-1-0 libglib2.0-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# get pebble SDK
RUN curl -sSL http://assets.getpebble.com.s3-website-us-east-1.amazonaws.com/sdk2/$PEBBLE_VERSION.tar.gz \
        | tar -v -C /opt -xz

# get arm tools
RUN curl -sSL http://assets.getpebble.com.s3-website-us-east-1.amazonaws.com/sdk/arm-cs-tools-ubuntu-universal.tar.gz \
        | tar -v -C /opt/$PEBBLE_VERSION -xz

# prepare python environment 
WORKDIR /opt/$PEBBLE_VERSION
RUN /bin/bash -c " \
    pip install virtualenv \
    && virtualenv --no-site-packages .env \
    && source .env/bin/activate \
    && pip install -r requirements.txt \
    && deactivate \
    "

# prepare pebble user for build environment + enable analytics
RUN adduser --disabled-password --gecos "" --ingroup users pebble && \
    echo "pebble ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chmod -R 777 /opt/ && \
    touch /opt/ENABLE_ANALYTICS

# change to pebble user
USER pebble

# set PATH
ENV PATH /opt/$PEBBLE_VERSION/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# prepare project mount path
VOLUME /pebble/

# set run command
WORKDIR /pebble/
CMD /bin/bash