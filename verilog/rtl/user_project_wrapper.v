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
	wire sys_clock;
	wire sys_reset;
	wire core_reset;
	wire[(32*4)-1:0]		hartid;
	wire[(32*4)-1:0]		resvec;
	
	/****************************************************************
	 * Sys Interconnect
	 ****************************************************************/
	localparam INIT_IDX_TILE0 = 0;
	localparam INIT_IDX_TILE1 = (INIT_IDX_TILE0+1);
	localparam INIT_IDX_TILE2 = (INIT_IDX_TILE1+1);
	localparam INIT_IDX_TILE3 = (INIT_IDX_TILE2+1);
	localparam INIT_IDX_DMA   = (INIT_IDX_TILE3+1);
	localparam INIT_IDX_MGMT  = (INIT_IDX_DMA+1);
	localparam NUM_INIT = (INIT_IDX_MGMT+1);
	localparam TARG_IDX_2K     = 0;
	localparam TARG_IDX_4K     = (TARG_IDX_2K+1);
	localparam TARG_IDX_8K     = (TARG_IDX_4K+1);
	localparam TARG_IDX_PERIPH = (TARG_IDX_8K+1);
	localparam NUM_TARG = (TARG_IDX_PERIPH+1);
	`WB_TAG_WIRES_ARR(i2ic_, 32, 32, 1, 1, 4, NUM_INIT);
	`WB_TAG_WIRES_ARR(ic2t_, 32, 32, 1, 1, 4, NUM_TARG);
	
	clusterv_sys_ic u_sys_ic (
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
		.clock    (sys_clock   ), 
		.reset    (sys_reset   ), 
		`WB_TAG_CONNECT(t_, i2ic_),
		`WB_TAG_CONNECT(i_, ic2t_));
	
	/****************************************************************
	 * TODO: 8k memories
	 ****************************************************************/
	`SKY130_OPENRAM_RW_WIRES_ARR(sram8k_, 11, 32, 4);
	clusterv_mem_ctrl_8k u_memc_8k (
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
		.clock        (sys_clock       ), 
		.reset        (sys_reset       ), 
		`WB_TAG_CONNECT_ARR(t_, ic2t_, TARG_IDX_8K, 32, 32, 1, 1, 4),
		`SKY130_OPENRAM_RW_CONNECT_ARR(sram0_, sram8k_, 0, 11, 32));
	
	generate
		genvar sram8k_i;
		for (sram8k_i=0; sram8k_i<4; sram8k_i=sram8k_i+1) begin : sram8k
		end
	endgenerate
	
	/****************************************************************
	 * TODO: 4k memories
	 ****************************************************************/
	`SKY130_OPENRAM_RW_WIRES_ARR(sram4k_, 10, 32, 4);
	clusterv_mem_ctrl_4k u_memc_4k (
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
			.clock        (sys_clock       ), 
			.reset        (sys_reset       ), 
			`WB_TAG_CONNECT_ARR(t_, ic2t_, TARG_IDX_4K, 32, 32, 1, 1, 4),
			`SKY130_OPENRAM_RW_CONNECT_ARR(sram0_, sram4k_, 0, 10, 32));
	
	generate
		genvar sram4k_i;
		for (sram4k_i=0; sram4k_i<4; sram4k_i=sram4k_i+1) begin : sram4k
		end
	endgenerate	
	
	/****************************************************************
	 * TODO: 2k memories
	 ****************************************************************/
	`SKY130_OPENRAM_RW_WIRES_ARR(sram2k_, 9, 32, 4);
	clusterv_mem_ctrl_2k u_memc_2k (
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
			.clock        (sys_clock       ), 
			.reset        (sys_reset       ), 
			`WB_TAG_CONNECT_ARR(t_, ic2t_, TARG_IDX_2K, 32, 32, 1, 1, 4),
			// Connect the common interface
			`SKY130_OPENRAM_RW_CONNECT_ARR(sram0_, sram2k_, 0, 10, 32),
			.sram1_csb(sram2k_csb[1]),
			.sram1_dat_r(sram2k_dat_r[(32*1)+:32]),
			.sram2_csb(sram2k_csb[2]),
			.sram2_dat_r(sram2k_dat_r[(32*2)+:32]),
			.sram3_csb(sram2k_csb[3]),
			.sram3_dat_r(sram2k_dat_r[(32*3)+:32])
			);
	
	generate
		genvar sram2k_i;
		for (sram2k_i=0; sram2k_i<4; sram2k_i=sram2k_i+1) begin : sram2k
			sky130_sram_2kbyte_1rw1r_32x512_8 u_sram(
					`ifdef USE_POWER_PINS
						.vccd1(vccd1),
						.vssd1(vssd1),
					`endif
					// Port 0: RW
					.clk0(sys_clock),
					.csb0(sram2k_csb[sram2k_i]),
					.web0(sram2k_web[0]),
					.wmask0(sram2k_wmask[3:0]),
					.addr0(sram2k_addr[31:0]),
					.din0(sram2k_dat_w[31:0]),
					.dout0(sram2k_dat_r[(32*sram2k_i)+:32])
					/*,
					// Port 1: R
					.clk1(1'b0),
					.csb1(1'b1),
					.addr1(8'h0) 
					 */
				);								
		end
	endgenerate		
	
	/****************************************************************
	 * Management interface
	 ****************************************************************/
	clusterv_mgmt_if u_mgmt_if (
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
		`WB_TAG_CONNECT_ARR(sys_, i2ic_, INIT_IDX_MGMT, 32, 32, 1, 1, 4),
		.resvec                (resvec               ), 
		.hartid                (hartid               ), 
		.sys_clock             (sys_clock            ), 
		.sys_reset             (sys_reset            ), 
		.core_reset            (core_reset           ));

	/****************************************************************
	 * Core Tiles
	 ****************************************************************/
	`SKY130_OPENRAM_RW_WIRES_ARR(tile2sram_, 8, 32, 4);
	wire[3:0]					tile_irq;
	generate
		genvar tile_i;
		for (tile_i=0; tile_i<4; tile_i=tile_i+1) begin : tiles
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
				.clock       (sys_clock                  ), 
				.reset       (core_reset                 ), 
				.hartid      (hartid[32*tile_i+:32]      ), 
				.resvec      (resvec[32*tile_i+:32]     ), 
				`WB_TAG_CONNECT_ARR(i_, i2ic_, INIT_IDX_TILE0+tile_i, 32, 32, 1, 1, 4),
				`SKY130_OPENRAM_RW_CONNECT_ARR(sram_, tile2sram_, tile_i, 8, 32),
				.irq         (tile_irq[tile_i]));
			
			sky130_sram_1kbyte_1rw1r_32x256_8 u_tile_sram(
`ifdef USE_POWER_PINS
					.vccd1(vccd1),
					.vssd1(vssd1),
`endif
					// Port 0: RW
					.clk0(sys_clock),
					.csb0(tile2sram_csb[tile_i]),
					.web0(tile2sram_web[tile_i]),
					.wmask0(tile2sram_wmask[4*tile_i+:4]),
					.addr0(tile2sram_addr[8*tile_i+:8]),
					.din0(tile2sram_dat_w[32*tile_i+:32]),
					.dout0(tile2sram_dat_r[32*tile_i+:32])
					/*,
					// Port 1: R
					.clk1(1'b0),
					.csb1(1'b1),
					.addr1(8'h0) 
					*/
			);					
		end
	endgenerate
	
	clusterv_periph_subsys clusterv_periph_subsys (
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
		.clock       (sys_clock      ), 
		.reset       (sys_reset      ), 
		`WB_TAG_CONNECT_ARR(regs_, ic2t_, TARG_IDX_PERIPH, 32, 32, 1, 1, 4),
		`WB_TAG_CONNECT_ARR(dma_,  i2ic_, INIT_IDX_DMA, 32, 32, 1, 1, 4),
		.core_irq    (tile_irq       ) /*, 
		.spi0_sck    (spi0_sck   ), 
		.spi0_sdo    (spi0_sdo   ), 
		.spi0_sdi    (spi0_sdi   ), 
		.spi1_sck    (spi1_sck   ), 
		.spi1_sdo    (spi1_sdo   ), 
		.spi1_sdi    (spi1_sdi   ), 
		.uart_tx     (uart_tx    ), 
		.uart_rx     (uart_rx    ) */);
	
endmodule	// user_project_wrapper
