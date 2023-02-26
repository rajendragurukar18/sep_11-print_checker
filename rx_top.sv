//=============================================================================
// usb_handshake_rx_top.sv  -  USB 2.0 handshake RECEIVER (STRUCTURAL ONLY)
// No logic here: only wires and sub-block instances.
//
//   usb_rx_packet_tracker      gating + PID-byte position
//   usb_pid_checker            PID complement check, group, type   (comb)
//   usb_handshake_classifier   ACK/NAK/STALL/NYET/ERR + legality   (comb)
//   usb_handshake_length_monitor  exactly 1 byte before EOP
//   usb_rx_pid_capture         holds PID decode until EOP
//   usb_rx_result_qualifier    registered, prioritised result pulses
//
// Link-layer assumptions: whole bytes only (no HS dribble), SOP may coincide
// with first byte but not EOP, new SOP aborts, stray bytes/EOP ignored.
// hs_mode_i / split_hs_phase_i sampled with the PID byte; hs_expected_i at EOP.
//=============================================================================
module usb_handshake_rx_top
    import usb_pid_pkg::*;
(
    input  logic       clk,
    input  logic       rst_n,

    input  logic [7:0] rx_byte_i,
    input  logic       rx_byte_valid_i,
    input  logic       rx_sop_i,
    input  logic       rx_eop_i,

    input  logic       hs_mode_i,
    input  logic       split_hs_phase_i,
    input  logic       hs_expected_i,

    output hs_type_e   handshake_type_o,
    output logic       handshake_valid_o,
    output logic       err_pid_o,
    output logic       err_length_o,
    output logic       err_unsupported_o,
    output logic       err_unexpected_o
);

    // tracker
    logic       byte_v, eop_v, is_pid_byte;
    // PID checker
    logic       pid_chk_ok;
    pid_group_e pid_group;
    pid_type_e  pid_type;
    // classifier
    hs_type_e   hs_type_comb;
    logic       hs_is_legal_comb, hs_is_unsupported_comb;
    // length monitor
    logic [7:0] len_byte_count;
    logic       len_eop_ok, len_error;
    // PID capture
    logic       pend_pid_error;
    hs_type_e   pend_hs_type;
    logic       pend_hs_legal, pend_hs_unsupported;

    usb_rx_packet_tracker u_tracker (
        .clk(clk), .rst_n(rst_n),
        .rx_sop_i(rx_sop_i), .rx_byte_valid_i(rx_byte_valid_i), .rx_eop_i(rx_eop_i),
        .byte_v_o(byte_v), .eop_v_o(eop_v), .is_pid_byte_o(is_pid_byte)
    );

    usb_pid_checker u_pid_checker (
        .pid_byte_i(rx_byte_i), .pid_chk_ok_o(pid_chk_ok),
        .pid_group_o(pid_group), .pid_type_o(pid_type)
    );

    usb_handshake_classifier u_hs_classifier (
        .pid_group_i(pid_group), .pid_type_i(pid_type),
        .hs_mode_i(hs_mode_i), .split_hs_phase_i(split_hs_phase_i),
        .hs_type_o(hs_type_comb), .hs_is_legal_o(hs_is_legal_comb),
        .hs_is_unsupported_o(hs_is_unsupported_comb)
    );

    usb_handshake_length_monitor u_len_monitor (
        .clk(clk), .rst_n(rst_n),
        .sop_i(rx_sop_i), .byte_strobe_i(byte_v), .eop_i(eop_v),
        .byte_count_o(len_byte_count), .eop_ok_o(len_eop_ok), .length_error_o(len_error)
    );

    usb_rx_pid_capture u_pid_capture (
        .clk(clk), .rst_n(rst_n),
        .sop_i(rx_sop_i), .capture_i(is_pid_byte),
        .pid_chk_ok_i(pid_chk_ok), .hs_type_i(hs_type_comb),
        .hs_is_legal_i(hs_is_legal_comb), .hs_is_unsupported_i(hs_is_unsupported_comb),
        .pend_pid_error_o(pend_pid_error), .pend_hs_type_o(pend_hs_type),
        .pend_hs_legal_o(pend_hs_legal), .pend_hs_unsupported_o(pend_hs_unsupported)
    );

    usb_rx_result_qualifier u_qualifier (
        .clk(clk), .rst_n(rst_n),
        .eop_v_i(eop_v), .len_error_i(len_error), .len_eop_ok_i(len_eop_ok),
        .hs_expected_i(hs_expected_i),
        .pend_pid_error_i(pend_pid_error), .pend_hs_type_i(pend_hs_type),
        .pend_hs_legal_i(pend_hs_legal), .pend_hs_unsupported_i(pend_hs_unsupported),
        .handshake_type_o(handshake_type_o), .handshake_valid_o(handshake_valid_o),
        .err_pid_o(err_pid_o), .err_length_o(err_length_o),
        .err_unsupported_o(err_unsupported_o), .err_unexpected_o(err_unexpected_o)
    );

endmodule : usb_handshake_rx_top
