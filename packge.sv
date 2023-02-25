package usb_pkg;
  localparam logic [3:0] PID_DATA0 = 4'b0011;   // 0xC3
  localparam logic [3:0] PID_DATA1 = 4'b1011;   // 0x4B
  localparam logic [3:0] PID_DATA2 = 4'b0111;   // 0x87 (HS only)
  localparam logic [3:0] PID_MDATA = 4'b1111;   // 0x0F (HS only)
 
  localparam logic [15:0] CRC16_INIT = 16'hFFFF;
  localparam logic [15:0] CRC16_POLY = 16'h8005;
 
  localparam logic [1:0] EP_CTRL = 2'b00;
  localparam logic [1:0] EP_ISOC = 2'b01;
  localparam logic [1:0] EP_BULK = 2'b10;
  localparam logic [1:0] EP_INTR = 2'b11;
 
  localparam logic [10:0] MAXPKT_LS      = 11'd8;
  localparam logic [10:0] MAXPKT_FS      = 11'd64;
  localparam logic [10:0] MAXPKT_FS_ISO  = 11'd1023;
  localparam logic [10:0] MAXPKT_HS_CTRL = 11'd64;
  localparam logic [10:0] MAXPKT_HS_BULK = 11'd512;
  localparam logic [10:0] MAXPKT_HS      = 11'd1024;
endpackage : usb_pkg
