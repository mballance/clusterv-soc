CLUSTERV_SOC_RTLDIR := $(dir $(lastword $(MAKEFILE_LIST)))
CLUSTERV_DIR := $(abspath $(CLUSTERV_SOC_RTLDIR)/../..)

ifneq (1,$(RULES))

ifeq (,$(findstring $(CLUSTERV_SOC_RTLDIR),$(MKDV_INCLUDED_DEFS)))

# Deliberately exclude user_project_wrapper
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_mem_ctrl_2k.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_mem_ctrl_4k.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_mem_ctrl_8k.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_mgmt_if.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_periph_subsys.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_soc.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_sys_ic.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_storage.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_tile.v
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/user_project_wrapper.v

ifeq (openram,$(CLUSTERV_SOC_SRAM))
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_tile_sram_sky130_openram.v
MKDV_VL_DEFINES += CLUSTERV_TILE_SRAM_MODULE=clusterv_tile_sram_sky130_openram
MKDV_VL_SRCS += $(CLUSTERV_SOC_RTLDIR)/clusterv_main_sram_sky130_openram.v
MKDV_VL_DEFINES += CLUSTERV_MAIN_SRAM_MODULE=clusterv_main_sram_sky130_openram
endif

ifeq (,$(CLUSTERV_SOC_RAM))
# TODO: raise an error over improper configuration
endif

include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwrisc/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-local-intc/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-bridges/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-sram-ctrl/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwperiph-dma/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwpic/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwpit/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwspi-memio/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwspi-initiator/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwuart-16550/verilog/rtl/defs_rules.mk

ifeq (icarus,$(MKDV_TOOL))
MKDV_VL_SRCS += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8/sky130_sram_1kbyte_1rw1r_32x256_8.v
MKDV_VL_SRCS += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8/sky130_sram_2kbyte_1rw1r_32x512_8.v
MKDV_VL_SRCS += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_4kbyte_1rw1r_32x1024_8/sky130_sram_4kbyte_1rw1r_32x1024_8.v
MKDV_VL_SRCS += $(PACKAGES_DIR)/sky130_sram_macros/sky130_sram_8kbyte_1rw1r_32x2048_8/sky130_sram_8kbyte_1rw1r_32x2048_8.v
endif

endif # endif protection

else # Rules

endif

