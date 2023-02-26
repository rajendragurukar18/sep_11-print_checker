//=============================================================================
// usb_tx_fsm.sv  -  TX SUB-BLOCK 2
// Sequencer: IDLE -> SOP pulse -> PID byte (valid/ready) -> EOP pulse -> IDLE
//   * request sampled in IDLE: legal -> latch PID byte and start,
//                              illegal -> tx_err_illegal_o pulse
//   * request while not IDLE -> ignored, tx_err_busy_o pulse
//   * tx_done_o pulses the cycle after the EOP pulse
//=============================================================================
module usb_tx_fsm (
    input  logic       clk,
    input  logic       rst_n,

    input  logic       tx_req_i,
    input  logic [7:0] enc_byte_i,       // from PID encoder
    input  logic       enc_legal_i,      // from PID encoder

    output logic       tx_sop_o,
    output logic [7:0] tx_byte_o,
    output logic       tx_byte_valid_o,
    input  logic       tx_byte_ready_i,
    output logic       tx_eop_o,

    output logic       tx_busy_o,
    output logic       tx_done_o,
    output logic       tx_err_illegal_o,
    output logic       tx_err_busy_o
);
    typedef enum logic [1:0] { S_IDLE, S_SOP, S_BYTE, S_EOP } state_e;
    state_e     state_r;
    logic [7:0] pid_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r          <= S_IDLE;
            pid_r            <= 8'h00;
            tx_done_o        <= 1'b0;
            tx_err_illegal_o <= 1'b0;
            tx_err_busy_o    <= 1'b0;
        end else begin
            tx_done_o        <= 1'b0;
            tx_err_illegal_o <= 1'b0;
            tx_err_busy_o    <= 1'b0;

            case (state_r)
                S_IDLE: begin
                    if (tx_req_i) begin
                        if (enc_legal_i) begin
                            pid_r   <= enc_byte_i;
                            state_r <= S_SOP;
                        end else begin
                            tx_err_illegal_o <= 1'b1;
                        end
                    end
                end
                S_SOP:  state_r <= S_BYTE;
                S_BYTE: if (tx_byte_ready_i) state_r <= S_EOP;
                S_EOP: begin
                    state_r   <= S_IDLE;
                    tx_done_o <= 1'b1;
                end
                default: state_r <= S_IDLE;
            endcase

            if (tx_req_i && (state_r != S_IDLE))
                tx_err_busy_o <= 1'b1;
        end
    end

    assign tx_sop_o        = (state_r == S_SOP);
    assign tx_byte_valid_o = (state_r == S_BYTE);
    assign tx_eop_o        = (state_r == S_EOP);
    assign tx_byte_o       = pid_r;
    assign tx_busy_o       = (state_r != S_IDLE);
endmodule : usb_tx_fsm
