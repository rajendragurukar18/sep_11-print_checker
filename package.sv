package usb_pkg;

    // 4-bit PID codes 
    typedef enum logic [3:0] {
        PID_OUT   = 4'b0001,  // Token   - Host->Function, data will follow
        PID_IN    = 4'b1001,  // Token   - Host->Function, requests data
        PID_SOF   = 4'b0101,  // Token   - Start of Frame 
        PID_SETUP = 4'b1101,  // Token   - Host->Function, begins control transfer
        PID_PING  = 4'b0100   // Special - flow-control probe 
    } pid_code_e;

    // Internal token-type selector used on module ports
    typedef enum logic [1:0] {
        TKN_OUT   = 2'b00,
        TKN_IN    = 2'b01,
        TKN_SETUP = 2'b10,
        TKN_PING  = 2'b11
    } tkn_sel_e;

    // SYNC field placeholder (logical-level model; NRZI line coding of the
    // actual KJKJKJKK pattern is a PHY-layer concern,  and is
    // out of scope for this token-layer design)
    localparam logic [7:0] USB_SYNC_BYTE = 8'h80;

    localparam int TOTAL_FRAME_BITS = 32; // SYNC(8)+PID(8)+ADDR(7)+ENDP(4)+CRC5(5)

   
    function automatic string tkn_name(tkn_sel_e t);
        case (t)
            TKN_OUT:   tkn_name = "OUT";
            TKN_IN:    tkn_name = "IN";
            TKN_SETUP: tkn_name = "SETUP";
            TKN_PING:  tkn_name = "PING";
            default:   tkn_name = "??";
        endcase
    endfunction

endpackage

