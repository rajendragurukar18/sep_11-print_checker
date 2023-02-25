import usb_pkg::*;

module token_tx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  tkn_sel_e   tkn_sel,
    input  logic [6:0] addr,
    input  logic [3:0] endp,

    output logic       tx_bit,
    output logic       tx_valid,
    output logic       busy,
    output logic       tx_done,

    output logic [7:0] pid_byte_o,
    output logic [4:0] crc5_o
);

    logic [5:0]  cnt;
    logic        busy_r, done_r;
    logic [6:0]  addr_r;
    logic [3:0]  endp_r;
    tkn_sel_e    tkn_r;

    pid_code_e  pid_code;
    logic [7:0] pid_byte;
    logic [4:0] crc5;

    pid_encoder u_pid_enc (
        .tkn_sel  (tkn_r),
        .pid_code (pid_code),
        .pid_byte (pid_byte)
    );

    crc5_gen u_crc5_gen (
        .data_in  ({endp_r, addr_r}),
        .crc5_out (crc5)
    );

    assign pid_byte_o = pid_byte;
    assign crc5_o     = crc5;

    // bit-select mux: each field is indexed LSB-first, matching transmit order
    always_comb begin
        if (cnt < 8)
            tx_bit = USB_SYNC_BYTE[cnt];
        else if (cnt < 16)
            tx_bit = pid_byte[cnt-8];
        else if (cnt < 23)
            tx_bit = addr_r[cnt-16];
        else if (cnt < 27)
            tx_bit = endp_r[cnt-23];
        else if (cnt < 32)
            tx_bit = crc5[cnt-27];
        else
            tx_bit = 1'b0;
    end

    assign tx_valid = busy_r;
    assign busy     = busy_r;
    assign tx_done  = done_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt    <= '0;
            busy_r <= 1'b0;
            done_r <= 1'b0;
            addr_r <= '0;
            endp_r <= '0;
            tkn_r  <= TKN_OUT;
        end else begin
            done_r <= 1'b0;
            if (start && !busy_r) begin
                busy_r <= 1'b1;
                cnt    <= '0;
                addr_r <= addr;
                endp_r <= endp;
                tkn_r  <= tkn_sel;
            end else if (busy_r) begin
                if (cnt == TOTAL_FRAME_BITS-1) begin
                    busy_r <= 1'b0;
                    done_r <= 1'b1;
                    cnt    <= '0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end

endmodule
