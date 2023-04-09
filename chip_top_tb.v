//==============================================================================
//========================================================
// File        : tb_top.v
//========================================================
// Company     : Kyros-Semi Pvt Ltd.
// Project     : Pinaka SoC Verification
// Description : Verifiation Top module
// 
// Author      : Ganesh K S(ganesh.ks@kyros-semi.com)
// Created On  : 29-May-2026
//
// Copyright (c) 2026 Kyros-Semi Pvt Ltd
// Confidential Proprietary Information
//==============================================================================
import tb_sync_pkg::*;
import uvm_pkg::*;
import tb_pkg::*;
//`include "axi_if.sv"
`include "i2c_if.sv"
`include "spi_if.sv"
`include "uart_if.sv"
`include "apb_if.sv"
`include "gpio_apb_if.sv"
`include "gpio_if.sv"
`include "trace_if.sv"

module chip_top_tb;
//  EXTERNAL CLOCK
reg  xtal_in    ;         
reg  rc_clk    ;         
reg  pll_clk    ;         
//reg  reset_n    ;
reg  reset_n_drv;      // procedural driver (rename your existing reg)
wire reset_n;   // net that connects to the DUT
//wire reset_n = reset_n_drv;   // net that connects to the DUT
reg  hard_reset    ;
reg  power_on_rst    ;

logic GPIO1_drv, GPIO1_oe;
bit saved_pte_resp_valid;
bit [31:0] saved_pte_rdata;


wire trst_n; 
wire tclk;
wire tms ;
wire tdi ;
wire tdo ;

// ============================================================
// PHYSICAL GPIO PINS
// ============================================================
tri gpio0;
tri gpio1;
tri gpio2;
tri gpio3;
tri gpio4;
tri gpio5;
tri gpio6;
tri gpio7;
tri gpio8;
tri gpio9;
tri gpio10;
tri gpio11;
tri gpio12;
tri gpio13;
tri gpio14;
tri gpio15;
tri gpio16;
tri gpio17;
tri gpio18;
tri gpio19;
tri gpio20;
tri gpio21;
tri gpio22;

initial begin
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out0,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out1,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out2,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out3,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out4,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out5,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out6,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out7,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out8,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out9,  1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out10, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out11, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out12, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out13, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out14, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out15, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out16, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out17, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out18, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out19, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out20, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out21, 1'b0);
    $deposit(chip_top_tb.u_chip_top.io_pad_top_instance.u_gpio_io_pad.gpio_pad_out22, 1'b0);
end

//clk/reset initialization
initial begin
    //tclk=0;
    rc_clk=0;
    pll_clk=0;
    xtal_in=0;
    $deposit(chip_top_tb.u_chip_top.pinaka_top_instance.basic_isa_instance.pc[31:0], 32'b0);
    reset_n_drv=0;
    //reset_n=0;
    //tck_delay=10ns;
    handshake_from_c_to_sv=0;
    handshake_from_sv_to_c=0;
    hard_reset=0;
    power_on_rst=1;
#100
    hard_reset=1;
end
assign reset_n=0;
assign trst_n=vif.trst_n;
assign tclk=vif.tclk;
assign tms =vif.tms;
assign tdi =vif.tdi;
assign vif.tdo=tdo;


//Interface declaration
i2c_if i2c_vif(u_chip_top.pinaka_top_instance.axi2apb_instance.pclk,power_on_rst);
spi_if spi_vif();
uart_if uart_vif(u_chip_top.pinaka_top_instance.axi2apb_instance.pclk,power_on_rst);
jtag_if vif();
apb_if apb_vif();
intf int_vif(u_chip_top.pinaka_top_instance.axi2apb_instance.pclk);
gpio_if #(NUM_GPIO) gpio_vif (.clk(u_chip_top.pinaka_top_instance.axi2apb_instance.pclk));
gpio_apb_if gpio_apb_vif();

trace_if trace_vif(
                    .it_clk(chip_top_tb.u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.atclk),
                    .core_clk_i(chip_top_tb.u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.atclk),
                    . pclk_i(chip_top_tb.u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.atclk)
                );


/*
//always #(tck_delay) tclk=~tclk;//
always #1 xtal_in=~xtal_in;//
always #0.5 rc_clk=~rc_clk;
always #1.25 pll_clk=~pll_clk;
*/

//WDT require slow clk
// Clock generation
always #1    xtal_in = ~xtal_in;
always #1.25 pll_clk = ~pll_clk;

// RC clock:
// During boot loading  -> toggle every 0.5
// After boot loading   -> toggle every 2.5
initial begin
    forever begin

        if (~ u_chip_top.pinaka_top_instance.boot_load_enable && u_chip_top.pinaka_top_instance.core_rstn )
            #10000 rc_clk = ~rc_clk;
        else
            #0.5 rc_clk = ~rc_clk;

    end
end

wire high =1'b1;
wire low  =1'b0;

chip_top u_chip_top(
.VDD            (high), 
.VSS            (low), 
.VDD_1_2        (high),
.VDD_1_8        (high), 
.VDD_2_5        (high),
.RESET_N        (reset_n), 
.XTAL_IN        (xtal_in), 
.XTAL_OUT       (),//out 
.ANA0           (low), 
.ANA1           (low), 
.ANA2           (low), 
.ANA3           (low), 
.ANA4           (low), 
.ANA5           (low), 
.ANA6           (low), 
.ANA7           (low), 
.ANA8           (low), 
.ANA9           (low), 
.ADC_IN         (low), 
.DAC_OUT        (), //out
.LDO_1_2_ACAP   (low),    
.LDO_1_2_DCAP   (low),
.LDO_1_8_ACAP   (low),
.LDO_1_8_DCAP   (low),
.LDO_2_5_ACAP   (low),
.LDO_2_5_DCAP   (low),
.TRST           (trst_n),
.TCK            (tclk),
.TMS            (tms),
.TDI            (tdi),
.TDO            (tdo),
.GPIO0          (gpio0),
.GPIO1          (gpio1),
.GPIO2          (gpio2),
.GPIO3          (gpio3),
.GPIO4          (gpio4),
.GPIO5          (gpio5),
.GPIO6          (gpio6),
.GPIO7          (gpio7),
.GPIO8          (gpio8),
.GPIO9          (gpio9),
.GPIO10         (gpio10),
.GPIO11         (gpio11),
.GPIO12         (gpio12),
.GPIO13         (gpio13),
.GPIO14         (gpio14),
.GPIO15         (gpio15),
.GPIO16         (gpio16),
.GPIO17         (gpio17),
.GPIO18         (gpio18),
.GPIO19         (gpio19),
.GPIO20         (gpio20),
.GPIO21         (gpio21),
.GPIO22         (gpio22)
);

`include "gpio_pins.sv"   //for calling SPI,I2C,UART pins through GPIO

initial begin
  force chip_top_tb.u_chip_top.analog_pinaka_rc_osc_clk = rc_clk;
  force chip_top_tb.u_chip_top.analog_pinaka_pll_clk    = pll_clk;
  force chip_top_tb.u_chip_top.iopad_pinaka_hard_reset  = hard_reset;
  force chip_top_tb.u_chip_top.analog_pinaka_por_vok    = power_on_rst;
  force chip_top_tb.u_chip_top.analog_pinaka_pll_lock   = 1'b1;
end



//-------------------------------------------------------------------------------
initial begin
    
 GPIO1_oe  = 1;
 GPIO1_drv = 0;
 uvm_event_pool::get_global("BOOT_LOAD_DONE").wait_trigger();

 $display("[%0t] Boot loading completed", $time);
 //tck_delay=25ns;
 GPIO1_drv = 1;
 GPIO1_oe  = 1;
 #250ns
 GPIO1_oe  = 0;

end


assign spi_vif.cpol = u_chip_top.pinaka_top_instance.spi_wrapper_instance.spi_cpol;
assign spi_vif.cpha = u_chip_top.pinaka_top_instance.spi_wrapper_instance.spi_cpha;


//for connecting i2c signals to interface
assign i2c_vif.pslverr = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.pslverr;
assign i2c_vif.pready = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.pready;
assign i2c_vif.prdata = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.prdata;
assign i2c_vif.psel = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.psel;
assign i2c_vif.pwrite = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.pwrite;
assign i2c_vif.penable = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.penable;
assign i2c_vif.paddr = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.paddr;
assign i2c_vif.pwdata = u_chip_top.pinaka_top_instance.i2c_wrapper_instance.pwdata;

assign gpio17 = (u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.pinmux1[23:21]==3'd3) ? (1'b1) :1'bz;












assign trace_vif.it_rst_n   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_rst_n;
//assign trace_vif.core_rst_ni= chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.core_rst_ni;
assign trace_vif.presetn_i  = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.presetn_i;

assign trace_vif.it_itype   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_itype[3:0];
assign trace_vif.it_iaddr   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_iaddr[15:0];
assign trace_vif.it_cause   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_cause[7:0];
assign trace_vif.it_tval    = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_tval[31:0];
assign trace_vif.it_context = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_context[1:0];

assign trace_vif.it_ienable_in  = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_ienable_in;
assign trace_vif.it_itype_valid = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_itype_valid;

assign trace_vif.it_first_instrn_valid_in = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_first_instrn_valid_in;

assign trace_vif.it_delta_addr    = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_delta_addr[19:0];
assign trace_vif.it_del_adr_valid = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.it_del_adr_valid;



assign trace_vif.afvalid_i   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.afvalid_i ;
assign trace_vif.afready_o   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.afready_o ;
assign trace_vif.atready_i   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.atready_i ;
assign trace_vif.atvalid_o   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.atvalid_o ;
assign trace_vif.atdata_o    = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.atdata_o[15:0] ;
assign trace_vif.paddr_i     = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.paddr_i[7:0] ;
assign trace_vif.psel_i      = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.psel_i ;
assign trace_vif.penable_i   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.penable_i ;
assign trace_vif.pwrite_i    = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.pwrite_i ;
assign trace_vif.pwdata_i    = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.pwdata_i[1:0] ;
assign trace_vif.prdata_o    = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.prdata_o[31:0] ;
assign trace_vif.pready_o    = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.pready_o ;
assign trace_vif.pslverr_o   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.pslverr_o ;


// Internal DUT status for UVM observation
assign trace_vif.fifo_full   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.i_itrace_top.i_fifo_sram.sram_full_o; 

assign trace_vif.sf3_valid   = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.i_itrace_top.te_inst.inst_trace_enformat3_sf3.sf3_valid ;
//assign trace_vif.fifo_write_en  = chip_top_tb.u_chip_top.pinaka_top_instance.core_debug_trace_instance.fifo_write_en ;




// -------------------------
// Connect DUT signals to UART interface
// -------------------------

assign apb_vif.pclk    = u_chip_top.pinaka_top_instance.uart_wrapper_instance.pclk;
assign apb_vif.presetn = u_chip_top.pinaka_top_instance.uart_wrapper_instance.presetn;

assign apb_vif.psel    = u_chip_top.pinaka_top_instance.uart_wrapper_instance.psel;
assign apb_vif.penable = u_chip_top.pinaka_top_instance.uart_wrapper_instance.penable;
assign apb_vif.pwrite  = u_chip_top.pinaka_top_instance.uart_wrapper_instance.pwrite;

assign apb_vif.paddr   = u_chip_top.pinaka_top_instance.uart_wrapper_instance.paddr;
assign apb_vif.pwdata  = u_chip_top.pinaka_top_instance.uart_wrapper_instance.pwdata;

assign apb_vif.prdata  = u_chip_top.pinaka_top_instance.uart_wrapper_instance.prdata;
assign apb_vif.pready  = u_chip_top.pinaka_top_instance.uart_wrapper_instance.pready;
assign apb_vif.pslverr = u_chip_top.pinaka_top_instance.uart_wrapper_instance.pslverr;

// -------------------------
// Connect DUT signals to GPIO interface
// -------------------------

assign gpio_apb_vif.pclk    = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.pclk;
assign gpio_apb_vif.presetn = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.presetn;

assign gpio_apb_vif.psel    = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.psel;
assign gpio_apb_vif.penable = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.penable;
assign gpio_apb_vif.pwrite  = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.pwrite;

assign gpio_apb_vif.paddr   = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.paddr;
assign gpio_apb_vif.pwdata  = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.pwdata;

assign gpio_apb_vif.prdata  = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.prdata;
assign gpio_apb_vif.pready  = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.pready;
assign gpio_apb_vif.pslverr = u_chip_top.pinaka_top_instance.gpio_top_reg_instance.gpio_regfile_instance.pslverr;

//wdt ext intruppt 
//assign u_chip_top.pinaka_top_instance.gpio_pad_in[13:8] = int_vif.gpio_pad_in[5:0];
// external interrupt GPIO connections
//assign gpio8  = int_vif.gpio_pad_in[0];
//assign gpio9  = int_vif.gpio_pad_in[1];
//assign gpio10 = int_vif.gpio_pad_in[2];
//assign gpio11 = int_vif.gpio_pad_in[3];
//assign gpio12 = int_vif.gpio_pad_in[4];
//assign gpio13 = int_vif.gpio_pad_in[5];

   
assign gpio8 = (u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.pinmux0[26:24]==3'd001) ? (int_vif.gpio_pad_in[0]) :1'bz;
assign gpio9 = (u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.pinmux0[29:27]==3'd001) ? (int_vif.gpio_pad_in[1]) :1'bz;
assign gpio10 = (u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.pinmux1[2:0]==3'd001) ? (int_vif.gpio_pad_in[2]) :1'bz;
assign gpio11 = (u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.pinmux1[5:3]==3'd001) ? (int_vif.gpio_pad_in[3]) :1'bz;
assign gpio12 = (u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.pinmux1[8:6]==3'd001) ? (int_vif.gpio_pad_in[4]) :1'bz;
assign gpio13 = (u_chip_top.pinaka_top_instance.gpio_top_reg_instance.pinmux_gpio_ss_instance.pinmux1[11:9]==3'd001) ? (int_vif.gpio_pad_in[5]) :1'bz;

   

   

initial begin
    uvm_config_db#(virtual i2c_if)::set(null,"*","i2c_vif",i2c_vif);

   uvm_config_db#(virtual spi_if)::set(null,"*","spi_vif",spi_vif);

   uvm_config_db#(virtual uart_if)::set(null,"*","uart_vif",uart_vif);

   uvm_config_db #(virtual jtag_if)::set(null,"*","vif",vif);

   uvm_config_db#(virtual intf)::set(null,"*","vif",int_vif);

   uvm_config_db#(virtual apb_if)::set(null,"*","apb_vif",apb_vif);

  uvm_config_db#(virtual gpio_apb_if)::set(null,"*","gpio_apb_vif",gpio_apb_vif);

   uvm_config_db#(virtual gpio_if)::set(null,"*","gpio_vif",gpio_vif);

 uvm_config_db #(virtual trace_if)::set(null, "*","vif", trace_vif);

   
    run_test("soc_base_test");
end 


//handshake block
initial begin
    forever begin
        @(posedge u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.ACLK);
        if(u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.u_sram7.mem[2047]=='hC0FFEE)
        begin
            handshake_from_c_to_sv=1;
            $display("HANDSHAKE : Requets Received from C");
            u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.u_sram7.mem[2047]='h00000000;            
        end

        if(handshake_from_sv_to_c==1)
        begin
            u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.u_sram7.mem[2047]='h7EA;
            $display("HANDSHAKE : Request Sent from SV to C");
            handshake_from_sv_to_c=0;
        end
    end
end

//C print mechanism
//C info print
always @(u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.u_sram7.mem[2045]) begin
   $display("[C_PRINT][INFO]:%h",u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.u_sram7.mem[2045]);
end

//C error print
always @(u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.u_sram7.mem[2044]) begin
   $display("[C_PRINT][ERROR]:%h",u_chip_top.pinaka_top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.u_sram7.mem[2044]);
end

initial begin
	$shm_open("wave.shm");
	$shm_probe("ACTMF");
end

//********** MMU PTE Delay Model starts ****************\\
/*
    int pte_resp_delay;

    initial begin    
        if (!$value$plusargs("pte_resp_delay=%d", pte_resp_delay)) begin
              pte_resp_delay = 0;
	end

	$display("[PTE_DELAY] delay = %0d cycles",pte_resp_delay);
    end

always @(posedge u_chip_top.pinaka_top_instance.core_clk) begin

    if ((pte_resp_delay != 0) && u_chip_top.pinaka_top_instance.mmu_pte_req_valid) begin

        // Wait for the response associated with this request
        @(negedge u_chip_top.pinaka_top_instance.core_clk);
        while (u_chip_top.pinaka_top_instance.pte_mmu_resp_valid !== 1'b1)
            @(negedge u_chip_top.pinaka_top_instance.core_clk);

        // Capture response/data
        saved_pte_resp_valid = u_chip_top.pinaka_top_instance.pte_wrapper_instance.u_pte_controller.ptw_resp_valid;
        saved_pte_rdata      = u_chip_top.pinaka_top_instance.pte_wrapper_instance.u_pte_controller.ptw_rdata;

        // Block original response
        force u_chip_top.pinaka_top_instance.pte_mmu_resp_valid = 1'b0;
        force u_chip_top.pinaka_top_instance.pte_mmu_read_data  = '0;
        
	if(u_chip_top.pinaka_top_instance.mmu_ptw_timeout) begin
		// Release
		release u_chip_top.pinaka_top_instance.pte_mmu_resp_valid;
		release u_chip_top.pinaka_top_instance.pte_mmu_read_data;
        	saved_pte_resp_valid = 1'b0;
        	saved_pte_rdata      = '0;
	end else begin 
	        // Delay response
	        if(pte_resp_delay >=16) begin
		        repeat (15) begin
		        	@(posedge u_chip_top.pinaka_top_instance.core_clk);
		        end
		        release u_chip_top.pinaka_top_instance.pte_mmu_resp_valid;
		        release u_chip_top.pinaka_top_instance.pte_mmu_read_data;
		
		        saved_pte_resp_valid = 1'b0;
		        saved_pte_rdata      = '0;

		end else begin
		        repeat (pte_resp_delay-1) begin
				@(posedge u_chip_top.pinaka_top_instance.core_clk);
		        end
		
		        // Present delayed response
		        force u_chip_top.pinaka_top_instance.pte_mmu_resp_valid = saved_pte_resp_valid;
		        force u_chip_top.pinaka_top_instance.pte_mmu_read_data  = saved_pte_rdata;
		
		        // Release after two clock
		        @(posedge u_chip_top.pinaka_top_instance.core_clk);
		        @(posedge u_chip_top.pinaka_top_instance.core_clk);
		
		        release u_chip_top.pinaka_top_instance.pte_mmu_resp_valid;
		        release u_chip_top.pinaka_top_instance.pte_mmu_read_data;
		
		        saved_pte_resp_valid = 1'b0;
		        saved_pte_rdata      = '0;
		end
	end
    end
end
*/
//********** MMU PTE Delay Model ends ****************\\
endmodule

