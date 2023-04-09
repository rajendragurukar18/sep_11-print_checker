import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_input_monitor extends uvm_monitor;

  `uvm_component_utils(trace_input_monitor)

  virtual trace_if vif;

  trace_transaction tr;

    bit current_atb_mode;


   bit current_trace_enable;

    bit        prev_itype_valid;
    bit [3:0]  prev_itype;
    bit [15:0] prev_iaddr;
    bit [7:0]  prev_cause;
    bit [31:0] prev_tval;
    bit [1:0]  prev_context;
    bit [19:0] prev_delta_addr;
    bit        prev_del_adr_valid;
    bit        prev_first_instr;
    //bit atb_mode;

  uvm_analysis_port #(trace_transaction) mon_ap;

  function new(string name="trace_input_monitor",
               uvm_component parent=null);

      super.new(name,parent);

      mon_ap = new("mon_ap",this);

  endfunction

  function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      if(!uvm_config_db#(virtual trace_if)::get(this,"","vif",vif))
          `uvm_fatal("IN_MON","Unable to get interface")
        //atb_mode = 1'b0;
        current_atb_mode = 1'b0;
	current_trace_enable = 1'b0;
  endfunction

task run_phase(uvm_phase phase);

  fork

    //==========================================================
    // APB MONITOR
    //==========================================================
    begin
      forever begin

        @(posedge vif.pclk_i);

  if (vif.psel_i &&
    vif.penable_i &&
    vif.pwrite_i &&
    vif.pready_o &&
    vif.paddr_i == 8'h00) begin

    current_trace_enable = vif.pwdata_i[0];
    current_atb_mode      = vif.pwdata_i[1];

end            
      end
    end


    //==========================================================
    // TRACE INPUT MONITOR
    //==========================================================
    begin
      forever begin

        @(posedge vif.core_clk_i);

     if (vif.it_itype_valid &&
    (
      !prev_itype_valid ||
      vif.it_itype              != prev_itype ||
      vif.it_iaddr              != prev_iaddr ||
      vif.it_cause              != prev_cause ||
      vif.it_tval               != prev_tval ||
      vif.it_context             != prev_context ||
     // vif.it_delta_addr         != prev_delta_addr ||
     // vif.it_del_adr_valid      != prev_del_adr_valid ||
      vif.it_first_instrn_valid_in != prev_first_instr
    )) begin           

          tr = trace_transaction::type_id::create("tr");

          tr.atb_mode = current_atb_mode;
	tr.trace_enable = current_trace_enable;


          tr.it_itype                 = vif.it_itype;
          tr.it_iaddr                 = vif.it_iaddr;
          tr.it_cause                 = vif.it_cause;
          tr.it_tval                  = vif.it_tval;
          tr.it_context               = vif.it_context;

          tr.it_ienable_in            = vif.it_ienable_in;
          tr.it_itype_valid           = vif.it_itype_valid;
          tr.it_first_instrn_valid_in = vif.it_first_instrn_valid_in;

          tr.it_delta_addr            = vif.it_delta_addr;
          tr.it_del_adr_valid         = vif.it_del_adr_valid;

          tr.afvalid_i                = vif.afvalid_i;
          tr.atready_i                = vif.atready_i;

          // APB inputs
          tr.paddr_i   = vif.paddr_i;
          tr.psel_i    = vif.psel_i;
          tr.penable_i = vif.penable_i;
          tr.pwrite_i  = vif.pwrite_i;
          tr.pwdata_i  = vif.pwdata_i;

/*
`uvm_info("IN_MON_DEBUG",
  $sformatf("SENT: valid=%0b itype=%04h iaddr=%04h del_valid=%0b delta=%05h first=%0b",
    vif.it_itype_valid,
    vif.it_itype,
    vif.it_iaddr,
    vif.it_del_adr_valid,
    vif.it_delta_addr,
    vif.it_first_instrn_valid_in),
  UVM_NONE)
*/

           mon_ap.write(tr);

    end

    // Update previous values every core clock
    prev_itype_valid = vif.it_itype_valid;
    prev_itype       = vif.it_itype;
    prev_iaddr       = vif.it_iaddr;
    prev_cause       = vif.it_cause;
    prev_tval        = vif.it_tval;
    prev_context     = vif.it_context;
    //prev_delta_addr  = vif.it_delta_addr;
   // prev_del_adr_valid = vif.it_del_adr_valid;
    prev_first_instr = vif.it_first_instrn_valid_in;

  end
end
  join

endtask

endclass

