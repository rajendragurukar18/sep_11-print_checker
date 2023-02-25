module usb_byte_counter #(
  parameter int unsigned LEN_W = 10
) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic             start,
  input  logic [LEN_W-1:0] length,
  input  logic             byte_accepted,
  output logic             is_last,
  output logic             is_zero_len
);
  logic [LEN_W-1:0] cnt;
  logic             zero_q;
 
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt    <= '0;
      zero_q <= 1'b0;
    end else if (start) begin
      cnt    <= length;
      zero_q <= (length == '0);
    end else if (byte_accepted && cnt != '0) begin
      cnt    <= cnt - 1'b1;
    end
  end
 
  assign is_last     = (cnt == LEN_W'(1));
  assign is_zero_len = zero_q;
endmodule
