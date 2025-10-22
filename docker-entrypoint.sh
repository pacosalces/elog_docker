#!/bin/bash
set -e

ELOG_UID=$(id -u elog)
ELOG_GID=$(id -g elog)

echo "Setting permissions for ELOG bind mounts (UID: $ELOG_UID, GID: $ELOG_GID)..."

# Correct ownership for mounted configuration and data directories
chown -R $ELOG_UID:$ELOG_GID /var/elog
chown -R $ELOG_UID:$ELOG_GID /etc/elog

# NEW: Explicitly ensure the owner (elog user) has read/write access
chmod -R u+rw /etc/elog
chmod -R u+rw /var/elog

echo "Starting elogd as unprivileged user 'elog'..."
exec gosu elog /usr/local/sbin/elogd -c /etc/elog/elogd.cfg -p 8080 -v 3