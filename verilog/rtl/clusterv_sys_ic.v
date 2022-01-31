/****************************************************************************
 * clusterv_sys_ic.v
 ****************************************************************************/
`ifndef INCLUDED_INTERFACE_MACROS
`include "wishbone_macros.svh"
`include "wishbone_tag_macros.svh"
`include "generic_sram_byte_en_macros.svh"
`include "sky130_openram_macros.svh"
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
		`WB_TAG_TARGET_PORT_ARR(tiles_, 32, 32, 1, 1, 4, 4),
		`WB_TARGET_PORT(dma_, 32, 32),
		`WB_INITIATOR_PORT(periph_, 32, 32),
		`SKY130_OPENRAM_RW_INITIATOR_PORT(sram2k_0_, 9, 32) /*,
		output				sram2k_1_csb,
		input[31:0]			sram2k_1_dat_r,
		output				sram2k_2_csb,
		input[31:0]			sram2k_2_dat_r,
		output				sram2k_3_csb,
		input[31:0]			sram2k_3_dat_r	*/	
		);
	
	localparam INITIATOR_IDX_TILE0 = 0;
	localparam INITIATOR_IDX_TILE1 = (INITIATOR_IDX_TILE0+1);
	localparam INITIATOR_IDX_TILE2 = (INITIATOR_IDX_TILE1+1);
	localparam INITIATOR_IDX_TILE3 = (INITIATOR_IDX_TILE2+1);
	localparam INITIATOR_IDX_DMA   = (INITIATOR_IDX_TILE3+1);
	localparam N_INITIATORS = (INITIATOR_IDX_DMA+1);
	
	localparam TARGET_IDX_SRAM_2K = 0;
	localparam TARGET_IDX_PERIPH  = (TARGET_IDX_SRAM_2K+1);
	localparam N_TARGETS = (TARGET_IDX_PERIPH+1);

	`WB_TAG_WIRES_ARR(i2ic_, 32, 32, 1, 1, 4, N_INITIATORS);
	
	// Bring in the tile interfaces
	localparam ADDR_WIDTH = 32;
	localparam DATA_WIDTH = 32;
	localparam TGD_WIDTH = 1;
	localparam TGA_WIDTH = 1;
	localparam TGC_WIDTH = 4;
	assign i2ic_adr[(INITIATOR_IDX_TILE0)*(ADDR_WIDTH)+:(4*ADDR_WIDTH)]   = tiles_adr;
	assign i2ic_dat_w[(INITIATOR_IDX_TILE0)*(DATA_WIDTH)+:(4*DATA_WIDTH)] = tiles_dat_w;
	assign tiles_dat_r = i2ic_dat_r[(INITIATOR_IDX_TILE0)*(DATA_WIDTH)+:(4*DATA_WIDTH)];
	assign i2ic_cyc[INITIATOR_IDX_TILE0+:4]   = tiles_cyc;
	assign tiles_err = i2ic_err[INITIATOR_IDX_TILE0+:4];
	assign i2ic_sel[(INITIATOR_IDX_TILE0)*(DATA_WIDTH/8)+:(4*(DATA_WIDTH/8))]   = tiles_sel;
	assign i2ic_stb[INITIATOR_IDX_TILE0+:4]  = tiles_stb;
	assign tiles_ack = i2ic_ack[INITIATOR_IDX_TILE0+:4];
	assign i2ic_we[INITIATOR_IDX_TILE0+:4]    = tiles_we;
	assign i2ic_tgd_w[(INITIATOR_IDX_TILE0)*(TGD_WIDTH)+:(4*TGD_WIDTH)] = tiles_tgd_w;
	assign tiles_tgd_r = i2ic_tgd_r[(INITIATOR_IDX_TILE0)*(TGD_WIDTH)+:(4*TGD_WIDTH)];
	assign i2ic_tga[(INITIATOR_IDX_TILE0)*(TGA_WIDTH)+:(4*TGA_WIDTH)] = tiles_tga;
	assign i2ic_tgc[(INITIATOR_IDX_TILE0)*(TGC_WIDTH)+:(4*TGC_WIDTH)] = tiles_tgc;
	
	`WB_ASSIGN_WIRES2ARR(i2ic_, dma_, INITIATOR_IDX_DMA, 32, 32);
	`WB_TAG_WIRES_ARR(ic2t_, 32, 32, 1, 1, 4, N_TARGETS);
	`WB_ASSIGN_ARR2WIRES(periph_, ic2t_, TARGET_IDX_PERIPH, 32, 32);
	
	wb_interconnect_tag_NxN #(
		.ADR_WIDTH     (32    ), 
		.DAT_WIDTH     (32    ), 
		.TGC_WIDTH     (4    ), 
		.TGA_WIDTH     (1    ), 
		.TGD_WIDTH     (1    ), 
		.N_INITIATORS  (N_INITIATORS  ), 
		.N_TARGETS     (N_TARGETS     ), 
		.T_ADR_MASK    ({
			32'hFFFF_C000, // 2k
			/*
			32'hFFFF_C000, // 4k
			32'hFFFF_C000, // 8k
			 */
			32'hF000_0000  // Peripheral+Flash
			}), 
		.T_ADR         ({
			32'h8000_0000, // 2k
			/*
			32'h8000_8000, // 4k
			32'h8000_C000, // 8k
			 */
			32'h1000_C000  // Peripheral+Flash
			})
		) u_ic (
		.clock         (clock        ), 
		.reset         (reset        ), 
		`WB_TAG_CONNECT( , i2ic_),
		`WB_TAG_CONNECT(t, ic2t_));

	`GENERIC_SRAM_BYTE_EN_WIRES(ctrl2sram2k_, 11, 32);

	assign sram2k_0_addr = ctrl2sram2k_addr;
	assign sram2k_0_dat_w = ctrl2sram2k_write_data;
	assign sram2k_0_web = ~ctrl2sram2k_write_en;
	assign sram2k_0_wmask = ctrl2sram2k_byte_en;

	assign sram2k_0_csb = ~(ctrl2sram2k_addr[10:9] == 2'b00);
	assign ctrl2sram2k_read_data = sram2k_0_dat_r;
	/*
	assign sram2k_1_csb = ~(ctrl2sram2k_addr[10:9] == 2'b01);
	assign sram2k_2_csb = ~(ctrl2sram2k_addr[10:9] == 2'b10);
	assign sram2k_3_csb = ~(ctrl2sram2k_addr[10:9] == 2'b11);
	
	assign ctrl2sram2k_read_data = 
		(ctrl2sram2k_addr[11:10] == 2'b00)?sram2k_0_dat_r:
		(ctrl2sram2k_addr[11:10] == 2'b01)?sram2k_1_dat_r:
		(ctrl2sram2k_addr[11:10] == 2'b10)?sram2k_2_dat_r:sram2k_3_dat_r;
	 */
	
	fw_wishbone_sram_ctrl_single #(
			.ADR_WIDTH     (11    ), 
			.DAT_WIDTH     (32    )
		) u_mem_ctrl_2k (
			.clock         (clock        ), 
			.reset         (reset        ), 
			`WB_TAG_CONNECT_ARR(t_, ic2t_, TARGET_IDX_SRAM_2K, 32, 32, 1, 1, 4),
			`GENERIC_SRAM_BYTE_EN_CONNECT(i_, ctrl2sram2k_));


endmodule


