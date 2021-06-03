TEST_ASM_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

CC=riscv64-zephyr-elf-gcc
AS=$(CC)

CFLAGS += -march=rv32i


asm/%.elf : $(TEST_ASM_DIR)/%.S
	mkdir -p `dirname $@`
	$(CC) -o $@ $(CFLAGS) $^  \
		-static -mcmodel=medany -nostartfiles \
		-T$(TEST_ASM_DIR)/asm.ld

