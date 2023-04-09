//==============================================================================
//========================================================
// File        : soc_base_test.sv
//========================================================
// Company     : Kyros-Semi Pvt Ltd.
// Project     : Pinaka SoC Verification
// Description : Base test which enables I2C,SPI, UART VIP's
//
// Author      : Ganesh K S(ganesh.ks@kyros-semi.com)
// Created On  : 29-May-2026
//
// Copyright (c) 2026 Kyros-Semi Pvt Ltd
// Confidential Proprietary Information
//==============================================================================
import tb_sync_pkg::*;


//#########added for regression-------//

class soc_base_test extends uvm_test;

  `uvm_component_utils(soc_base_test)

  i2c_cfg             cfg;
  soc_env             env_h;
  serial_agt_config   serial_agt_cfg;
  jtag_env             env;

  int_config           int_cfg;

  string c_test;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    //==================================================
    // I2C configuration
    //==================================================
    cfg = i2c_cfg::type_id::create("cfg");

    uvm_config_db#(i2c_cfg)::set(
      this,
      "*",
      "cfg",
      cfg
    );

        uvm_config_db #(bit)::set(this,"*","is_error_test",1'b0); // UART

    //==================================================
    // JTAG environment
    //==================================================
    env = jtag_env::type_id::create("env", this);


    //==================================================
    // Interrupt configuration
    //==================================================
    int_cfg = int_config::type_id::create("int_cfg");

    if (!uvm_config_db#(virtual intf)::get(
          this,
          "",
          "vif",
          int_cfg.vif
        ))
      `uvm_fatal(
        "TEST",
        "Cannot get interrupt vif"
      );

    uvm_config_db#(int_config)::set(
      this,
      "*",
      "int_cfg",
      int_cfg
    );


    //==================================================
    // SOC environment
    //==================================================
    env_h = soc_env::type_id::create(
      "env_h",
      this
    );


    //==================================================
    // Serial agent configuration
    //==================================================
    serial_agt_cfg =
      serial_agt_config::type_id::create(
        "serial_agt_cfg"
      );

    serial_agt_cfg.is_active = UVM_ACTIVE;

    uvm_config_db#(serial_agt_config)::set(
      this,
      "*",
      "serial_agt_config",
      serial_agt_cfg
    );


    //==================================================
    // UART VIF
    //==================================================
    if (!uvm_config_db#(virtual uart_if)::get(
          this,
          "",
          "uart_vif",
          serial_agt_cfg.vif
        ))
      `uvm_fatal(
        get_full_name(),
        "unable to get agt_cfg.vif"
      );
       
      


  endfunction


  //====================================================
  // BOOT FLOW
  //====================================================
  task boot_flow();

    boot_flow_seq seq;

    seq = boot_flow_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

  endtask


  //====================================================
  // RUN PHASE
  //====================================================
  task run_phase(uvm_phase phase);

    phase.raise_objection(this);


    //==================================================
    // Get C_TEST from Makefile
    //==================================================
    if (!$value$plusargs("C_TEST=%s", c_test)) begin

      c_test = "";

      `uvm_warning(
        "SOC_BASE_TEST",
        "C_TEST plusarg not found. Using normal delay = 100ns"
      );

    end
    else begin

      `uvm_info(
        "SOC_BASE_TEST",
        $sformatf("C_TEST = %s", c_test),
        UVM_LOW
      );

    end


    //==================================================
    // Boot
    //==================================================
    boot_flow();


    //==================================================
    // Delay selection
    //
    // WDT tests      -> 8ms
    // CLK_RST tests  -> 2ms
    // Other tests    -> 100ns
    //==================================================

    if ((c_test.len() >= 4) &&
        (c_test.substr(0,3) == "wdt_")) begin

      `uvm_info(
        "SOC_BASE_TEST",
        $sformatf(
          "C_TEST = %s : Using WDT delay = 8ms",
          c_test
        ),
        UVM_LOW
      );

      #5ms;

    end
    else if ((c_test.len() >= 8) &&
             (c_test.substr(0,7) == "clk_rst_")) begin

      `uvm_info(
        "SOC_BASE_TEST",
        $sformatf(
          "C_TEST = %s : Using CLK_RST delay = 2ms",
          c_test
        ),
        UVM_LOW
      );

      #2ms;

    end
    else begin

      `uvm_info(
        "SOC_BASE_TEST",
        $sformatf(
          "C_TEST = %s : Using normal delay = 100ns",
          c_test
        ),
        UVM_LOW
      );

      #100ns;

    end


    //==================================================
    // Wait for handshake from C
    //==================================================
    wait(handshake_from_c_to_sv == 1);

    handshake_from_c_to_sv = 0;


    phase.drop_objection(this);

  endtask

endclass



class soc_i2c_test extends soc_base_test;

    `uvm_component_utils(soc_i2c_test)
    i2c_cfg cfg;
 //   soc_env env_h;
   
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
          cfg = i2c_cfg::type_id::create("cfg");

        // Add multiple slave addresses here
        
         `ifdef SLV_AD_ER 
            for(int i=0;i<5;i++) 
                cfg.addr.push_back(i);
         `else
            for(int i=0;i<128;i++) 
                cfg.addr.push_back(i);
         `endif

        uvm_config_db#(i2c_cfg)::set(this,"*","cfg",cfg);


    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        boot_flow();
        #1ms;
        //Send handshake to C
        handshake_from_sv_to_c=1;
        $display($time,"sent handshake from sv to c");
        //wait_for_handshake();
        wait(handshake_from_c_to_sv==1);
        handshake_from_c_to_sv=0;
        $display("Handshake Reeived from C to SV\n");
        phase.drop_objection(this);
    endtask

endclass


////////core_trace


class trace_test extends soc_base_test;

    `uvm_component_utils(trace_test)
       
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
          
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        boot_flow();

         #4.5us;

        //Send handshake to C
        //handshake_from_sv_to_c=1;
        $display($time,"sent handshake from sv to c");
        //wait_for_handshake();
/*        wait(handshake_from_c_to_sv==1);
        handshake_from_c_to_sv=0;
        $display("1--Handshake Reeived from C to SV\n");
        handshake_from_sv_to_c=1;
*/
        wait(handshake_from_c_to_sv==1);
        handshake_from_c_to_sv=0;
    $display("2--Handshake Reeived from C to SV\n");

        phase.drop_objection(this);
    endtask

endclass



//################################################################################
//******** Added by Selvakumar *************************\\
// MMU_PTE_Test
class soc_mmu_pte_test extends uvm_test;
    `uvm_component_utils(soc_mmu_pte_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	pte_load_seq  load_pte_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Load_PTE
		load_pte_seq = pte_load_seq::type_id::create("load_pte_seq");
		load_pte_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

        	//Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");
	end
	phase.drop_objection(this);
    endtask

endclass

//******** Added by Selvakumar *************************\\
// MMU Context Test

class soc_mmu_pte_cntx_test extends uvm_test;
    `uvm_component_utils(soc_mmu_pte_cntx_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);
        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	pte_load_seq  load_pte_seq;
	pte_context_seq  cntx_pte_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin
        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Load_PTE
		load_pte_seq = pte_load_seq::type_id::create("load_pte_seq");
		load_pte_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

        	//Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("1 Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("1 Handshake Received from C to SV\n");

		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		//PTE_CONTEXT
		cntx_pte_seq = pte_context_seq::type_id::create("cntx_pte_seq");
		cntx_pte_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

        	//Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("2 Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("2 Handshake Received from C to SV\n");

	end
	phase.drop_objection(this);
    endtask
endclass
//###################################################################################

class soc_interrupt_test extends soc_base_test;

    `uvm_component_utils(soc_interrupt_test)

    ext_interrupt_seq int_seq;
    string c_test_name;


    // =========================================================
    // Constructor
    // =========================================================

    function new(string name = "soc_interrupt_test",
                 uvm_component parent);

        super.new(name, parent);

    endfunction


    // =========================================================
    // RUN PHASE
    // =========================================================

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);


        // =====================================================
        // Read C_TEST
        // =====================================================

        c_test_name = "";

        if (!$value$plusargs("C_TEST=%s", c_test_name)) begin
            c_test_name = "";
        end


        $display("====================================================");
        $display("%0t: SOC INTERRUPT TEST START", $time);
        $display("%0t: C_TEST_NAME = [%s]",
                 $time, c_test_name);
        $display("====================================================");


        // =====================================================
        // BOOT FLOW
        // =====================================================

        boot_flow();


        // =====================================================
        // FIRST HANDSHAKE FROM C
        // =====================================================

        $display("----------------------------------------------------");
        $display("%0t: Waiting for FIRST handshake from C",
                 $time);
        $display("----------------------------------------------------");

        wait (handshake_from_c_to_sv == 1);

        $display("%0t: FIRST handshake received from C",
                 $time);

        handshake_from_c_to_sv = 0;


        // =====================================================
        // INT CONFIG RETENTION TEST
        //
        // IMPORTANT:
        //
        // Do NOT execute the common interrupt sequence first.
        //
        // This test has its own interrupt sequence.
        // =====================================================

        if (c_test_name == "int_config_retention_test") begin

            $display("====================================================");
            $display("%0t: Running int_config_retention_test",
                     $time);
            $display("====================================================");


            // -------------------------------------------------
            // Generate IRQ11 -> IRQ12 -> IRQ10
            //
            // ONLY ONCE
            // -------------------------------------------------

            int_seq =
                ext_interrupt_seq::type_id::create(
                    "retention_int_seq"
                );


            $display("----------------------------------------------------");
            $display("%0t: Starting retention interrupt sequence",
                     $time);
            $display("----------------------------------------------------");


            int_seq.start(
                env_h.int_agent_h.seqr
            );


            $display("----------------------------------------------------");
            $display("%0t: Retention interrupt sequence completed",
                     $time);
            $display("----------------------------------------------------");


            // -------------------------------------------------
            // Tell C that ISR service is complete
            // -------------------------------------------------

            handshake_from_sv_to_c = 1;


            $display("----------------------------------------------------");
            $display("%0t: Sent handshake SV -> C",
                     $time);
            $display("----------------------------------------------------");


            // -------------------------------------------------
            // Wait for C to finish configuration-retention
            // checks and send final handshake
            // -------------------------------------------------

            $display("----------------------------------------------------");
            $display("%0t: Waiting for FINAL handshake from C",
                     $time);
            $display("----------------------------------------------------");


            wait (handshake_from_c_to_sv == 1);


            handshake_from_c_to_sv = 0;
            handshake_from_sv_to_c = 0;


            $display("====================================================");
            $display("%0t: int_config_retention_test FLOW DONE",
                     $time);
            $display("====================================================");

        end


        // =====================================================
        // INT PRIORITY UPDATE TEST
        // =====================================================

        else if (c_test_name == "int_priority_update_test") begin

            $display("====================================================");
            $display("%0t: Running int_priority_update_test",
                     $time);
            $display("====================================================");


            // -------------------------------------------------
            // PHASE 1
            // Generate IRQ10 + IRQ12
            // -------------------------------------------------

            int_seq =
                ext_interrupt_seq::type_id::create(
                    "priority_int_seq"
                );


            int_seq.start(
                env_h.int_agent_h.seqr
            );


            $display("----------------------------------------------------");
            $display("%0t: FIRST PRIORITY SEQUENCE COMPLETED",
                     $time);
            $display("%0t: Expected highest priority IRQ = IRQ12",
                     $time);
            $display("----------------------------------------------------");


            // -------------------------------------------------
            // Tell C to update IRQ10 priority
            // -------------------------------------------------

            handshake_from_sv_to_c = 1;


            $display("----------------------------------------------------");
            $display("%0t: HANDSHAKE SENT FROM SV TO C",
                     $time);
            $display("----------------------------------------------------");


            // -------------------------------------------------
            // Wait for C priority update
            // -------------------------------------------------

            wait (handshake_from_c_to_sv == 1);

            handshake_from_c_to_sv = 0;


            $display("----------------------------------------------------");
            $display("%0t: SECOND HANDSHAKE RECEIVED FROM C",
                     $time);
            $display("----------------------------------------------------");


            // -------------------------------------------------
            // Updated arbitration
            //
            // IRQ10 = 15
            // IRQ12 = 9
            //
            // Expected:
            // IRQ10 wins
            // -------------------------------------------------

            $display("====================================================");
            $display("%0t: UPDATED PRIORITY ARBITRATION",
                     $time);
            $display("%0t: IRQ10 priority = 15",
                     $time);
            $display("%0t: IRQ12 priority = 9",
                     $time);
            $display("%0t: Expected highest priority IRQ = IRQ10",
                     $time);
            $display("====================================================");


            handshake_from_sv_to_c = 0;


            $display("====================================================");
            $display("%0t: int_priority_update_test FLOW DONE",
                     $time);
            $display("====================================================");

        end


        // =====================================================
        // REPEATED IRQ TEST
        // =====================================================

        else if (c_test_name == "int_repeated_irq_test") begin

            $display("====================================================");
            $display("%0t: Running int_repeated_irq_test",
                     $time);
            $display("====================================================");


            int_seq =
                ext_interrupt_seq::type_id::create(
                    "int_seq_repeated"
                );


            int_seq.start(
                env_h.int_agent_h.seqr
            );


            $display("----------------------------------------------------");
            $display("%0t: Repeated interrupt sequence completed",
                     $time);
            $display("----------------------------------------------------");

        end


        // =====================================================
        // ALL OTHER INTERRUPT TESTS
        //
        // Common first interrupt sequence
        // =====================================================

        else begin

            $display("====================================================");
            $display("%0t: Running common interrupt sequence",
                     $time);
            $display("====================================================");


            int_seq =
                ext_interrupt_seq::type_id::create(
                    "int_seq_first"
                );


            int_seq.start(
                env_h.int_agent_h.seqr
            );


            $display("----------------------------------------------------");
            $display("%0t: FIRST interrupt sequence completed",
                     $time);
            $display("----------------------------------------------------");

        end


        // =====================================================
        // Allow simulation to continue
        // =====================================================

        #2ms;


        phase.drop_objection(this);


        $display("====================================================");
        $display("%0t: SOC INTERRUPT TEST DONE",
                 $time);
        $display("====================================================");


    endtask

endclass

//////wdt_halt_resume
class soc_wdt_halt_resume_test extends uvm_test;
    `uvm_component_utils(soc_wdt_halt_resume_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
		
        
        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");

	//	#100ns;
        
        // Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
	#1ms;

    
	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

        	//Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

         //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");


	       
	end
	#4ms;
    phase.drop_objection(this);
    endtask

endclass


/// Added by Darshan
class uart_base_test extends soc_base_test;

    `uvm_component_utils(uart_base_test)
    virtual uart_if uart_vif;

    serial_agt_config serial_agt_cfg;

    function new(string name="uart_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       `uvm_info(get_type_name,"Build Phase of Test",UVM_LOW);
        uvm_config_db #(bit)::set(this,"*","is_error_test",1'b0);
	if (!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif)) begin

            `uvm_fatal("VIF","uart_vif not found in uvm_config_db")
        end
       uart_vif.loopback_en = 1'b0;                       
    endfunction

    task run_init(wls_e    wls      = WLS_8,
                  parity_e parity   = PAR_EVEN,
                  stop_e   stop     = STOP_1,
                  int      div      = 27,
                  int      clk_mhz  = 100,
                  osm_e    osm      = OSM_16X);
        
	if (env_h.uart_agent_soc.slave_model != null) begin
            env_h.uart_agent_soc.slave_model.set_baud(div, clk_mhz, osm);
            env_h.uart_agent_soc.slave_model.set_protocol(wls, parity, stop);
        end

    endtask


    function void end_of_elaboration_phase(uvm_phase phase);
       `uvm_info(get_type_name,"end_of_elaboration Phase of Test",UVM_LOW);    
       // uvm_top.print_topology();
    endfunction

 
endclass

//------------tx test -------------------

class uart_tx_test extends uart_base_test;
    `uvm_component_utils(uart_tx_test)

function new(string name="uart_tx_test", uvm_component parent); 
        super.new(name,parent); 
    endfunction

task run_phase(uvm_phase phase);
	uart_slave_model slave;
        phase.raise_objection(this);
        `uvm_info("TEST","=== uart_tx_test ===",UVM_NONE)

	slave = env_h.uart_agent_soc.slave_model;
	if (slave == null)
            `uvm_fatal("TEST","slave handle is null")

        run_init();
        boot_flow();

        phase.phase_done.set_drain_time(this,15000000ns);      
        phase.drop_objection(this);
    endtask
endclass



//------------rx test -------------------

class uart_rx_test extends uart_base_test;
    `uvm_component_utils(uart_rx_test)
	
	rand int       num_bytes;
    rand bit [7:0] payload[];

	constraint c_size  { num_bytes inside {[1:1000]}; }
    constraint c_array { payload.size() == num_bytes; }


    function new(string name="uart_rx_test", uvm_component parent); 
        super.new(name,parent); 
    endfunction

    task run_phase(uvm_phase phase);
	uart_slave_model slave;
        phase.raise_objection(this);
        `uvm_info("TEST","=== uart_rx_test ===",UVM_NONE)

	slave = env_h.uart_agent_soc.slave_model;
	if (slave == null)
            `uvm_fatal("TEST","slave handle is null")

        run_init();
        boot_flow();

	wait(handshake_from_c_to_sv==1);
        handshake_from_c_to_sv=0;

	slave.send_byte(8'hA5);

    // Test 2
    slave.send_byte(8'hA5); slave.send_byte(8'hB5);
    slave.send_byte(8'hC5); slave.send_byte(8'hD5);
    slave.send_byte(8'hE5); slave.send_byte(8'hF5);
    slave.send_byte(8'h12); slave.send_byte(8'h34);
    slave.send_byte(8'h56); slave.send_byte(8'h78);

    // Test 3
    slave.send_byte(8'h00); slave.send_byte(8'hFF);

    // Test 4: walking-1
    slave.send_byte(8'h01); slave.send_byte(8'h02);
    slave.send_byte(8'h04); slave.send_byte(8'h08);
    slave.send_byte(8'h10); slave.send_byte(8'h20);
    slave.send_byte(8'h40); slave.send_byte(8'h80);

    // Test 5: alternating
    slave.send_byte(8'hAA); slave.send_byte(8'h55);

    // Test 6: no send  error flag check only

    // Test 7: 0x00--0xFF sweep
    for (int b = 0; b <= 255; b++)
	begin
        slave.send_byte(8'(b));
//	$display("value of b=%d",b);
	end

        phase.phase_done.set_drain_time(this,15000000ns);  
 	handshake_from_sv_to_c=1;
	$display("Handshake sent from sv to c");
            
        phase.drop_objection(this);
    endtask
endclass

//------------lsr test -------------------

class uart_lsr_test extends uart_base_test;
    `uvm_component_utils(uart_lsr_test)

function new(string name="uart_lsr_test", uvm_component parent); 
        super.new(name,parent); 
    endfunction

task run_phase(uvm_phase phase);
	uart_slave_model slave;
        phase.raise_objection(this);

        `uvm_info("TEST","=== uart_lsr_test ===",UVM_NONE)

	slave = env_h.uart_agent_soc.slave_model;
	if (slave == null)
            `uvm_fatal("TEST","slave handle is null")

        run_init();
        boot_flow();

	wait(handshake_from_c_to_sv);

    handshake_from_c_to_sv = 0;

	slave.send_byte(8'hA5);
  
	  handshake_from_sv_to_c = 1;

        phase.phase_done.set_drain_time(this,1000000ns); 
        phase.drop_objection(this);
    endtask
endclass

//------error test----------------
class uart_error_test extends uart_base_test;

  `uvm_component_utils(uart_error_test)

  function new(string name="uart_error_test",
               uvm_component parent);
    super.new(name,parent);
  endfunction

    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(this,"*","is_error_test",1'b1);
    endfunction


  task run_phase(uvm_phase phase);

    uart_slave_model slave;

    phase.raise_objection(this);
        
    `uvm_info("TEST","==== uart_error_test ====",UVM_NONE)

    slave = env_h.uart_agent_soc.slave_model;

    if(slave==null)
      `uvm_fatal("TEST","Slave handle is NULL")

    run_init();
        boot_flow();

    //----------------------------
    // PARITY
    //----------------------------

    wait(handshake_from_c_to_sv);

    handshake_from_c_to_sv = 0;

    slave.set_protocol(WLS_8,PAR_EVEN,STOP_1);

    slave.send_byte(8'hA5,.pe(1));
    slave.send_byte(8'hB5,.pe(1));

    handshake_from_sv_to_c = 1;

    //----------------------------
    // FRAMING
    //----------------------------

    wait(handshake_from_c_to_sv);

    handshake_from_c_to_sv = 0;

    slave.set_protocol(WLS_8,PAR_NONE,STOP_1);

    slave.send_byte(8'h44,.fe(1));
    slave.send_byte(8'h54,.fe(1));

    handshake_from_sv_to_c = 1;

    
    //----------------------------
    // BREAK
    //----------------------------

    wait(handshake_from_c_to_sv);

    handshake_from_c_to_sv = 0;
    slave.set_protocol(WLS_8,PAR_NONE,STOP_1);

    slave.send_byte(8'h00,.brk(1));
    
    slave.send_byte(8'h01);

    handshake_from_sv_to_c = 1;

   //----------------------------
    // OVERRUN
    //----------------------------

    wait(handshake_from_c_to_sv);

    handshake_from_c_to_sv = 0;
    slave.set_protocol(WLS_8,PAR_EVEN,STOP_1);

    repeat(21)
      slave.send_byte($urandom);

    handshake_from_sv_to_c = 1;


    phase.phase_done.set_drain_time(this,5000000ns);

    phase.drop_objection(this);

  endtask

endclass

//----------------------------------------------------
// uart_lcr_config_test
//----------------------------------------------------
class uart_lcr_config_test extends uart_base_test;

  `uvm_component_utils(uart_lcr_config_test)

  uart_slave_model slave;

  // Must match burst[] in uart_lcr_config_test.c exactly
  byte unsigned lcr_burst[] = '{
    8'h01, 8'h23, 8'h02, 8'h03, 
    8'h39, 8'h2B, 8'h1D, 8'h0A, 8'h1F
  };

  // Must match rx_bytes[] in C exactly
  byte unsigned rx_bytes[] = '{
    8'h11, 8'h22, 8'h33, 8'h44, 8'h55,
    8'h66, 8'h77, 8'h88, 8'h99
  };

  function new(string name="uart_config_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    wls_e    wls;
    parity_e parity;
    stop_e   stop;

    phase.raise_objection(this);
    `uvm_info("TEST","==== uart_config_test ====",UVM_NONE)

    slave = env_h.uart_agent_soc.slave_model;
    if(slave==null)
      `uvm_fatal("TEST","Slave handle is NULL")

  //  run_init();
    boot_flow();

    foreach(lcr_burst[j]) begin

      //---------------------------------------------
      // TX phase: reconfigure slave protocol for this LCR
      //---------------------------------------------
      wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;

      decode_lcr(lcr_burst[j], wls, parity, stop);
    //  slave.set_protocol(wls, parity, stop);
	run_init(.wls(wls),.parity(parity),.stop(stop));

      `uvm_info("TEST",
        $sformatf("burst[%0d]=8'h%0h -> wls=%s parity=%s stop=%s (TX phase)",
                    j, lcr_burst[j], wls.name(), parity.name(), stop.name()),
        UVM_LOW)

      handshake_from_sv_to_c = 1;

      //---------------------------------------------
      // RX phase: drive rx_bytes[j] as a CLEAN frame
      // (correct parity/stop for this config, no fault injected)
      //---------------------------------------------
      wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;

      slave.send_byte(rx_bytes[j]);

      `uvm_info("TEST",
        $sformatf("burst[%0d] -> sent rx_bytes[%0d]=8'h%0h clean frame",
                    j, j, rx_bytes[j]),
        UVM_LOW)

      handshake_from_sv_to_c = 1;
    end

    // final single-shot handshake at end of C test
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;
    handshake_from_sv_to_c = 1;

    phase.phase_done.set_drain_time(this,1000000ns);
    phase.drop_objection(this);
  endtask

   function void decode_lcr(byte unsigned lcr_val,
                            output wls_e    wls,
                            output parity_e parity,
                            output stop_e   stop);
    case(lcr_val[1:0])
      2'b00 : wls = WLS_5;
      2'b01 : wls = WLS_6;
      2'b10 : wls = WLS_7;
      2'b11 : wls = WLS_8;
    endcase

    stop = lcr_val[2] ? STOP_2 : STOP_1;

    parity = !lcr_val[3] ? PAR_NONE :
         lcr_val[5]  ? (lcr_val[4] ? PAR_SPACE : PAR_MARK) :
         lcr_val[4]  ? PAR_EVEN :
                       PAR_ODD;
  endfunction

endclass

//----------------------------------------------------
// uart_baud_config_test
//----------------------------------------------------
class uart_baud_config_test extends uart_base_test;

  `uvm_component_utils(uart_baud_config_test)

  uart_slave_model slave;

  // Must match divs[] in C exactly (values, order, count)
  int unsigned divs[] = '{ 27, 81, 326 };

  // Must match rx_bytes[] in C exactly
  byte unsigned rx_bytes[] = '{ 8'h5A, 8'h3C, 8'hE1 };

  // Must match uart_init() args on the C side
  int unsigned clk_mhz = 100;
  osm_e        osm     = OSM_16X;

  function new(string name="uart_baud_config_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST","==== uart_baud_config_test ====",UVM_NONE)

    slave = env_h.uart_agent_soc.slave_model;
    if(slave==null)
      `uvm_fatal("TEST","Slave handle is NULL")

    run_init();
    boot_flow();

    foreach(divs[j]) begin

      //---------------------------------------------
      // TX phase: reconfigure slave baud for this divisor
      //---------------------------------------------
      wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;

      slave.set_baud(divs[j], clk_mhz, osm);
      slave.set_protocol(WLS_8, PAR_NONE, STOP_1);

      `uvm_info("TEST",
        $sformatf("divs[%0d]=%0d -> baud reconfigured (TX phase)", j, divs[j]),
        UVM_LOW)

      handshake_from_sv_to_c = 1;

      //---------------------------------------------
      // RX phase: drive rx_bytes[j] on RXD at this baud
      //---------------------------------------------
      wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;

      slave.send_byte(rx_bytes[j]);

      `uvm_info("TEST",
        $sformatf("divs[%0d]=%0d -> sent rx_bytes[%0d]=8'h%0h",
                    j, divs[j], j, rx_bytes[j]),
        UVM_LOW)

      handshake_from_sv_to_c = 1;
    end

    // final single-shot handshake at end of C test
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;
    handshake_from_sv_to_c = 1;

    phase.phase_done.set_drain_time(this,3000000ns);
    phase.drop_objection(this);
  endtask

endclass

//----------------------------------------------------
// uart_loopback_test
//----------------------------------------------------
class uart_loopback_test extends uart_base_test;

  `uvm_component_utils(uart_loopback_test)

  uart_slave_model slave;   // passive monitor config handle

  int unsigned clk_mhz = 100;
  osm_e        osm     = OSM_16X;

  // must match bauds[] in C section 4
  int unsigned bauds[] = '{ 27, 54, 326 };

  function new(string name="uart_loopback_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    uart_vif.loopback_en = 1'b1;

    `uvm_info("TEST","==== uart_loopback_test ====",UVM_NONE)

    slave = env_h.uart_agent_soc.slave_model;
    if(slave==null)
      `uvm_fatal("TEST","Slave/monitor handle is NULL")

    run_init();
    boot_flow();

    //----------------------------------------------
    // Section 1: 8N1 all-byte sweep
    //----------------------------------------------
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;

    slave.set_baud(27, clk_mhz, osm);
    slave.set_protocol(WLS_8, PAR_NONE, STOP_1);
    `uvm_info("TEST","Section 1: 8N1 all-byte sweep armed (monitor set to 8N1 @div27)",UVM_LOW)

    handshake_from_sv_to_c = 1;

    //----------------------------------------------
    // Section 2: 7E1 pattern
    //----------------------------------------------
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;

    slave.set_baud(27, clk_mhz, osm);
    slave.set_protocol(WLS_7, PAR_EVEN, STOP_1);
    `uvm_info("TEST","Section 2: 7E1 pattern armed (monitor set to 7E1 @div27)",UVM_LOW)

    handshake_from_sv_to_c = 1;

    //----------------------------------------------
    // Section 3: 8N2 pattern
    //----------------------------------------------
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;

    slave.set_baud(27, clk_mhz, osm);
    slave.set_protocol(WLS_8, PAR_NONE, STOP_2);
    `uvm_info("TEST","Section 3: 8N2 pattern armed (monitor set to 8N2 @div27)",UVM_LOW)

    handshake_from_sv_to_c = 1;

    //----------------------------------------------
    // Section 4: multi-baud sweep, 8N1 protocol, 3 sub-iterations
    //----------------------------------------------
    foreach(bauds[bi]) begin
      wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;

      slave.set_baud(bauds[bi], clk_mhz, osm);
      slave.set_protocol(WLS_8, PAR_NONE, STOP_1);
      `uvm_info("TEST",
        $sformatf("Section 4[%0d]: multi-baud sweep armed (monitor set to 8N1 @div%0d)",
                    bi, bauds[bi]),
        UVM_LOW)

      handshake_from_sv_to_c = 1;
    end

    //----------------------------------------------
    // Final end-of-test handshake
    //----------------------------------------------
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;
    `uvm_info("TEST","Loopback sweep complete, all C-side CHECKs passed",UVM_LOW)
    handshake_from_sv_to_c = 1;

    phase.phase_done.set_drain_time(this,1000000ns);
    phase.drop_objection(this);
  endtask

endclass

//----------------------------------------------------
// uart_random_stress_test
//----------------------------------------------------
class uart_random_stress_test extends uart_base_test;

  `uvm_component_utils(uart_random_stress_test)

  uart_slave_model slave;

  int unsigned clk_mhz = 100;
  osm_e        osm     = OSM_16X;

  // Must match baud_tbl[] in C exactly
  int unsigned baud_tbl[4] = '{ 27, 54, 81, 163 };

  typedef struct {
    wls_e    wls;
    parity_e parity;
    stop_e   stop;
  } lcr_decode_s;

  // Must match lcr_tbl[] in C exactly, index-for-index
  lcr_decode_s lcr_tbl[5] = '{
    '{ WLS_8, PAR_NONE, STOP_1 },   // UART_LCR_8BIT
    '{ WLS_8, PAR_EVEN, STOP_1 },   // 8BIT | PARITY_EN | EVEN_PAR
    '{ WLS_8, PAR_ODD,  STOP_1 },   // 8BIT | PARITY_EN (odd) -- confirm vs DUT
    '{ WLS_7, PAR_NONE, STOP_1 },   // 7BIT
    '{ WLS_8, PAR_NONE, STOP_2 }    // 8BIT | STOP2
  };

  // Must match rx_pat[] in C exactly -- this is what the slave actively drives
  byte unsigned rx_pat[20] = '{
    8'hA5,8'h3C,8'h1E,8'hD2,8'h69,
    8'hF0,8'h18,8'hBB,8'h4D,8'hE6,
    8'h83,8'h5E,8'hC1,8'h0F,8'h97,
    8'h64,8'hDA,8'h2B,8'hA1,8'h37
  };

  function new(string name="uart_random_stress_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    int bi, li, idx;

    phase.raise_objection(this);
    `uvm_info("TEST","==== uart_random_stress_test ====",UVM_NONE)

    slave = env_h.uart_agent_soc.slave_model;
    if(slave==null)
      `uvm_fatal("TEST","Slave handle is NULL")

    run_init();
    boot_flow();

    for (bi = 0; bi < 4; bi++) begin
      for (li = 0; li < 5; li++) begin

        idx = bi * 5 + li;

                wait(handshake_from_c_to_sv);
        handshake_from_c_to_sv = 0;

        slave.set_baud(baud_tbl[bi], clk_mhz, osm);
        slave.set_protocol(lcr_tbl[li].wls, lcr_tbl[li].parity, lcr_tbl[li].stop);

        `uvm_info("TEST",
          $sformatf("combo[%0d] bi=%0d li=%0d -> TX phase armed (div=%0d wls=%s par=%s stop=%s)",
                      idx, bi, li, baud_tbl[bi],
                      lcr_tbl[li].wls.name(), lcr_tbl[li].parity.name(), lcr_tbl[li].stop.name()),
          UVM_LOW)

        handshake_from_sv_to_c = 1;

        //---------------------------------------------
        // RX phase: drive rx_pat[idx] on RXD at this baud/protocol
        //---------------------------------------------
        wait(handshake_from_c_to_sv);
        handshake_from_c_to_sv = 0;

        slave.send_byte(rx_pat[idx]);

        `uvm_info("TEST",
          $sformatf("combo[%0d] -> sent rx_pat[%0d]=8'h%0h", idx, idx, rx_pat[idx]),
          UVM_LOW)

        handshake_from_sv_to_c = 1;
      end
    end

    // final single-shot handshake at end of C test
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;
    handshake_from_sv_to_c = 1;

    phase.phase_done.set_drain_time(this,5000000ns);
    phase.drop_objection(this);
  endtask

endclass

//------------Non uart access test test -------------------

class uart_non_uart_access_test extends uart_base_test;
    `uvm_component_utils(uart_non_uart_access_test)

function new(string name="uart_non_uart_access_test", uvm_component parent); 
        super.new(name,parent); 
    endfunction

    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(this,"*","is_error_test",1'b1);
    endfunction

task run_phase(uvm_phase phase);
	uart_slave_model slave;
        phase.raise_objection(this);
        `uvm_info("TEST","=== uart_non_uart_access_test ===",UVM_NONE)

	slave = env_h.uart_agent_soc.slave_model;
	if (slave == null)
            `uvm_fatal("TEST","slave handle is null")

        run_init();
        boot_flow();

       // phase.phase_done.set_drain_time(this,50000ns);      
        phase.drop_objection(this);
    endtask
endclass


//========================================================
//SPI MEMORY MAPPING VERIFICATION THROUGH JTAG
//========================================================
class spi_memory_test extends soc_base_test;

`uvm_component_utils(spi_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
     spi_mem_seq    spi_seq;

    phase.raise_objection(this);
    spi_seq = spi_mem_seq::type_id::create("spi_mem_seq");
    spi_seq.start(env.agent.seqr);

   // handshake_from_sv_to_c=1;
    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
//	$display("Handshake Send to C from SV\n");
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//========================================================
//I2C MEMORY MAPPING VERIFICATION THROUGH JTAG
//========================================================
class i2c_memory_test extends soc_base_test;

`uvm_component_utils(i2c_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
     i2c_mem_seq    i2c_seq;

    phase.raise_objection(this);
    i2c_seq = i2c_mem_seq::type_id::create("i2c_mem_seq");
    i2c_seq.start(env.agent.seqr);

   // handshake_from_sv_to_c=1;
    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
//	$display("Handshake Send to C from SV\n");
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass

//=================MEMORY MAPPING UART WITH C TEST=======================
class memory_test extends soc_base_test;

  `uvm_component_utils(memory_test)
   virtual uart_if uart_vif;
  function new(string name = "memory_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);

	if (!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif)) begin

            `uvm_fatal("VIF","uart_vif not found in uvm_config_db")
        end
       uart_vif.loopback_en = 1'b1; 
    // For memory mapping test
    uvm_config_db#(bit)::set(this, "*", "is_error_test", 1'b1);

    
  endfunction

endclass

//=======================================================================

//========================================================
//UART MEMORY MAPPING VERIFICATION THROUGH JTAG
//========================================================
class uart_memory_test extends soc_base_test;

`uvm_component_utils(uart_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(this,"*","is_error_test",1'b1);
    endfunction

task run_phase(uvm_phase phase);
     uart_mem_seq    uart_seq;

    phase.raise_objection(this);
    uart_seq = uart_mem_seq::type_id::create("uart_mem_seq");
    uart_seq.start(env.agent.seqr);

   // handshake_from_sv_to_c=1;
    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
//	$display("Handshake Send to C from SV\n");
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass

//========================================================
//IMEM MEMORY MAPPING VERIFICATION THROUGH JTAG
//========================================================
class imem_memory_test extends soc_base_test;

`uvm_component_utils(imem_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
     imem_mem_seq    imem_seq;

    phase.raise_objection(this);
    imem_seq = imem_mem_seq::type_id::create("imem_mem_seq");
    imem_seq.start(env.agent.seqr);

   // handshake_from_sv_to_c=1;
    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
//	$display("Handshake Send to C from SV\n");
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass

//========================================================
//DMEM MEMORY MAPPING VERIFICATION THROUGH JTAG
//========================================================
class dmem_memory_test extends soc_base_test;

`uvm_component_utils(dmem_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    dmem_mem_seq    dmem_seq;

    phase.raise_objection(this);
    dmem_seq = dmem_mem_seq::type_id::create("dmem_mem_seq");
    dmem_seq.start(env.agent.seqr);

   // handshake_from_sv_to_c=1;
    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
//	$display("Handshake Send to C from SV\n");
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass

//========================================================
//ANALOG PLL MEMORY MAPPING VERIFICATION THROUGH JTAG
//========================================================
class analogpll_memory_test extends soc_base_test;

`uvm_component_utils(analogpll_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    analogpll_mem_seq    analogpll_seq;

    phase.raise_objection(this);
    analogpll_seq = analogpll_mem_seq::type_id::create("analogpll_mem_seq");
    analogpll_seq.start(env.agent.seqr);

   // handshake_from_sv_to_c=1;
    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
//	$display("Handshake Send to C from SV\n");
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//====================================================================
//CLOCK RESET CONTROLLER MEMORY MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class clk_rst_memory_test extends soc_base_test;

`uvm_component_utils(clk_rst_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    clk_rst_mem_seq    clk_rst_seq;

    phase.raise_objection(this);
    clk_rst_seq = clk_rst_mem_seq::type_id::create("clk_rst_mem_seq");
    clk_rst_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//====================================================================
//PTE MEMORY MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class pte_memory_test extends soc_base_test;

`uvm_component_utils(pte_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    pte_mem_seq    pte_seq;

    phase.raise_objection(this);
    pte_seq = pte_mem_seq::type_id::create("pte_mem_seq");
    pte_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//====================================================================
//SOC TOP REGISTER MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class soc_top_reg_memory_test extends soc_base_test;

`uvm_component_utils(soc_top_reg_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    soc_top_reg_mem_seq    soc_top_reg_seq;

    phase.raise_objection(this);
    soc_top_reg_seq = soc_top_reg_mem_seq::type_id::create("soc_top_reg_mem_seq");
    soc_top_reg_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass



//====================================================================
//WDT MEMORY MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class wdt_memory_test extends soc_base_test;

`uvm_component_utils(wdt_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    wdt_mem_seq    wdt_seq;

    phase.raise_objection(this);
    wdt_seq = wdt_mem_seq::type_id::create("wdt_mem_seq");
    wdt_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//====================================================================
//IPs DEBUG MEMORY MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class ips_debug_memory_test extends soc_base_test;

`uvm_component_utils(ips_debug_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    ips_debug_mem_seq    ips_debug_seq;

    phase.raise_objection(this);
    ips_debug_seq = ips_debug_mem_seq::type_id::create("ips_debug_mem_seq");
    ips_debug_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//====================================================================
//MMR MEMORY MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class mmr_memory_test extends soc_base_test;

`uvm_component_utils(mmr_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    mmr_mem_seq    mmr_seq;

    phase.raise_objection(this);
    mmr_seq = mmr_mem_seq::type_id::create("mmr_mem_seq");
    mmr_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//====================================================================
//CORE DEBUG MEMORY MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class core_debug_memory_test extends soc_base_test;

`uvm_component_utils(core_debug_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    core_debug_mem_seq    core_debug_seq;

    phase.raise_objection(this);
    core_debug_seq = core_debug_mem_seq::type_id::create("core_debug_mem_seq");
    core_debug_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass


//====================================================================
//GPIO MEMORY MAPPING VERIFICATION THROUGH JTAG
//====================================================================
class GPIO_memory_test extends soc_base_test;

`uvm_component_utils(GPIO_memory_test)

    
function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
    GPIO_mem_seq   GPIO_seq;

    phase.raise_objection(this);
    GPIO_seq = GPIO_mem_seq::type_id::create("GPIO_mem_seq");
    GPIO_seq.start(env.agent.seqr);

    $display("Handshake Send to C from SV\n");
    handshake_from_sv_to_c=1;
    wait(handshake_from_c_to_sv==1);
    handshake_from_c_to_sv=0;
    $display("Handshake Received from C to SV\n");
    phase.drop_objection(this);
endtask

endclass

//ADDED BY BASAVAKIRAN FOR CLK_RST
class clk_rst_check_debug_high extends uvm_test;

  `uvm_component_utils(clk_rst_check_debug_high)

  jtag_env env;

function new(string name="clk_rst_check_debug_high",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_clk_rst seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_clk_rst::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class clk_rst_check_mul_debug_high extends uvm_test;

  `uvm_component_utils(clk_rst_check_mul_debug_high)

  jtag_env env;

function new(string name="clk_rst_check_mul_debug_high",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_mul_seq_for_clk_rst mul_seq;

    phase.raise_objection(this);

    mul_seq = halt_and_run_mul_seq_for_clk_rst::type_id::create("mul_seq");

    mul_seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class clk_rst_i2c_rst_check extends uvm_test;

  `uvm_component_utils(clk_rst_i2c_rst_check)

  jtag_env env;

function new(string name="clk_rst_i2c_rst_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_i2c_rst seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_i2c_rst::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class clk_rst_i2c_rst_assert_de_check extends uvm_test;

  `uvm_component_utils(clk_rst_i2c_rst_assert_de_check)

  jtag_env env;

function new(string name="clk_rst_i2c_rst_assert_de_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_i2c_rst1 seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_i2c_rst1::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class clk_rst_uart_rst_check extends uvm_test;

  `uvm_component_utils(clk_rst_uart_rst_check)

  jtag_env env;

function new(string name="clk_rst_uart_rst_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_uart_rst seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_uart_rst::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class clk_rst_uart_rst_assert_de_check extends uvm_test;

  `uvm_component_utils(clk_rst_uart_rst_assert_de_check)

  jtag_env env;

function new(string name="clk_rst_uart_rst_assert_de_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_uart_rst1 seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_uart_rst1::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class clk_rst_spi_rst_check extends uvm_test;

  `uvm_component_utils(clk_rst_spi_rst_check)

  jtag_env env;

function new(string name="clk_rst_spi_rst_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_spi_rst seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_spi_rst::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class clk_rst_spi_rst_assert_de_check extends uvm_test;

  `uvm_component_utils(clk_rst_spi_rst_assert_de_check)

  jtag_env env;

function new(string name="clk_rst_spi_rst_assert_de_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_spi_rst1 seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_spi_rst1::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class clk_rst_per_rst_check extends uvm_test;

  `uvm_component_utils(clk_rst_per_rst_check)

  jtag_env env;

function new(string name="clk_rst_per_rst_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_per_rst seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_per_rst::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class clk_rst_per_rst_assert_de_check extends uvm_test;

  `uvm_component_utils(clk_rst_per_rst_assert_de_check)

  jtag_env env;

function new(string name="clk_rst_per_rst_assert_de_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_per_rst1 seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_per_rst1::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class clk_rst_ndm_rst_check extends uvm_test;

  `uvm_component_utils(clk_rst_ndm_rst_check)

  jtag_env env;

function new(string name="clk_rst_ndm_rst_check",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq_for_ndm_rst seq;

    phase.raise_objection(this);

    seq = halt_and_run_seq_for_ndm_rst::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass




//=============================================================================================================
//test ends for clk_rst by basavakiran
//============================================================================================================



// Debug to Core SBA Path //
class sba_b2b_test extends uvm_test;

  `uvm_component_utils(sba_b2b_test)

  jtag_env env;

function new(string name="sba_b2b_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_b2b_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_b2b_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_write_basic_test extends uvm_test;

  `uvm_component_utils(sba_write_basic_test)

  jtag_env env;

function new(string name="sba_write_basic_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_write_basic_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_write_basic_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_read_basic_test extends uvm_test;

  `uvm_component_utils(sba_read_basic_test)

  jtag_env env;

function new(string name="sba_read_basic_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_read_basic_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_read_basic_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_auto_increment_test extends uvm_test;

  `uvm_component_utils(sba_auto_increment_test)

  jtag_env env;

function new(string name="sba_auto_increment_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_auto_increment_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_auto_increment_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_readonaddr_test extends uvm_test;

  `uvm_component_utils(sba_readonaddr_test)

  jtag_env env;

function new(string name="sba_readonaddr_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_readonaddr_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_readonaddr_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_readondata_test extends uvm_test;

  `uvm_component_utils(sba_readondata_test)

  jtag_env env;

function new(string name="sba_readondata_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_readondata_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_readondata_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_read_write_mix_test extends uvm_test;

  `uvm_component_utils(sba_read_write_mix_test)

  jtag_env env;

function new(string name="sba_read_write_mix_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_read_write_mix_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_read_write_mix_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_error_response_test extends uvm_test;

  `uvm_component_utils(sba_error_response_test)

  jtag_env env;

function new(string name="sba_error_response_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_error_response_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_error_response_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class read_multiple_imem_test extends uvm_test;

  `uvm_component_utils(read_multiple_imem_test)

  jtag_env env;

function new(string name="read_multiple_imem_test",uvm_component parent=null);
super.new(name,parent);
endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    read_multiple_imem_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = read_multiple_imem_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class dtmcs_tdo_read_test extends uvm_test;

  `uvm_component_utils(dtmcs_tdo_read_test)

  jtag_env env;

function new(string name="dtmcs_tdo_read_test",uvm_component parent=null);
super.new(name,parent);
endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    dtmcs_tdo_read_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = dtmcs_tdo_read_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class idcode_tdo_read_test extends uvm_test;

  `uvm_component_utils(idcode_tdo_read_test)

  jtag_env env;

function new(string name="idcode_tdo_read_test",uvm_component parent=null);
super.new(name,parent);
endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    idcode_tdo_read_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = idcode_tdo_read_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class trace_basic_test extends uvm_test;
    `uvm_component_utils(trace_basic_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	trace_basic_seq basic_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
                
                //Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");

		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Trace basic
		basic_seq = trace_basic_seq::type_id::create("basic_seq");
		basic_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

	end
	phase.drop_objection(this);
    endtask

endclass

class trace_sberror_test extends uvm_test;
    `uvm_component_utils(trace_sberror_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	trace_sberror_seq error_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
                
                //Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");

		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Trace sba error
		error_seq = trace_sberror_seq::type_id::create("error_seq");
		error_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

	end
	phase.drop_objection(this);
    endtask

endclass

class trace_cmderror_test extends uvm_test;
    `uvm_component_utils(trace_cmderror_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	trace_cmderror_seq abs_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
                
                //Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");

		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Trace cmd error
		abs_seq = trace_cmderror_seq::type_id::create("abs_seq");
		abs_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

	end
	phase.drop_objection(this);
    endtask

endclass

class trace_ndmrst_test extends uvm_test;
    `uvm_component_utils(trace_ndmrst_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	trace_ndmrst_seq ndm_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
                
                //Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");

		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Trace ndm
		ndm_seq = trace_ndmrst_seq::type_id::create("ndm_seq");
		ndm_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

	end
	phase.drop_objection(this);
    endtask

endclass

class trace_invalid_addr_test extends uvm_test;
    `uvm_component_utils(trace_invalid_addr_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	trace_invalid_addr_seq invalid_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
                
                //Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");

		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Trace invalid addr
		invalid_seq = trace_invalid_addr_seq::type_id::create("invalid_seq");
		invalid_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

	end
	phase.drop_objection(this);
    endtask

endclass

class trace_integrity_test extends uvm_test;

    `uvm_component_utils(trace_integrity_test)

    jtag_env env;

    boot_flow_seq   boot_seq;
    haltreq_seq     halt_seq;
    trace_basic_seq basic_seq;
    resumereq_seq  resume_seq;


    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = jtag_env::type_id::create("env", this);

    endfunction


    task wait_c_handshake();

        wait(handshake_from_c_to_sv == 1'b1);

        handshake_from_c_to_sv = 1'b0;

        `uvm_info(get_type_name(),
                  "HANDSHAKE : Request Received from C",
                  UVM_LOW)

    endtask


    task run_one_flow(int event_id,
                      int iteration);

        boot_seq =
            boot_flow_seq::type_id::create(
                $sformatf("boot_seq_evt%0d", event_id));

        boot_seq.start(env.agent.seqr);

        `uvm_info(get_type_name(),
                  $sformatf(
                  "ITERATION %0d : BOOT_FLOW_SEQ COMPLETE",
                  iteration),
                  UVM_LOW)

        handshake_from_sv_to_c = 1'b1;

        `uvm_info(get_type_name(),
                  $sformatf(
                  "ITERATION %0d : HANDSHAKE SENT TO C",
                  iteration),
                  UVM_LOW)

        wait_c_handshake();



        //HALT //

        halt_seq =
            haltreq_seq::type_id::create(
                $sformatf("halt_seq_evt%0d", event_id));

        halt_seq.start(env.agent.seqr);

        `uvm_info(get_type_name(),
                  $sformatf(
                  "ITERATION %0d : HALTREQ_SEQ COMPLETE",
                  iteration),
                  UVM_LOW)

        basic_seq =
            trace_basic_seq::type_id::create(
                $sformatf("trace_basic_seq_evt%0d", event_id));

        basic_seq.start(env.agent.seqr);

        `uvm_info(get_type_name(),
                  $sformatf(
                  "ITERATION %0d : TRACE_BASIC_SEQ COMPLETE",
                  iteration),
                  UVM_LOW)

        resume_seq =
            resumereq_seq::type_id::create(
                $sformatf("resume_seq_evt%0d", event_id));

        resume_seq.start(env.agent.seqr);

        `uvm_info(get_type_name(),
                  $sformatf(
                  "ITERATION %0d : RESUME_REQ_SEQ COMPLETE",
                  iteration),
                  UVM_LOW)


        `uvm_info(get_type_name(),
                  $sformatf(
                  "TRACE EVENT %0d : ITERATION %0d COMPLETE",
                  event_id,
                  iteration),
                  UVM_LOW)

    endtask

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        run_one_flow(4, 1);


        run_one_flow(13, 2);

        phase.drop_objection(this);

    endtask

endclass

class trace_int2_test extends uvm_test;
    `uvm_component_utils(trace_int2_test)

    jtag_env env;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = jtag_env::type_id::create("env", this);
    endfunction

    task boot_flow();
        boot_flow_seq seq;
        seq = boot_flow_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
    endtask

    task run_phase(uvm_phase phase);

        boot_flow_seq boot_seq;
	haltreq_seq  halt_seq;
	trace_int2_seq int_seq;
	resumereq_seq resume_seq;

	phase.raise_objection(this); 
	begin

        	boot_seq = boot_flow_seq::type_id::create("boot_seq");
        	boot_seq.start(env.agent.seqr);
                
                //Send handshake to C
	        handshake_from_sv_to_c=1;
		$display("Handshake Send to C from SV\n");

	        //wait_for_handshake();
	        wait(handshake_from_c_to_sv==1);
	        handshake_from_c_to_sv=0;
	        $display("Handshake Received from C to SV\n");

		
		// Halt running CPU
		halt_seq = haltreq_seq::type_id::create("halt_seq");
		halt_seq.start(env.agent.seqr);
	
		// Trace basic
		int_seq = trace_int2_seq::type_id::create("int_seq");
		int_seq.start(env.agent.seqr);

	 	//  Resume CPU
		resume_seq = resumereq_seq::type_id::create("resume_seq");
		resume_seq.start(env.agent.seqr);

	end
	phase.drop_objection(this);
    endtask

endclass

//======================= TESETS Added by Sunil ==========================//

//============================================================
//--------------------halt_and_run_test-----------------------
//============================================================

class halt_and_run_test extends uvm_test;

  `uvm_component_utils(halt_and_run_test)

  jtag_env env;

  function new(string name="halt_and_run_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    halt_and_run_seq seq;
	
    phase.raise_objection(this);
    seq = halt_and_run_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass


//=========================================================================
//--------------------programbuf_insn_execute_test-------------------------
//=========================================================================

class pb_valid_insn_execute_test extends uvm_test;

  `uvm_component_utils(pb_valid_insn_execute_test)

  jtag_env env;

  function new(string name="pb_valid_insn_execute_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    pb_valid_insn_execute_seq seq;

    phase.raise_objection(this);
    seq = pb_valid_insn_execute_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass

//=========================================================================
//--------------------programbuf_ebreak_insn_execute_test------------------
//=========================================================================

class pb_ebreak_insn_execute_test extends uvm_test;

  `uvm_component_utils(pb_ebreak_insn_execute_test)

  jtag_env env;

  function new(string name="pb_ebreak_insn_execute_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    pb_ebreak_insn_execute_seq seq;

    phase.raise_objection(this);
    seq = pb_ebreak_insn_execute_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass



//===========================================================
//--------------------CSR WRITE TEST-------------------------
//===========================================================

class abs_cmd_csr_write_test extends uvm_test;

  `uvm_component_utils(abs_cmd_csr_write_test)

  jtag_env env;

  function new(string name="abs_cmd_csr_write_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    abs_cmd_csr_write_seq seq;

    phase.raise_objection(this);
    seq = abs_cmd_csr_write_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass


//==========================================================
//--------------------CSR READ TEST-------------------------
//==========================================================

class abs_cmd_csr_read_test extends uvm_test;

  `uvm_component_utils(abs_cmd_csr_read_test)

  jtag_env env;

  function new(string name="abs_cmd_csr_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    abs_cmd_csr_read_seq seq;

    phase.raise_objection(this);
    seq = abs_cmd_csr_read_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass




//=====================================================================
//--------------------CSR READ-WRITE-READ TEST-------------------------
//=====================================================================

class abs_cmd_csr_write_read_test extends uvm_test;

  `uvm_component_utils(abs_cmd_csr_write_read_test)

  jtag_env env;

  function new(string name="abs_cmd_csr_write_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    abs_cmd_csr_write_read_seq seq;

    phase.raise_objection(this);
    seq = abs_cmd_csr_write_read_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass

//=====================================================================
//-------------------------------GPR READ TEST--------------------------
//=====================================================================

class abs_cmd_gpr_read_test extends uvm_test;

  `uvm_component_utils(abs_cmd_gpr_read_test)

  jtag_env env;

  function new(string name="abs_cmd_gpr_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    abs_cmd_gpr_read_seq seq;

    phase.raise_objection(this);
    seq = abs_cmd_gpr_read_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass



// =============================================================================
// TRYING PB INSN EXECUTE + CSR/GPR REG READ/WRITE TEST 
// =============================================================================

class both_reg_access_pbinsn_execute_test extends uvm_test;

  `uvm_component_utils(both_reg_access_pbinsn_execute_test)

  jtag_env env;

  function new(string name="both_reg_access_pbinsn_execute_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    both_reg_access_pbinsn_execute_seq seq;

    phase.raise_objection(this);
    seq = both_reg_access_pbinsn_execute_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass




// =============================================================================
// TRYING PB INSN EXECUTE + CSR/GPR REG READ/WRITE TEST WITHOUT HALT
// =============================================================================

class without_halt_trigger_ace_test extends uvm_test;

  `uvm_component_utils(without_halt_trigger_ace_test)

  jtag_env env;

  function new(string name="without_halt_trigger_ace_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    without_halt_trigger_ace_seq seq;

    phase.raise_objection(this);
    seq = without_halt_trigger_ace_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass




// =============================================================================
// TRYING PB INSN EXECUTE + CSR/GPR REG READ/WRITE TEST with a INVALID CMD_TYPE
// cmd_type != 0
// =============================================================================

class invalid_cmdtype_test extends uvm_test;

  `uvm_component_utils(invalid_cmdtype_test)

  jtag_env env;

  function new(string name="invalid_cmdtype_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    invalid_cmdtype_seq seq;

    phase.raise_objection(this);
    seq = invalid_cmdtype_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass





// =============================================================================
// TRYING PB INSN EXECUTE + CSR/GPR REG READ/WRITE TEST 
// BUT WRITTEN COMMAND VALUE WHICH IS NOT SUPPORT FOR BOTH 
// SET abstract_cmderr = 3'b100
// =============================================================================

class unsupport_command_value_test extends uvm_test;

  `uvm_component_utils(unsupport_command_value_test)

  jtag_env env;

  function new(string name="unsupport_command_value_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    unsupport_command_value_seq seq;

	phase.raise_objection(this);
    seq = unsupport_command_value_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass




// =============================================================================
// TRYING PB INSN EXECUTE + CSR/GPR REG READ/WRITE TEST 
// BUT WRITTEN COMMAND VALUE WHICH IS NOT SUPPORT FOR BOTH 
// SET abstract_cmderr = 3'b100
// Clearing stcky error
// Now trying with a valid command value
// =============================================================================

class clear_sticky_error_test extends uvm_test;

  `uvm_component_utils(clear_sticky_error_test)

  jtag_env env;

  function new(string name="clear_sticky_error_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    clear_sticky_error_seq seq;

    phase.raise_objection(this);
    seq = clear_sticky_error_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass




// ============================================================================================
// Writing the test for reading HALTSUM0 REG WHEN THE CORE IS HALT and WHEN THE CORE IS RUNNING
// IF CORE IS HALT EXPECTING resp_rdata_dbg = 32'h00000001;
// IF CORE IS RUNNING EXPECTING resp_rdata_dbg = 32'h00000000;
// ============================================================================================

class read_haltsum0_reg_test extends uvm_test;

  `uvm_component_utils(read_haltsum0_reg_test)

  jtag_env env;

  function new(string name="read_haltsum0_reg_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    read_haltsum0_reg_seq seq;

	phase.raise_objection(this);
    seq = read_haltsum0_reg_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass



// ============================================================================================
// Writing the TEST for WRITE & READ FOR DATA REGISTER
// ============================================================================================

class data_reg_wr_rd_test extends uvm_test;

  `uvm_component_utils(data_reg_wr_rd_test)

  jtag_env env;

  function new(string name="data_reg_wr_rd_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    data_reg_wr_rd_seq seq;

	phase.raise_objection(this);
    seq = data_reg_wr_rd_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass



// ============================================================================================
// Writing the TEST for WRITE & READ FOR PROGBUF REGISTER
// ============================================================================================

class progbuf_reg_wr_rd_test extends uvm_test;

  `uvm_component_utils(progbuf_reg_wr_rd_test)

  jtag_env env;

  function new(string name="progbuf_reg_wr_rd_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    progbuf_reg_wr_rd_seq seq;

	phase.raise_objection(this);
    seq = progbuf_reg_wr_rd_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass



// ============================================================================================
// INVALID ADDR ACCESS (UNMAPPED ADDRESS) TEST
// ============================================================================================

class invalid_addr_write_read_test extends uvm_test;

  `uvm_component_utils(invalid_addr_write_read_test)

  jtag_env env;

  function new(string name="invalid_addr_write_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    invalid_addr_write_read_seq seq;

	phase.raise_objection(this);
    seq = invalid_addr_write_read_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass





//========================================================================
// DM REGISTER WRITE/READ TEST (build for only to cover toggle coverge)
//========================================================================
class dm_reg_wr_rd_test extends uvm_test;

  `uvm_component_utils(dm_reg_wr_rd_test)

  jtag_env env;

  function new(string name="dm_reg_wr_rd_testdm_reg_wr_rd_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    dm_reg_wr_rd_seq seq;

	phase.raise_objection(this);
    seq = dm_reg_wr_rd_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);

  endtask

endclass



class idcode_test extends uvm_test;
 
  `uvm_component_utils(idcode_test)
 
  jtag_env env;
 
  function new(string name = "idcode_test", uvm_component parent);
    super.new(name, parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env", this);
  endfunction
 
  task run_phase(uvm_phase phase);
    idcode_seq seq;
    phase.raise_objection(this);
    seq = idcode_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);
  endtask
 
endclass

class cpu_halt_test extends uvm_test;

  `uvm_component_utils(cpu_halt_test)

  jtag_env env;

  function new(string name="cpu_halt_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    cpu_halt_seq seq;

    phase.raise_objection(this);

    seq = cpu_halt_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass






class cpu_resume_test extends uvm_test;

  `uvm_component_utils(cpu_resume_test)

  jtag_env env;

  function new(string name="cpu_resume_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    cpu_resume_seq seq;

    phase.raise_objection(this);

    seq = cpu_resume_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass




class imem_single_write_test extends uvm_test;

  `uvm_component_utils(imem_single_write_test)

  jtag_env env;

  function new(string name="imem_single_write_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    imem_single_write_seq seq;

    phase.raise_objection(this);

    seq = imem_single_write_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class imem_write_read_test extends uvm_test;

  `uvm_component_utils(imem_write_read_test)

  jtag_env env;

  function new(string name="imem_write_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    imem_write_read_seq seq;

    phase.raise_objection(this);

    seq = imem_write_read_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class imem_read_test extends uvm_test;

  `uvm_component_utils(imem_read_test)

  jtag_env env;

  function new(string name="imem_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    imem_read_seq seq;

    phase.raise_objection(this);

    seq = imem_read_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class pc_value_test extends uvm_test;

  `uvm_component_utils(pc_value_test)

  jtag_env env;

  function new(string name="pc_value_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    pc_value seq;

    phase.raise_objection(this);

    seq = pc_value::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class imem_write_readback_test extends uvm_test;

  `uvm_component_utils(imem_write_readback_test)

  jtag_env env;

function new(string name="imem_write_readback_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    imem_write_readback_seq seq;

    phase.raise_objection(this);

    seq = imem_write_readback_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

// DMEM SINGLE WRITE TEST


class dmem_single_write_test extends uvm_test;

  `uvm_component_utils(dmem_single_write_test)

  jtag_env env;
function new(string name="dmem_single_write_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    dmem_single_write_seq seq;

    phase.raise_objection(this);

    seq = dmem_single_write_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class sba_memory_read_test extends uvm_test;

  `uvm_component_utils(sba_memory_read_test)

  jtag_env env;
function new(string name="dmem_single_write_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_dmem_compare_seq seq;

    phase.raise_objection(this);

    seq = sba_dmem_compare_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass



class boot_flow_test extends uvm_test;

  `uvm_component_utils(boot_flow_test)

  jtag_env env;

  function new(string name="boot_flow_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = jtag_env::type_id::create("env",this);

  endfunction

  task run_phase(uvm_phase phase);

    boot_flow_seq seq;

    phase.raise_objection(this);

    seq = boot_flow_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

       phase.drop_objection(this);

  endtask

endclass


class cpu_hang_pc_test extends uvm_test;

  `uvm_component_utils(cpu_hang_pc_test)

  jtag_env env;

function new(string name="cpu_hang_pc_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    cpu_hang_pc_seq seq;

    phase.raise_objection(this);

    seq = cpu_hang_pc_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass



class runtime_debug_after_boot_test extends uvm_test;

  `uvm_component_utils(runtime_debug_after_boot_test)

  jtag_env env;

function new(string name="runtime_debug_after_boot_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    runtime_debug_after_boot_seq seq;

    phase.raise_objection(this);

    seq = runtime_debug_after_boot_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass



//================================ TESTS ENDS HERE =====================================//


//======================= TESTS Added by Shilpa ==========================//

//dmi write
class dmi_write_test extends uvm_test;

  `uvm_component_utils(dmi_write_test)

  jtag_env env;

  function new(string name="dmi_write_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    dbg_dmi_write_seq seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = dbg_dmi_write_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


//dmi read
class dmi_read_test extends uvm_test;

  `uvm_component_utils(dmi_read_test)

  jtag_env env;

  function new(string name="dmi_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

   dmi_read_seq seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = dmi_read_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


//dmi no op
class dmi_no_op_test extends uvm_test;

  `uvm_component_utils(dmi_no_op_test)

  jtag_env env;

  function new(string name="dmi_no_op_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

     dmi_nop_seq seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = dmi_nop_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

//dmi back2back op
class dmi_back2back_test extends uvm_test;

  `uvm_component_utils(dmi_back2back_test)

  jtag_env env;

  function new(string name="dmi_back2back_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    dmi_back2back_seq seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = dmi_back2back_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

//dmi invalid 
class dmi_invalid_test extends uvm_test;

  `uvm_component_utils(dmi_invalid_test)

  jtag_env env;

  function new(string name="dmi_invalid_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    cpu_debug_invalid_flow_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = cpu_debug_invalid_flow_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


//dmi random 
class debug_random_test extends uvm_test;

  `uvm_component_utils(debug_random_test)

  jtag_env env;

  function new(string name="debug_random_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    random_cpu_debug_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = random_cpu_debug_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


//integration write 
class integration_write_test extends uvm_test;

  `uvm_component_utils(integration_write_test)

  jtag_env env;

  function new(string name="integration_write_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

     integration_write_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq =  integration_write_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

//intgration read seq 
class  int_read_test extends uvm_test;

  `uvm_component_utils( int_read_test)

  jtag_env env;

  function new(string name=" int_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

   integration_read_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = integration_read_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

//sba idle  seq 
class  sba_idle_test extends uvm_test;

  `uvm_component_utils( sba_idle_test)

  jtag_env env;

  function new(string name="sba_idle_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

   sba_idle_stability_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = sba_idle_stability_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

//error handling seq 
class  error_handling_test extends uvm_test;

  `uvm_component_utils( error_handling_test)

  jtag_env env;

  function new(string name=" error_handling_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    error_handling_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq =  error_handling_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass



//idle seq 
class  idle_seq_test extends uvm_test;

  `uvm_component_utils( idle_seq_test)

  jtag_env env;

  function new(string name=" idle_seq_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

   idle_case_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = idle_case_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


//ace bg seq 
class  ace_busy_test extends uvm_test;

  `uvm_component_utils(ace_busy_test)

  jtag_env env;

  function new(string name="ace_busy_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

  ace_busy_seq  seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq = ace_busy_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

//ace unsprt seq 
class  ace_unsprt_test extends uvm_test;

  `uvm_component_utils( ace_unsprt_test)

  jtag_env env;

  function new(string name=" ace_unsprt_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction


  task run_phase(uvm_phase phase);

  ace_cmderr_unsupported_seq seq;

    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,800ns);		

    seq =ace_cmderr_unsupported_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

//-------GPIO-------------------
class gpio_reset_test extends soc_base_test;

    `uvm_component_utils(gpio_reset_test)


    function new(string name = "gpio_reset_test", uvm_component parent = null);

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        boot_flow();


        `uvm_info("GPIO_RESET_TEST","Asserting GPIO reset",UVM_MEDIUM)
	
	 wait(handshake_from_c_to_sv);

        handshake_from_c_to_sv = 0;


         
        `uvm_info("GPIO_RESET_TEST","GPIO reset verification completed",UVM_MEDIUM)


        phase.drop_objection(this);

    endtask

endclass


class gpio_non_gpio_access_test extends soc_base_test;

    `uvm_component_utils(gpio_non_gpio_access_test)


    function new(string name = "gpio_non_gpio_access_test",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        phase.raise_objection(this);
       
        boot_flow();
         
        wait(handshake_from_c_to_sv);

        handshake_from_c_to_sv = 0;


        `uvm_info("GPIO_NON_GPIO_TEST","Non-GPIO access test completed", UVM_MEDIUM);


        phase.drop_objection(this);

    endtask

endclass

class gpio_invalid_addr_test extends soc_base_test;

    `uvm_component_utils(gpio_invalid_addr_test)


    function new(string name = "gpio_invalid_addr_test",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        phase.raise_objection(this);


        boot_flow();


        `uvm_info("GPIO_INVALID_ADDR_TEST",
                  "C is ready for invalid GPIO address accesses",UVM_MEDIUM);
 	wait(handshake_from_c_to_sv);

        handshake_from_c_to_sv = 0;


               `uvm_info("GPIO_INVALID_ADDR_TEST","Invalid GPIO address test completed",UVM_MEDIUM);


        phase.drop_objection(this);

    endtask

endclass

class gpio_output_test extends soc_base_test;

    `uvm_component_utils(gpio_output_test)

    function new( string name = "gpio_output_test", uvm_component parent = null );
        super.new(name,parent);
    endfunction


    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        boot_flow();

        repeat(4 + NUM_GPIO)
        begin

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            /*
             * GPIO monitor + APB monitor +
             * scoreboard verify the operation.
             */

            handshake_from_sv_to_c = 1;

        end

        phase.drop_objection(this);

    endtask

endclass

class gpio_input_test extends soc_base_test;

    `uvm_component_utils(gpio_input_test)


    function new(string name = "gpio_input_test",uvm_component parent = null);

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        gpio_input_seq #(NUM_GPIO) seq;

        phase.raise_objection(this);

        boot_flow();


        // ============================================================
        // 27 patterns
        //
        // 0  -> All zeros
        // 1  -> All ones
        // 2  -> 101010...
        // 3  -> 010101...
        // 4-26 -> One-hot
        // ============================================================

        for (int i = 0; i < (4 + NUM_GPIO); i++)
        begin

            // --------------------------------------------------------
            // Wait for C to be ready for the next pattern
            // --------------------------------------------------------

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;


            // --------------------------------------------------------
            // Create sequence for ONE pattern
            // --------------------------------------------------------

            seq = gpio_input_seq #(NUM_GPIO)::type_id::create(
                    $sformatf("gpio_input_seq_%0d", i)
                  );


            seq.pattern_index = i;


            // --------------------------------------------------------
            // Drive ONE pattern
            // --------------------------------------------------------

            seq.start(env_h.gpio_agent_h.sequencer);


            // --------------------------------------------------------
            // Inform C that this pattern has been driven
            // --------------------------------------------------------

            handshake_from_sv_to_c = 1;


            `uvm_info("GPIO_INPUT_TEST",$sformatf("Completed pattern %0d", i),UVM_MEDIUM);

        end

        // ------------------------------------------------------------
        // Release GPIO pins
        // ------------------------------------------------------------

        env_h.gpio_agent_h.driver.vif.release_gpio();

        phase.drop_objection(this);

    endtask

endclass

class gpio_set_clr_toggle_test extends soc_base_test;

    `uvm_component_utils(gpio_set_clr_toggle_test)


    function new(string name = "gpio_set_clr_toggle_test", uvm_component parent = null);

        super.new(name,parent);

    endfunction


    task run_phase( uvm_phase phase );

        phase.raise_objection(this);

        boot_flow();

        repeat(130)
        begin

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;


            /*
             * APB TLM FIFO captures every SET/CLR/TOGGLE
             * access. Scoreboard updates expected_gpio
             * in FIFO order.
             */


            handshake_from_sv_to_c = 1;

        end

    phase.phase_done.set_drain_time(this,100000ns);

        phase.drop_objection(this);

    endtask

endclass

//==============================================================================
// GPIO PINMUX TEST
//==============================================================================

class gpio_pinmux_test extends soc_base_test;

    `uvm_component_utils(gpio_pinmux_test)

    function new(string name = "gpio_pinmux_test", uvm_component parent = null);
        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        gpio_input_drive_seq #(NUM_GPIO) seq;

        phase.raise_objection(this);

        //======================================================================
        // Boot
        //======================================================================

        boot_flow();

        //======================================================================
        // Initial configuration handshake
        //
        // C:
        //   PINMUX0
        //   PINMUX1
        //   PINMUX2
        //   GPIO_DIR = GPIO_MASK
        //   send_handshake_to_sv()
        //
        // SV:
        //   wait()
        //   acknowledge
        //======================================================================

        wait(handshake_from_c_to_sv);

        handshake_from_c_to_sv = 0;

        `uvm_info("GPIO_PINMUX_TEST", "Initial GPIO configuration received from C", UVM_MEDIUM);

        handshake_from_sv_to_c = 1;


        //======================================================================
        // FUNC0 - FUNC4
        //======================================================================

        for (int func = 0; func <= 4; func++)
        begin

            `uvm_info("GPIO_PINMUX_TEST", $sformatf("======================================"), UVM_LOW);

            `uvm_info("GPIO_PINMUX_TEST", $sformatf("Starting PINMUX FUNC%0d", func), UVM_LOW);

            //==================================================================
            // PINMUX CONFIGURATION
            //==================================================================

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            `uvm_info("GPIO_PINMUX_TEST", $sformatf("FUNC%0d configuration received", func), UVM_MEDIUM);

            // ---------------------------------------------------------
            // C is waiting here
            // ---------------------------------------------------------

            handshake_from_sv_to_c = 1;

            //==================================================================
            // ALL OUTPUT - OUT = 0
            //==================================================================

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            `uvm_info("GPIO_PINMUX_TEST", "ALL OUTPUT : OUT = 0", UVM_MEDIUM);

            // No SV GPIO driving required.
            //
            // GPIO_DIR = 1 for all GPIOs.
            // Driver must release GPIOs.

            #1ns;

            handshake_from_sv_to_c = 1;

            //==================================================================
            // ALL OUTPUT - OUT = 1
            //==================================================================

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            `uvm_info("GPIO_PINMUX_TEST", "ALL OUTPUT : OUT = GPIO_MASK", UVM_MEDIUM);

            // GPIOs are still outputs.
            // SV releases them.

            #1ns;

            handshake_from_sv_to_c = 1;


            //==================================================================
            // ALL INPUT - DRIVE 0
            //==================================================================

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            `uvm_info("GPIO_PINMUX_TEST", "ALL INPUT : SV drives 0", UVM_MEDIUM);

            // ---------------------------------------------------------
            // Create input sequence
            // ---------------------------------------------------------

            seq =  gpio_input_drive_seq #(NUM_GPIO):: type_id::create( $sformatf("gpio_input_seq_0_func%0d", func));

            seq.drive_value = '0;

            // ---------------------------------------------------------
            // Drive GPIO input pins
            // ---------------------------------------------------------

            seq.start(env_h.gpio_agent_h.sequencer);

            // Allow GPIO driver to update interface
            #1ns;

            // ---------------------------------------------------------
            // Tell C that GPIOs are ready
            // ---------------------------------------------------------

            handshake_from_sv_to_c = 1;

            //==================================================================
            // ALL INPUT - DRIVE 1
            //==================================================================

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            `uvm_info("GPIO_PINMUX_TEST", "ALL INPUT : SV drives GPIO_MASK", UVM_MEDIUM);

            seq = gpio_input_drive_seq #(NUM_GPIO):: type_id::create($sformatf("gpio_input_seq_1_func%0d", func));

            seq.drive_value = GPIO_MASK;

            seq.start(env_h.gpio_agent_h.sequencer);

            #1ns;

            handshake_from_sv_to_c = 1;

            //==================================================================
            // MIXED DIRECTION - PATTERN 1
            //==================================================================

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            `uvm_info("GPIO_PINMUX_TEST","MIXED DIRECTION : Pattern 1",UVM_MEDIUM);

            seq = gpio_input_drive_seq #(NUM_GPIO):: type_id::create($sformatf("gpio_mixed_seq_1_func%0d", func));


            // SV input data
            //
            // 010101010101...
            //
            seq.drive_value = 23'h555555;

            seq.start(env_h.gpio_agent_h.sequencer);

            #1ns;

            handshake_from_sv_to_c = 1;

            //==================================================================
            // MIXED DIRECTION - PATTERN 2
            //==================================================================

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;

            `uvm_info("GPIO_PINMUX_TEST","MIXED DIRECTION : Pattern 2",UVM_MEDIUM);

            seq = gpio_input_drive_seq #(NUM_GPIO):: type_id::create($sformatf("gpio_mixed_seq_2_func%0d", func));

            // SV input data
            //
            // 101010101010...
            //
            seq.drive_value = 23'h2AAAAA;

            seq.start(env_h.gpio_agent_h.sequencer);

            #1ns;

            handshake_from_sv_to_c = 1;

            `uvm_info("GPIO_PINMUX_TEST",$sformatf("Completed PINMUX FUNC%0d", func), UVM_LOW);

        end


        //======================================================================
        // Release GPIOs
        //======================================================================

        env_h.gpio_agent_h.driver.vif.release_gpio();


        phase.drop_objection(this);

    endtask

endclass


class gpio_random_test extends soc_base_test;

    `uvm_component_utils(gpio_random_test)


    function new(string name = "gpio_random_test", uvm_component parent = null);

        super.new(name,parent);

    endfunction


    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        boot_flow();

        repeat(1000)
        begin

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;


            handshake_from_sv_to_c = 1;

        end


        phase.drop_objection(this);

    endtask

endclass


class gpio_stress_test extends soc_base_test;

    `uvm_component_utils(gpio_stress_test)


    function new(string name = "gpio_stress_test", uvm_component parent = null);

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        gpio_stress_seq #(NUM_GPIO) seq;

        phase.raise_objection(this);

        boot_flow();


        // ============================================================
        // Wait for C initial configuration
        //
        // C has:
        //   PINMUX0
        //   PINMUX1
        //   PINMUX2
        //   GPIO_DIR = GPIO_MASK
        // ============================================================

        wait(handshake_from_c_to_sv);

        handshake_from_c_to_sv = 0;


        `uvm_info("GPIO_STRESS_TEST",
                  "Initial GPIO configuration received from C",
                  UVM_MEDIUM);


        // C is waiting for SV response
        handshake_from_sv_to_c = 1;


        // ============================================================
        // Stress iterations
        // ============================================================

        for (int i = 0; i < 10000; i++)
        begin

            // --------------------------------------------------------
            // Wait for C to:
            //
            // 1. Optionally change GPIO_DIR
            // 2. Perform SET / CLR / TOGGLE
            // 3. Send handshake
            // --------------------------------------------------------

            wait(handshake_from_c_to_sv);

            handshake_from_c_to_sv = 0;


            `uvm_info("GPIO_STRESS_TEST",
                      $sformatf("Starting stress iteration %0d", i),
                      UVM_HIGH);


            // --------------------------------------------------------
            // Create sequence for ONE random input pattern
            // --------------------------------------------------------

            seq = gpio_stress_seq #(NUM_GPIO)::type_id::create($sformatf("gpio_stress_seq_%0d", i));


            // --------------------------------------------------------
            // Drive ONE random GPIO pattern
            //
            // gpio_if will automatically release GPIO_DIR=1 pins.
            // --------------------------------------------------------

            seq.start(env_h.gpio_agent_h.sequencer);


            // --------------------------------------------------------
            // Tell C that SV has driven the GPIO pins
            //
            // C will now perform:
            //
            // mmio_read(GPIO_IN)
            //
            // which generates PRDATA.
            // --------------------------------------------------------

            handshake_from_sv_to_c = 1;


            `uvm_info("GPIO_STRESS_TEST",
                      $sformatf("Completed stress iteration %0d", i),
                      UVM_HIGH);

        end


        // ============================================================
        // Release GPIO pins
        // ============================================================

        env_h.gpio_agent_h.driver.vif.release_gpio();


        phase.drop_objection(this);

    endtask

endclass


//preboot memory mapping
class  preboot_test extends uvm_test;

  `uvm_component_utils(preboot_test)

  jtag_env env;

  function new(string name="preboot_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

 preboot_seq  seq;

    phase.raise_objection(this);		

    seq =  preboot_seq ::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass


class bypass_reg_test extends uvm_test;

  `uvm_component_utils(bypass_reg_test)

  jtag_env env;

function new(string name="bypass_reg_test",uvm_component parent=null);
super.new(name,parent);
endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    bypass_reg_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = bypass_reg_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

class sba_readonaddr_toggle_test extends uvm_test;

  `uvm_component_utils(sba_readonaddr_toggle_test)

  jtag_env env;

function new(string name="sba_readonaddr_toggle_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_readonaddr_toggle_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_readonaddr_toggle_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass



class sba_readondata_toggle_test extends uvm_test;

  `uvm_component_utils(sba_readondata_toggle_test)

  jtag_env env;

function new(string name="sba_readondata_toggle_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = jtag_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);

    sba_readondata_toggle_seq seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,800ns);	

    seq = sba_readondata_toggle_seq::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass



//----------------------------------------------------
// soc_traceIP_uart_integrity_test
//----------------------------------------------------
class soc_traceIP_uart_integrity_test extends uart_base_test;

  `uvm_component_utils(soc_traceIP_uart_integrity_test)

  uart_slave_model slave;

  // Must match divs[] in C exactly (values, order, count)
  int unsigned divs[] = '{ 27,326 };

  // Must match rx_bytes[] in C exactly
  byte unsigned rx_bytes[] = '{ 8'h5A, 8'h3C, 8'hE1 };

  // Must match uart_init() args on the C side
  int unsigned clk_mhz = 200;
  osm_e        osm     = OSM_16X;

  function new(string name="uart_baud_config_test", uvm_component parent);
    super.new(name,parent);
  endfunction
 
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(this,"*","is_error_test",1'b1);
    endfunction


  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST","==== uart_baud_config_test ====",UVM_NONE)

    slave = env_h.uart_agent_soc.slave_model;
    if(slave==null)
      `uvm_fatal("TEST","Slave handle is NULL")

    run_init();
    boot_flow();

    foreach(divs[j]) begin

      //---------------------------------------------
      // TX phase: reconfigure slave baud for this divisor
      //---------------------------------------------
      wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;

      slave.set_baud(divs[j], clk_mhz, osm);
      slave.set_protocol(WLS_8, PAR_EVEN, STOP_1);

      `uvm_info("TEST",$sformatf("divs[%0d]=%0d -> baud reconfigured (TX phase)", j, divs[j]),UVM_LOW)

      handshake_from_sv_to_c = 1;

      //---------------------------------------------
      // RX phase: drive rx_bytes[j] on RXD at this baud
      //---------------------------------------------
      wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;

    //  slave.send_byte(rx_bytes[j]);
     slave.send_byte(8'hA5,.pe(1));
     slave.send_byte(8'h44,.fe(1));
     slave.send_byte(8'h00,.brk(1));		

      `uvm_info("TEST",$sformatf("divs[%0d]=%0d -> sent rx_bytes[%0d]=8'h%0h",j, divs[j], j, rx_bytes[j]),UVM_LOW)

      handshake_from_sv_to_c = 1;
    end

     wait(handshake_from_c_to_sv);
      handshake_from_c_to_sv = 0;
    slave.send_byte(8'h35);
    slave.send_byte(8'h55);
      handshake_from_sv_to_c = 1;


    // final single-shot handshake at end of C test
    wait(handshake_from_c_to_sv);
    handshake_from_c_to_sv = 0;
    handshake_from_sv_to_c = 1;

    phase.phase_done.set_drain_time(this,3000000ns);
    phase.drop_objection(this);
  endtask

endclass





