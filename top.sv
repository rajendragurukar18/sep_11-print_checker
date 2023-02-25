/*


//=============================================================================
// usb_handshake_rx_top.sv
// TOP MODULE : USB 2.0 Protocol Layer - Handshake Packet Receiver
//
// Scope: Protocol layer only. This module assumes the Link Layer below it
// has already performed SYNC detection, NRZI decoding, bit-unstuffing and
// serial-to-parallel conversion, and hands the Protocol Layer:
//   - one byte at a time (rx_byte_i) qualified by rx_byte_valid_i
//   - a start-of-packet pulse   (rx_sop_i) when SYNC is detected
//   - an end-of-packet pulse    (rx_eop_i) when EOP is detected
//
// A Handshake packet (Figure 8-16, Section 8.4.5) is exactly one byte long
// (the PID) followed immediately by EOP. This top module:
//   1. Captures the byte-time-zero (PID) byte and decodes it
//        (usb_pid_checker          -> complement check, group, type)
//        (usb_handshake_classifier -> ACK/NAK/STALL/NYET/ERR + legality)
//   2. Independently tracks packet framing
//        (usb_handshake_length_monitor -> exactly 1 byte before EOP ?)
//   3. At EOP, combines both results into one qualified, single-cycle
//      output pulse:
//        handshake_valid_o / handshake_type_o   -- good handshake
//        err_pid_o                              -- PID checksum failure
//        err_length_o                           -- framing/length violation
//        err_unsupported_o                      -- NYET/ERR at wrong speed
//                                                   or ERR outside split ctx
//        err_unexpected_o                       -- legally-framed PID that is
//                                                   simply not a handshake at
//                                                   all, while one was expected
//
// Context inputs (driven by the surrounding transaction/protocol state
// machine, not by this block):
//   hs_mode_i         : 1 = link operating at High-Speed
//   split_hs_phase_i  : 1 = currently in the handshake phase of a split
//                        transaction (required to legally decode ERR)
//   hs_expected_i     : 1 = the current transaction phase expects a
//                        handshake response (gates err_unexpected_o)
//=============================================================================
import usb_pid_pkg::*;

module usb_handshake_rx_top (
    input  logic       clk,
    input  logic       rst_n,

    // Link-layer byte interface
    input  logic [7:0] rx_byte_i,
    input  logic       rx_byte_valid_i,
    input  logic       rx_sop_i,
    input  logic       rx_eop_i,

    // Transaction-layer context
    input  logic       hs_mode_i,
    input  logic       split_hs_phase_i,
    input  logic       hs_expected_i,

    // Decoded handshake output
    output hs_type_e    handshake_type_o,
    output logic         handshake_valid_o,

    // Error reporting (each a 1-cycle pulse)
    output logic         err_pid_o,
    output logic         err_length_o,
    output logic         err_unsupported_o,
    output logic         err_unexpected_o
);

    //-------------------------------------------------------------------
    // SUB-BLOCK 1 : PID checker (combinational)
    //-------------------------------------------------------------------
    logic       pid_chk_ok;
    pid_group_e pid_group;
    pid_type_e  pid_type;

    usb_pid_checker u_pid_checker (
        .pid_byte_i   (rx_byte_i),
        .pid_chk_ok_o (pid_chk_ok),
        .pid_group_o  (pid_group),
        .pid_type_o   (pid_type)
    );

    //-------------------------------------------------------------------
    // SUB-BLOCK 2 : Handshake classifier (combinational)
    //-------------------------------------------------------------------
    hs_type_e hs_type_comb;
    logic      hs_is_legal_comb;
    logic      hs_is_unsupported_comb;

    usb_handshake_classifier u_hs_classifier (
        .pid_group_i          (pid_group),
        .pid_type_i           (pid_type),
        .hs_mode_i            (hs_mode_i),
        .split_hs_phase_i     (split_hs_phase_i),
        .hs_type_o            (hs_type_comb),
        .hs_is_legal_o        (hs_is_legal_comb),
        .hs_is_unsupported_o  (hs_is_unsupported_comb)
    );

    //-------------------------------------------------------------------
    // SUB-BLOCK 3 : Length / EOP framing monitor (sequential+comb)
    //-------------------------------------------------------------------
    logic [7:0] len_byte_count;
    logic       len_eop_ok;
    logic       len_error;

    usb_handshake_length_monitor u_len_monitor (
        .clk            (clk),
        .rst_n          (rst_n),
        .sop_i          (rx_sop_i),
        .byte_strobe_i  (rx_byte_valid_i),
        .eop_i          (rx_eop_i),
        .byte_count_o   (len_byte_count),
        .eop_ok_o       (len_eop_ok),
        .length_error_o (len_error)
    );

    //-------------------------------------------------------------------
    // Byte-position tracking : is the *current* byte the PID byte (#1)?
    //-------------------------------------------------------------------
    logic byte_seen_r;   // 1 once the PID byte has been captured for this packet
    logic is_pid_byte;

    assign is_pid_byte = rx_byte_valid_i && !byte_seen_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_seen_r <= 1'b0;
        end else begin
            if (rx_sop_i)
                byte_seen_r <= 1'b0;
            else if (is_pid_byte)
                byte_seen_r <= 1'b1;
        end
    end

    //-------------------------------------------------------------------
    // Latch the PID decode at byte-time-zero (pending, unqualified result)
    //-------------------------------------------------------------------
    logic       pend_pid_error_r;
    hs_type_e    pend_hs_type_r;
    logic       pend_hs_legal_r;
    logic       pend_hs_unsupported_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pend_pid_error_r      <= 1'b0;
            pend_hs_type_r        <= HS_NONE;
            pend_hs_legal_r       <= 1'b0;
            pend_hs_unsupported_r <= 1'b0;
        end else if (is_pid_byte) begin
            pend_pid_error_r      <= ~pid_chk_ok;
            pend_hs_type_r        <= hs_type_comb;
            pend_hs_legal_r       <= hs_is_legal_comb & pid_chk_ok;
            pend_hs_unsupported_r <= hs_is_unsupported_comb & pid_chk_ok;
        end
    end

    //-------------------------------------------------------------------
    // Final qualification at EOP : combine framing verdict + PID decode
    //-------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            handshake_type_o  <= HS_NONE;
            handshake_valid_o <= 1'b0;
            err_pid_o         <= 1'b0;
            err_length_o      <= 1'b0;
            err_unsupported_o <= 1'b0;
            err_unexpected_o  <= 1'b0;
        end else begin
            // default: single-cycle pulses
            handshake_valid_o <= 1'b0;
            err_pid_o         <= 1'b0;
            err_length_o      <= 1'b0;
            err_unsupported_o <= 1'b0;
            err_unexpected_o  <= 1'b0;
            handshake_type_o  <= HS_NONE;

            if (rx_eop_i) begin
                if (len_error) begin
                    // Wrong framing (0 bytes, or >1 byte before EOP):
                    // "must be considered invalid and ignored" (8.4.5)
                    err_length_o <= 1'b1;
                end
                else if (len_eop_ok) begin
                    if (pend_pid_error_r) begin
                        err_pid_o <= 1'b1;
                    end
                    else if (pend_hs_legal_r) begin
                        handshake_valid_o <= 1'b1;
                        handshake_type_o  <= pend_hs_type_r;
                    end
                    else if (pend_hs_unsupported_r) begin
                        err_unsupported_o <= 1'b1;
                        handshake_type_o  <= pend_hs_type_r; // informational
                    end
                    else if (hs_expected_i) begin
                        err_unexpected_o <= 1'b1;
                    end
                    // else: correctly framed, non-handshake PID, and no
                    // handshake was expected here -> silently not our concern
                end
            end
        end
    end

endmodule : usb_handshake_rx_top
*/





//=============================================================================
// usb_handshake_rx_top.sv
// USB 2.0 Protocol Layer - Handshake Packet Receiver (Spec 8.3.1, 8.4.5)
// Fix: EOP is processed only if a packet is open (SOP seen), so a stray or
//      duplicate EOP cannot re-issue a previous handshake result.
//=============================================================================
import usb_pid_pkg::*;

module usb_handshake_rx_top (
    input  logic       clk,
    input  logic       rst_n,

    // Link-layer byte interface
    input  logic [7:0] rx_byte_i,
    input  logic       rx_byte_valid_i,
    input  logic       rx_sop_i,
    input  logic       rx_eop_i,

    // Transaction-layer context
    input  logic       hs_mode_i,
    input  logic       split_hs_phase_i,
    input  logic       hs_expected_i,

    // Decoded handshake output
    output hs_type_e   handshake_type_o,
    output logic       handshake_valid_o,

    // Error reporting (1-cycle pulses)
    output logic       err_pid_o,
    output logic       err_length_o,
    output logic       err_unsupported_o,
    output logic       err_unexpected_o
);

    // SUB-BLOCK 1 : PID checker
    logic       pid_chk_ok;
    pid_group_e pid_group;
    pid_type_e  pid_type;

    usb_pid_checker u_pid_checker (
        .pid_byte_i   (rx_byte_i),
        .pid_chk_ok_o (pid_chk_ok),
        .pid_group_o  (pid_group),
        .pid_type_o   (pid_type)
    );

    // SUB-BLOCK 2 : Handshake classifier
    hs_type_e hs_type_comb;
    logic     hs_is_legal_comb;
    logic     hs_is_unsupported_comb;

    usb_handshake_classifier u_hs_classifier (
        .pid_group_i          (pid_group),
        .pid_type_i           (pid_type),
        .hs_mode_i            (hs_mode_i),
        .split_hs_phase_i     (split_hs_phase_i),
        .hs_type_o            (hs_type_comb),
        .hs_is_legal_o        (hs_is_legal_comb),
        .hs_is_unsupported_o  (hs_is_unsupported_comb)
    );

    // SUB-BLOCK 3 : Length / EOP framing monitor
    logic [7:0] len_byte_count;
    logic       len_eop_ok;
    logic       len_error;

    usb_handshake_length_monitor u_len_monitor (
        .clk            (clk),
        .rst_n          (rst_n),
        .sop_i          (rx_sop_i),
        .byte_strobe_i  (rx_byte_valid_i),
        .eop_i          (rx_eop_i),
        .byte_count_o   (len_byte_count),
        .eop_ok_o       (len_eop_ok),
        .length_error_o (len_error)
    );

    // Packet-open tracking (set by SOP, cleared by EOP)
    logic pkt_active_r;
    logic eop_qual;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pkt_active_r <= 1'b0;
        else if (rx_sop_i)
            pkt_active_r <= 1'b1;
        else if (rx_eop_i)
            pkt_active_r <= 1'b0;
    end

    assign eop_qual = rx_eop_i && pkt_active_r;

    // PID byte position tracking (byte #1 of the packet)
    logic byte_seen_r;
    logic is_pid_byte;

    assign is_pid_byte = rx_byte_valid_i && !byte_seen_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            byte_seen_r <= 1'b0;
        else if (rx_sop_i)
            byte_seen_r <= 1'b0;
        else if (is_pid_byte)
            byte_seen_r <= 1'b1;
    end

    // Latch PID decode at byte #1
    logic     pend_pid_error_r;
    hs_type_e pend_hs_type_r;
    logic     pend_hs_legal_r;
    logic     pend_hs_unsupported_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pend_pid_error_r      <= 1'b0;
            pend_hs_type_r        <= HS_NONE;
            pend_hs_legal_r       <= 1'b0;
            pend_hs_unsupported_r <= 1'b0;
        end else if (is_pid_byte) begin
            pend_pid_error_r      <= ~pid_chk_ok;
            pend_hs_type_r        <= hs_type_comb;
            pend_hs_legal_r       <= hs_is_legal_comb & pid_chk_ok;
            pend_hs_unsupported_r <= hs_is_unsupported_comb & pid_chk_ok;
        end
    end

    // Final qualification at EOP
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            handshake_type_o  <= HS_NONE;
            handshake_valid_o <= 1'b0;
            err_pid_o         <= 1'b0;
            err_length_o      <= 1'b0;
            err_unsupported_o <= 1'b0;
            err_unexpected_o  <= 1'b0;
        end else begin
            handshake_valid_o <= 1'b0;
            err_pid_o         <= 1'b0;
            err_length_o      <= 1'b0;
            err_unsupported_o <= 1'b0;
            err_unexpected_o  <= 1'b0;
            handshake_type_o  <= HS_NONE;

            if (eop_qual) begin                       // was: rx_eop_i
                if (len_error) begin
                    err_length_o <= 1'b1;             // 8.4.5: invalid, ignored
                end
                else if (len_eop_ok) begin
                    if (pend_pid_error_r)
                        err_pid_o <= 1'b1;            // 8.3.1: PID error
                    else if (pend_hs_legal_r) begin
                        handshake_valid_o <= 1'b1;
                        handshake_type_o  <= pend_hs_type_r;
                    end
                    else if (pend_hs_unsupported_r) begin
                        err_unsupported_o <= 1'b1;
                        handshake_type_o  <= pend_hs_type_r;
                    end
                    else if (hs_expected_i)
                        err_unexpected_o <= 1'b1;
                end
            end
        end
    end

endmodule : usb_handshake_rx_top
