//==============================================================================
//========================================================
// File        : soc_tb_pkg.sv
//========================================================
// Company     : Kyros-Semi Pvt Ltd.
// Project     : Pinaka SoC Verification
// Description : SOC testbench package
//
// Author      : Ganesh K S(ganesh.ks@kyros-semi.com)
// Created On  : 29-May-2026
//
// Copyright (c) 2026 Kyros-Semi Pvt Ltd
// Confidential Proprietary Information
//==============================================================================
`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
package tb_pkg;
 //-----------UART---------------------------------  
    parameter bit [7:0] ADDR_THR  = 8'h00;  // TX Holding Reg  (pwrite=1)
    parameter bit [7:0] ADDR_RBR  = 8'h00;  // RX Buffer  Reg  (pwrite=0)
    parameter bit [7:0] ADDR_IER  = 8'h04;  // Interrupt Enable
    parameter bit [7:0] ADDR_FCR  = 8'h08;  // FIFO Control    (pwrite=1)
    parameter bit [7:0] ADDR_IIR  = 8'h08;  // Int ID Register (pwrite=0)
    parameter bit [7:0] ADDR_LCR  = 8'h0C;  // Line Control
    parameter bit [7:0] ADDR_MCR  = 8'h10;  // Modem Control
    parameter bit [7:0] ADDR_LSR  = 8'h14;  // Line Status     (read-only)
    parameter bit [7:0] ADDR_MSR  = 8'h18;  // Modem Status    (read-only)
    parameter bit [7:0] ADDR_SCR  = 8'h1C;  // Scratch Pad
    parameter bit [7:0] ADDR_DLL  = 8'h20;  // Divisor LSB     (DLAB=1)
    parameter bit [7:0] ADDR_DLH  = 8'h24;  // Divisor MSB     (DLAB=1) 
    parameter bit [7:0] ADDR_MDR  =  8'h34;  // Oversampling     
    parameter bit [7:0] ADDR_INVALID  =  8'h54;  // INVALID ADDRESS   

// LSR bit positions
    parameter int LSR_DR     = 0; // Data Ready
    parameter int LSR_OE     = 1; // Overrun Error
    parameter int LSR_PE     = 2; // Parity  Error
    parameter int LSR_FE     = 3; // Framing Error
    parameter int LSR_BI     = 4; // Break Indicator
    parameter int LSR_THRE   = 5; // TX Holding Reg Empty
    parameter int LSR_TEMT   = 6; // TX Empty (shift reg + holding reg)
    parameter int LSR_TFULL  = 8; // TX FULL
    // FIFO depth (TL16C550 compatible)
    parameter int FIFO_DEPTH = 16;

 
//===============Enum declarations START=========================================    
    typedef enum bit [1:0] {
        WLS_5 = 2'b00,
        WLS_6 = 2'b01,
        WLS_7 = 2'b10,
        WLS_8 = 2'b11
    } wls_e;
 
    typedef enum bit [2:0] {
        PAR_NONE  = 3'b000,
        PAR_ODD   = 3'b001,
        PAR_EVEN  = 3'b011,
        PAR_MARK  = 3'b101,
        PAR_SPACE = 3'b111
    } parity_e;
 
    typedef enum bit {
        STOP_1   = 1'b0,
        STOP_2   = 1'b1   // 1.5 for 5-bit word, 2 for 6/7/8-bit
    } stop_e;
 
    typedef enum bit {
        OSM_16X = 1'b0,
        OSM_13X = 1'b1
    } osm_e;
 
    // Who is driving the serial line in this transaction
    typedef enum { DIR_SLAVE_TO_DUT, DIR_DUT_TO_SLAVE } serial_dir_e;
//============================Enum declarations END=========================

//---------GPIO register offsets----------
    parameter int NUM_GPIO = 23;
    parameter int GPIO_MASK = 32'h7fffff;
   
    localparam bit [7:0] GPIO_DIR_ADDR =  8'h00;
    localparam bit [7:0] GPIO_OUT_ADDR =  8'h04;
    localparam bit [7:0] GPIO_IN_ADDR =  8'h08;
    localparam bit [7:0] GPIO_SET_ADDR = 8'h0C;
    localparam bit [7:0] GPIO_CLR_ADDR = 8'h10;
    localparam bit [7:0] GPIO_TOGGLE_ADDR = 8'h14;
    localparam bit [7:0] PINMUX0_ADDR = 8'h1C;
    localparam bit [7:0] PINMUX1_ADDR = 8'h20;
    localparam bit [7:0] PINMUX2_ADDR = 8'h24;

    //I2C agent
   // `include "i2c_config.sv"
   // `include "i2c_slave_m.sv"
   // `include "slave_agent.sv"
   // 
   // `include "i2c_env.sv"
    
    `include "i2c_config.sv"
    `include "i2c_tx.sv"
    `include "i2c_sequencer.sv"
    `include "i2c_driver.sv"
    `include "i2c_monitor.sv"
    `include "i2c_agent.sv"
    `include "apb_i2c_sbd.sv"

  
    `include "spi_config.sv"
    `include "spi_tx.sv"
    `include "spi_driver.sv"
    // `include "spi_flash_model.sv"
    `include "spi_monitor.sv"
    `include "spi_agent.sv" 
    //`include "spi_seq_item.sv"
    //`include "spi_sequence.sv"
    //`include "spi_sequencer.sv"
    //`include "spi_driver.sv"
    //`include "spi_monitor.sv"
    //`include "spi_agent.sv"
    //

// core trace unit part

    `include "trace_transaction.sv"
    `include "trace_sequence.sv"
    `include "trace_sequencer.sv"
    `include "trace_driver.sv"
    `include "trace_input_monitor.sv"
    `include "trace_output_monitor.sv"      
    `include "trace_agent.sv"
    `include "trace_scoreboard.sv"     
   //`include "trace_env.sv"
  //`include "trace_test.sv"
  // `include "top_tb.sv"




   `include "apb_transaction.sv"

    `include "serial_seq_item.sv"
    `include "serial_agt_config.sv"
    `include "uart_slave_model.sv"
    `include "serial_monitor.sv"
    `include "uart_apb_monitor.sv"
    `include "serial_agent.sv"
    `include "uart_sb.sv"


    `include "jtag_trx.sv"
    `include "jtag_sequnce.sv"
    `include "jtag_sequncer.sv"
    `include "jtag_bfm.sv"
    `include "jtag_driver.sv"   
    `include "jtag_monitor.sv"
    `include "jtag_agent.sv"
    `include "boot_checker.sv"
    `include "jtag_scb.sv"
    `include "jtag_env.sv"

    // Interrupt Controller
    `include "int_config.sv"
    `include "int_seq_item.sv"
    `include "int_sequencer.sv"
    `include "int_driver.sv"
    `include "int_monitor.sv"
    `include "int_agent.sv"
    `include "int_seq.sv"

    // -----GPIO----------
    `include "gpio_transaction.sv"
    `include "gpio_apb_transaction.sv"
    `include "gpio_base_seq.sv"

    `include "gpio_driver.sv"
    `include "gpio_monitor.sv"
    `include "gpio_sequencer.sv"
    `include "gpio_apb_monitor.sv"
    `include "gpio_scoreboard.sv"

    `include "gpio_agent.sv"

    //`include "spi_interface.sv"
    `include "soc_env.sv"
    `include "soc_base_test.sv"
endpackage

