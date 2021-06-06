CLUSTERV_SOC_SYNTH_COMMONDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CLUSTERV_SOC_DIR := $(abspath $(CLUSTERV_SOC_SYNTH_COMMONDIR)/../../..)
PACKAGES_DIR := $(CLUSTERV_SOC_DIR)/packages
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)

ifneq (1,$(RULES))

#MKDV_VL_DEFINES += USE_POWER_PINS
MKDV_VL_INCDIRS += $(CLUSTERV_SOC_DIR)/caravel

include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk
#MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.v
#MKDV_LEF_FILES += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.lef
#MKDV_GDS_FILES += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.gds

include $(DV_MK)
else # Rules
include $(DV_MK)

endif

