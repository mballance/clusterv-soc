/****************************************************************************
 * clusterv_mem_ctrl_2k.v
 ****************************************************************************/
`ifndef INCLUDED_INTERFACE_MACROS
`include "wishbone_tag_macros.svh"
`include "generic_sram_byte_en_macros.svh"
`include "sky130_openram_macros.svh"
`endif

  
/**
 * Module: clusterv_mem_ctrl_8k
 * 
 * TODO: Add module documentation
 */
module clusterv_mem_ctrl_8k(
`ifdef USE_POWER_PINS
		inout vdda1,	// User area 1 3.3V supply
		inout vdda2,	// User area 2 3.3V supply
		inout vssa1,	// User area 1 analog ground
		inout vssa2,	// User area 2 analog ground
		inout vccd1,	// User area 1 1.8V supply
		inout vccd2,	// User area 2 1.8v supply
		inout vssd1,	// User area 1 digital ground
		inout vssd2,	// User area 2 digital ground
`endif
		input				clock,
		input				reset,
		`WB_TAG_TARGET_PORT(t_, 32, 32, 1, 1, 4),
		`SKY130_OPENRAM_RW_INITIATOR_PORT(sram0_, 11, 32),
		output				sram1_csb,
		input[31:0]			sram1_dat_r,
		output				sram2_csb,
		input[31:0]			sram2_dat_r,
		output				sram3_csb,
		input[31:0]			sram3_dat_r);

	`GENERIC_SRAM_BYTE_EN_WIRES(ctrl2sram_, 13, 32);

	assign sram0_addr = ctrl2sram_addr;
	assign sram0_dat_w = ctrl2sram_write_data;
	assign sram0_web = ~ctrl2sram_write_en;
	assign sram0_wmask = ctrl2sram_byte_en;

	assign sram0_csb = ~(ctrl2sram_addr[13:12] == 2'b00);
	assign sram1_csb = ~(ctrl2sram_addr[13:12] == 2'b01);
	assign sram2_csb = ~(ctrl2sram_addr[13:12] == 2'b10);
	assign sram3_csb = ~(ctrl2sram_addr[13:12] == 2'b11);
	
	assign ctrl2sram_read_data = 
		(ctrl2sram_addr[14:10] == 2'b00)?sram0_dat_r:
		(ctrl2sram_addr[14:10] == 2'b01)?sram1_dat_r:
		(ctrl2sram_addr[14:10] == 2'b10)?sram2_dat_r:sram3_dat_r;
	
	fw_wishbone_sram_ctrl_single #(
		.ADR_WIDTH     (12    ), 
		.DAT_WIDTH     (32    )
		) u_mem_ctrl (
		.clock         (clock        ), 
		.reset         (reset        ), 
		`WB_TAG_CONNECT(t_, t_),
		`GENERIC_SRAM_BYTE_EN_CONNECT(i_, ctrl2sram_));

endmodule


