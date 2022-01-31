/****************************************************************************
 * clusterv_tile_sram_wrapper.v
 ****************************************************************************/
`include "generic_sram_byte_en_macros.svh"

  
/**
 * Module: clusterv_tile_sram_wrapper
 * 
 * TODO: Add module documentation
 */
module clusterv_tile_sram_wrapper(
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

	reg[31:0]			ram[5:0];
	reg[5:0]			addr_r;
		
	assign t_read_data = ram[addr_r];
		
	always @(posedge clock) begin
		addr_r <= t_addr[7:2];
		
		if (t_write_en) begin
			if (t_byte_en[0]) begin
				ram[t_addr[7:2]][7:0] <= t_write_data[7:0];
			end
			if (t_byte_en[1]) begin
				ram[t_addr[7:2]][15:8] <= t_write_data[15:8];
			end
			if (t_byte_en[2]) begin
				ram[t_addr[7:2]][23:16] <= t_write_data[23:16];
			end
			if (t_byte_en[3]) begin
				ram[t_addr[7:2]][31:24] <= t_write_data[31:24];
			end
		end
	end
	
`ifdef CLUSTERV_TILE_SRAM_WRAPPER_MODULE
`else
	initial begin
		$display("Error: %m no implementation defined for clusterv_tile_sram_wrapper");
		$finish;
	end
`endif

endmodule


