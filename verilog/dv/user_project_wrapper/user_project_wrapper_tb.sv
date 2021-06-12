/****************************************************************************
 * user_project_wrapper_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ps
`endif

`include "verilog/rtl/defines.v"
`include "wishbone_macros.svh"

/**
 * Module: user_project_wrapper_tb
 * 
 * TODO: Add module documentation
 */
module user_project_wrapper_tb(/*input clock*/);

	reg power1;
	reg power2;

	wire temp;
`ifdef HAVE_HDL_CLOCKGEN
	reg clock;

`ifdef NEED_TIMESCALE
	always #10 clock <= (clock === 1'b0);
`else
	always #10ns clock <= (clock === 1'b0);
`endif
	initial clock <= 1'b0;
//	assign clock = clock_r;
	assign temp = clock;
`endif
	
`ifdef IVERILOG
`include "iverilog_control.svh"
`endif
	
	reg RSTB;
	
	initial begin
		RSTB <= 1'b0;
		
		#1000;
		RSTB <= 1'b1;	    // Release reset
		#2000;
	end	
	
	initial begin			// Power-up
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end	
	
	wire VDD3V3;
	wire VDD1V8;
	wire VSS;

	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;
	
	wire [37:0] mprj_io;	// Most of these are no-connects
	wire [15:0] checkbits;
	reg  [7:0] checkbits_lo;
	wire [7:0] checkbits_hi;

	assign mprj_io[23:16] = checkbits_lo;
	assign checkbits = mprj_io[31:16];
	assign checkbits_hi = checkbits[15:8];
	assign mprj_io[3] = 1'b1;       // Force CSB high.

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	wire gpio;	
	
	// These are the mappings of mprj_io GPIO pads that are set to
	// specific functions on startup:
	//
	// JTAG      = mgmt_gpio_io[0]              (inout)
	// SDO       = mgmt_gpio_io[1]              (output)
	// SDI       = mgmt_gpio_io[2]              (input)
	// CSB       = mgmt_gpio_io[3]              (input)
	// SCK       = mgmt_gpio_io[4]              (input)
	// ser_rx    = mgmt_gpio_io[5]              (input)
	// ser_tx    = mgmt_gpio_io[6]              (output)
	// irq       = mgmt_gpio_io[7]              (input)	

	wire[`MPRJ_IO_PADS-1:0]			io_in;
	wire[`MPRJ_IO_PADS-1:0]			io_out;
	wire[`MPRJ_IO_PADS-1:0]			io_oe;
	wire[`MPRJ_IO_PADS-1:0]			io_oeb = ~io_oe;
	wire[`MPRJ_IO_PADS-1:0]			banks_i;
	`WB_WIRES(wb2dut_, 32, 32);
	
	gpio_bfm #(
		.N_PINS    (`MPRJ_IO_PADS ), 
		.N_BANKS   (  )
		) u_pin_gpio (
		.clock     (clock    ), 
		.reset     (~RSTB    ), 
		.pin_i     (io_out   ), 
		.pin_o     (io_in    ), 
		.pin_oe    (io_oe    ), 
		.banks_i   (banks_i  ), 
		.banks_o   ({`MPRJ_IO_PADS{1'b0}}),
		.banks_oe  ({`MPRJ_IO_PADS{1'b0}}));
	
	wb_initiator_bfm #(
		.ADDR_WIDTH  (32 ), 
		.DATA_WIDTH  (32 )
		) u_mgmt_bfm (
		.clock       (clock      ), 
		.reset       (~RSTB      ), 
		`WB_CONNECT( , wb2dut_   ));
	
	user_project_wrapper u_dut (
		.wb_clk_i     (clock    ), 
		.wb_rst_i     (~RSTB    ), 
		.wbs_stb_i    (wb2dut_stb   ), 
		.wbs_cyc_i    (wb2dut_cyc   ), 
		.wbs_we_i     (wb2dut_we    ), 
		.wbs_sel_i    (wb2dut_sel   ), 
		.wbs_dat_i    (wb2dut_dat_w   ), 
		.wbs_adr_i    (wb2dut_adr   ), 
		.wbs_ack_o    (wb2dut_ack   ), 
		.wbs_dat_o    (wb2dut_dat_r   ), 
		/*
		.la_data_in   (la_data_in  ), 
		.la_data_out  (la_data_out ), 
		.la_oenb      (la_oenb     ), 
		 */
		.io_in        (io_in       ), 
		.io_out       (io_out      ), 
		.io_oeb       (io_oeb      ), 
//		.analog_io    (analog_io   ), 
		.user_clock2  (clock ));

`ifdef UNDEFINED

	spi_target_bfm u_spiflash_bfm(
		.reset      (reset     ), 
		.sck        (flash_clk ), 
		.sdi        (flash_io0 ), 
		.sdo        (flash_io1 ), 
		.csn        (flash_csb ));

	/************************************************************************
	 * Caravel core-debug 
	 ************************************************************************/
	`define MGMT_CORE uut.soc.soc.cpu.picorv32_core

	// Glue logic to connect BFM into picorv32_core
	wire picorv32_clk = `MGMT_CORE .clk;
	wire picorv32_resetn = `MGMT_CORE .resetn;
	wire launch_next_insn = `MGMT_CORE .launch_next_insn;
	wire picorv32_trap = `MGMT_CORE .trap;
	wire dbg_valid_insn = `MGMT_CORE .dbg_valid_insn; 
	wire[31:0] dbg_insn_opcode = `MGMT_CORE .dbg_insn_opcode;
	wire[31:0] dbg_insn_addr = `MGMT_CORE .dbg_insn_addr;
	wire[4:0] picorv32_latched_rd = `MGMT_CORE .latched_rd;
	wire picorv32_irq_state = `MGMT_CORE .irq_state;
	wire picorv32_cpuregs_write = `MGMT_CORE .cpuregs_write;
	wire[31:0] picorv32_cpuregs_wrdata = `MGMT_CORE .cpuregs_wrdata;
	wire dbg_mem_instr = `MGMT_CORE .dbg_mem_instr;
	wire[31:0] dbg_mem_addr = `MGMT_CORE .dbg_mem_addr;
	wire[3:0] dbg_mem_wstrb = `MGMT_CORE .dbg_mem_wstrb;
	wire[31:0] dbg_mem_rdata = `MGMT_CORE .dbg_mem_rdata;
	wire[31:0] dbg_mem_wdata = `MGMT_CORE .dbg_mem_wdata;
	wire dbg_mem_valid = `MGMT_CORE .dbg_mem_valid;
	wire dbg_mem_ready = `MGMT_CORE .dbg_mem_ready;
	
	reg        rvfi_valid;
//		output [63:0] rvfi_order,
	reg [31:0] rvfi_insn;
	reg        rvfi_trap;
	reg        rvfi_halt;
	reg        rvfi_intr;
	/*
		output [ 4:0] rvfi_rs1_addr,
		output [ 4:0] rvfi_rs2_addr,
		output [31:0] rvfi_rs1_rdata,
		output [31:0] rvfi_rs2_rdata,
	 */
		reg [ 4:0] rvfi_rd_addr;
		reg [31:0] rvfi_rd_wdata;
		reg[31:0] rvfi_pc_rdata;
	/*
		output [31:0] rvfi_pc_wdata,
	 */
	reg [31:0] rvfi_mem_addr;
	reg [ 3:0] rvfi_mem_rmask;
	reg [ 3:0] rvfi_mem_wmask;
	reg [31:0] rvfi_mem_rdata;
	reg [31:0] rvfi_mem_wdata;	
		
	always @(posedge picorv32_clk) begin
		rvfi_valid <= picorv32_resetn && (launch_next_insn || picorv32_trap) && dbg_valid_insn;
		rvfi_insn <= dbg_insn_opcode;
		rvfi_pc_rdata <= dbg_insn_addr;
		if (!picorv32_resetn) begin
			rvfi_rd_addr <= 0;
			rvfi_rd_wdata <= 0;
		end else begin
			if (picorv32_cpuregs_write && !picorv32_irq_state) begin
				rvfi_rd_addr <= picorv32_latched_rd;
				rvfi_rd_wdata <= picorv32_latched_rd ? picorv32_cpuregs_wrdata : {32{1'b0}};
			end
		end
		
		if (dbg_mem_instr) begin
			rvfi_mem_addr <= 0;
			rvfi_mem_rmask <= 0;
			rvfi_mem_wmask <= 0;
			rvfi_mem_rdata <= 0;
			rvfi_mem_wdata <= 0;
		end else if (dbg_mem_valid && dbg_mem_ready) begin
			rvfi_mem_addr <= dbg_mem_addr;
			rvfi_mem_rmask <= dbg_mem_wstrb ? 0 : ~0;
			rvfi_mem_wmask <= dbg_mem_wstrb;
			rvfi_mem_rdata <= dbg_mem_rdata;
			rvfi_mem_wdata <= dbg_mem_wdata;
		end
	end

	riscv_debug_bfm u_caravel_core_bfm (
		.clock      (clock     ), 
		.reset      (reset     ), 
		.valid      (rvfi_valid), 
		.instr      (rvfi_insn ), 
	/*
		.intr       (intr      ), 
		.iret       (iret      ), 
	 */
		.rd_addr    (rvfi_rd_addr  ), 
		.rd_wdata   (rvfi_rd_wdata ), 
		.pc         (rvfi_pc_rdata ), 
	/*
		.csr_waddr  (csr_waddr ), 
		.csr_wdata  (csr_wdata ), 
		.csr_write  (csr_write ), 
	 */
		.mem_addr   (rvfi_mem_addr  ), 
		.mem_rmask  (rvfi_mem_rmask ), 
		.mem_wmask  (rvfi_mem_wmask ), 
		.mem_data   ((|rvfi_mem_wmask)?rvfi_mem_wdata:rvfi_mem_rdata)
		);
`endif /* UNDEFINED */
	
endmodule


