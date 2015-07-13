#
# Copyright (C) 2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=mpfr
PKG_VERSION:=3.1.3

PKG_SOURCE_URL:=http://www.mpfr.org/mpfr-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_MD5SUM:=5fdfa3cfa5c86514ee4a241a1affa138

include $(INCLUDE_DIR)/host-build.mk

HOST_CONFIGURE_ARGS += \
	--enable-static \
	--disable-shared \
	--with-gmp=$(STAGING_DIR_HOST)

define Build/Configure
	$(call Build/Configure/Default,\
		$(HOST_CONFIGURE_ARGS) \
	)
endef

define Build/Install
	$(MAKE) -C $(PKG_BUILD_DIR) install
endef

$(eval $(call HostBuild))
