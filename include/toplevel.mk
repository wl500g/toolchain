# Makefile for OpenWrt
#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

PREP_MK= OPENWRT_BUILD= QUIET=0

include $(TOPDIR)/include/verbose.mk

REVISION:=$(shell $(TOPDIR)/scripts/getver.sh)

TOOLCHAINVERSION:=$(REVISION)
export TOOLCHAINVERSION
export IS_TTY=$(shell tty -s && echo 1 || echo 0)

ifeq ($(FORCE),)
  .config scripts/config/conf scripts/config/mconf: tmp/.prereq-build
endif

prepare-mk: FORCE ;

.config: ./scripts/config/conf
	@+if [ \! -f .config ] || ! grep CONFIG_HAVE_DOT_CONFIG .config >/dev/null; then \
		[ -e defconfig ] && cp defconfig .config; \
		$(NO_TRACE_MAKE) menuconfig $(PREP_MK); \
	fi

scripts/config/mconf:
	@$(SUBMAKE) -s -j1 -C scripts/config all

$(eval $(call rdep,scripts/config,scripts/config/mconf))

scripts/config/conf:
	@$(SUBMAKE) -s -j1 -C scripts/config conf

config: scripts/config/conf FORCE
	$< Config.in

config-clean: FORCE
	$(NO_TRACE_MAKE) -C scripts/config clean

defconfig: scripts/config/conf FORCE
	touch .config
	@if [ -e defconfig ]; then cp defconfig .config; fi
	$< --defconfig=.config Config.in

confdefault-y=allyes
confdefault-m=allmod
confdefault-n=allno
confdefault:=$(confdefault-$(CONFDEFAULT))

oldconfig: scripts/config/conf FORCE
	$< --$(if $(confdefault),$(confdefault),old)config Config.in

menuconfig: scripts/config/mconf FORCE
	if [ \! -f .config -a -e defconfig ]; then \
		cp defconfig .config; \
	fi
	$< Config.in

kernel_oldconfig: .config FORCE
	$(NO_TRACE_MAKE) -C target/linux oldconfig

kernel_menuconfig: .config FORCE
	$(NO_TRACE_MAKE) -C target/linux menuconfig

tmp/.prereq-build: include/prereq-build.mk
	mkdir -p tmp
	rm -f tmp/.host.mk
	@$(_SINGLE)$(NO_TRACE_MAKE) -j1 -r -s -f $(TOPDIR)/include/prereq-build.mk prereq 2>/dev/null || { \
		echo "Prerequisite check failed. Use CHECK_<tool>=0 to override."; \
		false; \
	}
	touch $@

download: .config FORCE
	@+$(SUBMAKE) tools/download
	@+$(SUBMAKE) toolchain/download

clean dirclean: .config
	@+$(SUBMAKE) -r $@ 

prereq:: .config
	@+$(MAKE) -r -s tmp/.prereq-build $(PREP_MK)
	@+$(NO_TRACE_MAKE) -r -s $@

%::
	@+$(PREP_MK) $(NO_TRACE_MAKE) -s prereq
	@( \
		./scripts/config/conf --defconfig=.config --oldnoconfig -w tmp/.config Config.in > /dev/null 2>&1; \
		if ./scripts/kconfig.pl '>' .config tmp/.config | grep -q CONFIG; then \
			echo "WARNING: your configuration is out of sync. Please run make menuconfig, oldconfig or defconfig!"; \
		fi; \
		rm -f tmp/.config \
	)
	@+$(SUBMAKE) -r $@

help:
	cat README

docs docs/compile: FORCE
	@$(_SINGLE)$(SUBMAKE) -j1 -C docs compile

docs/clean: FORCE
	@$(_SINGLE)$(SUBMAKE) -j1 -C docs clean

distclean:
	rm -rf tmp build_dir staging_dir dl .config* feeds bin
	@$(SUBMAKE) -j1 -C scripts/config clean

ifeq ($(findstring v,$(DEBUG)),)
  .SILENT: symlinkclean clean dirclean distclean config-clean download help tmpinfo-clean .config scripts/config/mconf scripts/config/conf menuconfig tmp/.prereq-build tmp/.prereq-package
endif
.PHONY: help FORCE
.NOTPARALLEL:
