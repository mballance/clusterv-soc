MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))
CLUSTERV_SOC_DIR := $(abspath $(SYNTH_DIR)/../../..)

MKDV_OPENLANE_DESTDIR = $(CLUSTERV_SOC_DIR)
OPENLANE_SRCDIRS += $(SYNTH_DIR)/../../../caravel/openlane/user_project_wrapper_empty

MKDV_TOOL ?= openlane
TOP_MODULE = user_project_wrapper

MKDV_LEF_FILES += $(CLUSTERV_SOC_DIR)/lef/clusterv_tile.lef
MKDV_GDS_FILES += $(CLUSTERV_SOC_DIR)/gds/clusterv_tile.gds

MKDV_VL_SRCS_BB += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_tile.v
MKDV_LEF_FILES += $(CLUSTERV_SOC_DIR)/lef/clusterv_tile.lef
MKDV_GDS_FILES += $(CLUSTERV_SOC_DIR)/gds/clusterv_tile.gds

MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.v
MKDV_LEF_FILES += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.lef
MKDV_GDS_FILES += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.gds

MKDV_VL_SRCS += $(CLUSTERV_SOC_DIR)/verilog/rtl/user_project_wrapper.v


include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

