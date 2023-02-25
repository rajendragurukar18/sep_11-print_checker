//=============================================================================
// usb_pid_pkg.sv
// Common type/constant package for the USB 2.0 Protocol Layer
// Handshake Packet Receiver.
//
// Reference : USB Specification Revision 2.0
//   - Section 8.3.1 (Packet Identifier Field) / Figure 8-1
//   - Table  8-1   (PID Types)
//   - Section 8.4.5 (Handshake Packets) / Figure 8-16
//
// PID byte convention:
//   The 8-bit PID byte as handed off by the Link Layer is treated in the
//   conventional "byte" (MSb..LSb) form used by protocol analyzers:
//     pid_byte[3:0] = packet type field   (PID<3:0> of Table 8-1)
//     pid_byte[7:4] = check field         (one's complement of type field)
//   This matches the well known handshake byte values ACK=8'hD2, NAK=8'h5A,
//   STALL=8'h1E, NYET=8'h96, ERR=8'h3C (derived directly from Table 8-1 +
//   Figure 8-1: byte = {~type_field, type_field}).
//=============================================================================
/*
package usb_pid_pkg;

    // ------------------------------------------------------------------
    // PID Group encoding -> packet type bits <1:0>  (Section 8.3.1)
    // ------------------------------------------------------------------
    typedef enum logic [1:0] {
        PID_GROUP_SPECIAL   = 2'b00,
        PID_GROUP_TOKEN     = 2'b01,
        PID_GROUP_HANDSHAKE = 2'b10,
        PID_GROUP_DATA      = 2'b11
    } pid_group_e;

    // ------------------------------------------------------------------
    // Full PID type field values, PID<3:0>  (Table 8-1)
    // ------------------------------------------------------------------
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
        PIDTYPE_PRE_ERR = 4'b1100, // PRE (token context) / ERR (handshake context)
        PIDTYPE_SETUP   = 4'b1101,
        PIDTYPE_STALL   = 4'b1110,
        PIDTYPE_MDATA   = 4'b1111
    } pid_type_e;

    // ------------------------------------------------------------------
    // Full 8-bit PID byte constants : byte = {~type_field, type_field}
    // ------------------------------------------------------------------
    localparam logic [7:0] PIDBYTE_ACK   = 8'hD2;
    localparam logic [7:0] PIDBYTE_NAK   = 8'h5A;
    localparam logic [7:0] PIDBYTE_STALL = 8'h1E;
    localparam logic [7:0] PIDBYTE_NYET  = 8'h96;
    localparam logic [7:0] PIDBYTE_ERR   = 8'h3C; // same byte as PRE, context disambiguated
    localparam logic [7:0] PIDBYTE_OUT   = 8'hE1;
    localparam logic [7:0] PIDBYTE_DATA0 = 8'hC3;

    // ------------------------------------------------------------------
    // Decoded handshake type enumeration
    // ------------------------------------------------------------------
    typedef enum logic [2:0] {
        HS_NONE  = 3'b000,
        HS_ACK   = 3'b001,
        HS_NAK   = 3'b010,
        HS_STALL = 3'b011,
        HS_NYET  = 3'b100,
        HS_ERR   = 3'b101
    } hs_type_e;

endpackage : usb_pid_pkg



*/


//=============================================================================
// usb_pid_pkg.sv
//=============================================================================
package usb_pid_pkg;

    typedef enum logic [1:0] {
        PID_GROUP_SPECIAL   = 2'b00,
        PID_GROUP_TOKEN     = 2'b01,
        PID_GROUP_HANDSHAKE = 2'b10,
        PID_GROUP_DATA      = 2'b11
    } pid_group_e;

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
        PIDTYPE_PRE_ERR = 4'b1100,
        PIDTYPE_SETUP   = 4'b1101,
        PIDTYPE_STALL   = 4'b1110,
        PIDTYPE_MDATA   = 4'b1111
    } pid_type_e;

    localparam logic [7:0] PIDBYTE_ACK   = 8'hD2;
    localparam logic [7:0] PIDBYTE_NAK   = 8'h5A;
    localparam logic [7:0] PIDBYTE_STALL = 8'h1E;
    localparam logic [7:0] PIDBYTE_NYET  = 8'h96;
    localparam logic [7:0] PIDBYTE_ERR   = 8'h3C;
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

