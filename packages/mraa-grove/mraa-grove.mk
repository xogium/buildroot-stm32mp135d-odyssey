################################################################################
#
# mraa-grove
#
################################################################################

MRAA_GROVE_VERSION = d055b45b7e0744de60855f35007999dded684945
MRAA_GROVE_SITE = $(call github,eclipse,mraa,$(MRAA_GROVE_VERSION))
MRAA_GROVE_LICENSE = MIT
MRAA_GROVE_LICENSE_FILES = COPYING
MRAA_GROVE_INSTALL_STAGING = YES
MRAA_GROVE_DEPENDENCIES = host-swig host-python3

ifeq ($(BR2_i386),y)
MRAA_GROVE_ARCH = i386
else ifeq ($(BR2_x86_64),y)
MRAA_GROVE_ARCH = x86_64
else ifeq ($(BR2_arm)$(BR2_armeb),y)
MRAA_GROVE_ARCH = arm
else ifeq ($(BR2_aarch64)$(BR2_aarch64_be),y)
MRAA_GROVE_ARCH = aarch64
else ifeq ($(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el),y)
MRAA_GROVE_ARCH = mips
endif

# USBPLAT only makes sense with FTDI4222, which requires the ftd2xx library,
# which doesn't exist in buildroot
# Disable C++ as it is used only by FTDI4222 and tests
MRAA_GROVE_CONF_OPTS += \
	-DBUILDARCH=$(MRAA_GROVE_ARCH) \
	-DBUILDCPP=OFF \
	-DUSBPLAT=OFF \
	-DFTDI4222=OFF \
	-DENABLEEXAMPLES=OFF \
	-DBUILDTESTS=OFF

ifeq ($(BR2_PACKAGE_JSON_C),y)
MRAA_GROVE_CONF_OPTS += -DJSONPLAT=ON
MRAA_GROVE_DEPENDENCIES += json-c
else
MRAA_GROVE_CONF_OPTS += -DJSONPLAT=OFF
endif

$(eval $(cmake-package))
