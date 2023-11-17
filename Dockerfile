FROM ubuntu:20.04

MAINTAINER cronic@horizen.io

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV GOSU_VERSION 1.17

RUN set -eux; \
# save list of currently installed packages for later so we can clean up
  apt-get update; \
  DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y; \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils; \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates wget; \
  if ! command -v gpg; then \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg2 dirmngr; \
  elif gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
# "This package provides support for HKPS keyservers." (GnuPG 1.x only)
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg-curl; \
  fi; \
  rm -rf /var/lib/apt/lists/*; \
  \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  \
# verify the signature
  export GNUPGHOME="$(mktemp -d)"; \
  ( gpg2 --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
  gpg2 --batch --keyserver hkp://ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
  gpg2 --batch --keyserver pgp.mit.edu --recv-key B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
  gpg2 --batch --keyserver keyserver.pgp.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
  gpg2 --batch --keyserver pgp.key-server.io --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 ) \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  command -v gpgconf && gpgconf --kill all || :; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  \
# clean up fetch dependencies
  apt-mark auto '.*' > /dev/null; \
  [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
  DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*; \
  \
  chmod +x /usr/local/bin/gosu; \
# verify that the binary works
  gosu --version; \
  gosu nobody true; \
  chmod +x /usr/local/bin/entrypoint.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
