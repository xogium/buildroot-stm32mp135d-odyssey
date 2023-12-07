################################################################################
#
# libbmi088
#
################################################################################

LIBBMI088_VERSION = 45af6b10598613d085625b3d687f9ebe7ae12efe
LIBBMI088_SITE = $(call github,turmary,bmi088-python,$(LIBBMI088_VERSION))
LIBBMI088_LICENSE = MIT
LIBBMI088_DEPENDENCIES = bmi08x-src

define LIBBMI088_BUILD_CMDS
	rmdir $(@D)/bosch-lib || rm $(@D)/bosch-lib
	ln -s $(STAGING_DIR)/usr/src/bmi08x/ $(@D)/bosch-lib
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) all
endef

define LIBBMI088_INSTALL_TARGET_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) DESTDIR="$(TARGET_DIR)" PREFIX="/usr" -C $(@D) install
endef

$(eval $(generic-package))
