/****************************************************************************
 * clusterv_tile_sram_bfm.v
 ****************************************************************************/
`include "generic_sram_byte_en_macros.svh"
  
/**
 * Module: clusterv_tile_sram_bfm
 * 
 * TODO: Add module documentation
 */
module clusterv_tile_sram_bfm(
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

	generic_sram_byte_en_target_bfm #(
		.DAT_WIDTH  (32 ), 
		.ADR_WIDTH  (8  )
		) u_sram (
		.clock      (clock        ), 
		.adr        (t_addr       ), 
		.we         (t_write_en   ), 
		.sel        (t_byte_en    ), 
		.dat_r      (t_read_data  ), 
		.dat_w      (t_write_data ));

endmodule


