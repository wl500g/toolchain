# 
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=gdb
PKG_VERSION:=7.8.2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MD5SUM:=a80cf252ed2e775d4e4533341bbf2459
PKG_SOURCE_URL:=@GNU/gdb

STAGING_DIR_HOST:=$(TOOLCHAIN_DIR)
BUILD_DIR_HOST:=$(BUILD_DIR_TOOLCHAIN)

include $(INCLUDE_DIR)/host-build.mk

PKG_SOURCE_DIR:=$(PKG_BUILD_DIR)
ifeq ($(GDB_VARIANT),gdbserver)
	PKG_SOURCE_DIR:=$(PKG_BUILD_DIR)/gdb/gdbserver
	GDB_BUILD_DIR:=$(PKG_BUILD_DIR)-$(GDB_VARIANT)
	PKG_BUILD_DIR:=$(GDB_BUILD_DIR)
endif

GDB_CONFIGURE:= \
	SHELL="$(BASH)" \
	gdb_cv_func_sigsetjmp=yes \
	CFLAGS="-O2" \
	$(PKG_SOURCE_DIR)/configure

define Build/Configure
	(cd $(PKG_BUILD_DIR) && rm -f config.cache; \
		$(GDB_CONFIGURE) \
	);
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Build/Clean
	rm -rf $(PKG_BUILD_DIR) $(PKG_BUILD_DIR)-gdbserver
	rm -f $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb
	rm -f $(TOOLCHAIN_DIR)/bin/$(GNU_TARGET_NAME)-gdb
	rm -f $(TOOLCHAIN_DIR)/target-utils/gdbserver
endef
