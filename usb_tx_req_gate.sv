module usb_tx_req_gate
  import usb_pkg::*;
#(
  parameter bit          HS_SUPPORT = 1'b0,
  parameter int unsigned MAX_PKT    = 1023,
  parameter int unsigned LEN_W      = $clog2(MAX_PKT + 1)
) (
  input  logic             clk,
  input  logic             rst_n,
 
  input  logic             req_valid,
  input  logic             asm_req_ready,
  input  logic [1:0]       req_type,
  input  logic             ls_mode,
  input  logic             hs_mode,
  input  logic [LEN_W-1:0] req_length,
  input  logic [LEN_W-1:0] cfg_max_pkt,
  input  logic             sel_err,
 
  output logic             asm_req_valid,
  output logic             req_fire_ok,
  output logic             hs_eff,
  output logic             err_req
);
  logic [10:0] len11, cfg11, type_max, eff_max;
  logic        req_bad, rej_q;
 
  assign hs_eff = HS_SUPPORT && hs_mode;
  assign len11  = 11'(req_length);
  assign cfg11  = 11'(cfg_max_pkt);
 
  always_comb begin
    if (ls_mode) begin
      type_max = MAXPKT_LS;
    end else if (hs_eff) begin
      case (req_type)
        EP_CTRL: type_max = MAXPKT_HS_CTRL;
        EP_BULK: type_max = MAXPKT_HS_BULK;
        default: type_max = MAXPKT_HS;
      endcase
    end else begin
      type_max = (req_type == EP_ISOC) ? MAXPKT_FS_ISO : MAXPKT_FS;
    end
    eff_max = type_max;
    if (cfg11 < eff_max)        eff_max = cfg11;
    if (11'(MAX_PKT) < eff_max) eff_max = 11'(MAX_PKT);
  end
 
  assign req_bad = (len11 > eff_max)
                || (ls_mode && (req_type == EP_ISOC || req_type == EP_BULK))
                || (ls_mode && hs_eff)
                || sel_err;
 
  wire req_fire = req_valid && asm_req_ready;
  assign req_fire_ok   = req_fire && !req_bad;
  assign asm_req_valid = req_valid && !req_bad;
 
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) rej_q <= 1'b0;
    else        rej_q <= req_fire && req_bad;
  end
  assign err_req = rej_q;
endmodule
 
