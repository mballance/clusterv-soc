/****************************************************************************
 * clusterv_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ps
`endif

`include "verilog/rtl/defines.v"
`include "wishbone_macros.svh"

  
/**
 * Module: clusterv_tb
 * 
 * TODO: Add module documentation
 */
module clusterv_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r;
`ifdef NEED_TIMESCALE
	always #10 clock_r <= (clock_r === 1'b0);
`else
	always #10ns clock_r <= (clock_r === 1'b0);
`endif
	assign clock = clock_r;
`endif	
	
`ifdef IVERILOG
`include "iverilog_control.svh"
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
	
	`WB_WIRES(wb_bfm2dut_, 32, 32);
	
	wire[3:0]			user_irq;
	// Logic Analyzer Signals
	wire  [127:0] la_data_in;
	wire  [127:0] la_data_out;
	wire  [127:0] la_oenb;

	// IOs
	wire  [`MPRJ_IO_PADS-1:0] io_in;
	wire  [`MPRJ_IO_PADS-1:0] io_out;
	wire  [`MPRJ_IO_PADS-1:0] io_oeb;

	// Analog (direct connection to GPIO pad---use with caution)
	// Note that analog I/O is not available on the 7 lowest-numbered
	// GPIO pads, and so the analog_io indexing is offset from the
	// GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
	wire  [`MPRJ_IO_PADS-10:0] analog_io;

	// Independent clock (on independent integer divider)
	wire   user_clock2 = clock;

	user_project_wrapper u_dut (
`ifdef USE_POWER_PINS
`endif
		.wb_clk_i     (clock            ), 
		.wb_rst_i     (reset            ), 
		.wbs_stb_i    (wb_bfm2dut_stb   ), 
		.wbs_cyc_i    (wb_bfm2dut_cyc   ), 
		.wbs_we_i     (wb_bfm2dut_we    ), 
		.wbs_sel_i    (wb_bfm2dut_sel   ), 
		.wbs_dat_i    (wb_bfm2dut_dat_w ), 
		.wbs_adr_i    (wb_bfm2dut_adr   ), 
		.wbs_ack_o    (wb_bfm2dut_ack   ), 
		.wbs_dat_o    (wb_bfm2dut_dat_r ), 
		.la_data_in   (la_data_in       ), 
		.la_data_out  (la_data_out      ), 
		.la_oenb      (la_oenb          ), 
		.io_in        (io_in            ), 
		.io_out       (io_out           ), 
		.io_oeb       (io_oeb           ), 
		.analog_io    (analog_io        ), 
		.user_clock2  (user_clock2      ), 
		.user_irq     (user_irq         ));

	wb_initiator_bfm #(
		.ADDR_WIDTH  (32 ), 
		.DATA_WIDTH  (32 )
		) u_mgmt_bfm (
		.clock       (clock       ), 
		.reset       (reset       ), 
		`WB_CONNECT( , wb_bfm2dut_));

endmodule


