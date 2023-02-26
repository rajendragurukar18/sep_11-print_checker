module usb_handshake_length_monitor (
    input  logic       clk,
    input  logic       rst_n,

    input  logic       sop_i,
    input  logic       byte_strobe_i,
    input  logic       eop_i,

    output logic [7:0] byte_count_o,
    output logic       eop_ok_o,        // exactly 1 byte then EOP
    output logic       length_error_o   // any other framing
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            byte_count_o <= 8'd0;
        else if (sop_i)
            byte_count_o <= byte_strobe_i ? 8'd1 : 8'd0;      
        else if (eop_i)
            byte_count_o <= 8'd0;                             
        else if (byte_strobe_i && (byte_count_o != 8'hFF))    
            byte_count_o <= byte_count_o + 8'd1;
    end

    always_comb begin
        eop_ok_o       = eop_i && !byte_strobe_i && (byte_count_o == 8'd1);
        length_error_o = eop_i && (byte_strobe_i || (byte_count_o != 8'd1));
    end
endmodule : usb_handshake_length_monitor
