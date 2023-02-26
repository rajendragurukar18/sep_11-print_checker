//=============================================================================
// usb_pid_pkg.sv  -  common types for USB 2.0 protocol-layer handshake RX
// Ref: USB 2.0 spec Sec 8.3.1 (Fig 8-1), Table 8-1, Sec 8.4.5 (Fig 8-16)
//=============================================================================
package usb_pid_pkg;

    // PID group = PID<1:0>
    typedef enum logic [1:0] {
        PID_GROUP_SPECIAL   = 2'b00,
        PID_GROUP_TOKEN     = 2'b01,
        PID_GROUP_HANDSHAKE = 2'b10,
        PID_GROUP_DATA      = 2'b11
    } pid_group_e;

    // PID type field = PID<3:0>
    typedef enum logic [3:0] {
        PIDTYPE_RSVD    = 4'b0000,
        PIDTYPE_OUT     = 4'b0001,
        PIDTYPE_ACK     = 4'b0010,
        PIDTYPE_DATA0   = 4'b0011,
        PIDTYPE_PING    = 4'b0100,
        PIDTYPE_SOF     = 4'b0101,
        PIDTYPE_NYET    = 4'b0110,
        PIDTYPE_DATA2   = 4'b0111,
        PIDTYPE_SPLIT   = 4'b1000,
        PIDTYPE_IN      = 4'b1001,
        PIDTYPE_NAK     = 4'b1010,
        PIDTYPE_DATA1   = 4'b1011,
        PIDTYPE_PRE_ERR = 4'b1100,   // PRE (token ctx) / ERR (split handshake ctx)
        PIDTYPE_SETUP   = 4'b1101,
        PIDTYPE_STALL   = 4'b1110,
        PIDTYPE_MDATA   = 4'b1111
    } pid_type_e;

    // Full PID byte = {~type, type}
    localparam logic [7:0] PIDBYTE_ACK   = 8'hD2;
    localparam logic [7:0] PIDBYTE_NAK   = 8'h5A;
    localparam logic [7:0] PIDBYTE_STALL = 8'h1E;
    localparam logic [7:0] PIDBYTE_NYET  = 8'h96;
    localparam logic [7:0] PIDBYTE_ERR   = 8'h3C;   // same byte as PRE
    localparam logic [7:0] PIDBYTE_OUT   = 8'hE1;
    localparam logic [7:0] PIDBYTE_DATA0 = 8'hC3;

    typedef enum logic [2:0] {
        HS_NONE  = 3'b000,
        HS_ACK   = 3'b001,
        HS_NAK   = 3'b010,
        HS_STALL = 3'b011,
        HS_NYET  = 3'b100,
        HS_ERR   = 3'b101
    } hs_type_e;

endpackage : usb_pid_pkg
