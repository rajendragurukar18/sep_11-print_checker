module usb_pid_selector
  import usb_pkg::*;
#(
  parameter bit HS_SUPPORT = 1'b0
) (
  input  logic       toggle_bit,
  input  logic       force_data0,
  input  logic       is_isoc,
  input  logic       hs_mode,
  input  logic       dir_in,
  input  logic [1:0] mult,
  input  logic [1:0] tx_idx,
  output logic [3:0] pid,
  output logic [7:0] pid_byte,
  output logic       pid_err
);
  generate
    if (HS_SUPPORT) begin : g_hs
      logic [1:0] remain;
      always_comb begin
        pid     = PID_DATA0;
        pid_err = 1'b0;
        remain  = 2'd0;
        if (is_isoc) begin
          if (!hs_mode) begin
            pid = PID_DATA0;
          end else if (mult == 2'd0 || tx_idx >= mult) begin
            pid_err = 1'b1;
          end else begin
            remain = mult - tx_idx - 2'd1;
            if (dir_in) begin
              case (remain)
                2'd0:    pid = PID_DATA0;
                2'd1:    pid = PID_DATA1;
                default: pid = PID_DATA2;
              endcase
            end else begin
              if (remain != 2'd0) pid = PID_MDATA;
              else begin
                case (mult)
                  2'd1:    pid = PID_DATA0;
                  2'd2:    pid = PID_DATA1;
                  default: pid = PID_DATA2;
                endcase
              end
            end
          end
        end else if (force_data0) begin
          pid = PID_DATA0;
        end else begin
          pid = toggle_bit ? PID_DATA1 : PID_DATA0;
        end
      end
    end else begin : g_fsls
      assign pid     = (is_isoc || force_data0 || !toggle_bit) ? PID_DATA0 : PID_DATA1;
      assign pid_err = 1'b0;
      wire   unused_ok = &{1'b0, hs_mode, dir_in, mult, tx_idx};
    end
  endgenerate
 
  assign pid_byte = {~pid, pid};
endmodule
 
