module usb_packet_assembler
  import usb_pkg::*;
#(
  parameter int unsigned LEN_W = 10
) (
  input  logic             clk,
  input  logic             rst_n,
 
  input  logic             req_valid,
  output logic             req_ready,
  input  logic [7:0]       req_pid_byte,
  input  logic [LEN_W-1:0] req_length,
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
 
  output logic             done,
  output logic             aborted,
  output logic             underrun
);
  typedef enum logic [1:0] {S_IDLE, S_PID, S_DATA, S_CRC} state_t;
  state_t state;
 
  logic [7:0] pid_byte_q;
 
  logic start, byte_acc;
  assign start     = (state == S_IDLE) && req_valid;
  assign pld_ready = (state == S_DATA) && tx_ready && !abort;
  assign byte_acc  = pld_ready && pld_valid;
 
  logic cnt_last, cnt_zero;
  usb_byte_counter #(.LEN_W(LEN_W)) u_cnt (
    .clk(clk), .rst_n(rst_n), .start(start), .length(req_length),
    .byte_accepted(byte_acc), .is_last(cnt_last), .is_zero_len(cnt_zero)
  );
 
  logic [15:0] crc_out, crc_next_out;
  usb_crc16_gen u_crc (
    .clk(clk), .rst_n(rst_n), .init(start), .data_valid(byte_acc),
    .data_in(pld_data), .crc_out(crc_out), .crc_next_out(crc_next_out)
  );
 
  logic        split_load, crc_last;
  logic [15:0] split_in;
  logic [7:0]  crc_byte;
 
  usb_crc16_splitter u_split (
    .clk(clk), .rst_n(rst_n), .load(split_load), .crc_in(split_in),
    .advance((state == S_CRC) && tx_ready && !abort),
    .crc_byte(crc_byte), .crc_last(crc_last)
  );
 
  always_comb begin
    split_load = 1'b0;
    split_in   = crc_next_out;
    if (state == S_PID && tx_ready && cnt_zero && !abort) begin
      split_load = 1'b1;
      split_in   = crc_out;
    end else if (byte_acc && cnt_last) begin
      split_load = 1'b1;
      split_in   = crc_next_out;
    end
  end
 
  logic tx_valid_raw;
  always_comb begin
    tx_data      = 8'h00;
    tx_valid_raw = 1'b0;
    tx_sop       = 1'b0;
    tx_eop       = 1'b0;
    case (state)
      S_PID:  begin tx_data = pid_byte_q; tx_valid_raw = 1'b1; tx_sop = 1'b1; end
      S_DATA: begin tx_data = pld_data;   tx_valid_raw = pld_valid; end
      S_CRC:  begin tx_data = crc_byte;   tx_valid_raw = 1'b1; tx_eop = crc_last; end
      default: ;
    endcase
  end
  assign tx_valid   = tx_valid_raw && !abort;
 
  assign req_ready  = (state == S_IDLE);
  assign pkt_active = (state != S_IDLE);
 
  logic done_q, abort_q, under_q;
  assign done     = done_q;
  assign aborted  = abort_q;
  assign underrun = under_q;
 
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state      <= S_IDLE;
      pid_byte_q <= 8'h00;
      done_q     <= 1'b0;
      abort_q    <= 1'b0;
      under_q    <= 1'b0;
    end else begin
      done_q  <= 1'b0;
      abort_q <= 1'b0;
      under_q <= 1'b0;
 
      if (abort && state != S_IDLE) begin
        state   <= S_IDLE;
        abort_q <= 1'b1;
      end else begin
        case (state)
          S_IDLE: if (req_valid) begin
            pid_byte_q <= req_pid_byte;
            state      <= S_PID;
          end
          S_PID:  if (tx_ready) state <= cnt_zero ? S_CRC : S_DATA;
          S_DATA: begin
            if (!pld_valid) begin
              state   <= S_IDLE;
              under_q <= 1'b1;
            end else if (tx_ready && cnt_last)
              state <= S_CRC;
          end
          S_CRC:  if (tx_ready && crc_last) begin
            state  <= S_IDLE;
            done_q <= 1'b1;
          end
          default: state <= S_IDLE;
        endcase
      end
    end
  end
endmodule
 
