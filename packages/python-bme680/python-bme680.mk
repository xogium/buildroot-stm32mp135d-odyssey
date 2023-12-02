################################################################################
#
# python-bme680
#
################################################################################

PYTHON_BME680_VERSION = 1.1.1
PYTHON_BME680_SOURCE = bme680-$(PYTHON_BME680_VERSION).tar.gz
PYTHON_BME680_SITE = https://files.pythonhosted.org/packages/e5/b4/5576f6f4fe94b4b518ddf40e24d29ba00117ab9b92fcb90e4c23e16eff4f
PYTHON_BME680_SETUP_TYPE = setuptools
PYTHON_BME680_LICENSE = MIT

$(eval $(python-package))
