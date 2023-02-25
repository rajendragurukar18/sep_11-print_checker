import usb_pkg::*;

module pid_encoder (
    input  tkn_sel_e   tkn_sel,
    output pid_code_e  pid_code,
    output logic [7:0] pid_byte
);

    always_comb begin
        unique case (tkn_sel)
            TKN_OUT:   pid_code = PID_OUT;
            TKN_IN:    pid_code = PID_IN;
            TKN_SETUP: pid_code = PID_SETUP;
            TKN_PING:  pid_code = PID_PING;
            default:   pid_code = PID_OUT;
        endcase
        pid_byte = {~pid_code, pid_code};
    end

endmodule
