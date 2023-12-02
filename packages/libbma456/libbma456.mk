################################################################################
#
# libbma456
#
################################################################################

LIBBMA456_VERSION = 7c8243eda12985e0dc16af6d7e4ff4f9e1801a81
LIBBMA456_SITE = $(call github,Seeed-Studio,Seeed_BMA456,$(LIBBMA456_VERSION))
LIBBMA456_LICENSE = MIT
LIBBMA456_INSTALL_STAGING = YES

define LIBBMA456_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) all
endef

define LIBBMA456_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/*.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0755 $(@D)/libbma456.so $(STAGING_DIR)/usr/lib
endef

define LIBBMA456_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libbma456.so $(TARGET_DIR)/usr/lib
	$(INSTALL) -D -m 0755 $(@D)/bma456_test $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
