FROM ubuntu:16.04

MAINTAINER cronicc@protonmail.com

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install ca-certificates curl \
    && Baseurl="https://github.com/tianon/gosu/releases/download/" \
    && GOSU_VERSION="1.11" \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && curl -o /usr/local/bin/gosu -SL "$Baseurl/$GOSU_VERSION/gosu-$dpkgArch" \
    && curl -o /usr/local/bin/gosu.asc -SL "$Baseurl/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
       gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
       gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ca-certificates curl \
    && apt-get autoclean \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*.deb

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
