/****************************************************************************
 * clusterv_main_sram_sky130_openram.v
 ****************************************************************************/
`include "generic_sram_byte_en_macros.svh"
  
/**
 * Module: cluster_main_sram_sky130_openram
 * 
 * TODO: Add module documentation
 */
module clusterv_main_sram_sky130_openram(
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
		`GENERIC_SRAM_BYTE_EN_TARGET_PORT(t_, 10, 32)
		);

`ifdef UNDEFINED
	sky130_sram_2kbyte_1rw1r_32x512_8 #(
			.VERBOSE(0)
		) u_main_sram(
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
			.dout0(t_read_data),
			// Port 1: R
			.clk1(1'b0),
			.csb1(1'b1),
			.addr1(8'h0)
		);	
`else
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
`endif

endmodule


