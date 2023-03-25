import uvm_pkg::*;
`include "uvm_macros.svh"

`uvm_analysis_imp_decl(_IN)
`uvm_analysis_imp_decl(_OUT)

class trace_scoreboard_sf0 extends uvm_scoreboard;

  `uvm_component_utils(trace_scoreboard_sf0)

  //------------------------------------------------------------
  // Analysis Ports
  //------------------------------------------------------------
  uvm_analysis_imp_IN #(trace_transaction, trace_scoreboard_sf0) in_imp;
  uvm_analysis_imp_OUT #(trace_transaction, trace_scoreboard_sf0) out_imp;

  //------------------------------------------------------------
  // Transactions
  //------------------------------------------------------------
  //--------------------------------------------------------------------------
// Transactions
//--------------------------------------------------------------------------
trace_transaction input_tr;
trace_transaction output_tr;

//--------------------------------------------------------------------------
// SF0 Expected Packet
//--------------------------------------------------------------------------
/*
typedef struct {

  bit [15:0] word0;
  bit [15:0] word1;
  bit [15:0] word2;
  bit [15:0] word3;

} sf0_packet_t;
*/

typedef struct {

  // Existing 16-bit ATB words
  bit [15:0] word0;
  bit [15:0] word1;
  bit [15:0] word2;
  bit [15:0] word3;

  // 8-bit ATB mode words
  bit [15:0] byte_word0;
  bit [15:0] byte_word1;
  bit [15:0] byte_word2;
  bit [15:0] byte_word3;
  bit [15:0] byte_word4;
  bit [15:0] byte_word5;
  bit [15:0] byte_word6;
  bit [15:0] byte_word7;

  // ATB configuration
  bit atb_mode;

} sf0_packet_t;




// Queue to store predicted packets
sf0_packet_t expected_queue[$];

// Temporary packet
sf0_packet_t exp_pkt;

// Compare counter
int compare_count;

bit packet_started;

sf0_packet_t curr_pkt;

//------------------------------------------------------------
// Predictor Variables
//------------------------------------------------------------
bit        branch_tmp;
bit ienable_tmp;

bit interrupt_tmp;
//bit thaddr_tmp;
bit sf3_predicted;

bit [2:0] header_field;
//bit [1:0] format_field;
//bit [1:0] subformat_field;

bit [63:0] expected_packet;

// SF2 Context Tracking
//------------------------------------------------------------
bit [1:0] prev_context;
bit       prev_context_valid;


// Format1 tracking

bit [30:0] branch_map_predict;
bit [30:0] branch_map_predict_d;
int format2_count;
bit format1_predicted;
bit format1_pending;


//------------------------------------------------------------
// SF3 Tracking
//------------------------------------------------------------
int sf3_input_count;
bit sf3_test_mode;

// Virtual Interface
//------------------------------------------------------------
virtual trace_if vif;

// Previous SF3 valid state
bit sf3_valid_d;

  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------
  function new(string name="trace_scoreboard_sf0",
               uvm_component parent=null);
    super.new(name,parent);

    in_imp  = new("in_imp", this);
    out_imp = new("out_imp", this);
  endfunction

  //------------------------------------------------------------
  // Build Phase
  //------------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
if(!uvm_config_db #(virtual trace_if)::get(this, "", "vif", vif))
    `uvm_fatal("SB", "Unable to get Virtual Interface")

    sf3_valid_d = 1'b0;
    header_field    = 3'b010;
    sf3_predicted = 1'b0;

    //format_field    = 2'b11;
    //subformat_field = 2'b00;
    compare_count = 0;
    packet_started = 0;

    // SF2 Context Tracking Initialization
    //------------------------------------------------------------
    prev_context       = 2'b00;
    prev_context_valid = 1'b0;
    
    sf3_input_count = 0;
    sf3_test_mode   = 1'b0;

    format2_count     = 0;
    format1_predicted = 1'b0;
    branch_map_predict = 31'b0;
    format1_pending    =1'b0;
    branch_map_predict_d = 31'b0;
    
endfunction

function void prepare_atb_packet();

    //----------------------------------------------------------
    // 16-bit ATB format
    //----------------------------------------------------------
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];

    //----------------------------------------------------------
    // 8-bit ATB format
    // ATDATA is still 16 bits wide
    //----------------------------------------------------------
    exp_pkt.byte_word0 = {expected_packet[7:0],   8'h00};
    exp_pkt.byte_word1 = {expected_packet[15:8],  8'h00};
    exp_pkt.byte_word2 = {expected_packet[23:16], 8'h00};
    exp_pkt.byte_word3 = {expected_packet[31:24], 8'h00};
    exp_pkt.byte_word4 = {expected_packet[39:32], 8'h00};
    exp_pkt.byte_word5 = {expected_packet[47:40], 8'h00};
    exp_pkt.byte_word6 = {expected_packet[55:48], 8'h00};
    exp_pkt.byte_word7 = {expected_packet[63:56], 8'h00};

    exp_pkt.atb_mode = input_tr.atb_mode;

endfunction



function automatic bit [15:0] get_expected_atdata(int index);

    if (curr_pkt.atb_mode == 1'b0) begin

        // 8-bit ATB mode
        case(index)
            0: get_expected_atdata = curr_pkt.byte_word0;
            1: get_expected_atdata = curr_pkt.byte_word1;
            2: get_expected_atdata = curr_pkt.byte_word2;
            3: get_expected_atdata = curr_pkt.byte_word3;
            4: get_expected_atdata = curr_pkt.byte_word4;
            5: get_expected_atdata = curr_pkt.byte_word5;
            6: get_expected_atdata = curr_pkt.byte_word6;
            7: get_expected_atdata = curr_pkt.byte_word7;
            default: get_expected_atdata = 16'h0000;
        endcase

    end
    else begin

        // 16-bit ATB mode
        case(index)
            0: get_expected_atdata = curr_pkt.word0;
            1: get_expected_atdata = curr_pkt.word1;
            2: get_expected_atdata = curr_pkt.word2;
            3: get_expected_atdata = curr_pkt.word3;
            default: get_expected_atdata = 16'h0000;
        endcase

    end

endfunction




  //------------------------------------------------------------
  // INPUT MONITOR
  //------------------------------------------------------------
//------------------------------------------------------------
// INPUT MONITOR
//------------------------------------------------------------
virtual function void write_IN(trace_transaction tr);

    input_tr = tr;

    if (tr.it_itype_valid && tr.trace_enable)
begin
        

     `uvm_info("INPUT_DEBUG",
    $sformatf(
      "INPUT: itype_valid=%0b first_instr=%0b iaddr=%04h itype=%04h context=%02h cause=%02h tval=%08h trace_enable=%0b atb_mode=%0b",
      tr.it_itype_valid,
      tr.it_first_instrn_valid_in,
      tr.it_iaddr,
      tr.it_itype,
      tr.it_context,
      tr.it_cause,
      tr.it_tval,
      tr.trace_enable,
      tr.atb_mode
    ),
    UVM_NONE)
     

        //--------------------------------------------------
        // SF0
        //--------------------------------------------------
        if (tr.it_first_instrn_valid_in)
        begin
            predict_sf0();
        end

        //--------------------------------------------------
        // Format1
        //--------------------------------------------------
        else if (format1_pending &&
                 tr.it_del_adr_valid &&
                 !format1_predicted)
        begin
            `uvm_info("FORMAT1",
                      "Format1 generation detected - predicting Format1 packet",
                      UVM_LOW)

            predict_format1();

            format1_predicted = 1'b1;
            format1_pending   = 1'b0;
        end

        //--------------------------------------------------
        // Format2
        //--------------------------------------------------
        else if (tr.it_del_adr_valid &&
         ((tr.it_itype == 4'b0101) ||
          (tr.it_itype == 4'b0100) ||
          (tr.it_itype == 4'b0110))) 
       begin

            predict_format2();

            format2_count++;

            //--------------------------------------------------
            // Build branch-map model
            //--------------------------------------------------
            branch_map_predict_d = branch_map_predict;
            branch_map_predict   = 31'b0;

            if (tr.it_itype == 4'b0101)
            begin
                branch_map_predict[format2_count-1] = 1'b1;
            end

            //--------------------------------------------------
            // Branch map becomes full
            //--------------------------------------------------
            if (format2_count == 16)
            begin
                format1_pending = 1'b1;

                `uvm_info("FORMAT1",
                          "Branch map full - waiting for Format1 generation",
                          UVM_LOW)
            end
        end

        //--------------------------------------------------
        // SF2
        //--------------------------------------------------
        else if (prev_context_valid &&
                 (tr.it_context != prev_context))
        begin
            predict_sf2();
        end

        //--------------------------------------------------
        // SF1
        //--------------------------------------------------
      else
begin
    `uvm_info("SF1_SKIP",
        $sformatf(
            "Skipping SF1 fallback: itype=%04h iaddr=%04h",
            tr.it_itype,
            tr.it_iaddr
        ),
        UVM_LOW)
end


        //--------------------------------------------------
        // Update context history
        //--------------------------------------------------
        prev_context       = tr.it_context;
        prev_context_valid = 1'b1;

    end

endfunction






//------------------------------------------------------------
// SF0 Predictor
//------------------------------------------------------------
function void predict_sf0();

    //----------------------------------------------------------
    // Branch Bit
    //----------------------------------------------------------
    branch_tmp = (input_tr.it_itype == 4'b0101);

    //----------------------------------------------------------
    // Build Expected SF0 Packet
    //
    // New RTL:
    // {42'b0,
    //  iaddr[15:0],
    //  context[1:0],
    //  branch,
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        42'b0,
        input_tr.it_iaddr,
        input_tr.it_context,
        branch_tmp,
        3'b010
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB Words
    //----------------------------------------------------------

    prepare_atb_packet();

    
    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_NONE);

    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE);

    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE);

    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE);

    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction





//------------------------------------------------------------
// SF1 Predictor


//------------------------------------------------------------
// SF1 Predictor
//------------------------------------------------------------
function void predict_sf1();

    `uvm_info("SF1_DEBUG",
    $sformatf(
        "SF1 CALLED: itype=%04h iaddr=%04h tval=%08h cause=%02h context=%02h atb_mode=%0b del_addr_valid=%0b first_instr=%0b",
        input_tr.it_itype,
        input_tr.it_iaddr,
        input_tr.it_tval,
        input_tr.it_cause,
        input_tr.it_context,
        input_tr.atb_mode,
        input_tr.it_del_adr_valid,
        input_tr.it_first_instrn_valid_in
    ),
    UVM_NONE)
    //----------------------------------------------------------
    // Temporary Fields
    //----------------------------------------------------------
    branch_tmp    = (input_tr.it_itype == 4'b0101);
    interrupt_tmp = (input_tr.it_itype == 4'b0010);

    //----------------------------------------------------------
    // Build Expected SF1 Packet
    //
    // New RTL:
    //
    // {1'b0,
    //  tval[31:0],
    //  iaddr[15:0],
    //  interrupt,
    //  cause[7:0],
    //  context[1:0],
    //  branch,
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        1'b0,
        input_tr.it_tval,
        input_tr.it_iaddr,
        interrupt_tmp,
        input_tr.it_cause,
        input_tr.it_context,
        branch_tmp,
        3'b011
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB Words
    //----------------------------------------------------------

    /*
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];
    */
    prepare_atb_packet();
    
    `uvm_info("SF1_DEBUG",
    $sformatf(
        "SF1 PACKET: expected_packet=%016h word0=%04h byte_word0=%04h",
        expected_packet,
        exp_pkt.word0,
        exp_pkt.byte_word0
    ),
    UVM_NONE)


/*
    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_NONE);

    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE);

    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE);

    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE);
*/
    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);


`uvm_info("QUEUE_DEBUG",
    $sformatf(
        "SF1 PUSHED: queue_size=%0d first_byte_word=%04h",
        expected_queue.size(),
        expected_queue[0].byte_word0
    ),
    UVM_NONE)

endfunction






//------------------------------------------------------------
// SF2 Predictor
//------------------------------------------------------------
function void predict_sf2();

    //----------------------------------------------------------
    // Build Expected SF2 Packet
    //
    // New RTL:
    //
    // {59'b0,
    //  context[1:0],
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        59'b0,
        input_tr.it_context,
        3'b100
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB Words
    //----------------------------------------------------------

    /*
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];
    */


    prepare_atb_packet();

    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_NONE);

    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE);

    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE);

    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE);

    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction






//------------------------------------------------------------
// Format2 Predictor
//------------------------------------------------------------
function void predict_format2();

    bit notify;
    bit updiscon;
    bit irreport;

    //----------------------------------------------------------
    // Format2 status bits
    //----------------------------------------------------------
    notify   = input_tr.it_delta_addr[19];
    updiscon = notify;
    irreport = updiscon;

    //----------------------------------------------------------
    // Build expected Format2 packet
    //
    // {36'b0,
    //  irreport,
    //  updiscon,
    //  notify,
    //  delta_addr[19:0],
    //  FORMAT_FIELD = 2'b10,
    //  HEADER_FIELD = 3'b001}
    //----------------------------------------------------------
    expected_packet =
    {
        36'b0,
        irreport,
        updiscon,
        notify,
        input_tr.it_delta_addr,
        2'b10,
        3'b001
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB words
    //----------------------------------------------------------

    /*
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];
    */
    
    prepare_atb_packet();



    //----------------------------------------------------------
    // Print expected words
    //----------------------------------------------------------


    `uvm_info("FORMAT2_PREDICTOR",
    $sformatf(
      "FORMAT2: itype=%04h iaddr=%04h del_valid=%0b delta=%05h -> Word0=%04h queue_before=%0d",
      input_tr.it_itype,
      input_tr.it_iaddr,
      input_tr.it_del_adr_valid,
      input_tr.it_delta_addr,
      exp_pkt.word0,
      expected_queue.size()
    ),
    UVM_NONE)


    `uvm_info("FORMAT2_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE)

    `uvm_info("FORMAT2_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE)

    `uvm_info("FORMAT2_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE)

    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction





//------------------------------------------------------------
// Format1 Predictor
//------------------------------------------------------------
function void predict_format1();

    bit notify;
    bit updiscon;
    bit irreport;

    //----------------------------------------------------------
    // Format1 control bits
    //----------------------------------------------------------
    notify   = input_tr.it_delta_addr[19];
    updiscon = notify;
    irreport = updiscon;

    //----------------------------------------------------------
    // Build expected Format1 packet
    //----------------------------------------------------------
    expected_packet =
    {
        irreport,
        updiscon,
        notify,
        input_tr.it_delta_addr,   // if1_del_addr_in
        branch_map_predict_d,      // branch_map_i
        5'b11111,                // BRANCHES
        2'b01,                   // FORMAT
        3'b000                    // HEADER
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB words
    //----------------------------------------------------------

    /*
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];
    */

    prepare_atb_packet();


    //----------------------------------------------------------
    // Print expected words
    //----------------------------------------------------------
    `uvm_info("FORMAT1_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_NONE)

    `uvm_info("FORMAT1_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE)

    `uvm_info("FORMAT1_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE)

    `uvm_info("FORMAT1_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE)

    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction






//------------------------------------------------------------
// SF3 Predictor
//------------------------------------------------------------
function void predict_sf3();

    branch_tmp  = (vif.it_itype == 4'b0101);
    ienable_tmp = vif.it_ienable_in;
    //----------------------------------------------------------
    // Build expected SF3 packet
    //
    // New RTL:
    //
    // {57'b0,
    //  qual_status[1:0],
    //  branch_tmp,
    //  ienable_in,
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        57'b0,
        2'b00,
        branch_tmp,
        ienable_tmp,
        3'b101
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB words
    //----------------------------------------------------------
    /*
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];
    */
    
    prepare_atb_packet();

    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_LOW)

    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_LOW)

    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_LOW)

    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_LOW)

    //----------------------------------------------------------
    // Add SF3 expected packet to queue
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction






//------------------------------------------------------------
// SF3 Event Monitor
//------------------------------------------------------------
//------------------------------------------------------------
// SF3 Event Monitor
//------------------------------------------------------------
//------------------------------------------------------------
// SF3 Event Monitor
//------------------------------------------------------------
virtual task run_phase(uvm_phase phase);

    forever
    begin
        @(posedge vif.it_clk);

        //----------------------------------------------------
        // Re-arm when FIFO is no longer full
        //----------------------------------------------------
        if (!vif.fifo_full)
        begin
            sf3_predicted = 1'b0;
        end

        //----------------------------------------------------
        // SF3 event detected
        //----------------------------------------------------
        if (vif.sf3_valid && !sf3_predicted)
        begin
            `uvm_info("SF3",
                      "SF3 valid detected - predicting SF3 packet",
                      UVM_LOW)

            branch_tmp  = (vif.it_itype == 4'b0101);
            ienable_tmp = vif.it_ienable_in;

            predict_sf3();

            sf3_predicted = 1'b1;
        end

    end

endtask

  //------------------------------------------------------------
  // OUTPUT MONITOR
  //------------------------------------------------------------
virtual function void write_OUT(trace_transaction tr);

    output_tr = tr;

    if(tr.atvalid_o)
    begin

        `uvm_info("OUTPUT_SB",
          $sformatf("TIME=%0t ATVALID=%0b ATDATA=%04h",
                    $time,
                    tr.atvalid_o,
                    tr.atdata_o),
          UVM_NONE);


        //----------------------------------------------------
        // Start of a new packet
        //----------------------------------------------------
        if(!packet_started)
        begin

            if(expected_queue.size() == 0)
            begin
                `uvm_error("SB","Expected Queue Empty")
                return;
            end


            //------------------------------------------------
            // DO NOT POP YET
            // Just look at the first expected packet
            //------------------------------------------------
            curr_pkt = expected_queue[0];

		`uvm_info("QUEUE_HEAD",
  $sformatf(
    "QUEUE HEAD: word0=%04h atb_mode=%0b queue_size=%0d",
    expected_queue[0].word0,
    expected_queue[0].atb_mode,
    expected_queue.size()
  ),
  UVM_NONE)


`uvm_info("QUEUE_HEAD",
    $sformatf(
        "QUEUE HEAD: word0=%04h byte_word0=%04h atb_mode=%0b queue_size=%0d",
        curr_pkt.word0,
        curr_pkt.byte_word0,
        curr_pkt.atb_mode,
        expected_queue.size()
    ),
    UVM_NONE)

            //------------------------------------------------
            // Wait until DUT gives expected first word
            //------------------------------------------------
          if(tr.atdata_o != get_expected_atdata(0))
            begin
                `uvm_info("SB",
                    $sformatf(
                      "Waiting... DUT=%04h Expected First=%04h",
                      tr.atdata_o,
                      get_expected_atdata(0)),
                    UVM_LOW)

                return;
            end


            //------------------------------------------------
            // First word matched
            // NOW remove packet from queue
            //------------------------------------------------
            void'(expected_queue.pop_front());

            packet_started = 1;
            compare_count = 0;


            `uvm_info("SB",
                "First packet word detected. Starting comparison.",
                UVM_LOW)

        end


        //----------------------------------------------------
        // Packet word comparison
        //----------------------------------------------------
        case(compare_count)

            0:
            begin
                if(tr.atdata_o == get_expected_atdata(0))
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD0 MATCH Exp=%04h Act=%04h",
                          get_expected_atdata(0),
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD0 MISMATCH Exp=%04h Act=%04h",
                          get_expected_atdata(0),
                          tr.atdata_o))
            end


            1:
            begin
                if(tr.atdata_o == get_expected_atdata(1))
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD1 MATCH Exp=%04h Act=%04h",
                          get_expected_atdata(1),
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD1 MISMATCH Exp=%04h Act=%04h",
                          get_expected_atdata(1),
                          tr.atdata_o))
            end


            2:
            begin
                if(tr.atdata_o == get_expected_atdata(2))
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD2 MATCH Exp=%04h Act=%04h",
                          get_expected_atdata(2),
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD2 MISMATCH Exp=%04h Act=%04h",
                          get_expected_atdata(2),
                          tr.atdata_o))
            end


            3:
            begin
                if(tr.atdata_o == get_expected_atdata(3))
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD3 MATCH Exp=%04h Act=%04h",
                          get_expected_atdata(3),
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD3 MISMATCH Exp=%04h Act=%04h",
                          get_expected_atdata(3),
                          tr.atdata_o))
            end




            4:
begin
    if(tr.atdata_o == get_expected_atdata(4))
        `uvm_info("COMPARE",
            $sformatf(
              "WORD4 MATCH Exp=%04h Act=%04h",
              get_expected_atdata(4),
              tr.atdata_o),
            UVM_LOW)
    else
        `uvm_error("COMPARE",
            $sformatf(
              "WORD4 MISMATCH Exp=%04h Act=%04h",
              get_expected_atdata(4),
              tr.atdata_o))
end

5:
begin
    if(tr.atdata_o == get_expected_atdata(5))
        `uvm_info("COMPARE",
            $sformatf(
              "WORD5 MATCH Exp=%04h Act=%04h",
              get_expected_atdata(5),
              tr.atdata_o),
            UVM_LOW)
    else
        `uvm_error("COMPARE",
            $sformatf(
              "WORD5 MISMATCH Exp=%04h Act=%04h",
              get_expected_atdata(5),
              tr.atdata_o))
end

6:
begin
    if(tr.atdata_o == get_expected_atdata(6))
        `uvm_info("COMPARE",
            $sformatf(
              "WORD6 MATCH Exp=%04h Act=%04h",
              get_expected_atdata(6),
              tr.atdata_o),
            UVM_LOW)
    else
        `uvm_error("COMPARE",
            $sformatf(
              "WORD6 MISMATCH Exp=%04h Act=%04h",
              get_expected_atdata(6),
              tr.atdata_o))
end

7:
begin
    if(tr.atdata_o == get_expected_atdata(7))
        `uvm_info("COMPARE",
            $sformatf(
              "WORD7 MATCH Exp=%04h Act=%04h",
              get_expected_atdata(7),
              tr.atdata_o),
            UVM_LOW)
    else
        `uvm_error("COMPARE",
            $sformatf(
              "WORD7 MISMATCH Exp=%04h Act=%04h",
              get_expected_atdata(7),
              tr.atdata_o))
end







        endcase


       compare_count++;

    if ((curr_pkt.atb_mode == 1'b1 && compare_count == 4) ||
    (curr_pkt.atb_mode == 1'b0 && compare_count == 8))
    begin
        compare_count = 0;
        packet_started = 0;

        `uvm_info("SB",
         "Packet comparison completed",
            UVM_LOW)
    end

    end

endfunction


endclass
