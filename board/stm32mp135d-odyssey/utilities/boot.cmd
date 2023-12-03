if test $boot_device = "mmc" && test $boot_instance = "0"; then
	echo "Micro sd card boot" &&
	ext4load mmc 0:5 ${fdt_addr_r} /boot/stm32mp135d-odyssey-grove.dtb &&
	ext4load mmc 0:5 ${kernel_addr_r} /boot/zImage &&
	setenv bootargs "root=/dev/mmcblk0p5 ip=dhcp rootwait rw quiet console=ttySTM0,115200n8 earlycon";
fi

if test $boot_device = "mmc" && test $boot_instance = "1"; then
	echo "eMMC boot" &&
	ext4load mmc 1:2 ${fdt_addr_r} /boot/stm32mp135d-odyssey-grove.dtb &&
	ext4load mmc 1:2 ${kernel_addr_r} /boot/zImage &&
	setenv bootargs "root=/dev/mmcblk1p2 ip=dhcp rootwait rw quiet console=ttySTM0,115200n8 earlycon";
fi

bootz ${kernel_addr_r} - ${fdt_addr_r}
