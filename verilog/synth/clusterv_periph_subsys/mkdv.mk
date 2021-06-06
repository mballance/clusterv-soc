MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))
CLUSTERV_SOC_DIR := $(abspath $(SYNTH_DIR)/../../..)

MKDV_OPENLANE_DESTDIR = $(CLUSTERV_SOC_DIR)

MKDV_TOOL ?= openlane
TOP_MODULE = clusterv_periph_subsys

include $(SYNTH_DIR)/../common/defs_rules.mk
include $(CLUSTERV_SOC_DIR)/verilog/rtl/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

