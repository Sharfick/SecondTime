#!/bin/bash

core_install(){

	echo "подготовка к настройки ядра"
	emerge --ask sys-kernel/gentoo-sources
	emerge --ask sys-kernel/genkernel

	sed -i "s/LABEL=boot	\/boot	ext4	noauto,noatime	1 2/LABEL=boot	\/boot	ext4	defaults	0 2/g" /etc/fstab
	
	echo "настройка ядра"
	genkernel all

	ls /boot/vmlinu* /boot/initramfs*
	echo "hostname='gentoo'"

	emerge -q networkmanager
	rc-update add networkmanager boot

	emerge sys-fs/dosfstools
	emerge sys-fs/btrfs-progs
	emerge sys-fs/e2fsprogs

}

error_exit(){
	
	#echo "обработка ошибок"
	echo "Error: $1"
	exit 1

}

installer(){

	echo "настройка загузчика"
	emerge --ask --verbose sys-boot/grub

	echo  "GRUB_PLATFORMS='efi-64'" >> /etc/portage/make.conf

	emerge --ask sys-boot/grub
	emerge --ask --update --newuse --verbose sys-boot/grub

	grub-install --target=x86_64-efi --efi-directory=/boot
	grub-mkconfig -o /boot/grub/grub.cfg

	exit
	cd

	umount-l /mnt/gentoo/dev{/shm,/pts,}
	umount -R /mnt/gentoo

	reboot

}

	core_install || error_exit "core error"
	installer || error_exit "installer error"
