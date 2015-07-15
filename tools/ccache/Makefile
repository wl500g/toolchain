# 
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
#include $(INCLUDE_DIR)/target.mk

PKG_NAME:=ccache
PKG_VERSION:=3.1.11

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://samba.org/ftp/ccache/
PKG_MD5SUM:=0f6df80c8941d9020a1fd5df5ad57dd7

include $(INCLUDE_DIR)/host-build.mk

HOSTCC:=$(HOSTCC_NOCACHE)

define Build/Install/ccache
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin/
	$(CP) ./files/* $(STAGING_DIR_HOST)/bin/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Build/Clean
	-$(MAKE) -C $(PKG_BUILD_DIR) uninstall
	$(call Build/Clean/Default)
endef

define Build/Install
	$(call Build/Install/Default)
	$(call Build/Install/ccache)
endef

$(eval $(call HostBuild))
