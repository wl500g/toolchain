GDB_VARIANT:=gdbserver

include ../common.mk

GDB_CONFIGURE += \
	--prefix=/opt \
	--host=$(REAL_GNU_TARGET_NAME) \
	--disable-werror \
	--disable-inprocess-agent

define Build/Configure
	mkdir -p $(GDB_BUILD_DIR)
	(cd $(GDB_BUILD_DIR) && rm -f config.cache; \
		$(GDB_CONFIGURE) \
	);
endef

define Build/Install
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gdbserver $(TOOLCHAIN_DIR)/target-utils/
	$(TARGET_CROSS)strip $(TOOLCHAIN_DIR)/target-utils/gdbserver
endef

$(eval $(call HostBuild))
