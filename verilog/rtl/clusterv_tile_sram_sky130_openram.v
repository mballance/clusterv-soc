/****************************************************************************
 * clusterv_tile_sram_wrapper.v
 ****************************************************************************/
`include "generic_sram_byte_en_macros.svh"

  
/**
 * Module: clusterv_tile_sram_wrapper
 * 
 * TODO: Add module documentation
 */
module clusterv_tile_sram_sky130_openram(
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
		`GENERIC_SRAM_BYTE_EN_TARGET_PORT(t_, 8, 32)
		);
	
	sky130_sram_1kbyte_1rw1r_32x256_8 u_main_sram(
			`ifdef USE_POWER_PINS
				.vccd1(vccd1),
				.vssd1(vssd1),
			`endif
			// Port 0: RW
			.clk0(clock),
			.csb0(~(t_read_en|t_write_en)),
			.web0(~t_write_en),
			.wmask0(t_byte_en),
			.addr0(t_addr),
			.din0(t_write_data),
			.dout0(tile2sram_dat_r[32*tile_i+:32]),
			// Port 1: R
			.clk1(1'b0),
			.csb1(1'b1),
			.addr1(8'h0)
		);	

endmodule


