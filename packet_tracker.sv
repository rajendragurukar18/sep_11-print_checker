//=============================================================================
// usb_rx_packet_tracker.sv  -  RX SUB-BLOCK 4
// Tracks "are we inside a packet" and which byte is the PID byte.
// Gates link-layer strobes so stray bytes / EOPs (no SOP) are ignored.
//   * SOP may coincide with the first byte, never with EOP
//   * a new SOP aborts a packet in progress
//=============================================================================
module usb_rx_packet_tracker (
    input  logic clk,
    input  logic rst_n,
    input  logic rx_sop_i,
    input  logic rx_byte_valid_i,
    input  logic rx_eop_i,

    output logic byte_v_o,        // byte accepted (inside a packet)
    output logic eop_v_o,         // EOP accepted  (inside a packet)
    output logic is_pid_byte_o    // this byte is byte #1 of the packet
);
    logic pkt_active_r;
    logic byte_seen_r;

    assign byte_v_o      = rx_byte_valid_i && (pkt_active_r || rx_sop_i);
    assign eop_v_o       = rx_eop_i        &&  pkt_active_r;
    assign is_pid_byte_o = byte_v_o && (!byte_seen_r || rx_sop_i);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pkt_active_r <= 1'b0;
            byte_seen_r  <= 1'b0;
        end else begin
            if (rx_sop_i)        pkt_active_r <= 1'b1;
            else if (eop_v_o)    pkt_active_r <= 1'b0;

            if (is_pid_byte_o)   byte_seen_r <= 1'b1;
            else if (rx_sop_i)   byte_seen_r <= 1'b0;
        end
    end
endmodule : usb_rx_packet_tracker
