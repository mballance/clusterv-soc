/****************************************************************************
 * clusterv_caravel_top.v
 ****************************************************************************/
 
`ifndef INTERFACE_MACROS_INCLUDED
`include "wishbone_tag_macros.svh"
`include "sky130_openram_macros.svh"
`endif

`ifndef MPRJ_IO_PADS
	`define MPRJ_IO_PADS_1 19	/* number of user GPIO pads on user1 side */
	`define MPRJ_IO_PADS_2 19	/* number of user GPIO pads on user2 side */
	`define MPRJ_IO_PADS (`MPRJ_IO_PADS_1 + `MPRJ_IO_PADS_2)
`endif

/**
 * Module: clusterv_caravel_top
 * 
 * TODO: Add module documentation
 */
module clusterv_caravel_top(
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

		// Wishbone Slave ports (WB MI A)
		input wb_clk_i,
		input wb_rst_i,
		input wbs_stb_i,
		input wbs_cyc_i,
		input wbs_we_i,
		input [3:0] wbs_sel_i,
		input [31:0] wbs_dat_i,
		input [31:0] wbs_adr_i,
		output wbs_ack_o,
		output [31:0] wbs_dat_o,

		// Logic Analyzer Signals
		input  [127:0] la_data_in,
		output [127:0] la_data_out,
		input  [127:0] la_oenb,

		// IOs
		input  [`MPRJ_IO_PADS-1:0] io_in,
		output [`MPRJ_IO_PADS-1:0] io_out,
		output [`MPRJ_IO_PADS-1:0] io_oeb,

		// IRQ
		output [2:0] irq		
		);

	reg[31:0]		count;
	
	reg state;
	assign wbs_ack_o = (wbs_cyc_i && wbs_stb_i && state == 1);
	reg csb;
	
	always @(posedge wb_clk_i or posedge wb_rst_i) begin
		if (wb_rst_i) begin
			state <= 0;
			csb <= 1;
			count <= 0;
		end else begin
			case (state)
				0: begin
					if (wbs_cyc_i && wbs_stb_i) begin
						state <= 1;
						csb <= 0;
					end
				end
				1: begin
					state <= 0;
					csb <= 1;
				end
			endcase
			count <= count + 1;
		end
	end

	/*
	assign la_data_out[31:0] = count;
			

	assign la_data_out[127:32] = {128{1'b0}};
	 */

`ifdef UNDEFINED
`endif
	`WB_TAG_WIRES(init2it_, 32, 32, 1, 1, 4);
	wire[31:0]			hartid = 32'h0;
	wire[31:0]			resvec = 32'h10000000;
	
	assign init2it_ack = (init2it_cyc & init2it_stb);
	assign init2it_dat_r = count;
	assign la_data_out = init2it_dat_w;
	clusterv_tile u_tile (
			`ifdef USE_POWER_PINS
				.vdda1(vdda1),	// User area 1 3.3V supply
				.vdda2(vdda2),	// User area 2 3.3V supply
				.vssa1(vssa1),	// User area 1 analog ground
				.vssa2(vssa2),	// User area 2 analog ground
				.vccd1(vccd1),	// User area 1 1.8V supply
				.vccd2(vccd2),	// User area 2 1.8v supply
				.vssd1(vssd1),	// User area 1 digital ground
				.vssd2(vssd2),	// User area 2 digital ground
			`endif			
			.clock       (wb_clk_i    ), 
			.reset       (wb_rst_i    ), 
			.hartid      (hartid        ), 
			.resvec      (resvec        ),
			`WB_TAG_CONNECT(i_, init2it_)
			);
//			`WB_TAG_CONNECT_ARR(i_, init2ic_, tile_i, 32, 32, 1, 1, 4),
//			`SKY130_OPENRAM_RW_CONNECT_ARR(sram_, tile2sram_, tile_i, 8, 32),
//			/*.irq         (irq[tile_i]   )*/);

`ifdef UNDEFINED
	sky130_sram_1kbyte_1rw1r_32x256_8 /*#(
			.VERBOSE(0)
		)*/ u_sram(
			`ifdef USE_POWER_PINS
				.vccd1(vccd1),
				.vssd1(vssd1),
			`endif
			// Port 0: RW
			.clk0(wb_clk_i),
			.csb0(csb),
			.web0(~wbs_we_i),
			.wmask0(wbs_sel_i),
			.addr0(wbs_adr_i),
			.din0(count),
			.dout0(wbs_dat_o)/*,
			// Port 1: R
			.clk1(1'b0),
			.csb1(1'b1),
			.addr1(8'h0) */
		);		
`endif

	// TODO: want to control this?
	assign irq = {3{1'b0}};

endmodule


