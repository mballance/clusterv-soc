/****************************************************************************
 * clusterv_mgmt_if.v
 ****************************************************************************/
`ifndef INCLUDED_INTERFACE_MACROS
`include "wishbone_macros.svh"
`include "wishbone_tag_macros.svh"
`endif
  
/**
 * Module: clusterv_mgmt_if
 * 
 * TODO: Add module documentation
 */
module clusterv_mgmt_if #(
		parameter DEFAULT_RESET_VECTOR = 32'h10000000
		) (
		/*
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
 */
		input				mgmt_clock,
		input				mgmt_reset,
		`WB_TARGET_PORT(mgmt_, 32, 32),
		`WB_INITIATOR_PORT(sys_, 32, 32),
		output				sys_clock,
		output				sys_reset,
		output				core_reset,
		output				cfg_sclk,
		output				cfg_sdo,
		input				cfg_sdi
		);

	localparam TARGET_IDX_REGS = 0;
	localparam TARGET_IDX_SPI = (TARGET_IDX_REGS+1);
	localparam N_TARGETS = (TARGET_IDX_SPI+1);
	
	`WB_WIRES_ARR(mgmt_regs_, 32, 32, N_TARGETS);
	`WB_WIRES(mgmt_ic2bridge_, 32, 32);
	
	reg[3:0]		clkdiv;
	reg[3:0]		clkdiv_cnt;
	
	always @(posedge mgmt_clock or posedge mgmt_reset) begin
		if (mgmt_reset) begin
			clkdiv <= 0;
			clkdiv_cnt <= 0;
		end else begin
			if (clkdiv == clkdiv_cnt) begin
				clkdiv_cnt <= 0;
			end
		end
	end
			

	// TODO:
	assign sys_clock = (mgmt_clock & (clkdiv == clkdiv_cnt));
	assign sys_reset = mgmt_reset;
	
	wb_interconnect_1xN_pt #(
		.ADR_WIDTH   (32        ), 
		.DAT_WIDTH   (32        ), 
		.N_TARGETS   (N_TARGETS ), 
		.T_ADR_MASK  ({
				32'hFF000000,
				32'hFF000000
			}), 
		.T_ADR       ({
				32'h10000000, // local regs
				32'h11000000  // spi
			})
		) u_mgmt_ic (
		.clock       (mgmt_clock      ), 
		.reset       (mgmt_reset      ), 
		`WB_CONNECT(t_, mgmt_),
		`WB_CONNECT(i_, mgmt_regs_),
		`WB_CONNECT(pt_, mgmt_ic2bridge_));
	
	fwspi_initiator u_cfgspi (
		.clock     (mgmt_clock    ), 
		.reset     (mgmt_reset    ), 
		`WB_CONNECT_ARR(rt_, mgmt_regs_, TARGET_IDX_SPI, 32, 32),
//		.inta      (inta     ), 
//		.tx_ready  (tx_ready ), 
//		.rx_ready  (rx_ready ), 
		.sck       (cfg_sclk ), 
		.mosi      (cfg_sdo  ), 
		.miso      (cfg_sdi  ));
	
	reg[31:0]			resvec_r;
	reg 				core_reset_r;
	reg[7:0]			sysaddr_page;

	assign core_reset = core_reset_r;
	
	`WB_WIRES(localregs_, 32, 32);
	`WB_ASSIGN_ARR2WIRES(localregs_, mgmt_regs_, TARGET_IDX_REGS, 32, 32);
	
	assign localregs_ack = (localregs_cyc && localregs_stb);
	
	always @(posedge mgmt_clock or posedge mgmt_reset) begin
		if (mgmt_reset) begin
			resvec_r <= DEFAULT_RESET_VECTOR;
			sysaddr_page <= 8'h80;
			core_reset_r <= 1'b1;
		end else begin
			if (localregs_cyc && localregs_stb && localregs_we) begin
				case (localregs_adr[3:2])
					2'b00: begin
						resvec_r <= localregs_dat_w;
					end
					2'b01: begin
						core_reset_r <= localregs_dat_w[0];
					end
				endcase
			end
		end
	end

	`WB_WIRES(bridge2sys_, 32, 32);
	wb_clockdomain_bridge #(
		.ADR_WIDTH  (32 ), 
		.DAT_WIDTH  (32 )
		) u_mgmt2sys_bridge (
		.reset      (mgmt_reset   ), 
		.i_clock    (mgmt_clock   ), 
		`WB_CONNECT(i_, mgmt_ic2bridge_),
		.t_clock    (sys_clock    ), 
		`WB_CONNECT(t_, bridge2sys_  ));
	assign sys_adr = {sysaddr_page, bridge2sys_adr[23:0]};
	assign sys_cyc = bridge2sys_cyc;
	assign sys_dat_w = bridge2sys_dat_w;
	assign sys_sel = bridge2sys_sel;
	assign sys_stb = bridge2sys_stb;
	assign sys_we = bridge2sys_we;
	assign bridge2sys_ack = sys_ack;
	assign bridge2sys_dat_r = sys_dat_r;
	assign bridge2sys_err = sys_err;

endmodule


