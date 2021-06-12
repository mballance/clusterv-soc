MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))
CLUSTERV_SOC_DIR := $(abspath $(SYNTH_DIR)/../../..)

MKDV_OPENLANE_DESTDIR = $(CLUSTERV_SOC_DIR)
OPENLANE_SRCDIRS += $(SYNTH_DIR)/../../../caravel/openlane/user_project_wrapper_empty

MKDV_TOOL ?= openlane
TOP_MODULE = clusterv_caravel_top

MKDV_VL_DEFINES += INTERFACE_MACROS_INCLUDED

MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/wishbone_tag_macros.svh
MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/sky130_openram_macros.svh
MKDV_VL_SRCS += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/wishbone_tag_macros.svh
MKDV_VL_SRCS += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/sky130_openram_macros.svh

MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.v
MKDV_LEF_FILES += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.lef
MKDV_GDS_FILES += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.gds

MKDV_VL_SRCS_BB += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_tile.v
MKDV_LEF_FILES += $(CLUSTERV_SOC_DIR)/lef/clusterv_tile.lef
MKDV_GDS_FILES += $(CLUSTERV_SOC_DIR)/gds/clusterv_tile.gds

MKDV_VL_SRCS += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_caravel_top.v

#MKDV_VL_SRCS += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_tile_sram_sky130_openram.v
#MKDV_VL_DEFINES += CLUSTERV_TILE_SRAM_MODULE=clusterv_tile_sram_sky130_openram
#MKDV_VL_SRCS += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_main_sram_sky130_openram.v
#MKDV_VL_DEFINES += CLUSTERV_MAIN_SRAM_MODULE=clusterv_main_sram_sky130_openram

include $(SYNTH_DIR)/../common/defs_rules.mk

include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk
#include $(PACKAGES_DIR)/fwrisc/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-bridges/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-sram-ctrl/verilog/rtl/defs_rules.mk
#include $(PACKAGES_DIR)/fwperiph-dma/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwspi-memio/verilog/rtl/defs_rules.mk
#include $(PACKAGES_DIR)/fwspi-initiator/verilog/rtl/defs_rules.mk
#include $(PACKAGES_DIR)/fwuart-16550/verilog/rtl/defs_rules.mk


RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

