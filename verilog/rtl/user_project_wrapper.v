// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */
 
`undef INCLUDE_SRAM

`ifndef INCLUDED_INTERFACE_MACROS
`include "verilog/rtl/defines.v"
`include "wishbone_tag_macros.svh"
`include "wishbone_macros.svh"
`include "sky130_openram_macros.svh"
`endif /* INCLUDED_INTERFACE_MACROS */
 
`ifndef MPRJ_IO_PADS
`define MPRJ_IO_PADS_1 19	/* number of user GPIO pads on user1 side */
`define MPRJ_IO_PADS_2 19	/* number of user GPIO pads on user2 side */
`define MPRJ_IO_PADS (`MPRJ_IO_PADS_1 + `MPRJ_IO_PADS_2)
`endif

module user_project_wrapper #(
    parameter BITS = 32
)(
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

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

	/****************************************************************
	 * Sys Interconnect
	 ****************************************************************/
	localparam INIT_IDX_TILE0 = 0;
	localparam INIT_IDX_TILE1 = (INIT_IDX_TILE0+1);
	localparam INIT_IDX_TILE2 = (INIT_IDX_TILE1+1);
	localparam INIT_IDX_TILE3 = (INIT_IDX_TILE2+1);
	localparam INIT_IDX_DMA   = (INIT_IDX_TILE3+1);
	localparam INIT_IDX_MGMT  = (INIT_IDX_DMA+1);
	localparam NUM_INIT        = (INIT_IDX_MGMT+1);
	localparam TARG_IDX_2K     = 0;
	localparam TARG_IDX_4K     = (TARG_IDX_2K+1);
	localparam TARG_IDX_8K     = (TARG_IDX_4K+1);
	localparam TARG_IDX_PERIPH = (TARG_IDX_8K+1);
	localparam NUM_TARG        = (TARG_IDX_PERIPH+1);
	
	localparam N_TILES = 4;
	
	`WB_WIRES(dma2ic_, 32, 32);
	`WB_WIRES(ic2periph_, 32, 32);
	`WB_TAG_WIRES_ARR(tiles2ic_, 32, 32, 1, 1, 4, N_TILES);
	
//	`SKY130_OPENRAM_RW_WIRES_ARR(tile2sram_, 8, 32, N_TILES);
	wire[4:0]							cfg_sdi;
	wire[N_TILES-1:0]					tile_irq;
	wire								sys_clock = wb_clk_i;
	wire								core_reset = wb_rst_i;
	wire								sys_reset = wb_rst_i;
	
	assign cfg_sdi[0] = io_in[0];
	wire   cfg_sclk   = io_in[1];
	// Have all outputs tied
//	assign io_out[0]  = cfg_sdi[4];
	assign tile_irq   = io_in[5:2];
	generate
		genvar tile_i;
		for (tile_i=0; tile_i<N_TILES; tile_i=tile_i+1) begin : tiles
				clusterv_tile u_tile (
`ifdef UNDEFINED
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
`endif
					.clock       (sys_clock                  ), 
					.reset       (core_reset                 ), 
					.sys_reset   (core_reset                 ), 
					.cfg_sclk    (cfg_sclk                   ),
					.cfg_sdi     (cfg_sdi[tile_i]            ),
					.cfg_sdo     (cfg_sdi[tile_i+1]          ),
					`WB_TAG_CONNECT_ARR(i_, tiles2ic_, tile_i, 32, 32, 1, 1, 4),
//					`SKY130_OPENRAM_RW_CONNECT_ARR(sram_, tile2sram_, tile_i, 8, 32),
					.irq         (tile_irq[tile_i]));
			
			`ifdef INCLUDE_SRAM
			sky130_sram_1kbyte_1rw1r_32x256_8 u_tile_sram0 (
				`ifdef USE_POWER_PINS
					.vccd1(vccd1),
					.vssd1(vssd1),
				`endif
				// Port 0: RW
				.clk0(sys_clock),
				.csb0(tile2sram_csb[0]),
				.web0(tile2sram_web[0]),
				.wmask0(tile2sram_wmask[4*0+:4]),
				.addr0(tile2sram_addr[8*0+:8]),
				.din0(tile2sram_dat_w[32*0+:32]),
				.dout0(tile2sram_dat_r[32*0+:32]),
				// Port 1: R
				.clk1(sys_clock),
				.csb1(tile2sram_csb[0]),
				.addr1(tile2sram_addr[8*0+:8]) 
			);
		`else
//			assign tile2sram_dat_r = {N_TILES*32{1'b0}};
		`endif
		end /* end generate for */
	endgenerate

	`WB_TAG_WIRES(ic2ext_, 32, 32, 1, 1, 4);
	wb_interconnect_tag_NxN #(
		.ADR_WIDTH   (32  ), 
		.DAT_WIDTH   (32  ), 
		.TGA_WIDTH   (1  ), 
		.TGD_WIDTH   (1  ), 
		.TGC_WIDTH   (4  ), 
		.N_INITIATORS(N_TILES),
		.N_TARGETS   (1  ), 
		.T_ADR_MASK  ({32'hFFFF0000} ), 
		.T_ADR       ({32'h80000000} )
		) u_ic (
		.clock       (sys_clock      ), 
		.reset       (core_reset      ), 

		`WB_TAG_CONNECT( , tiles2ic_),
		`WB_TAG_CONNECT(t, ic2ext_));

	assign la_data_out[31:0]  = ic2ext_adr;
	assign la_data_out[63:32] = ic2ext_dat_w;
	assign la_data_out[64] = ic2ext_cyc;
	assign la_data_out[68:65] = ic2ext_sel;
	assign la_data_out[69] = ic2ext_stb;
	assign la_data_out[70] = ic2ext_we;
	assign la_data_out[71] = ic2ext_tgd_w;
	assign la_data_out[72] = ic2ext_tga;
	assign la_data_out[76:73] = ic2ext_tgc;
	assign la_data_out[127:77] = 0;
	
	assign ic2ext_dat_r = la_data_in[31:0];
	assign ic2ext_err = la_data_in[32];
	assign ic2ext_ack = la_data_in[33];
	assign ic2ext_tgd_r = la_data_in[34];
	
	assign user_irq = {3{1'b0}};
	
	assign io_oeb = {`MPRJ_IO_PADS{1'b0}};
	assign io_out = {`MPRJ_IO_PADS{1'b0}};
	
`ifdef UNDEFINED
	assign la_data_out = {128{1'b0}};
	assign io_out = {`MPRJ_IO_PADS{1'b0}};
	assign io_oeb = {`MPRJ_IO_PADS{1'b0}};
	
	user_proj_inner u_inner (
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
			.wb_clk_i(wb_clk_i),
			.wb_rst_i(wb_rst_i),
			.wbs_stb_i(wbs_stb_i),
			.wbs_we_i(wbs_we_i),
			.wbs_sel_i(wbs_sel_i),
			.wbs_dat_i(wbs_dat_i),
			.wbs_adr_i(wbs_adr_i),
			.wbs_ack_o(wbs_ack_o),
			.wbs_dat_o(wbs_dat_o),
//			.la_data_in(la_data_in),
//			.la_data_out(la_data_out),
//			.la_oenb(la_oenb),
//			.io_in(io_in),
//			.io_out(io_out),
//			.io_oeb(io_oeb),
			.analog_io(analog_io),
			.user_clock2(user_clock2)
//			.user_irq(user_irq)
		);
`endif /* UNDEFINED */

	clusterv_periph_subsys u_periph_subsys (
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
			.mgmt_clock            (wb_clk_i              ), 
			.mgmt_reset            (wb_rst_i              ), 
			.mgmt_adr              (wbs_adr_i             ), 
			.mgmt_dat_w            (wbs_dat_i             ), 
			.mgmt_dat_r            (wbs_dat_o             ), 
			.mgmt_cyc              (wbs_cyc_i             ), 
			//		.mgmt_err              (mgmt_err             ), 
			.mgmt_sel              (wbs_sel_i             ), 
			.mgmt_stb              (wbs_stb_i             ), 
			.mgmt_ack              (wbs_ack_o             ), 
			.mgmt_we               (wbs_we_i              ),
			`WB_CONNECT(regs_, ic2periph_),
			`WB_CONNECT(dma_,  dma2ic_),
			.core_irq    (tile_irq       ), /* 
		.spi0_sck    (spi0_sck   ), 
		.spi0_sdo    (spi0_sdo   ), 
		.spi0_sdi    (spi0_sdi   ), 
		.spi1_sck    (spi1_sck   ), 
		.spi1_sdo    (spi1_sdo   ), 
		.spi1_sdi    (spi1_sdi   ), 
		.uart_tx     (uart_tx    ), 
		.uart_rx     (uart_rx    ) */
			.sys_clock             (sys_clock            ), 
			.sys_reset             (sys_reset            ), 
			.core_reset            (core_reset           ),
			.cfg_sclk              (cfg_sclk             ),
			.cfg_sdo               (cfg_sdi[0]           ),
			.cfg_sdi               (cfg_sdi[4]           ));	
	
endmodule	// user_project_wrapper
