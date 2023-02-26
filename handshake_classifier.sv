module usb_handshake_classifier
    import usb_pid_pkg::*;
(
    input  pid_group_e pid_group_i,
    input  pid_type_e  pid_type_i,
    input  logic       hs_mode_i,           // 1 = High-Speed
    input  logic       split_hs_phase_i,    // 1 = handshake phase of a split xfer

    output hs_type_e   hs_type_o,
    output logic       hs_is_legal_o,
    output logic       hs_is_unsupported_o
);
    logic is_ack, is_nak, is_stall, is_nyet, is_err_pattern;

    always_comb begin
        is_ack         = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_ACK);
        is_nak         = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_NAK);
        is_stall       = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_STALL);
        is_nyet        = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_NYET);
        is_err_pattern = (pid_group_i == PID_GROUP_SPECIAL)   && (pid_type_i == PIDTYPE_PRE_ERR)
                         && split_hs_phase_i;

        // flags are mutually exclusive, so a priority if/else is safe
        if      (is_ack)         hs_type_o = HS_ACK;
        else if (is_nak)         hs_type_o = HS_NAK;
        else if (is_stall)       hs_type_o = HS_STALL;
        else if (is_nyet)        hs_type_o = HS_NYET;
        else if (is_err_pattern) hs_type_o = HS_ERR;
        else                     hs_type_o = HS_NONE;

        hs_is_legal_o       = is_ack || is_nak || is_stall ||
                              ((is_nyet || is_err_pattern) &&  hs_mode_i);
        hs_is_unsupported_o = (is_nyet || is_err_pattern) && !hs_mode_i;
    end
endmodule : usb_handshake_classifier
