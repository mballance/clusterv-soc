
MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
CLUSTERV_SOC_DIR := $(abspath $(TEST_DIR)/../../..)
MKDV_TOOL ?= icarus
CLUSTERV_SOC_SRAM ?= bfm

MKDV_PLUGINS += cocotb pybfms
PYBFMS_MODULES += riscv_debug_bfms spi_bfms generic_sram_bfms
PYBFMS_MODULES += wishbone_bfms gpio_bfms
MKDV_COCOTB_MODULE ?= clusterv_soc_tests.clusterv_soc_test_base

TOP_MODULE = clusterv_soc_tb

MKDV_VL_SRCS += $(wildcard $(TEST_DIR)/*.sv)
MKDV_VL_DEFINES += SIM FUNCTIONAL
VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal

VLOG_OPTIONS += -suppress 2892

#SW_IMAGE ?= asm/smoke.elf

#MKDV_RUN_DEPS += $(SW_IMAGE)
#MKDV_RUN_ARGS += +sw.image=$(SW_IMAGE)

include $(TEST_DIR)/../common/defs_rules.mk

RULES := 1
include $(TEST_DIR)/../common/defs_rules.mk

asm/%.elf : 
	$(MAKE) -f $(TEST_DIR)/tests/asm/asm.mk $@

