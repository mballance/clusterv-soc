#****************************************************************************
#* mkdv.mk
#*
#* Test-execution Makefile for clusterv_soc tests
#****************************************************************************
MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
CLUSTERV_SOC_DIR := $(abspath $(TEST_DIR)/../../..)
MKDV_TOOL ?= icarus
MKDV_TIMEOUT ?= 4ms
CLUSTERV_SOC_SRAM ?= openram
#BOOT ?= flash
BOOT ?= ram

MKDV_PLUGINS += cocotb pybfms
PYBFMS_MODULES += riscv_debug_bfms spi_bfms generic_sram_bfms
PYBFMS_MODULES += wishbone_bfms gpio_bfms
MKDV_COCOTB_MODULE ?= clusterv_soc_tests.clusterv_soc_test_base

TOP_MODULE = clusterv_soc_tb

MKDV_VL_SRCS += $(wildcard $(TEST_DIR)/*.sv)
MKDV_VL_DEFINES += SIM FUNCTIONAL

# Verilator-specific options
VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal

# Questa-specific options
VLOG_OPTIONS += -suppress 2892

SW_IMAGE ?= baremetal/smoke.elf

ifneq (,$(SW_IMAGE))
MKDV_RUN_DEPS += $(SW_IMAGE)
MKDV_RUN_ARGS += +sw.image=$(SW_IMAGE)
endif

MKDV_RUN_ARGS += +boot=$(BOOT)


#SW_IMAGE ?= asm/smoke.elf

#MKDV_RUN_DEPS += $(SW_IMAGE)
#MKDV_RUN_ARGS += +sw.image=$(SW_IMAGE)

include $(TEST_DIR)/../common/defs_rules.mk

RULES := 1
include $(TEST_DIR)/../common/defs_rules.mk

asm/%.elf : 
	$(MAKE) -f $(TEST_DIR)/tests/asm/asm.mk $@
	
baremetal/%.elf :
	$(MAKE) BOOT=$(BOOT) -f $(TEST_DIR)/tests/baremetal/baremetal.mk $@
	

