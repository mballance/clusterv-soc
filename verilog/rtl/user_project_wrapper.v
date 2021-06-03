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

// `include "verilog/rtl/defines.v"
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
	
	wire clock = wb_clk_i;
	wire irq = 0;
	wire reset = 1;

	// TODO: want to control this?
	assign user_irq = {3{1'b0}};
	
	`SKY130_OPENRAM_RW_WIRES(tile0sram_, 8, 32);
	
	`WB_TAG_WIRES(tile0ic_, 32, 32, 1, 1, 4);
	
	clusterv_tile u_tile0 (
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
		.clock       (clock        ), 
		.reset       (reset        ), 
		.hartid      (32'h0        ), 
		.resvec      (32'h10000000 ), 
		`WB_TAG_CONNECT(i_, tile0ic_),
		`SKY130_OPENRAM_RW_CONNECT(sram_, tile0sram_),
		.irq         (irq        ));
	
	assign io_out = tile0ic_adr;
	assign tile0ic_dat_r = io_in;
	
	sky130_sram_1kbyte_1rw1r_32x256_8 u_tile0_sram(
`ifdef USE_POWER_PINS
				.vccd1(vccd1),
				.vssd1(vssd1),
`endif
			// Port 0: RW
			.clk0(clock),
			.csb0(tile0sram_csb),
			.web0(tile0sram_web),
			.wmask0(tile0sram_wmask),
			.addr0(tile0sram_addr),
			.din0(tile0sram_dat_w),
			.dout0(tile0sram_dat_r),
			// Port 1: R
			.clk1(1'b0),
			.csb1(1'b1),
			.addr1(8'h0)
			);
	
	
// Dummy assignment so that we can take it through the openlane flow
// assign io_out = io_in;

endmodule	// user_project_wrapper
