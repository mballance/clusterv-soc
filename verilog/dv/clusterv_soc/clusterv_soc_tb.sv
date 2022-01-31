/****************************************************************************
 * clusterv_soc_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ps
`endif

`include "verilog/rtl/defines.v"
`include "wishbone_macros.svh"
  
/**
 * Module: clusterv_soc_tb
 * 
 * TODO: Add module documentation
 */
module clusterv_soc_tb(input wire clock);
	
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

	reg sys_reset /*verilator public */= 0;
	reg[7:0] reset_cnt = 0;
	
	always @(posedge clock) begin
		if (reset_cnt == 20) begin
			sys_reset <= 0;
		end else begin
			if (reset_cnt == 1) begin
				sys_reset <= 1;
			end
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	`WB_WIRES(wb_bfm2dut_, 32, 32);
	
	wire[31:0]		resvec;
	wire			core_reset;
	
	gpio_bfm #(
		.N_PINS    (32   ), 
		.N_BANKS   (1  )
		) u_resvec_bfm (
		.clock     (clock    ), 
		.reset     (1'b0     ), 
		.pin_i     (32'h0    ), 
		.pin_o     (resvec   ), 
		.banks_o   (32'h0    ), 
		.banks_oe  (32'h0    ));
	
	gpio_bfm #(
		.N_PINS    (1   ), 
		.N_BANKS   (1   )
		) u_core_reset_bfm (
		.clock     (clock    ), 
		.reset     (1'b0     ), 
		.pin_i     (32'h0    ), 
		.pin_o     (core_reset), 
		.banks_o   (32'h0    ), 
		.banks_oe  (32'h0    ));
	
	wire flash_sck;
	wire flash_csn;
	wire flash_sdo;
	wire flash_sdi;
	
	clusterv_soc u_dut (
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
		.mgmt_clock  (clock      	), 
		.mgmt_reset  (sys_reset     ), 
		`WB_CONNECT(mgmt_t_, wb_bfm2dut_),
		.flash_sck   (flash_sck ), 
		.flash_csn   (flash_csn  ), 
		.flash_sdo   (flash_sdo  ), 
		.flash_sdi   (flash_sdi  ));
	
	wb_initiator_bfm #(
		.ADDR_WIDTH  (32 ), 
		.DATA_WIDTH  (32 )
		) u_mgmt_bfm (
		.clock       (clock       ), 
		.reset       (sys_reset   ), 
		`WB_CONNECT( , wb_bfm2dut_));
	
	spi_target_bfm u_spi_memio_bfm (
		.reset      (sys_reset ), 
		.sck        (flash_sck ), 
		.sdi        (flash_sdo ), 
		.sdo        (flash_sdi ), 
		.csn        (flash_csn ));

endmodule


