CLUSTERV_SOC_RTLDIR := $(dir $(lastword $(MAKEFILE_LIST)))
CLUSTERV_DIR := $(abspath $(CLUSTERV_SOC_RTLDIR)/../..)

ifneq (1,$(RULES))

ifeq (,$(findstring $(CLUSTERV_SOC_RTLDIR),$(MKDV_INCLUDED_DEFS)))

# Deliberately exclude user_project_wrapper
MKDV_VL_SRCS += $(wildcard $(CLUSTERV_SOC_RTLDIR)/*.v)
include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwrisc/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/defs_rules.mk

ifeq (icarus,$(MKDV_TOOL))
MKDV_VL_SRCS += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.v
endif

endif

else # Rules

endif

