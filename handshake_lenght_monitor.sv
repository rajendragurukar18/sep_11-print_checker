
/*
//=============================================================================
// usb_handshake_length_monitor.sv
// SUB-BLOCK 3 : Handshake Packet Length / EOP Framing Monitor
//
// Function (USB2.0 Spec 8.4.5, Figure 8-16):
//   "Handshake packets ... consist of only a PID"  (Field=PID, Bits=8)
//   "Handshake packets are delimited by an EOP after one byte of packet
//    field. If a packet decodes as an otherwise valid handshake but does
//    not terminate with an EOP after one byte, it must be considered
//    invalid and ignored by the receiver."
//
// byte_count_o is a sequential running count of bytes seen since the last
// SOP. eop_ok_o / length_error_o are combinational verdicts of the CURRENT
// cycle's stimulus (byte_strobe_i / eop_i) against that count, so a
// downstream module sampling them synchronously on the same clock edge that
// eop_i arrives sees a correctly time-aligned result (no extra latency).
//=============================================================================

module usb_handshake_length_monitor (
    input  logic clk,
    input  logic rst_n,

    input  logic sop_i,          // 1-cycle pulse: SYNC field detected / packet start
    input  logic byte_strobe_i,  // 1-cycle pulse: one byte delivered by link layer
    input  logic eop_i,          // 1-cycle pulse: EOP detected by link layer

    output logic [7:0] byte_count_o,   // running byte count since last SOP
    output logic        eop_ok_o,       // combinational: legal 1-byte handshake framing
    output logic        length_error_o  // combinational: framing violation
);

    // Sequential byte counter -----------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_count_o <= 8'd0;
        end else begin
            if (sop_i)
                byte_count_o <= 8'd0;
            else if (byte_strobe_i && !eop_i)
                byte_count_o <= byte_count_o + 8'd1;
        end
    end

    // Combinational verdict, valid the same cycle eop_i (or a bad
    // simultaneous byte+eop) is asserted ------------------------------------
    always_comb begin
        eop_ok_o       = eop_i && !byte_strobe_i && (byte_count_o == 8'd1);

        length_error_o = (byte_strobe_i && eop_i)                                ||  // malformed: simultaneous
                         (eop_i && !byte_strobe_i && (byte_count_o != 8'd1))     ||  // 0 or >1 bytes seen
                         (byte_strobe_i && !eop_i && (byte_count_o >= 8'd1));        // 2nd+ byte arriving
    end

endmodule : usb_handshake_length_monitor
*/



//=============================================================================
// usb_handshake_length_monitor.sv
// USB 2.0 Spec 8.4.5 : a handshake packet is exactly one byte (the PID)
// followed by EOP; otherwise it is invalid and ignored.
// Fix: counter saturates at 8'hFF so a long packet cannot wrap to 1.
//=============================================================================
module usb_handshake_length_monitor (
    input  logic clk,
    input  logic rst_n,

    input  logic sop_i,
    input  logic byte_strobe_i,
    input  logic eop_i,

    output logic [7:0] byte_count_o,
    output logic       eop_ok_o,
    output logic       length_error_o
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            byte_count_o <= 8'd0;
        else if (sop_i)
            byte_count_o <= 8'd0;
        else if (byte_strobe_i && !eop_i && (byte_count_o != 8'hFF))
            byte_count_o <= byte_count_o + 8'd1;
    end

    always_comb begin
        eop_ok_o       = eop_i && !byte_strobe_i && (byte_count_o == 8'd1);

        length_error_o = (byte_strobe_i && eop_i) ||
                         (eop_i && !byte_strobe_i && (byte_count_o != 8'd1));
    end

endmodule : usb_handshake_length_monitor
