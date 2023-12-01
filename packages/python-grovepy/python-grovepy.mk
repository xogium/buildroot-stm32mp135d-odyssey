################################################################################
#
# python-grovepy
#
################################################################################

PYTHON_GROVEPY_VERSION = 88e277108522e8c92e61089d287cc4ad82ff251c
PYTHON_GROVEPY_SITE = $(call github,Seeed-Studio,grove.py,$(PYTHON_GROVEPY_VERSION))
PYTHON_GROVEPY_SETUP_TYPE = setuptools
PYTHON_GROVEPY_LICENSE = MIT
PYTHON_GROVEPY_LICENSE_FILES = LICENSE

$(eval $(python-package))
