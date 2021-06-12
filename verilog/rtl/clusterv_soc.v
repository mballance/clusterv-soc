/****************************************************************************
 * clusterv_soc.v
 ****************************************************************************/
`include "generic_sram_byte_en_macros.svh"
`include "sky130_openram_macros.svh"
`include "wishbone_macros.svh"
`include "wishbone_tag_macros.svh"

`ifndef CLUSTERV_MAIN_SRAM_MODULE
`define CLUSTERV_MAIN_SRAM_MODULE clusterv_main_sram
`endif
`ifndef CLUSTERV_TILE_SRAM_MODULE
`define CLUSTERV_TILE_SRAM_MODULE clusterv_tile_sram
`endif

`define STUB_PERIPH_SUBSYS
// `define STUB_FLASH
`define STUB_MEMC

/**
 * Module: clusterv_soc
 * 
 * TODO: Add module documentation
 */
module clusterv_soc(
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
		input			sys_reset,
		input			core_reset,
		input[31:0]		resvec,
		`WB_TARGET_PORT(mgmt_t_, 32, 32),
		output			flash_sck,
		output			flash_csn,
		output			flash_sdo,
		input			flash_sdi,
		output    		spi0_sck,
		output			spi0_sdo,
		input			spi0_sdi,
		output			spi1_sck,
		output			spi1_sdo,
		input			spi1_sdi,
		output			uart_tx,
		input			uart_rx
		);

	localparam N_TILES = 4;
//	localparam N_TILES = 1;
	
	wire[N_TILES-1:0] irq = 0;
	
	localparam INITIATOR_IDX_MGMT = N_TILES;
	localparam INITIATOR_IDX_DMA  = (INITIATOR_IDX_MGMT+1);
	localparam N_INITIATORS       = INITIATOR_IDX_DMA+1;
	
	localparam TARGET_IDX_SRAM = 0;
	localparam TARGET_IDX_FLASH = (TARGET_IDX_SRAM+1);
	localparam TARGET_IDX_PERIPH = (TARGET_IDX_FLASH+1);
	localparam N_TARGETS = (TARGET_IDX_PERIPH+1);
	
	`SKY130_OPENRAM_RW_WIRES_ARR(tile2sram_, 8, 32, N_TILES);
	`WB_TAG_WIRES_ARR(init2ic_, 32, 32, 1, 1, 4, N_INITIATORS);
	`WB_TAG_WIRES_ARR(ic2targ_, 32, 32, 1, 1, 4, N_TARGETS);
	
	// Connect the mgmt interface into the main interconnect
	`WB_ASSIGN_WIRES2ARR(init2ic_, mgmt_t_, INITIATOR_IDX_MGMT, 32, 32);

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
					.reset       (core_reset  ), 
					.hartid      (hartid        ), 
					.resvec      (resvec        ), 
					`WB_TAG_CONNECT_ARR(i_, init2ic_, tile_i, 32, 32, 1, 1, 4),
					`SKY130_OPENRAM_RW_CONNECT_ARR(sram_, tile2sram_, tile_i, 8, 32),
					.irq         (irq[tile_i]   ));

			//	assign io_out = tile0ic_adr;
			//	assign tile0ic_dat_r = io_in;
			sky130_sram_1kbyte_1rw1r_32x256_8 #(
					.VERBOSE(0)
				) u_tile_sram(
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
					.dout0(tile2sram_dat_r[32*tile_i+:32])/*,
			// Port 1: R
			.clk1(1'b0),
			.csb1(1'b1),
			.addr1(8'h0) */
				);	
`ifdef UNDEFINED
			`CLUSTERV_TILE_SRAM_MODULE u_tile_sram(
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

					.clock(clock),
					.reset(sys_reset),
					`SKY130_OPENRAM_RW_CONNECT_ARR(t_, tile2sram_, tile_i, 8, 32)
				);
`endif
		end
	endgenerate

	
	`WB_WIRES(regs_, 32, 32);
	
	wb_interconnect_tag_NxN #(
		.ADR_WIDTH     (32    ), 
		.DAT_WIDTH     (32    ), 
		.TGC_WIDTH     (4    ), 
		.TGA_WIDTH     (1    ), 
		.TGD_WIDTH     (1    ), 
		.N_INITIATORS  (N_INITIATORS ), 
		.N_TARGETS     (N_TARGETS    ), 
		.T_ADR_MASK    ({
				32'hFFF00000,
				32'hFFF00000,
				32'hFFFF0000
				}), 
		.T_ADR         ({
				32'h80000000, // SRAM
				32'h10000000, // Flash
				32'h20000000  // Periph
				})
		) u_core_ic (
		.clock         (clock        ), 
		.reset         (sys_reset        ), 
		`WB_TAG_CONNECT( , init2ic_),
		`WB_TAG_CONNECT(t, ic2targ_));
	
//	localparam N_MAIN_SRAM = 4;
	localparam N_MAIN_SRAM = 1;
	localparam SRAM_ADR_WIDTH = 10;
	`GENERIC_SRAM_BYTE_EN_WIRES(sram_, 12, 32);

`ifdef STUB_MEMC
		assign ic2targ_ack[TARGET_IDX_SRAM] = 1'b0;
`else
	fw_wishbone_sram_ctrl_single #(
			.ADR_WIDTH     (16           ), 
			.DAT_WIDTH     (32           )
		) u_sram_ctrl (
			.clock         (clock        ), 
			.reset         (sys_reset        ), 
			`WB_TAG_CONNECT_ARR(t_, ic2targ_, TARGET_IDX_SRAM, 32, 32, 1, 1, 4),
			`GENERIC_SRAM_BYTE_EN_CONNECT(i_, sram_));	

	wire[32*N_MAIN_SRAM-1:0]				banked_sram_read_data;
	generate
		genvar main_sram_i;
		for (main_sram_i=0; main_sram_i<N_MAIN_SRAM; main_sram_i=main_sram_i+1) begin : main_sram
			`CLUSTERV_MAIN_SRAM_MODULE u_main_sram (
					.clock         (clock        	   ), 
					.reset         (sys_reset        	   ), 
					.t_addr        (sram_addr  ), 
					.t_read_data   (banked_sram_read_data[32*main_sram_i+:32]),
					.t_write_data  (sram_write_data ), 
					.t_write_en    ((sram_addr[SRAM_ADR_WIDTH+:2]==main_sram_i)?sram_write_en:1'b0),
					.t_byte_en     ((sram_addr[SRAM_ADR_WIDTH+:2]==main_sram_i)?sram_byte_en:4'b0),
					.t_read_en     ((sram_addr[SRAM_ADR_WIDTH+:2]==main_sram_i)?sram_read_en:1'b0));
		end
	endgenerate
	assign sram_read_data = banked_sram_read_data[32*sram_addr[SRAM_ADR_WIDTH+:2]+:32];
`endif
	
	// Stub this out for now
	`WB_WIRES(flashcfg_, 32, 32);
	assign flashcfg_adr = {32{1'b0}};
	assign flashcfg_cyc = 1'b0;
	assign flashcfg_dat_w = {32{1'b0}};
	assign flashcfg_sel = {4{1'b0}};
	assign flashcfg_stb = 1'b0;
	assign flashcfg_we = 1'b0;

`ifdef STUB_FLASH
	assign flashcfg_ack = 1'b0;
	assign ic2targ_ack[TARGET_IDX_FLASH] = 1'b0;
`else
	fwspi_memio_wb u_flash (
		.clock          (clock         ), 
		.reset          (sys_reset         ), 
		`WB_CONNECT(cfg_, flashcfg_),
		`WB_CONNECT_ARR(flash_, ic2targ_, TARGET_IDX_FLASH, 32, 32),
		/*
		.quad_mode      (quad_mode     ), 
		 */
		.flash_csb      (flash_csn     ), 
		.flash_clk      (flash_sck     ), 
		/*
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
		 */
		.flash_io0_do   (flash_sdo     ), 
		/*
		.flash_io1_do   (flash_io1_do  ), 
		.flash_io2_do   (flash_io2_do  ), 
		.flash_io3_do   (flash_io3_do  ), 
		 */
		.flash_io0_di   (1'b0  ), 
		.flash_io1_di   (flash_sdi     ),
		.flash_io2_di   (1'b0  ), 
		.flash_io3_di   (1'b0  )
		/*
		 */);
`endif
	

	assign init2ic_tga[1*INITIATOR_IDX_DMA+:1] = 1'b0;
	assign init2ic_tgc[4*INITIATOR_IDX_DMA+:4] = {4{1'b0}};
	assign init2ic_tgd_w[1*INITIATOR_IDX_DMA+:1] = 1'b0;
	
	assign ic2targ_tgd_r[1*TARGET_IDX_PERIPH+:1] = 1'b0;

`ifdef STUB_PERIPH_SUBSYS
	assign regs_ack = 1'b0;
	assign regs_dat_r = {32{1'b0}};
	assign init2ic_cyc[INITIATOR_IDX_DMA] = 0;
	assign init2ic_stb[INITIATOR_IDX_DMA] = 0;
`else
	clusterv_periph_subsys u_periph (
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
		.clock       (clock      ), 
		.reset       (sys_reset      ), 
		`WB_CONNECT_ARR(regs_, ic2targ_, TARGET_IDX_PERIPH, 32, 32),
		`WB_CONNECT_ARR(dma_, init2ic_, INITIATOR_IDX_DMA, 32, 32),
		.spi0_sck    (spi0_sck   ), 
		.spi0_sdo    (spi0_sdo   ), 
		.spi0_sdi    (spi0_sdi   ), 
		.spi1_sck    (spi1_sck   ), 
		.spi1_sdo    (spi1_sdo   ), 
		.spi1_sdi    (spi1_sdi   ), 
		.uart_tx     (uart_tx    ), 
		.uart_rx     (uart_rx    ));
`endif
	
endmodule


