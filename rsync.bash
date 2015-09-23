#!/usr/bin/env bash
this=$(cd $(dirname $0); pwd)
mount |grep usb || sudo mount /mnt/usb || exit

sudo rsync -nrvhi $this /mnt/usb/ --exclude 'results/*' --size-only
echo okay?
read junk
sudo rsync -rvhi $this /mnt/usb/ --exclude 'results/*'  --size-only


