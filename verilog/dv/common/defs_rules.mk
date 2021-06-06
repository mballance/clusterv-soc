
CLUSTERV_SOC_DV_COMMONDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CLUSTERV_SOC_DIR := $(abspath $(CLUSTERV_SOC_DV_COMMONDIR)/../../..)
PACKAGES_DIR := $(CLUSTERV_SOC_DIR)/packages
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)


ifneq (1,$(RULES))

MKDV_PYTHONPATH += $(CLUSTERV_SOC_DV_COMMONDIR)/python
MKDV_VL_INCDIRS += $(CLUSTERV_SOC_DIR)/caravel

ifeq (bfm,$(CLUSTERV_SOC_SRAM))
MKDV_VL_SRCS += $(CLUSTERV_SOC_DV_COMMONDIR)/clusterv_tile_sram_bfm.v
MKDV_VL_DEFINES += CLUSTERV_TILE_SRAM_MODULE=clusterv_tile_sram_bfm
MKDV_VL_SRCS += $(CLUSTERV_SOC_DV_COMMONDIR)/clusterv_main_sram_bfm.v
MKDV_VL_DEFINES += CLUSTERV_MAIN_SRAM_MODULE=clusterv_main_sram_bfm
endif

include $(PACKAGES_DIR)/fwrisc/verilog/dbg/defs_rules.mk
include $(CLUSTERV_SOC_DIR)/verilog/rtl/defs_rules.mk
include $(DV_MK)
else # Rules
include $(DV_MK)

endif

