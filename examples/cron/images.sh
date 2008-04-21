#!/bin/sh -x

set -e

ARCHITECTURE="$(dpkg --print-architecture)"
DATE="$(date +%Y%m%d)"

for DISTRIBUTION in etch lenny sid
do
	rm -rf cache/stages*

	for FLAVOUR in standard gnome-desktop kde-desktop xfce-desktop
	do
		mkdir -p config

		if [ -e .stage ]
		then
			lh clean
		fi

		rm -rf config
		rm -rf cache/packages*
		rm -rf cache/stages_rootfs

		lh config -d ${DISTRIBUTION} -p ${FLAVOUR} --cache-stages "bootstrap rootfs" --apt-recommends disabled --source enabled --mirror-bootstrap http://mirror/ftp.debian.org/debian/ --mirror-chroot http://mirror/ftp.debian.org/debian/ --mirror-chroot-security http://mirror/ftp.debian.org/debian-security/

		if [ "${DISTRIBUTION}" = "sid" ]
		then
			echo 'deb http://live.debian.net/debian/ ./' > config/chroot_sources/live-snapshots.chroot
			echo 'deb http://live.debian.net/debian/ ./' > config/chroot_sources/live-snapshots.boot

			wget http://ftp-master.debian-unofficial.org/other/openpgp/archive-key-2008.asc -O config/chroot_sources/live-snapshots.chroot.gpg
			wget http://ftp-master.debian-unofficial.org/other/openpgp/archive-key-2008.asc -O config/chroot_sources/live-snapshots.binary.gpg

		fi

		lh build | tee debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso.log

		mv binary.iso debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso
		mv binary.list debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso.list
		mv binary.packages debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso.packages
		mv source.tar.gz debian-live-${DISTRIBUTION}-source-${FLAVOUR}.tar.gz
		mv source.list debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.tar.gz.list

		lh clean --binary
		lh config -b usb-hdd
		lh binary | tee debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img.log

		mv binary.img debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img
		mv binary.list debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img.list
		mv binary.packages debian-live-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img.packages
	done
done
