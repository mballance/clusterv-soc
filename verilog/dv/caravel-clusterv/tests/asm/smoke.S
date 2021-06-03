
.section .flash_bootstrap, "ax"

init_copy_loop:
	la x1, _ld_ram_bootstrap
	la x2, _ram_bootstrap
	la x3, _etext

.section .ram_bootstrap, "ax"
	la x1, _ldtext
	la x2, _text

.section .text

start:


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

	// x1 has the storage address
	// x3 has the load address
1:
	lw x5, 0(x1)
	sw x5, 0(x3)
	beq x3, x4, 2f
	addi x1, x1, 4
	addi x3, x3, 4
	j 1b
2:

	// Now, jump to sram. Here, again, we need to
	// offset the address to compensate for the difference
	// in load address
	la x2, copy_loop
	li x3, 0x10000000
	sub x2, x2, x3
	jr x2

copy_loop:
	// Copy from flash to sram
	la x1, _ldtext
	la x2, _text
	la x3, _etext
1:
	lw x4, 0(x1)
	sw x4, 0(x2)
	beq x2, x3, 2f
	addi x1, x1, 4
	addi x2, x2, 4
2:
	// Done copying
e_copy_loop:

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


