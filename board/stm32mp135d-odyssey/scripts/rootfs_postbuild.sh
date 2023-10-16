#!/bin/sh

# combine tf-a and fip into one single image easily writable in the eMMC boot regions

dd if="${BINARIES_DIR}/tf-a-stm32mp135d-odyssey.stm32" \
	of="${BINARIES_DIR}/combined-tf-a-and-fip.img"

dd if="${BINARIES_DIR}/fip.bin" \
	of="${BINARIES_DIR}/combined-tf-a-and-fip.img" \
	oflag=seek_bytes seek=256K

# copy boot.scr into the target
cp "${BINARIES_DIR}/boot.scr" \
	"${TARGET_DIR}/boot/boot.scr"
