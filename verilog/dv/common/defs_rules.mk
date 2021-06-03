
CLUSTERV_SOC_DV_COMMONDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CLUSTERV_SOC_DIR := $(abspath $(CLUSTERV_SOC_DV_COMMONDIR)/../../..)
PACKAGES_DIR := $(CLUSTERV_SOC_DIR)/packages

DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)


ifneq (1,$(RULES))

MKDV_PYTHONPATH += $(CLUSTERV_SOC_DV_COMMONDIR)/python

include $(CLUSTERV_SOC_DIR)/verilog/rtl/defs_rules.mk
include $(DV_MK)
else # Rules
include $(DV_MK)

endif

