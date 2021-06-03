/****************************************************************************
 * clusterv_tile.v
 ****************************************************************************/
`include "wishbone_tag_macros.svh"
`include "sky130_openram_macros.svh"

/**
 * Module: clusterv_tile
 * 
 * TODO: Add module documentation
 */
module clusterv_tile(
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
		
		input			clock,
		input			reset,
		input[31:0]		hartid,
		input[31:0]     resvec,
		`WB_TAG_INITIATOR_PORT(i_, 32, 32, 1, 1, 4),
		`SKY130_OPENRAM_RW_INITIATOR_PORT(sram_, 8, 32),
		input			irq
		);
	
	`WB_TAG_WIRES(core2ic_, 32, 32, 1, 1, 4);
	`WB_TAG_WIRES(ic2sram_, 32, 32, 1, 1, 4);
	
	fwrisc_rv32imca_wb u_core (
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
	
	assign sram_csb = ~(ic2sram_cyc && ic2sram_stb);
	assign sram_web = ~ic2sram_we;
	assign sram_wmask = ic2sram_sel; // TODO: pos or neg edge?
	assign sram_addr = ic2sram_adr[9:2];
	assign sram_dat_w = ic2sram_dat_w;
	assign ic2sram_dat_r = sram_dat_r;
	
endmodule


