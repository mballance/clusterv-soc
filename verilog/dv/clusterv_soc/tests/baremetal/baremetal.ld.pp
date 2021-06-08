/*
# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
*/

MEMORY {
#ifdef BOOT_FLASH
	// Boot from Flash and run from RAM
	FLASH (rx)	: ORIGIN = 0x10000000, LENGTH = 0x400000 	/* 4MB */
	RAM(xrw)	: ORIGIN = 0x80000060, LENGTH = 0x04000		/* 16KB */
#define CODELOC >RAM AT>FLASH
#else
	RAM(xrw)	: ORIGIN = 0x80000000, LENGTH = 0x04000		/* 16KB */
#define CODELOC >RAM
#endif
}

SECTIONS {

#ifdef BOOT_FLASH
	/* The program code and other data goes into FLASH */
	/* The bootstrap section gets the main copy loop 
	 * into RAM where it can work more efficiently
	 */
	.flash_bootstrap :
	{
		. = ALIGN(4);
		*(.flash_bootstrap)
	} >FLASH
	
	.ram_bootstrap :
	{
		. = ALIGN(4);
		_ram_bootstrap = .;
		_ld_ram_bootstrap = LOADADDR(.ram_bootstrap);
		*(.ram_bootstrap)
		_e_ram_bootstrap = .;
	} >RAM AT>FLASH
#endif /* BOOT_FLASH */
	
	.text :
	{
		. = ALIGN(4);
		_text = .;
		_ldtext = LOADADDR(.text);
		*(.text)	/* .text sections (code) */
		*(.text*)	/* .text* sections (code) */
		*(.rodata)	/* .rodata sections (constants, strings, etc.) */
		*(.rodata*)	/* .rodata* sections (constants, strings, etc.) */
		*(.srodata)	/* .srodata sections (constants, strings, etc.) */
		*(.srodata*)	/* .srodata*sections (constants, strings, etc.) */
		. = ALIGN(4);
		_etext = .;		/* define a global symbol at end of code */
		_sidata = _etext;	/* This is used by the startup to initialize data */
		_eldtext = LOADADDR(.text) + SIZEOF(.text);
	} CODELOC

	/* Initialized data section */
	.data : AT ( _sidata )
	{
		. = ALIGN(4);
		_sdata = .;
		_ram_start = .;
		. = ALIGN(4);
		*(.data)
		*(.data*)
		*(.sdata)
		*(.sdata*)
		. = ALIGN(4);
		_edata = .;
	} >RAM

	/* Uninitialized data section */
	.bss :
	{
		. = ALIGN(4);
		_sbss = .;
		*(.bss)
		*(.bss*)
		*(.sbss)
		*(.sbss*)
		*(COMMON)

		. = ALIGN(4);
		_ebss = .;
	} >RAM

	/* Define the start of the heap */
	.heap :
	{
		. = ALIGN(4);
		_heap_start = .;
	} >RAM
}
