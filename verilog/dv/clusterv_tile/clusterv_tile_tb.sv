/****************************************************************************
 * clusterv_tile_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ps
`endif

`include "wishbone_tag_macros.svh"
  
/**
 * Module: clusterv_tile_tb
 * 
 * TODO: Add module documentation
 */
module clusterv_tile_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r;
`ifdef NEED_TIMESCALE
	always #10 clock_r <= (clock_r === 1'b0);
`else
	always #10ns clock_r <= (clock_r === 1'b0);
`endif
	assign clock = clock_r;
`endif
	
	reg reset = 0;
	reg[7:0] reset_cnt = 0;
	
	always @(posedge clock) begin
		if (reset_cnt == 20) begin
			reset <= 0;
		end else begin
			if (reset_cnt == 1) begin
				reset <= 1;
			end
			reset_cnt <= reset_cnt + 1;
		end
	end

	`WB_TAG_WIRES(core2sram_, 32, 32, 1, 1, 4);
	clusterv_tile u_dut (
		.clock    (clock         ), 
		.reset    (reset         ), 
		.hartid   (32'h0         ), 
		.resvec   (32'h10000000  ), 
		`WB_TAG_CONNECT(i_, core2sram_),
		.irq      (irq           ));

	reg wb_state;
	assign core2sram_ack = (wb_state == 1);
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			wb_state <= 0;
		end else begin
			case (wb_state)
				0: begin
					if (core2sram_cyc && core2sram_stb) begin
						wb_state <= 1;
					end
				end
				1: begin
					wb_state <= 0;
				end
			endcase
		end
	end


endmodule


