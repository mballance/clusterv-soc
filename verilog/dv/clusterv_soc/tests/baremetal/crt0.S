
#ifdef BOOT_FLASH
.section .flash_bootstrap, "ax"

rom_boot:
	// Initialize the trap handler for all cores on boot
	la t0, trap_handler
	csrw mtvec, t0

	// Determine which core we are and proceed accordingly
	csrr t2, mhartid

	beqz	t2, init_copy_loop

	// If we're a non-primary core, just wfi in flash
	// space until core0 wakes us up
non_primary_wfi:
	wfi
	j	non_primary_wfi

init_copy_loop:
	la t0, _ld_ram_bootstrap
	la t1, _ram_bootstrap
	la t2, _e_ram_bootstrap

	// x1 has the storage address
	// x3 has the load address
1:
	lw t3, 0(t0)
	sw t3, 0(t1)
	beq t1, t2, 2f
	addi t0, t0, 4
	addi t1, t1, 4
	j 1b
2:

	// Now, need to jump to RAM location
	la t1, copy_loop
	jr t1

.section .ram_bootstrap, "ax"
	la x1, _ldtext
	la x2, _text

copy_loop:
	// Copy from flash to sram
	la t0, _ldtext
	la t1, _text
	la t2, _etext
1:
	lw t3, 0(t0)
	sw t3, 0(t1)
	beq t1, t2, 2f
	addi t0, t0, 4
	addi t1, t1, 4
	j	1b
2:
	// Done copying
e_copy_loop:
	// Now, jump to the actual boot code
	j	start
#endif /* BOOT_FLASH */


#ifdef UNDEFINED
#ifdef BOOT_FLASH
	// First, copy just the copy loop to sram
	// Note: this loop is actually running from ROM,
	// so the la addresses will be offset by an
	// additional 0x10000000.
	la x1, _ldtext
	la x2, _text

	// Determine the actual src/dest addresses
	// Note: this is just for the copy loop
	la x3, copy_loop
	sub x4, x3, x2 // Offset of copy_loop
	add x1, x1, x4 // source address with extra 0x10000000 offset

	la x4, e_copy_loop //
	li x5, 0x10000000
	sub x1, x1, x5
	sub x3, x3, x5
	sub x4, x4, x5

	// Now, jump to sram. Here, again, we need to
	// offset the address to compensate for the difference
	// in load address
	la x2, copy_loop
	li x3, 0x10000000
	sub x2, x2, x3
	jr x2


#endif /* FLASH_BOOT */
#endif

// Beginning of real boot code, which is run from RAM
.section .text
start:
// zero-initialize register file
	mv x1, zero
	mv x2, zero
	mv x3, zero
	mv x4, zero
	mv x5, zero
	mv x6, zero
	mv x7, zero
	mv x8, zero
	mv x9, zero
	mv x10, zero
	mv x11, zero
	mv x12, zero
	mv x13, zero
	mv x14, zero
	mv x15, zero
	mv x16, zero
	mv x17, zero
	mv x18, zero
	mv x19, zero
	mv x20, zero
	mv x21, zero
	mv x22, zero
	mv x23, zero
	mv x24, zero
	mv x25, zero
	mv x26, zero
	mv x27, zero
	mv x28, zero
	mv x29, zero
	mv x30, zero
	mv x31, zero


1:
	addi x1, x1, 1
	j	1b
	nop
	nop
	nop
	nop

trap_handler:
	j	trap_handler

