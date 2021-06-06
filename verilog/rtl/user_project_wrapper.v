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

`include "verilog/rtl/defines.v"
`include "wishbone_tag_macros.svh"
`include "sky130_openram_macros.svh"
 
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
	
	localparam N_TILES = 4;
	
	wire clock = wb_clk_i;
	wire[N_TILES-1:0] irq = 0;
	
	wire sys_reset;
	wire sys_clock;
	wire reset = sys_reset;
	wire[31:0]		resvec;

	// TODO: want to control this?
	assign user_irq = {3{1'b0}};
	
	`SKY130_OPENRAM_RW_WIRES_ARR(tile2sram_, 8, 32, 4);
	`WB_TAG_WIRES_ARR(tile2ic_, 32, 32, 1, 1, 4, 4);

	generate
		genvar tile_i;
		for (tile_i=0; tile_i<N_TILES; tile_i=tile_i+1) begin : tile
			wire[31:0] hartid = tile_i;
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
				.clock       (clock         ), 
				.reset       (reset         ), 
				.hartid      (hartid        ), 
				.resvec      (resvec        ), 
				`WB_TAG_CONNECT_ARR(i_, tile2ic_, tile_i, 32, 32, 1, 1, 4),
				`SKY130_OPENRAM_RW_CONNECT_ARR(sram_, tile2sram_, tile_i, 8, 32),
				.irq         (irq[tile_i]   ));

//	assign io_out = tile0ic_adr;
//	assign tile0ic_dat_r = io_in;
	
			sky130_sram_1kbyte_1rw1r_32x256_8 u_tile0_sram(
`ifdef USE_POWER_PINS
				.vccd1(vccd1),
				.vssd1(vssd1),
`endif
				// Port 0: RW
				.clk0(clock),
				.csb0(tile2sram_csb[tile_i]),
				.web0(tile2sram_web[tile_i]),
				.wmask0(tile2sram_wmask[4*tile_i+:4]),
				.addr0(tile2sram_addr[8*tile_i+:8]),
				.din0(tile2sram_dat_w[32*tile_i+:32]),
				.dout0(tile2sram_dat_r[32*tile_i+:32]),
				// Port 1: R
				.clk1(1'b0),
				.csb1(1'b1),
				.addr1(8'h0)
				);
		end
	endgenerate
	
	`WB_TAG_WIRES(mgmt_sys_i_, 32, 32, 1, 1, 4);

`ifdef UNDEFINED	
	clusterv_periph_subsys u_periph_subsys (
		.mgmt_clock        (wb_clk_i       ), 
		.mgmt_reset        (wb_rst_i       ), 
		.mgmt_t_adr        (wbs_adr_i       ), 
		.mgmt_t_dat_w      (wbs_dat_i     ), 
		.mgmt_t_dat_r      (wbs_dat_o     ), 
		.mgmt_t_cyc        (wbs_cyc_i       ), 
//		.mgmt_t_err        (wbs_e       ), 
		.mgmt_t_sel        (wbs_sel_i       ), 
		.mgmt_t_stb        (wbs_stb_i       ), 
		.mgmt_t_ack        (wbs_ack_o       ), 
		.mgmt_t_we         (wbs_we_i        ), 
		.sys_clock         (sys_clock        ), 
		.sys_reset         (sys_reset        ), 
		`WB_TAG_CONNECT(mgmt_sys_i_, mgmt_sys_i_),
		.resvec            (resvec           ));
	
	fwspi_memio_wb u_spi_memio (
		.clock          (sys_clock     ), 
		.reset          (reset         ), 
		.cfg_adr        (cfg_adr       ), 
		.cfg_dat_w      (cfg_dat_w     ), 
		.cfg_dat_r      (cfg_dat_r     ), 
		.cfg_cyc        (cfg_cyc       ), 
		.cfg_err        (cfg_err       ), 
		.cfg_sel        (cfg_sel       ), 
		.cfg_stb        (cfg_stb       ), 
		.cfg_ack        (cfg_ack       ), 
		.cfg_we         (cfg_we        ), 
		.flash_adr      (flash_adr     ), 
		.flash_dat_w    (flash_dat_w   ), 
		.flash_dat_r    (flash_dat_r   ), 
		.flash_cyc      (flash_cyc     ), 
		.flash_err      (flash_err     ), 
		.flash_sel      (flash_sel     ), 
		.flash_stb      (flash_stb     ), 
		.flash_ack      (flash_ack     ), 
		.flash_we       (flash_we      ), 
		.quad_mode      (quad_mode     ), 
		.flash_csb      (flash_csb     ), 
		.flash_clk      (flash_clk     ), 
		.flash_csb_oeb  (flash_csb_oeb ), 
		.flash_clk_oeb  (flash_clk_oeb ), 
		.flash_io0_oeb  (flash_io0_oeb ), 
		.flash_io1_oeb  (flash_io1_oeb ), 
		.flash_io2_oeb  (flash_io2_oeb ), 
		.flash_io3_oeb  (flash_io3_oeb ), 
		.flash_csb_ieb  (flash_csb_ieb ), 
		.flash_clk_ieb  (flash_clk_ieb ), 
		.flash_io0_ieb  (flash_io0_ieb ), 
		.flash_io1_ieb  (flash_io1_ieb ), 
		.flash_io2_ieb  (flash_io2_ieb ), 
		.flash_io3_ieb  (flash_io3_ieb ), 
		.flash_io0_do   (flash_io0_do  ), 
		.flash_io1_do   (flash_io1_do  ), 
		.flash_io2_do   (flash_io2_do  ), 
		.flash_io3_do   (flash_io3_do  ), 
		.flash_io0_di   (flash_io0_di  ), 
		.flash_io1_di   (flash_io1_di  ), 
		.flash_io2_di   (flash_io2_di  ), 
		.flash_io3_di   (flash_io3_di  ));
`endif /* UNDEFINED */
	
	
// Dummy assignment so that we can take it through the openlane flow
// assign io_out = io_in;

endmodule	// user_project_wrapper
