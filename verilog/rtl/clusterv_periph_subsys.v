/****************************************************************************
 * clusterv_periph_subsys.v
 ****************************************************************************/
`include "wishbone_macros.svh"
`include "wishbone_tag_macros.svh"
  
/**
 * Module: clusterv_periph_subsys
 * 
 * TODO: Add module documentation
 */
module clusterv_periph_subsys(
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
		input		clock,
		input		reset,
		`WB_TARGET_PORT(regs_, 16, 32),
		`WB_INITIATOR_PORT(dma_, 32, 32),
		output		spi0_sck,
		output		spi0_sdo,
		input		spi0_sdi,
		output		spi1_sck,
		output		spi1_sdo,
		input		spi1_sdi,
		output		uart_tx,
		input		uart_rx
		);

	localparam TARGET_IDX_SPI0 = 0;
	localparam TARGET_IDX_SPI1 = (TARGET_IDX_SPI0+1);
	localparam TARGET_IDX_UART = (TARGET_IDX_SPI1+1);
	localparam TARGET_IDX_DMA  = (TARGET_IDX_UART+1);
	localparam N_TARGETS = (TARGET_IDX_DMA+1);
	
	localparam DMAREQ_IDX_SPI0_TX = 0;
	localparam DMAREQ_IDX_SPI0_RX = (DMAREQ_IDX_SPI0_TX+1);
	localparam DMAREQ_IDX_SPI1_TX = (DMAREQ_IDX_SPI0_RX+1);
	localparam DMAREQ_IDX_SPI1_RX = (DMAREQ_IDX_SPI1_TX+1);
	localparam N_DMAREQ = (DMAREQ_IDX_SPI1_RX+1);
	
	wire[N_DMAREQ-1:0]			periph_dmareq;
	
	localparam IRQ_IDX_SPI0 = 0;
	localparam IRQ_IDX_SPI1 = (IRQ_IDX_SPI0+1);
	localparam IRQ_IDX_UART = (IRQ_IDX_SPI1+1);
	localparam IRQ_IDX_DMA  = (IRQ_IDX_UART+1);
	localparam N_IRQ = (IRQ_IDX_DMA+1);
	wire[N_IRQ-1:0]			periph_irq;

	`WB_WIRES_ARR(ic2periph_, 16, 32, N_TARGETS);
	`WB_WIRES(error_t_, 16, 32);
	wb_interconnect_1xN_pt #(
		.ADR_WIDTH   (16  ), 
		.DAT_WIDTH   (32  ), 
		.N_TARGETS   (N_TARGETS  ), 
		.T_ADR_MASK  ({
				16'hFF00,		// SPI0
				16'hFF00,		// SPI1
				16'hFF00,		// UART
				16'hF000        // DMA
			}), 
		.T_ADR       ({
				16'h0100,		// SPI0
				16'h0200,		// SPI1
				16'h0300,		// UART
				16'h1000		// DMA
			})
		) u_periph_ic (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`WB_CONNECT(t_, regs_),
		`WB_CONNECT(i_, ic2periph_),
		`WB_CONNECT(pt_, error_t_));

	// Ensure out-of-bounds accesses don't stall
	assign error_t_ack = (error_t_cyc && error_t_stb);
	assign error_t_err = (error_t_cyc && error_t_stb);
	assign error_t_dat_r = 32'hdeadbeef;

	fwspi_initiator u_spi0 (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`WB_CONNECT_ARR(rt_, ic2periph_, TARGET_IDX_SPI0, 16, 32),
		.inta      (periph_irq[IRQ_IDX_SPI0] ), 
		.tx_ready  (periph_dmareq[DMAREQ_IDX_SPI0_TX] ), 
		.rx_ready  (periph_dmareq[DMAREQ_IDX_SPI0_RX] ), 
		.sck       (spi0_sck ), 
		.mosi      (spi0_sdo ), 
		.miso      (spi0_sdi ));
	
	fwspi_initiator u_spi1 (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`WB_CONNECT_ARR(rt_, ic2periph_, TARGET_IDX_SPI1, 16, 32),
		.inta      (periph_irq[IRQ_IDX_SPI1] ), 
		.tx_ready  (periph_dmareq[DMAREQ_IDX_SPI1_TX] ), 
		.rx_ready  (periph_dmareq[DMAREQ_IDX_SPI1_RX] ), 
		.sck       (spi1_sck ), 
		.mosi      (spi1_sdo ), 
		.miso      (spi1_sdi ));
	
	fwuart_16550_wb u_uart (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`WB_CONNECT_ARR(rt_, ic2periph_, TARGET_IDX_UART, 16, 32),
		.irq       (periph_irq[IRQ_IDX_UART] ), 
		.tx_o      (uart_tx     ), 
		.rx_i      (uart_rx     ), 
		.cts_i     (1'b1        ), 
		.dsr_i     (1'b1        ), 
		.ri_i      (1'b0        ), 
		.dcd_i     (1'b1        ));

	`WB_WIRES(dma_stub_, 32, 32);
	assign dma_stub_ack = dma_stub_cyc & dma_stub_stb;
	assign dma_stub_err = dma_stub_cyc & dma_stub_stb;
	assign dma_stub_dat_r = 32'hdeadbeef;
	fwperiph_dma_wb #(
		.ch_count      (8            )
		) u_dma (
		.clock         (clock        ), 
		.reset         (reset        ), 
		`WB_CONNECT_ARR(rt_, ic2periph_, TARGET_IDX_DMA, 16, 32),
		`WB_CONNECT(i0_, dma_),
		`WB_CONNECT(i1_, dma_stub_),
		.dma_req_i     (periph_dmareq ), 
		/* TODO:
		.dma_ack_o     (dma_ack_o     ), 
		.dma_nd_i      (dma_nd_i      ), 
		.dma_rest_i    (dma_rest_i    ), 
		 */
		.inta_o        (periph_irq[IRQ_IDX_DMA] )
		);

endmodule


