import uvm_pkg::*;
`include "uvm_macros.svh"


class sf0_enable_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(sf0_enable_sequence)

  trace_transaction tr;
  //bit [2:0] context_value;

  
  function new(string name = "sf0_enable_sequence");
    super.new(name);
  endfunction

  virtual task body();

    //--------------------------------------------------
    // SF0 Packet
    //--------------------------------------------------

    tr = trace_transaction::type_id::create("sf0_pkt");

    start_item(tr);

    // APB Enable
    tr.paddr_i  = 8'h00;
    tr.pwrite_i = 1'b1;
    tr.pwdata_i = 32'h00000001;

    // SF0 Trace Inputs
    tr.it_itype = 4'd2;


/*
    tr.it_iaddr = $urandom_range('hFFFFF, 'h0);

    tr.it_cause = 8'h00;
    tr.it_tval  = 20'h00000;

    tr.it_priv    = 3'd0;
    tr.it_context = 3'd0;
*/

tr.it_iaddr = $urandom_range('hFFFF, 'h0);

tr.it_cause = 8'h00;
tr.it_tval  = 32'h00000000;

tr.it_context = 2'd0;


    //--------------------------------------------------
    // Enable SF0 packet generation
    //--------------------------------------------------

    tr.it_ienable_in            = 1'b0;
    tr.it_itype_valid           = 1'b1;

    // IMPORTANT: SF0 indication
    tr.it_first_instrn_valid_in = 1'b1;

    tr.it_delta_addr     = 20'h00000;
    tr.it_del_adr_valid  = 1'b0;

    tr.afvalid_i = 1'b0;
    tr.atready_i = 1'b1;

    finish_item(tr);

  endtask

endclass



class sf1_enable_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(sf1_enable_sequence)

  trace_transaction tr;

  function new(string name = "sf1_enable_sequence");
    super.new(name);
  endfunction

  virtual task body();

    //--------------------------------------------------
    // SF1 Packet
    //--------------------------------------------------

    tr = trace_transaction::type_id::create("sf1_pkt");

    start_item(tr);

    // APB Enable
    tr.paddr_i  = 8'h00;
    tr.pwrite_i = 1'b1;
    tr.pwdata_i = 32'h00000001;

    // SF1 Trace Inputs
    tr.it_itype   = 4'd2;

/*


    tr.it_iaddr = $urandom_range('hFFFFF, 'h0);
    tr.it_cause = $urandom_range('hFF, 'h00);
    tr.it_tval  = $urandom_range('hFFFFF, 'h0);
    tr.it_priv  = $urandom_range(7,0);

    tr.it_context = 3'd0;
*/

    tr.it_iaddr = $urandom_range('hFFFF, 'h0);
    tr.it_cause = $urandom_range('hFF, 'h00);
    tr.it_tval  = $urandom_range('hFFFFFFFF, 'h00000000);
    tr.it_context = 2'd0;




    // Enable packet generation
    tr.it_ienable_in            = 1'b0;
    tr.it_itype_valid           = 1'b1;
    tr.it_first_instrn_valid_in = 1'b0;

    tr.it_delta_addr    = 20'h00000;
    tr.it_del_adr_valid = 1'b0;

    tr.afvalid_i = 1'b0;
    tr.atready_i = 1'b1;

    finish_item(tr);

  endtask

endclass



// to check the sf3 test for that i am creating sf1 test to make atready_i=0 

class sf1_fifo_fill_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(sf1_fifo_fill_sequence)

  trace_transaction tr;

  function new(string name = "sf1_fifo_fill_sequence");
    super.new(name);
  endfunction

  virtual task body();

    repeat(15)
    begin
      tr = trace_transaction::type_id::create("sf1_fifo_fill_pkt");

      start_item(tr);

      tr.paddr_i  = 8'h00;
      tr.pwrite_i = 1'b1;
      tr.pwdata_i = 32'h00000001;

      // SF1 inputs
      tr.it_itype   = 4'd2;
      tr.it_iaddr   = $urandom_range('hFFFF, 'h0000);
      tr.it_cause   = $urandom_range('hFF, 'h00);
      tr.it_tval    = $urandom_range('hFFFFFFFF, 'h00000000);
      tr.it_context = 2'b00;

      tr.it_ienable_in            = 1'b0;
      tr.it_itype_valid           = 1'b1;
      tr.it_first_instrn_valid_in = 1'b0;

      tr.it_delta_addr    = 20'h00000;
      tr.it_del_adr_valid = 1'b0;

      tr.afvalid_i = 1'b0;

      // Hold ATB so FIFO can fill
      tr.atready_i = 1'b0;

      finish_item(tr);
    end

  endtask

endclass






class disable_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(disable_sequence)

  trace_transaction tr;

  function new(string name = "disable_sequence");
    super.new(name);
  endfunction

  virtual task body();

    //--------------------------------------------------
    // Disable / Idle
    //--------------------------------------------------

    tr = trace_transaction::type_id::create("disable");

    start_item(tr);

    tr.it_itype   = 4'd0;

 /*
    tr.it_iaddr   = 20'h00000;
    tr.it_cause   = 8'h00;
    tr.it_tval    = 20'h00000;
    tr.it_priv    = 3'd0;
    tr.it_context = 3'd0;
*/


    tr.it_iaddr   = 16'h0000;
    tr.it_cause   = 8'h00;
    tr.it_tval    = 32'h00000000;
    tr.it_context = 2'd0;



    // Disable packet generation
    tr.it_ienable_in            = 1'b0;
    tr.it_itype_valid           = 1'b0;
    tr.it_first_instrn_valid_in = 1'b0;

    tr.it_delta_addr    = 20'h00000;
    tr.it_del_adr_valid = 1'b0;

    tr.afvalid_i = 1'b0;
    tr.atready_i = 1'b1;

    // APB
    tr.paddr_i  = 8'h00;
    tr.pwrite_i = 1'b1;
    tr.pwdata_i = 32'h00000001;

    finish_item(tr);

  endtask

endclass



class sf2_context_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(sf2_context_sequence)

  trace_transaction tr;

 // bit [2:0] context_value;

    bit [1:0] context_value;


  function new(string name = "sf2_context_sequence");
    super.new(name);
  endfunction

  virtual task body();

    tr = trace_transaction::type_id::create("sf2_context_pkt");

    start_item(tr);

    tr.paddr_i  = 8'h00;
    tr.pwrite_i = 1'b1;
    tr.pwdata_i = 32'h00000001;

    tr.it_itype = 4'd2;
/*
    tr.it_iaddr = 20'h12345;
    tr.it_cause = 8'h00;
    tr.it_tval  = 20'h00000;

    tr.it_priv    = 3'b011;       // FIXED
    tr.it_context = context_value; // VARIABLE
*/

tr.it_iaddr = 16'h2345;
tr.it_cause = 8'h00;
tr.it_tval  = 32'h00000000;

tr.it_context = context_value;



    tr.it_ienable_in            = 1'b0;
    tr.it_itype_valid           = 1'b1;
    tr.it_first_instrn_valid_in = 1'b0;

    tr.it_delta_addr    = 20'h00000;
    tr.it_del_adr_valid = 1'b0;

    tr.afvalid_i = 1'b0;
    tr.atready_i = 1'b1;

    finish_item(tr);

  endtask

endclass


class format2_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(format2_sequence)

  trace_transaction tr;

  function new(string name = "format2_sequence");
    super.new(name);
  endfunction

  virtual task body();

      tr = trace_transaction::type_id::create("format2_pkt");

      start_item(tr);

      // APB
      tr.paddr_i  = 8'h00;
      tr.pwrite_i = 1'b1;
      tr.pwdata_i = 32'h00000001;
      
      tr.atb_mode = 1'b0;

      // Format2 inputs
      tr.it_itype   = 4'b0101;
      tr.it_iaddr   = $urandom_range('hFFFF, 'h0000);
      tr.it_cause   = 8'h00;
      tr.it_tval    = 32'h00000000;
      tr.it_context = 2'b00;

      // Format2 enable conditions
      tr.it_ienable_in            = 1'b0;
      tr.it_itype_valid           = 1'b1;
      tr.it_first_instrn_valid_in = 1'b0;

      // Random Format2 delta address
      tr.it_delta_addr    = $urandom_range('hFFFFF, 'h00000);
      tr.it_del_adr_valid = 1'b1;

      tr.afvalid_i = 1'b0;
      tr.atready_i = 1'b1;

      finish_item(tr);



  endtask

endclass




class fifo_fill_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(fifo_fill_sequence)

  trace_transaction tr;

  function new(string name = "fifo_fill_sequence");
    super.new(name);
  endfunction

  virtual task body();

    // Send enough packets to fill FIFO
    repeat(30)
    begin

      tr = trace_transaction::type_id::create("fifo_fill_pkt");

      start_item(tr);

      // Trace inputs
      tr.it_itype   = 4'd2;

          tr.it_iaddr   = $urandom_range('hFFFF, 'h0);
    tr.it_cause   = $urandom_range('hFF, 'h00);
    tr.it_tval    = $urandom_range('hFFFFFFFF, 'h00000000);
    tr.it_context = 2'b00;


      // Normal valid trace transaction
      tr.it_ienable_in            = 1'b0;
      tr.it_itype_valid           = 1'b1;
      tr.it_first_instrn_valid_in = 1'b0;

      tr.it_delta_addr    = 20'h00000;
      tr.it_del_adr_valid = 1'b0;

      tr.afvalid_i = 1'b0;

      // IMPORTANT:
      // Do not allow ATB side to drain FIFO
      tr.atready_i = 1'b0;

      // APB fields
      tr.paddr_i  = 8'h00;
      tr.pwrite_i = 1'b1;
      tr.pwdata_i = 32'h00000001;

      finish_item(tr);

    end

  endtask

endclass






class atb_read_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(atb_read_sequence)

  trace_transaction tr;

  function new(string name = "atb_read_sequence");
    super.new(name);
  endfunction

  virtual task body();
  tr = trace_transaction::type_id::create("atb_read_pkt");

    start_item(tr);
    //--------------------------------------------------
    // No new trace packet
    //--------------------------------------------------
    tr.it_itype_valid           = 1'b0;
    tr.it_first_instrn_valid_in = 1'b0;
    tr.it_ienable_in            = 1'b0;

    //--------------------------------------------------
    // Allow ATB/FIFO read
    //--------------------------------------------------
    tr.atready_i = 1'b1;

    //--------------------------------------------------
    // No flush for now
    //--------------------------------------------------
    tr.afvalid_i = 1'b0;

    finish_item(tr);
  endtask
endclass







class trace_sequence extends uvm_sequence #(trace_transaction);

  `uvm_object_utils(trace_sequence)


  sf0_enable_sequence sf0_seq;
  sf1_enable_sequence sf1_seq;
  disable_sequence    disable_seq;
  sf2_context_sequence sf2_seq;
  format2_sequence format2_seq;
  fifo_fill_sequence fifo_fill_seq; 

  sf1_fifo_fill_sequence sf1_fifo_fill_seq;
  atb_read_sequence   atb_read_seq;
  



    bit [1:0] context1;
    bit [1:0] context2;

  function new(string name = "trace_sequence");
    super.new(name);
  endfunction

  virtual task body();

    //--------------------------------------------------
    // Create child sequences
    //--------------------------------------------------

     format2_seq = format2_sequence::type_id::create("format2_seq");
     //format2_seq = format2_sequence::type_id::create("format2_seq");
     //format2_seq = format2_sequence::type_id::create("format2_seq");
     //format2_seq = format2_sequence::type_id::create("format2_seq");
   
//sf1_seq.start(m_sequencer);
//sf1_seq.start(m_sequencer);

format2_seq.start(m_sequencer);
format2_seq.start(m_sequencer);
format2_seq.start(m_sequencer);

format2_seq.start(m_sequencer);
format2_seq.start(m_sequencer);
format2_seq.start(m_sequencer);

format2_seq.start(m_sequencer);
format2_seq.start(m_sequencer);

format2_seq.start(m_sequencer);
format2_seq.start(m_sequencer);
//sf1_fifo_fill_seq.start(m_sequencer);
//atb_read_seq.start(m_sequencer);

  endtask

endclass
