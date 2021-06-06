TEST_ASM_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

CC=riscv64-zephyr-elf-gcc
AS=$(CC)

CFLAGS += -march=rv32i


asm/%.elf : $(TEST_ASM_DIR)/%.S baremetal.ld
	mkdir -p `dirname $@`
	$(CC) -o $@ $(CFLAGS) $(filter-out %.ld,$^) \
		-static -mcmodel=medany -nostartfiles \
		-T$(filter %.ld,$^)

baremetal.ld : $(TEST_ASM_DIR)/baremetal.ld.pp
	$(CC) -x c $(CFLAGS) -E $^ -o - | grep -v '^#' > $@

