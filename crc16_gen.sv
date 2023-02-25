module usb_crc16_gen
  import usb_pkg::*;
(
  input  logic        clk,
  input  logic        rst_n,
  input  logic        init,
  input  logic        data_valid,
  input  logic [7:0]  data_in,
  output logic [15:0] crc_out,
  output logic [15:0] crc_next_out
);
  function automatic logic [15:0] crc16_byte(input logic [15:0] c, input logic [7:0] d);
    logic [15:0] r;
    logic        fb;
    r = c;
    for (int i = 0; i < 8; i++) begin
      fb = r[15] ^ d[i];
      r  = {r[14:0], 1'b0};
      if (fb) r = r ^ CRC16_POLY;
    end
    return r;
  endfunction
 
  logic [15:0] crc_q, crc_nxt;
 
  assign crc_nxt      = crc16_byte(crc_q, data_in);
  assign crc_out      = ~crc_q;
  assign crc_next_out = ~crc_nxt;
 
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)          crc_q <= CRC16_INIT;
    else if (init)       crc_q <= CRC16_INIT;
    else if (data_valid) crc_q <= crc_nxt;
  end
endmodule
