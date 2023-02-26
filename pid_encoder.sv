//=============================================================================
// usb_handshake_pid_encoder.sv  -  TX SUB-BLOCK 1 (combinational)
// hs_type -> PID type field -> full PID byte {~type, type}   [Sec 8.3.1]
// Also decides whether the requested handshake is LEGAL to transmit.
//
// Legality rules implemented (adjust here if your project differs):
//   HOST    : ACK only
//   DEVICE  : ACK, NAK, STALL                     (all speeds)
//             NYET                                (High-Speed only)
//             ERR  (hub, split handshake phase)   (High-Speed only)
//   HS_NONE / unknown encodings are never legal.
//=============================================================================
module usb_handshake_pid_encoder
    import usb_pid_pkg::*;
(
    input  hs_type_e   hs_type_i,
    input  logic       is_host_i,         // 1 = host, 0 = device/hub
    input  logic       hs_mode_i,         // 1 = High-Speed
    input  logic       split_hs_phase_i,  // 1 = handshake phase of a split xfer

    output logic [7:0] pid_byte_o,
    output logic       legal_o
);
    logic [3:0] type_field;
    logic       known;

    always_comb begin
        type_field = 4'b0000;
        known      = 1'b1;
        case (hs_type_i)
            HS_ACK:   type_field = PIDTYPE_ACK;
            HS_NAK:   type_field = PIDTYPE_NAK;
            HS_STALL: type_field = PIDTYPE_STALL;
            HS_NYET:  type_field = PIDTYPE_NYET;
            HS_ERR:   type_field = PIDTYPE_PRE_ERR;
            default:  known      = 1'b0;
        endcase

        pid_byte_o = {~type_field, type_field};

        case (hs_type_i)
            HS_ACK:          legal_o = 1'b1;
            HS_NAK, HS_STALL:legal_o = !is_host_i;
            HS_NYET:         legal_o = !is_host_i && hs_mode_i;
            HS_ERR:          legal_o = !is_host_i && hs_mode_i && split_hs_phase_i;
            default:         legal_o = 1'b0;
        endcase
        legal_o = legal_o && known;
    end
endmodule : usb_handshake_pid_encoder
