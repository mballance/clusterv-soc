TEST_BAREMETAL_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

CC=riscv64-zephyr-elf-gcc
AS=$(CC)
LD=riscv64-zephyr-elf-ld

LDFLAGS += -b elf32-littleriscv


CFLAGS += -march=rv32i

ifeq (flash,$(BOOT))
CFLAGS += -DBOOT_FLASH
ASFLAGS += -DBOOT_FLASH
endif

vpath %.c $(TEST_BAREMETAL_DIR)
vpath %.S $(TEST_BAREMETAL_DIR)

baremetal/%.elf : %.o crt0.o baremetal.ld
	mkdir -p `dirname $@`
	$(CC) -o $@ $(CFLAGS) $(filter-out %.ld,$^) \
		-static -mcmodel=medany -nostartfiles \
		-T$(filter %.ld,$^)

baremetal.ld : $(TEST_BAREMETAL_DIR)/baremetal.ld.pp
	$(CC) -x c $(CFLAGS) -E $^ -o - | grep -v '^#' > $@

