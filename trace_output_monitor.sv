import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_output_monitor extends uvm_monitor;

   `uvm_component_utils(trace_output_monitor)

   //------------------------------------------------------------
   // Virtual Interface
   //------------------------------------------------------------
   virtual trace_if vif;

   //------------------------------------------------------------
   // Transaction Handle
   //------------------------------------------------------------
   trace_transaction tr;

	int output_count = 0;
   //------------------------------------------------------------
   // Analysis Port
   //------------------------------------------------------------
   uvm_analysis_port #(trace_transaction) mon_ap;

   //------------------------------------------------------------
   // Constructor
   //------------------------------------------------------------
   function new(string name="trace_output_monitor",
   uvm_component parent = null);

      super.new(name, parent);

      mon_ap = new("mon_ap", this);

   endfunction

   //------------------------------------------------------------
   // Build Phase
   //------------------------------------------------------------
   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      if(!uvm_config_db #(virtual trace_if)::get(this, "", "vif", vif))
         `uvm_fatal("MON", "Unable to get Virtual Interface")

   endfunction

   //------------------------------------------------------------
   // Run Phase
   //------------------------------------------------------------
   virtual task run_phase(uvm_phase phase);

      forever begin

         //-------------------------------------------------------
         // Wait for DUT Output
         //-------------------------------------------------------
         @(posedge vif.it_clk);
   if(vif.atvalid_o && vif.atready_i)
begin
    `uvm_info("MON_CLK",
         $sformatf("CLK : atvalid=%0d atready=%0d atdata=%h",
                 vif.atvalid_o,
                 vif.atready_i,
                 vif.atdata_o),
        UVM_LOW)
end    

         //-------------------------------------------------------
         // Capture only valid packet
         //-------------------------------------------------------
 if (vif.atvalid_o && vif.atready_i)
begin

    tr = trace_transaction::type_id::create("tr");

    // Capture DUT outputs
    tr.afready_o = vif.afready_o;
    tr.atvalid_o = vif.atvalid_o;
    tr.atdata_o  = vif.atdata_o;

    // APB outputs
    tr.prdata_o  = vif.prdata_o;
    tr.pready_o  = vif.pready_o;
    tr.pslverr_o = vif.pslverr_o;


    // Print only first 50 ATB transfers
    if (output_count < 50) begin

        `uvm_info("MONITOR",
          $sformatf("Captured : atvalid=%0d atdata=%h",
            tr.atvalid_o,
            tr.atdata_o),
          UVM_LOW)

        $display("--------------------------------");
        $display("TIME=%0t", $time);
        $display("ATVALID=%0b", vif.atvalid_o);
        $display("ATDATA = %04h", vif.atdata_o);

        output_count++;

    end


    // ALWAYS send transaction to scoreboard
    mon_ap.write(tr);

end
      end

   endtask

endclass
