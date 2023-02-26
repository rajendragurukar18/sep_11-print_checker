//=============================================================================
// usb_pid_checker.sv  -  SUB-BLOCK 1 (combinational)
// PID = 4-bit type + 4-bit check (one's complement of type)  [Sec 8.3.1]
//=============================================================================
module usb_pid_checker
    import usb_pid_pkg::*;
(
    input  logic [7:0]  pid_byte_i,
    output logic        pid_chk_ok_o,   // 1 = check field == ~type field
    output pid_group_e  pid_group_o,
    output pid_type_e   pid_type_o
);
    logic [3:0] type_field;
    logic [3:0] check_field;

    assign type_field  = pid_byte_i[3:0];
    assign check_field = pid_byte_i[7:4];

    always_comb begin
        pid_chk_ok_o = (check_field == ~type_field);
        pid_group_o  = pid_group_e'(type_field[1:0]);
        pid_type_o   = pid_type_e'(type_field);
    end
endmodule : usb_pid_checker
