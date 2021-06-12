/****************************************************************************
 * clusterv_sys_ic.v
 ****************************************************************************/
`ifndef INCLUDED_INTERFACE_MACROS
`include "wishbone_tag_macros.svh"
`endif
  
/**
 * Module: clusterv_sys_ic
 * 
 * TODO: Add module documentation
 */
module clusterv_sys_ic(
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
		input			clock,
		input			reset,
		`WB_TAG_TARGET_PORT_ARR(t_, 32, 32, 1, 1, 4, 6),
		`WB_TAG_INITIATOR_PORT_ARR(i_, 32, 32, 1, 1, 4, 4)
		);
	
	wb_interconnect_tag_NxN #(
		.ADR_WIDTH     (32    ), 
		.DAT_WIDTH     (32    ), 
		.TGC_WIDTH     (4    ), 
		.TGA_WIDTH     (1    ), 
		.TGD_WIDTH     (1    ), 
		.N_INITIATORS  (6 ), 
		.N_TARGETS     (4    ), 
		.T_ADR_MASK    ({
			32'hFFFF_C000, // 2k
			32'hFFFF_C000, // 4k
			32'hFFFF_C000, // 8k
			32'hF000_0000  // Peripheral+Flash
			}), 
		.T_ADR         ({
			32'h8000_0000, // 2k
			32'h8000_8000, // 4k
			32'h8000_C000, // 8k
			32'h1000_C000  // Peripheral+Flash
			})
		) u_ic (
		.clock         (clock        ), 
		.reset         (reset        ), 
		`WB_TAG_CONNECT( , t_),
		`WB_TAG_CONNECT(t, i_));


endmodule


