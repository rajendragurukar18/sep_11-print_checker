//=============================================================================
// usb_rx_pid_capture.sv  -  RX SUB-BLOCK 5
// Holds the (still unqualified) PID decode captured with the PID byte.
// Cleared by a new SOP so nothing stale leaks into the next packet.
//=============================================================================
module usb_rx_pid_capture
    import usb_pid_pkg::*;
(
    input  logic     clk,
    input  logic     rst_n,
    input  logic     sop_i,
    input  logic     capture_i,              // = is_pid_byte

    input  logic     pid_chk_ok_i,
    input  hs_type_e hs_type_i,
    input  logic     hs_is_legal_i,
    input  logic     hs_is_unsupported_i,

    output logic     pend_pid_error_o,
    output hs_type_e pend_hs_type_o,
    output logic     pend_hs_legal_o,
    output logic     pend_hs_unsupported_o
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pend_pid_error_o      <= 1'b0;
            pend_hs_type_o        <= HS_NONE;
            pend_hs_legal_o       <= 1'b0;
            pend_hs_unsupported_o <= 1'b0;
        end else if (capture_i) begin
            pend_pid_error_o      <= ~pid_chk_ok_i;
            pend_hs_type_o        <= hs_type_i;
            pend_hs_legal_o       <= hs_is_legal_i       & pid_chk_ok_i;
            pend_hs_unsupported_o <= hs_is_unsupported_i & pid_chk_ok_i;
        end else if (sop_i) begin
            pend_pid_error_o      <= 1'b0;
            pend_hs_type_o        <= HS_NONE;
            pend_hs_legal_o       <= 1'b0;
            pend_hs_unsupported_o <= 1'b0;
        end
    end
endmodule : usb_rx_pid_capture
