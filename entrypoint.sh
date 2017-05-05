#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}
GRP_ID=${LOCAL_GRP_ID:-9001}

echo "Starting with UID/GID : $USER_ID/$GRP_ID"
groupadd -g $GRP_ID user
useradd --shell /bin/bash -u $USER_ID -g $GRP_ID -o -c "" -m user
export HOME=/home/user

exec /usr/local/bin/gosu user "$@"
