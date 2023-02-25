module usb_crc16_splitter (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        load,
  input  logic [15:0] crc_in,
  input  logic        advance,
  output logic [7:0]  crc_byte,
  output logic        crc_last
);
  function automatic logic [7:0] rev8(input logic [7:0] x);
    logic [7:0] y;
    for (int i = 0; i < 8; i++) y[i] = x[7 - i];
    return y;
  endfunction
 
  logic [15:0] crc_q;
  logic        idx_q;
 
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc_q <= 16'd0;
      idx_q <= 1'b0;
    end else if (load) begin
      crc_q <= crc_in;
      idx_q <= 1'b0;
    end else if (advance) begin
      idx_q <= 1'b1;
    end
  end
 
  assign crc_byte = idx_q ? rev8(crc_q[7:0]) : rev8(crc_q[15:8]);
  assign crc_last = idx_q;
endmodule
