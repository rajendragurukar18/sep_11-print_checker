module usb_data_toggle_tracker
  import usb_pkg::*;
(
  input  logic       clk,
  input  logic       rst_n,
 
  input  logic       use_int_toggle,
  input  logic       ext_toggle,
  input  logic       req_fire_ok,
  input  logic [3:0] sel_pid,
  input  logic       req_is_isoc,
  input  logic       done,
  input  logic       aborted,
  input  logic       underrun,
  input  logic       ack_rcvd,
  input  logic       nyet_rcvd,
  input  logic       toggle_clr,
 
  output logic       toggle_used,
  output logic       ep_toggle,
  output logic       ack_pending
);
  logic tog_q;
  logic sent_data0_q;
  logic sent_noniso_q;
  logic pend_q;
 
  wire ack_any = (ack_rcvd | nyet_rcvd) && pend_q;
 
  logic tog_nxt;
  always_comb begin
    tog_nxt = tog_q;
    if (ack_any)    tog_nxt = sent_data0_q;
    if (toggle_clr) tog_nxt = 1'b0;
  end
 
  assign toggle_used = use_int_toggle ? tog_nxt : ext_toggle;
 
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tog_q         <= 1'b0;
      sent_data0_q  <= 1'b1;
      sent_noniso_q <= 1'b0;
      pend_q        <= 1'b0;
    end else begin
      if (done && sent_noniso_q) pend_q <= 1'b1;
      if (aborted || underrun)   pend_q <= 1'b0;
 
      if (req_fire_ok) begin
        sent_data0_q  <= (sel_pid == PID_DATA0);
        sent_noniso_q <= !req_is_isoc;
        pend_q        <= 1'b0;
      end
 
      tog_q <= tog_nxt;
      if (ack_any)    pend_q <= 1'b0;
      if (toggle_clr) pend_q <= 1'b0;
    end
  end
 
  assign ep_toggle   = tog_q;
  assign ack_pending = pend_q;
endmodule
 
