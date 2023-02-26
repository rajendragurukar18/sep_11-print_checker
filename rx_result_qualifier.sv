//=============================================================================
// usb_rx_result_qualifier.sv  -  RX SUB-BLOCK 6
// At EOP, combines framing verdict + captured PID decode into ONE registered
// 1-cycle result.  Priority (USB 2.0 Sec 8.4.5):
//   length error > PID check error > legal handshake > unsupported
//   (NYET/ERR at wrong speed/context) > unexpected (only if hs_expected)
// hs_expected_i is sampled in the EOP cycle.
//=============================================================================
module usb_rx_result_qualifier
    import usb_pid_pkg::*;
(
    input  logic     clk,
    input  logic     rst_n,
    input  logic     eop_v_i,
    input  logic     len_error_i,
    input  logic     len_eop_ok_i,
    input  logic     hs_expected_i,

    input  logic     pend_pid_error_i,
    input  hs_type_e pend_hs_type_i,
    input  logic     pend_hs_legal_i,
    input  logic     pend_hs_unsupported_i,

    output hs_type_e handshake_type_o,
    output logic     handshake_valid_o,
    output logic     err_pid_o,
    output logic     err_length_o,
    output logic     err_unsupported_o,
    output logic     err_unexpected_o
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            handshake_type_o  <= HS_NONE;
            handshake_valid_o <= 1'b0;
            err_pid_o         <= 1'b0;
            err_length_o      <= 1'b0;
            err_unsupported_o <= 1'b0;
            err_unexpected_o  <= 1'b0;
        end else begin
            handshake_type_o  <= HS_NONE;
            handshake_valid_o <= 1'b0;
            err_pid_o         <= 1'b0;
            err_length_o      <= 1'b0;
            err_unsupported_o <= 1'b0;
            err_unexpected_o  <= 1'b0;

            if (eop_v_i) begin
                if (len_error_i) begin
                    err_length_o <= 1'b1;
                end else if (len_eop_ok_i) begin
                    if (pend_pid_error_i) begin
                        err_pid_o <= 1'b1;
                    end else if (pend_hs_legal_i) begin
                        handshake_valid_o <= 1'b1;
                        handshake_type_o  <= pend_hs_type_i;
                    end else if (pend_hs_unsupported_i) begin
                        err_unsupported_o <= 1'b1;
                        handshake_type_o  <= pend_hs_type_i;   // informational
                    end else if (hs_expected_i) begin
                        err_unexpected_o  <= 1'b1;
                    end
                end
            end
        end
    end
endmodule : usb_rx_result_qualifier
