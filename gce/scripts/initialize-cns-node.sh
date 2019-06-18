#!/bin/bash
CONTAINERSDEVICE=$(readlink -f /dev/disk/by-id/google-*containers*)
CONTAINERSDIR="/var/lib/docker"

mkfs.xfs ${CONTAINERSDEVICE}
mkdir -p ${CONTAINERSDIR}
restorecon -R ${CONTAINERSDIR}

echo UUID=$(blkid -s UUID -o value ${CONTAINERSDEVICE}) ${CONTAINERSDIR} xfs defaults,discard 0 2 >> /etc/fstab

mount -a
