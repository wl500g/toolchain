# 
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=pkg-config
PKG_VERSION:=0.28

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pkgconfig.freedesktop.org/releases/
PKG_MD5SUM:=aa3c86e67551adc3ac865160e34a2a0d

include $(INCLUDE_DIR)/host-build.mk

unexport PKG_CONFIG

HOST_CONFIGURE_ARGS += --with-internal-glib

define Build/Install
	$(MAKE) -C $(PKG_BUILD_DIR) \
		install
	mv $(STAGING_DIR_HOST)/bin/pkg-config $(STAGING_DIR_HOST)/bin/pkg-config.real
	$(INSTALL_BIN) ./files/pkg-config $(STAGING_DIR_HOST)/bin/pkg-config
endef

define Build/Clean
	$(MAKE) -C $(PKG_BUILD_DIR) uninstall
	$(MAKE) -C $(PKG_BUILD_DIR) clean
	$(call Build/Clean/Default)
endef

$(eval $(call HostBuild))
