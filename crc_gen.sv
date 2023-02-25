module crc5_gen (
    input  logic [10:0] data_in,   // {ENDP[3:0], ADDR[6:0]}
    output logic [4:0]  crc5_out
);

    // crc_stage[0]      = initial seed (5'h1F)
    // crc_stage[i+1]    = CRC state after processing data_in[i]
    // crc_stage[11]     = CRC state after processing all 11 bits
    logic [4:0] crc_stage [0:11];

    assign crc_stage[0] = 5'h1F;

    genvar i;
    generate
        for (i = 0; i < 11; i = i + 1) begin : crc_stage_gen
            logic fb;

            // feedback bit = incoming data bit XOR current MSB of CRC
            assign fb = data_in[i] ^ crc_stage[i][4];

            // shift left by 1, then XOR with polynomial taps (5'b00101)
            // if feedback bit is 1
            assign crc_stage[i+1] = fb ? ({crc_stage[i][3:0], 1'b0} ^ 5'b00101)
                                        : {crc_stage[i][3:0], 1'b0};
        end
    endgenerate

    // one's-complement of final CRC state (CRC5-USB convention)
    assign crc5_out = ~crc_stage[11];

endmodule
