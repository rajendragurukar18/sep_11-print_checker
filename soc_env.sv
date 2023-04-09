//==============================================================================
//========================================================
// File        : soc_env.sv
//========================================================
// Company     : Kyros-Semi Pvt Ltd.
// Project     : Pinaka SoC Verification
// Description : soc environment
//
// Author      : Ganesh K S(ganesh.ks@kyros-semi.com)
// Created On  : 29-May-2026
//
// Copyright (c) 2026 Kyros-Semi Pvt Ltd
// Confidential Proprietary Information
//==============================================================================
class soc_env extends uvm_env;

    `uvm_component_utils(soc_env)
    //axi_agent          axi_agent_soc;
    spi_agent          spi_agent_soc;
    i2c_agent    i2c_agent_soc;
    serial_agent    uart_agent_soc;
    serial_agt_config serial_agt_cfg;
    uart_sb u_sb;
    apb_i2c_sbd i2c_sbd;
    trace_agent      agt;
    trace_scoreboard_sf0 sb;


   gpio_agent #(NUM_GPIO) gpio_agent_h;
   gpio_apb_monitor apb_monitor_h;
   gpio_scoreboard #(NUM_GPIO) scoreboard_h;

    int_agent      int_agent_h;
    

//   gpio_agent       gpio_agent_h;
//   uart_agent       uart_agent_h;
    function new(string name = "soc_env",uvm_component parent);
    super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //axi_agent_soc = axi_agent::type_id::create("axi_agent_soc", this);
      spi_agent_soc = spi_agent::type_id::create("spi_agent_soc", this);
      i2c_agent_soc = i2c_agent::type_id::create("i2c_agent_soc", this);
      i2c_sbd = apb_i2c_sbd::type_id::create("i2c_sbd", this);
      agt = trace_agent::type_id::create("agt", this);
      sb = trace_scoreboard_sf0::type_id::create("sb", this);


      //serial_agt_cfg = serial_agt_config::type_id::create("serial_agt_cfg");
      //serial_agt_cfg.is_active = UVM_ACTIVE;
      //uvm_config_db #(serial_agt_config) :: set(this,"*","serial_agt_config",serial_agt_cfg);

      uart_agent_soc = serial_agent::type_id::create("uart_agent_soc", this);
	u_sb = uart_sb::type_id::create("u_sb",this);	

      int_agent_h = int_agent::type_id::create("int_agent_h",this);
      

     //TODO update for uart and spi
        gpio_agent_h =   gpio_agent#(NUM_GPIO)::type_id::create("gpio_agent_h",this);
        apb_monitor_h = gpio_apb_monitor::type_id::create("apb_monitor_h",this);
        scoreboard_h =  gpio_scoreboard#(NUM_GPIO)::type_id::create("scoreboard_h",this);
    endfunction

    function void connect_phase(uvm_phase phase);
       	super.connect_phase(phase);
        //TODO
	    uart_agent_soc.a_mn.ap.connect(u_sb.apb_fifo.analysis_export);
	    uart_agent_soc.slave_model.txd_rcvd_ap.connect(u_sb.txd_fifo.analysis_export);
        uart_agent_soc.slave_model.rxd_sent_ap.connect(u_sb.rxd_fifo.analysis_export);
        i2c_agent_soc.mon.ap_port.connect(i2c_sbd.imp_i2c);

	//------GPIO---------------------
	apb_monitor_h.ap.connect(scoreboard_h.apb_fifo.analysis_export);
        gpio_agent_h.monitor.ap.connect(scoreboard_h.gpio_fifo.analysis_export);
	gpio_agent_h.driver.drive_ap.connect(scoreboard_h.drive_fifo.analysis_export);

	agt.in_mon.mon_ap.connect(sb.in_imp);
    	agt.out_mon.mon_ap.connect(sb.out_imp);

    endfunction

endclass
