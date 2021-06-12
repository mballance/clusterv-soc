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
		input				mgmt_clock,
		input				mgmt_reset,
		`WB_TARGET_PORT(mgmt_, 32, 32),
		`WB_TAG_INITIATOR_PORT(sys_, 32, 32, 1, 1, 4),
		output[(4*32)-1:0]	resvec,
		output[(4*32)-1:0]	hartid,
		output				sys_clock,
		output				sys_reset,
		output				core_reset
		);

	`WB_WIRES(mgmt_regs_, 32, 32);
	`WB_TAG_WIRES(mgmt_ic2bridge_, 32, 32, 1, 1, 4);
	assign mgmt_ic2bridge_tga = 1'b0;
	assign mgmt_ic2bridge_tgc = 4'b0;
	assign mgmt_ic2bridge_tgd_w = 1'b0;

	// TODO:
	assign sys_clock = mgmt_clock;
	assign sys_reset = mgmt_reset;
	
	wb_interconnect_1xN_pt #(
		.ADR_WIDTH   (32  ), 
		.DAT_WIDTH   (32  ), 
		.N_TARGETS   (1  ), 
		.T_ADR_MASK  ({
				32'hF0000000
			}), 
		.T_ADR       ({
				32'h10000000
			})
		) u_mgmt_ic (
		.clock       (mgmt_clock      ), 
		.reset       (mgmt_reset      ), 
		`WB_CONNECT(t_, mgmt_),
		`WB_CONNECT(i_, mgmt_regs_),
		`WB_CONNECT(pt_, sys_));
	
	reg[31:0]			resvec_r;
	reg 				core_reset_r;
	reg[7:0]			sysaddr_page;

	// TODO: make truly programmable
	assign resvec[31:0]   = resvec_r;
	assign resvec[63:32]  = resvec_r;
	assign resvec[95:64]  = resvec_r;
	assign resvec[127:96] = resvec_r;
	assign hartid[31:0]   = 0;
	assign hartid[63:32]  = 1;
	assign hartid[95:64]  = 2;
	assign hartid[127:96] = 3;
	assign core_reset = core_reset_r;
	
	assign mgmt_regs_ack = (mgmt_regs_cyc && mgmt_regs_stb);
	
	always @(posedge mgmt_clock or posedge mgmt_reset) begin
		if (mgmt_reset) begin
			resvec_r <= DEFAULT_RESET_VECTOR;
			sysaddr_page <= 8'h80;
			core_reset_r <= 1'b1;
		end else begin
			if (mgmt_regs_cyc && mgmt_regs_stb) begin
				resvec_r <= mgmt_regs_dat_w;
			end
		end
	end
	
	wb_clockdomain_bridge_tag #(
		.ADR_WIDTH  (32 ), 
		.DAT_WIDTH  (32 ), 
		.TGA_WIDTH  (1 ), 
		.TGD_WIDTH  (1 ), 
		.TGC_WIDTH  (4 )
		) u_mgmt2sys_bridge (
		.reset      (mgmt_reset   ), 
		.i_clock    (mgmt_clock   ), 
		`WB_TAG_CONNECT(i_, mgmt_ic2bridge_),
		.t_clock    (sys_clock    ), 
		`WB_TAG_CONNECT(t_, sys_  ));

endmodule


