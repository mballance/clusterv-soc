MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))
CLUSTERV_SOC_DIR := $(abspath $(SYNTH_DIR)/../../..)

MKDV_OPENLANE_DESTDIR = $(CLUSTERV_SOC_DIR)

MKDV_TOOL ?= openlane
TOP_MODULE = clusterv_sys_ic

include $(SYNTH_DIR)/../common/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/defs_rules.mk
MKDV_VL_SRCS += $(CLUSTERV_SOC_DIR)/verilog/rtl/clusterv_sys_ic.v

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

