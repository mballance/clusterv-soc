/****************************************************************************
 * clusterv_tile_sram_wrapper.v
 ****************************************************************************/
`include "sky130_openram_macros.svh"
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
		`SKY130_OPENRAM_RW_TARGET_PORT(t_, 8, 32)
		);

`ifdef UNDEFINED
	sky130_sram_1kbyte_1rw1r_32x256_8 #(
			.VERBOSE(0)
		) u_sram(
			`ifdef USE_POWER_PINS
				.vccd1(vccd1),
				.vssd1(vssd1),
			`endif
			// Port 0: RW
			.clk0(clock),
			.csb0(t_csb),
			.web0(t_web),
			.wmask0(t_wmask),
			.addr0(t_addr),
			.din0(t_dat_w),
			.dout0(t_dat_r),
			// Port 1: R
			.clk1(1'b0),
			.csb1(1'b1),
			.addr1(8'h0)
		);	
`else
		localparam RAM_BITS = 8;
		reg[31:0]			ram[RAM_BITS-1:0];
		reg[5:0]			addr_r;
		
		assign t_dat_r = ram[addr_r];
		
		always @(posedge clock) begin
			addr_r <= t_addr[RAM_BITS-1:0];
		
			if (!t_csb && !t_web) begin
				if (t_wmask[0]) begin
					ram[t_addr[RAM_BITS-1:0]][7:0] <= t_dat_w[7:0];
				end
				if (t_wmask[1]) begin
					ram[t_addr[RAM_BITS-1:0]][15:8] <= t_dat_w[15:8];
				end
				if (t_wmask[2]) begin
					ram[t_addr[RAM_BITS-1:0]][23:16] <= t_dat_w[23:16];
				end
				if (t_wmask[3]) begin
					ram[t_addr[RAM_BITS-1:0]][31:24] <= t_dat_w[31:24];
				end
			end
		end	
`endif

endmodule


