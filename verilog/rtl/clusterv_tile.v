/****************************************************************************
 * clusterv_tile.v
 ****************************************************************************/
`ifndef INTERFACE_MACROS_INCLUDED
`include "wishbone_tag_macros.svh"
`include "sky130_openram_macros.svh"
`endif /* INTERFACE_MACROS_INCLUDED */

/**
 * Module: clusterv_tile
 * 
 * TODO: Add module documentation
 */
module clusterv_tile #(
		parameter HARTID=32'h8000_0000
		) (
`ifdef UNDEFINED
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
`endif
		input			clock,
		input			reset,
		input			sys_reset,
		input			cfg_sclk,
		input			cfg_sdi,
		output			cfg_sdo,
		`WB_TAG_INITIATOR_PORT(i_, 32, 32, 1, 1, 4),
		`SKY130_OPENRAM_RW_INITIATOR_PORT(sram_, 8, 32),
		input			irq
		);
	
	// Configuration registers
	reg[31:0]			resvec;
	reg[31:0]			hartid;
	
	assign cfg_sdo = hartid[0];
	
	always @(posedge cfg_sclk or posedge sys_reset) begin
		if (sys_reset) begin
			resvec <= 32'h80000000;
			hartid <= HARTID;
		end else begin
			hartid <= {resvec[0], hartid[31:1]};
			resvec <= {cfg_sdi, resvec[31:1]};
		end
	end
	
	
	`WB_TAG_WIRES(core2ic_, 32, 32, 1, 1, 4);
	`WB_TAG_WIRES(ic2sram_, 32, 32, 1, 1, 4);
	
	fwrisc_rv32imca_wb #(
			.USE_FIXED_HARTID(0),
			.USE_FIXED_RESVEC(0)
		) u_core (
		.clock     (clock    ), 
		.reset     (reset    ), 
		.hartid    (hartid   ),
		.resvec    (resvec   ),
		`WB_TAG_CONNECT( , core2ic_),
		.irq       (irq      ));

	wb_interconnect_tag_1xN_pt #(
		.ADR_WIDTH   (32  ), 
		.DAT_WIDTH   (32  ), 
		.TGA_WIDTH   (1  ), 
		.TGD_WIDTH   (1  ), 
		.TGC_WIDTH   (4  ), 
		.N_TARGETS   (1  ), 
		.T_ADR_MASK  ({
				32'hFFFF0000
			}), 
		.T_ADR       ({
				32'h20000000
			})
		) u_tile_ic (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`WB_TAG_CONNECT(t_, core2ic_),
		`WB_TAG_CONNECT(i_, ic2sram_),
		`WB_TAG_CONNECT(pt_, i_)
		);
	
	reg wb_state;
	assign ic2sram_ack = (wb_state == 1);
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			wb_state <= 1'b0;
		end else begin
			case (wb_state)
				0: begin
					if (ic2sram_cyc && ic2sram_stb) begin
						wb_state <= 1;
					end
				end
				1: begin
					wb_state <= 0;
				end
			endcase
		end
	end
	
//	`SKY130_OPENRAM_RW_WIRES(sram_, 8, 32);
	
	assign sram_csb        = ~(ic2sram_cyc && ic2sram_stb);
	assign sram_web        = ~(ic2sram_cyc && ic2sram_stb && ic2sram_we);
	assign sram_wmask      = ic2sram_sel; 
	assign sram_addr       = ic2sram_adr[9:2];
	assign sram_dat_w      = ic2sram_dat_w;
	assign ic2sram_dat_r   = sram_dat_r;
	
//	// Register RAM for now
//	reg[31:0]				ram[63:0];
//
//	reg[5:0]		addr_r;
//	always @(posedge clock) begin
//		addr_r <= ic2sram_adr[9:2];
//		
//		if (!sram_csb & !sram_web) begin
//			if (sram_wmask[3]) begin
//				ram[ic2sram_adr[7:2]][31:24] <= sram_dat_w[31:24];
//			end
//			if (sram_wmask[2]) begin
//				ram[ic2sram_adr[7:2]][23:16] <= sram_dat_w[23:16];
//			end
//			if (sram_wmask[1]) begin
//				ram[ic2sram_adr[7:2]][15:8] <= sram_dat_w[15:8];
//			end
//			if (sram_wmask[0]) begin
//				ram[ic2sram_adr[7:2]][7:0] <= sram_dat_w[7:0];
//			end
//		end
//	end
//	
//	assign sram_dat_r = ram[addr_r];
	
endmodule


