//=============================================================================
// usb_handshake_classifier.sv
// SUB-BLOCK 2 : Handshake Classifier  (combinational decode)
//
// Function (USB2.0 Spec 8.4.5 / 8.4.6):
//   Given an already PID-checked group/type, decide whether it corresponds
//   to one of the defined handshake packets and, if so, which one:
//       ACK   PID<3:0>=0010   (group=HANDSHAKE) - all speeds
//       NAK   PID<3:0>=1010   (group=HANDSHAKE) - all speeds
//       STALL PID<3:0>=1110   (group=HANDSHAKE) - all speeds
//       NYET  PID<3:0>=0110   (group=HANDSHAKE) - HIGH-SPEED ONLY (8.4.5)
//       ERR   PID<3:0>=1100   (group=SPECIAL, reuses PRE's bit pattern) -
//                              HIGH-SPEED ONLY, and only meaningful when the
//                              receiver (hub) is in the handshake phase of a
//                              split transaction (8.4.5: "ERR ... reuses PRE
//                              value"). This context is supplied by the
//                              transaction layer via split_hs_phase_i,
//                              because the bit pattern alone cannot
//                              distinguish PRE (token) from ERR (handshake).
//
//   Purely combinational. Reports three mutually exclusive outcome flags for
//   the current byte's group/type; the sequential top module latches the
//   outcome at the correct byte-time and finally qualifies it against
//   packet framing (EOP after exactly one byte) and against whether a
//   handshake was actually expected.
//=============================================================================
import usb_pid_pkg::*;

module usb_handshake_classifier (
    input  pid_group_e pid_group_i,
    input  pid_type_e  pid_type_i,

    input  logic       hs_mode_i,          // 1 = link currently at High-Speed
    input  logic       split_hs_phase_i,   // 1 = handshake phase of a split transaction
                                            //     (required context to accept ERR)

    output hs_type_e    hs_type_o,          // decoded handshake type
    output logic         hs_is_legal_o,      // 1 = a fully legal handshake for this context
    output logic         hs_is_unsupported_o // 1 = matched NYET/ERR bit pattern but not
                                              //     legal in the current speed/context
                                              //     (e.g. NYET at Full/Low-Speed)
);

    logic is_ack, is_nak, is_stall, is_nyet, is_err_pattern;

    always_comb begin
        is_ack         = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_ACK);
        is_nak         = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_NAK);
        is_stall       = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_STALL);
        is_nyet        = (pid_group_i == PID_GROUP_HANDSHAKE) && (pid_type_i == PIDTYPE_NYET);
        is_err_pattern = (pid_group_i == PID_GROUP_SPECIAL)   && (pid_type_i == PIDTYPE_PRE_ERR)
                          && split_hs_phase_i;

        unique case (1'b1)
            is_ack   : hs_type_o = HS_ACK;
            is_nak   : hs_type_o = HS_NAK;
            is_stall : hs_type_o = HS_STALL;
            is_nyet  : hs_type_o = HS_NYET;
            is_err_pattern : hs_type_o = HS_ERR;
            default  : hs_type_o = HS_NONE;
        endcase

        hs_is_legal_o = is_ack || is_nak || is_stall ||
                        (is_nyet && hs_mode_i) ||
                        (is_err_pattern && hs_mode_i);

        hs_is_unsupported_o = (is_nyet && !hs_mode_i) ||
                              (is_err_pattern && !hs_mode_i);
    end

endmodule : usb_handshake_classifier

