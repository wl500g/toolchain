# 
# Copyright (C) 2006-2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

KERNELNAME=

KERNEL_MAKEOPTS := -C $(LINUX_DIR) \
	CROSS_COMPILE="$(KERNEL_CROSS)" \
	ARCH="$(LINUX_KARCH)" \
	KBUILD_HAVE_NLS=no \
	CONFIG_SHELL="$(BASH)"

INITRAMFS_EXTRA_FILES ?= $(GENERIC_PLATFORM_DIR)/image/initramfs-base-files.txt

ifneq (,$(KERNEL_CC))
  KERNEL_MAKEOPTS += CC="$(KERNEL_CC)"
endif


define Kernel/Patch
	if [ -d $(GENERIC_FILES_DIR) ]; then $(CP) $(GENERIC_FILES_DIR)/* $(LINUX_DIR)/; fi
	if [ -d $(FILES_DIR) ]; then \
		$(CP) $(FILES_DIR)/* $(LINUX_DIR)/; \
		find $(LINUX_DIR)/ -name \*.rej | xargs rm -f; \
	fi
	$(call PatchDir,$(GENERIC_PATCH_DIR),generic/)
	$(call PatchDir,$(PATCH_DIR),platform/)
endef

ifeq ($(strip $(CONFIG_EXTERNAL_KERNEL_TREE)),"")
define Kernel/Prepare/Default
	bzcat $(DL_DIR)/$(LINUX_SOURCE) | $(TAR) -C $(KERNEL_BUILD_DIR) $(TAR_OPTIONS)
	$(Kernel/Patch)
endef
else
define Kernel/Prepare/Default
	if [ \! -d $(CONFIG_EXTERNAL_KERNEL_TREE) ]; then \
		$(call MESSAGE, Failed to locate kernel sources at $(CONFIG_EXTERNAL_KERNEL_TREE)); \
		false; \
	fi
	mkdir -p $(KERNEL_BUILD_DIR)
	if [ -d $(LINUX_DIR) ]; then \
		rmdir $(LINUX_DIR); \
	fi
	ln -s $(CONFIG_EXTERNAL_KERNEL_TREE) $(LINUX_DIR)
endef
endif

define Kernel/Configure/2.6
	-$(MAKE) $(KERNEL_MAKEOPTS) oldconfig prepare scripts
endef
define Kernel/Configure/Default
	$(LINUX_CONFCMD) > $(LINUX_DIR)/.config.target
#	$(SCRIPT_DIR)/metadata.pl kconfig $(TMP_DIR)/.packageinfo $(TOPDIR)/.config > $(LINUX_DIR)/.config.override
	$(SCRIPT_DIR)/kconfig.pl 'm+' $(LINUX_DIR)/.config.target $(LINUX_DIR)/.config.override > $(LINUX_DIR)/.config
	$(call Kernel/Configure/$(KERNEL))
	rm -rf $(KERNEL_BUILD_DIR)/modules
endef

define Kernel/Clean/Default
	rm -f $(KERNEL_BUILD_DIR)/linux-$(LINUX_VERSION)/.configured
	$(MAKE) -C $(KERNEL_BUILD_DIR)/linux-$(LINUX_VERSION) clean
endef


