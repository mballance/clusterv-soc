MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))
CLUSTERV_SOC_DIR := $(abspath $(SYNTH_DIR)/../../..)

MKDV_OPENLANE_DESTDIR = $(CLUSTERV_SOC_DIR)
OPENLANE_SRCDIRS += $(SYNTH_DIR)/../../../caravel/openlane/user_project_wrapper_empty

MKDV_TOOL ?= openlane
TOP_MODULE = user_project_wrapper

MKDV_VL_DEFINES += INTERFACE_MACROS_INCLUDED INCLUDED_INTERFACE_MACROS
MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/wishbone_tag_macros.svh
MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/wishbone_macros.svh
MKDV_VL_SRCS_BB += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/sky130_openram_macros.svh
MKDV_VL_SRCS += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/wishbone_tag_macros.svh
MKDV_VL_SRCS += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/wishbone_macros.svh
MKDV_VL_SRCS += $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/sky130_openram_macros.svh

MKDV_LEF_FILES += $(CLUSTERV_SOC_DIR)/lef/clusterv_caravel_top.lef
MKDV_GDS_FILES += $(CLUSTERV_SOC_DIR)/gds/clusterv_caravel_top.gds
MKDV_VL_SRCS_BB += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_caravel_top.v

MKDV_VL_SRCS_BB += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_tile.v
MKDV_LEF_FILES += $(CLUSTERV_SOC_DIR)/lef/clusterv_tile.lef
MKDV_GDS_FILES += $(CLUSTERV_SOC_DIR)/gds/clusterv_tile.gds

MKDV_VL_SRCS += $(CLUSTERV_SOC_DIR)/verilog/rtl/user_project_wrapper.v

MKDV_RUN_DEPS += $(MKDV_RUNDIR)/$(TOP_MODULE)/pin_order.cfg

include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

$(MKDV_RUNDIR)/$(TOP_MODULE)/pin_order.cfg : $(SYNTH_DIR)/pin_order.cfg
	cp $^ $@

