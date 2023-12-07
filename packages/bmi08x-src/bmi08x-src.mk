################################################################################
#
# bmi08x-src
#
################################################################################

BMI08X_SRC_VERSION = bmi08x_v1.4.4
BMI08X_SRC_SITE = $(call github,boschsensortec,BMI08x-Sensor-API,$(BMI08X_SRC_VERSION))
BMI08X_SRC_LICENSE = BSD-3-Clause
BMI08X_SRC_INSTALL_STAGING = YES

define BMI08X_SRC_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/src/bmi08x/
	cp -r $(@D)/* $(STAGING_DIR)/usr/src/bmi08x/
endef

$(eval $(generic-package))
