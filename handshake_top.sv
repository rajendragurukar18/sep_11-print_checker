//=============================================================================
// usb_handshake_top.sv  -  INTEGRATED handshake RX + TX (STRUCTURAL ONLY)
// No logic here: only the two instances. The RX and TX paths are independent;
// they share only clock, reset and the speed / split context.
// The link layer (SYNC, NRZI, bit-stuffing, EOP) connects to the rx_* and
// tx_* link ports; the transaction layer uses the rest.
//=============================================================================
module usb_handshake_top
    import usb_pid_pkg::*;
(
    input  logic       clk,
    input  logic       rst_n,

    // shared context
    input  logic       hs_mode_i,           // 1 = High-Speed
    input  logic       split_hs_phase_i,    // 1 = handshake phase of a split xfer

    // ---------------- RX : link layer -> protocol layer ----------------
    input  logic [7:0] rx_byte_i,
    input  logic       rx_byte_valid_i,
    input  logic       rx_sop_i,
    input  logic       rx_eop_i,
    input  logic       hs_expected_i,

    // RX results (transaction layer)
    output hs_type_e   handshake_type_o,
    output logic       handshake_valid_o,
    output logic       err_pid_o,
    output logic       err_length_o,
    output logic       err_unsupported_o,
    output logic       err_unexpected_o,

    // ---------------- TX : transaction layer request ----------------
    input  logic       tx_req_i,
    input  hs_type_e   tx_type_i,
    input  logic       tx_is_host_i,

    // TX : protocol layer -> link layer
    output logic       tx_sop_o,
    output logic [7:0] tx_byte_o,
    output logic       tx_byte_valid_o,
    input  logic       tx_byte_ready_i,
    output logic       tx_eop_o,

    // TX status
    output logic       tx_busy_o,
    output logic       tx_done_o,
    output logic       tx_err_illegal_o,
    output logic       tx_err_busy_o
);

    usb_handshake_rx_top u_rx (
        .clk(clk), .rst_n(rst_n),
        .rx_byte_i(rx_byte_i), .rx_byte_valid_i(rx_byte_valid_i),
        .rx_sop_i(rx_sop_i), .rx_eop_i(rx_eop_i),
        .hs_mode_i(hs_mode_i), .split_hs_phase_i(split_hs_phase_i),
        .hs_expected_i(hs_expected_i),
        .handshake_type_o(handshake_type_o), .handshake_valid_o(handshake_valid_o),
        .err_pid_o(err_pid_o), .err_length_o(err_length_o),
        .err_unsupported_o(err_unsupported_o), .err_unexpected_o(err_unexpected_o)
    );

    usb_handshake_tx_top u_tx (
        .clk(clk), .rst_n(rst_n),
        .tx_req_i(tx_req_i), .tx_type_i(tx_type_i), .tx_is_host_i(tx_is_host_i),
        .hs_mode_i(hs_mode_i), .split_hs_phase_i(split_hs_phase_i),
        .tx_sop_o(tx_sop_o), .tx_byte_o(tx_byte_o), .tx_byte_valid_o(tx_byte_valid_o),
        .tx_byte_ready_i(tx_byte_ready_i), .tx_eop_o(tx_eop_o),
        .tx_busy_o(tx_busy_o), .tx_done_o(tx_done_o),
        .tx_err_illegal_o(tx_err_illegal_o), .tx_err_busy_o(tx_err_busy_o)
    );

endmodule : usb_handshake_top
