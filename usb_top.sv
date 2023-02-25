module usb_data_tx_top
  import usb_pkg::*;
#(
  parameter bit          HS_SUPPORT = 1'b0,
  parameter int unsigned MAX_PKT    = (HS_SUPPORT ? 1024 : 1023),
  localparam int unsigned LEN_W     = $clog2(MAX_PKT + 1)
) (
  input  logic             clk,
  input  logic             rst_n,
 
  input  logic             req_valid,
  output logic             req_ready,
  input  logic             req_use_int_toggle,
  input  logic             req_toggle,
  input  logic             req_force_data0,
  input  logic [1:0]       req_type,
  input  logic             ls_mode,
  input  logic             hs_mode,
  input  logic             req_dir_in,
  input  logic [1:0]       req_mult,
  input  logic [1:0]       req_tx_idx,
  input  logic [LEN_W-1:0] req_length,
  input  logic [LEN_W-1:0] cfg_max_pkt,
  input  logic             abort,
 
  input  logic [7:0]       pld_data,
  input  logic             pld_valid,
  output logic             pld_ready,
 
  output logic [7:0]       tx_data,
  output logic             tx_valid,
  input  logic             tx_ready,
  output logic             tx_sop,
  output logic             tx_eop,
  output logic             pkt_active,
 
  input  logic             ack_rcvd,
  input  logic             nyet_rcvd,
  input  logic             toggle_clr,
  output logic             ep_toggle,
  output logic             ack_pending,
 
  output logic             done,
  output logic             err_req,
  output logic             aborted,
  output logic             underrun
);
  logic [3:0] sel_pid;
  logic [7:0] sel_pid_byte;
  logic       sel_err, toggle_used, hs_eff, asm_req_ready, asm_req_valid, req_fire_ok;
 
  wire req_is_isoc = (req_type == EP_ISOC);
 
  assign req_ready = asm_req_ready;
 
  usb_data_toggle_tracker u_tog (
    .clk(clk), .rst_n(rst_n),
    .use_int_toggle(req_use_int_toggle), .ext_toggle(req_toggle),
    .req_fire_ok(req_fire_ok), .sel_pid(sel_pid), .req_is_isoc(req_is_isoc),
    .done(done), .aborted(aborted), .underrun(underrun),
    .ack_rcvd(ack_rcvd), .nyet_rcvd(nyet_rcvd), .toggle_clr(toggle_clr),
    .toggle_used(toggle_used), .ep_toggle(ep_toggle), .ack_pending(ack_pending)
  );
 
  usb_pid_selector #(.HS_SUPPORT(HS_SUPPORT)) u_sel (
    .toggle_bit(toggle_used), .force_data0(req_force_data0), .is_isoc(req_is_isoc),
    .hs_mode(hs_mode), .dir_in(req_dir_in), .mult(req_mult), .tx_idx(req_tx_idx),
    .pid(sel_pid), .pid_byte(sel_pid_byte), .pid_err(sel_err)
  );
 
  usb_tx_req_gate #(.HS_SUPPORT(HS_SUPPORT), .MAX_PKT(MAX_PKT), .LEN_W(LEN_W)) u_gate (
    .clk(clk), .rst_n(rst_n),
    .req_valid(req_valid), .asm_req_ready(asm_req_ready),
    .req_type(req_type), .ls_mode(ls_mode), .hs_mode(hs_mode),
    .req_length(req_length), .cfg_max_pkt(cfg_max_pkt), .sel_err(sel_err),
    .asm_req_valid(asm_req_valid), .req_fire_ok(req_fire_ok),
    .hs_eff(hs_eff), .err_req(err_req)
  );
 
  usb_packet_assembler #(.LEN_W(LEN_W)) u_asm (
    .clk(clk), .rst_n(rst_n),
    .req_valid(asm_req_valid), .req_ready(asm_req_ready),
    .req_pid_byte(sel_pid_byte), .req_length(req_length),
    .abort(abort),
    .pld_data(pld_data), .pld_valid(pld_valid), .pld_ready(pld_ready),
    .tx_data(tx_data), .tx_valid(tx_valid), .tx_ready(tx_ready),
    .tx_sop(tx_sop), .tx_eop(tx_eop), .pkt_active(pkt_active),
    .done(done), .aborted(aborted), .underrun(underrun)
  );
endmodule
