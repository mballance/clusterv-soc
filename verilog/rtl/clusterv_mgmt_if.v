/****************************************************************************
 * clusterv_mgmt_if.v
 ****************************************************************************/
`include "wishbone_macros.svh"
`include "wishbone_tag_macros.svh"
  
/**
 * Module: clusterv_mgmt_if
 * 
 * TODO: Add module documentation
 */
module clusterv_mgmt_if #(
		parameter DEFAULT_RESET_VECTOR = 32'h10000000
		) (
		input			mgmt_clock,
		input			mgmt_reset,
		`WB_TARGET_PORT(mgmt_, 32, 32),
		`WB_TAG_INITIATOR_PORT(sys_, 32, 32, 1, 1, 4),
		output[31:0]	resvec,
		output			sys_clock,
		output			sys_reset
		);

	`WB_WIRES(mgmt_regs_, 32, 32);
	`WB_TAG_WIRES(mgmt_ic2bridge_, 32, 32, 1, 1, 4);
	assign mgmt_ic2bridge_tga = 1'b0;
	assign mgmt_ic2bridge_tgc = 4'b0;
	assign mgmt_ic2bridge_tgd_w = 1'b0;

	// TODO:
	wire sys_clock = mgmt_clock;
	wire sys_reset = mgmt_reset;
	
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
		`WB_CONNECT(pt_, mgmt_ic2bridge_));
	
	reg[31:0]			resvec_r;
	reg[7:0]			sysaddr_page;
	
	assign resvec = resvec_r;
	
	always @(posedge mgmt_clock or posedge mgmt_reset) begin
		if (mgmt_reset) begin
			resvec_r <= DEFAULT_RESET_VECTOR;
			sysaddr_page <= 8'h0;
		end else begin
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
		.i_adr      (mgmt_adr     ), 
		.i_dat_w    (mgmt_dat_w   ), 
		.i_dat_r    (mgmt_dat_r   ), 
		.i_cyc      (mgmt_cyc     ), 
		.i_err      (mgmt_err     ), 
		.i_sel      (mgmt_sel     ), 
		.i_stb      (mgmt_stb     ), 
		.i_ack      (mgmt_ack     ), 
		.i_we       (mgmt_we      ), 
		.i_tgd_w    (1'b0         ), 
		.i_tga      (1'b0         ), 
		.i_tgc      (4'b0         ), 
		.t_clock    (sys_clock    ), 
		`WB_TAG_CONNECT(t_, sys_  ));

endmodule


