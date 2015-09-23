#!/usr/bin/env bash
this=$(cd $(dirname $0); pwd)
mount |grep usb || sudo mount /mnt/usb || exit

rcmd="sudo rsync -rvhi $this /mnt/usb/ --exclude 'results/*' --size-only --exclude '.git'"
eval $rcmd --dry-run
echo
echo -n "okay? (^c to quit)??? "
read junk
eval $rcmd 


