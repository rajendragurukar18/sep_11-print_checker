//=============================================================================
// usb_handshake_tx_top.sv  -  USB 2.0 handshake TRANSMITTER (STRUCTURAL ONLY)
// No logic here: only wires and sub-block instances.
//
//   usb_handshake_pid_encoder  type -> PID byte {~t,t} + legality (comb)
//   usb_tx_fsm                 SOP / byte(valid-ready) / EOP sequencing
//
// Legality: host = ACK only; device = ACK/NAK/STALL (all speeds),
//           NYET (HS), ERR (HS + split handshake phase).
// Not here: SYNC/NRZI/bit-stuffing (link layer), turnaround timing,
//           choosing which handshake to send (transaction layer).
//=============================================================================
module usb_handshake_tx_top
    import usb_pid_pkg::*;
(
    input  logic       clk,
    input  logic       rst_n,

    input  logic       tx_req_i,
    input  hs_type_e   tx_type_i,
    input  logic       tx_is_host_i,
    input  logic       hs_mode_i,
    input  logic       split_hs_phase_i,

    output logic       tx_sop_o,
    output logic [7:0] tx_byte_o,
    output logic       tx_byte_valid_o,
    input  logic       tx_byte_ready_i,
    output logic       tx_eop_o,

    output logic       tx_busy_o,
    output logic       tx_done_o,
    output logic       tx_err_illegal_o,
    output logic       tx_err_busy_o
);

    logic [7:0] enc_byte;
    logic       enc_legal;

    usb_handshake_pid_encoder u_enc (
        .hs_type_i(tx_type_i), .is_host_i(tx_is_host_i),
        .hs_mode_i(hs_mode_i), .split_hs_phase_i(split_hs_phase_i),
        .pid_byte_o(enc_byte), .legal_o(enc_legal)
    );

    usb_tx_fsm u_fsm (
        .clk(clk), .rst_n(rst_n),
        .tx_req_i(tx_req_i), .enc_byte_i(enc_byte), .enc_legal_i(enc_legal),
        .tx_sop_o(tx_sop_o), .tx_byte_o(tx_byte_o), .tx_byte_valid_o(tx_byte_valid_o),
        .tx_byte_ready_i(tx_byte_ready_i), .tx_eop_o(tx_eop_o),
        .tx_busy_o(tx_busy_o), .tx_done_o(tx_done_o),
        .tx_err_illegal_o(tx_err_illegal_o), .tx_err_busy_o(tx_err_busy_o)
    );

endmodule : usb_handshake_tx_top
