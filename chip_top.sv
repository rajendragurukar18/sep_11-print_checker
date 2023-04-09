module      chip_top        (
    



inout       logic           VDD                 ,
inout       logic           VSS                 ,
inout       logic           VDD_1_2             ,
inout       logic           RESET_N             ,
input       logic           XTAL_IN             ,
output      logic           XTAL_OUT            ,
inout       logic           VDD_1_8             ,
inout       logic           VDD_2_5             ,
inout       logic           ANA0                ,
inout       logic           ANA1                ,
inout       logic           ANA2                ,
inout       logic           ANA3                ,
inout       logic           ANA4                ,
inout       logic           ANA5                ,
inout       logic           ANA6                ,
inout       logic           ANA7                ,
inout       logic           ANA8                ,
inout       logic           ANA9                ,
inout       logic           ADC_IN              ,
inout       logic           DAC_OUT             ,
inout       logic           LDO_1_2_ACAP        ,
inout       logic           LDO_1_2_DCAP        ,
inout       logic           LDO_1_8_ACAP        ,
inout       logic           LDO_1_8_DCAP        ,
inout       logic           LDO_2_5_ACAP        ,
inout       logic           LDO_2_5_DCAP        ,
inout       logic           TRST                ,
inout       logic           TCK                 ,
inout       logic           TMS                 ,
inout       logic           TDI                 ,
inout       logic           TDO                 ,
inout       logic           GPIO0               ,
inout       logic           GPIO1               ,
inout       logic           GPIO2               ,
inout       logic           GPIO3               ,
inout       logic           GPIO4               ,
inout       logic           GPIO5               ,
inout       logic           GPIO6               ,
inout       logic           GPIO7               ,
inout       logic           GPIO8               ,
inout       logic           GPIO9               ,
inout       logic           GPIO10              ,
inout       logic           GPIO11              ,
inout       logic           GPIO12              ,
inout       logic           GPIO13              ,
inout       logic           GPIO14              ,
inout       logic           GPIO15              ,
inout       logic           GPIO16              ,
inout       logic           GPIO17              ,
inout       logic           GPIO18              ,
inout       logic           GPIO19              ,
inout       logic           GPIO20              ,
inout       logic           GPIO21              ,
inout       logic           GPIO22          

                            )                   ;



//--------------------------------------------INTERNAL WIRES-----------------------------------                            





//                      ANALOG TOP TO PINAKA TOP (TO REGISTER)

logic       [23:0]          analog_pinaka_cifb_vout_m00             ; 
logic       [23:0]          analog_pinaka_ciff_vout_m00             ; 
logic       [11:0]          analog_pinaka_sar_vout_m00              ; 
logic       [11:0]          analog_pinaka_tdc_vout                  ;


//                  CLOCK SIGNAL FROM THE ANALOG TOP TO PINAKA TOP

logic                       analog_pinaka_rc_osc_clk                ;
logic                       analog_pinaka_pll_clk                   ;


//                  ANALOG TOP TO PINAKA TOP STATUS SIGNAL (GPIO PINMUX)

logic                       analog_pinaka_rc_osc_clk_ok             ;
logic                       analog_pinaka_v12_vok                   ;
logic                       analog_pinaka_v18_vok                   ;
logic                       analog_pinaka_v25_vok                   ;
logic                       analog_pinaka_pll_lock                  ;
logic                       analog_pinaka_por_vok                   ;


//                  PINAKA TOP TO IOPAD TOP (JTAG SIGNALS)

logic                       iopad_pinaka_tck                        ;
logic                       iopad_pinaka_trstn                      ;
logic                       iopad_pinaka_tms                        ;
logic                       iopad_pinaka_tdi                        ;


//                  IOPAD TOP TO PINAKA TOP (JTAG SIGNAL)
 
logic                       pinaka_iopad_tdo                        ;


//                  XTAL CLK AND HARD RESET FROM THE IO PAD TOP

logic                       xtal_clk                                ;
logic                       iopad_pinaka_hard_reset                 ;


//                  PREBOOT ANALOG REGISTER FROM PINAKA TOP

logic       [29:0]          pinaka_analog_preboot_reg0              ;
logic       [15:0]          pinaka_analog_preboot_reg1              ;


//                  POST BOOT ANALOG REGISTER FROM PINAKA TOP

logic       [50:0]          pinaka_analog_postboot_reg0             ;
logic       [50:0]          pinaka_analog_postboot_reg1             ;
logic       [16:0]          pinaka_analog_postboot_reg2             ;
logic       [11:0]          pinaka_analog_postboot_reg3             ;
logic       [11:0]          pinaka_analog_postboot_reg4             ;
logic       [50:0]          pinaka_analog_postboot_reserved_reg     ;


//                  POST BOOT CALIBRATE ANALOG REGISTER FROM THE PINAKA TOP

logic       [31:0]          pinaka_analog_calibrate_reg0            ;
logic       [31:0]          pinaka_analog_calibrate_reg1            ;
logic       [31:0]          pinaka_analog_calibrate_reg2            ;
logic       [31:0]          pinaka_analog_calibrate_reg3            ;
logic       [31:0]          pinaka_analog_calibrate_reg4            ;
logic       [31:0]          pinaka_analog_calibrate_reg5            ;

//                      IOPAD AND PINAKA TOP (GPIO SIGNALS)         

logic       [22:0]          iopad_pinaka_gpio_pad_in                ;
logic       [22:0]          pinaka_iopad_gpio_pad_out               ;
logic       [22:0]          pinaka_iopad_gpio_pad_oe                ;
logic       [22:0]          pinaka_iopad_pull_en                    ;

//                      IOPAD AND ANALOG TOP (POWER SUPPLY)

logic                       iopad_analog_vddd_12                    ;
logic                       iopad_analog_vssa_xx_ext                ;






//----------------------------------------------------------------------------------------------------------------




logic       [191:0]         total_calibrate_reg                     ;
logic       [191:0]         total_config_trim_reg                   ;
logic       [383:0]         pinaka_analog_384_reg                   ;


assign      total_calibrate_reg     =   { pinaka_analog_calibrate_reg0 , pinaka_analog_calibrate_reg1, pinaka_analog_calibrate_reg2 ,pinaka_analog_calibrate_reg3 , pinaka_analog_calibrate_reg4, pinaka_analog_calibrate_reg5 } ;
assign      total_config_trim_reg   =   { pinaka_analog_postboot_reserved_reg, pinaka_analog_postboot_reg0, pinaka_analog_postboot_reg1, pinaka_analog_preboot_reg0, pinaka_analog_preboot_reg1[10:2] } ;

assign      pinaka_analog_384_reg   =   { total_calibrate_reg, total_config_trim_reg } ;




//--------------------------------------TOP MODULES INSTANTIATIONS------------------------------------



//------------------------------------  ANALOG TOP INSTANTIATION-----------------------------




analog_top          analog_top_instance     (


//                          TO THE PINAKA TOP (REGISTER)

            .cifb_vout_m00                  (analog_pinaka_cifb_vout_m00)           , 
            .ciff_vout_m00                  (analog_pinaka_ciff_vout_m00)           , 
            .sar_vout_m00                   (analog_pinaka_sar_vout_m00)            , 
            .tdc_vout_m00                   (analog_pinaka_tdc_vout)                , 


//                          CLOCKS TO THE PINAKA TOP

            .osc_clk_m00                    (analog_pinaka_rc_osc_clk)              , 
            .pll_clk_m00                    (analog_pinaka_pll_clk)                 , 


//                      STATUS SIGNAL TO PINAKA TOP (GPIO PINMUX)

            .osc_ok_m00                     (analog_pinaka_rc_osc_clk_ok)           , 
            .v12_vok_m00                    (analog_pinaka_v12_vok)                 , 
            .v18_vok_m00                    (analog_pinaka_v18_vok)                 , 
            .v25_vok_m00                    (analog_pinaka_v25_vok)                 ,
            .pll_lock_m00                   (analog_pinaka_pll_lock)                , 
            .por_vok_m00                    (analog_pinaka_por_vok)                 ,                 


//                  FROM THE PINAKA TOP (MIX OF PRE AND POST BOOT REGISTERS)

            .CFGfromDig                     (pinaka_analog_384_reg)                 , 


//                          FROM THE PINAKA TOP (PREBOOT REGISTER)

            .BlockSel                       (pinaka_analog_preboot_reg1[15:11])     , 
            .ModeSel                        (pinaka_analog_preboot_reg1[1:0])       , 


//                      FROM THE PINAKA TOP (POST BOOT REGISTERS)

            .cdac_vin_mxx                   (pinaka_analog_postboot_reg3)           , 
            .csdac_vin_mxx                  (pinaka_analog_postboot_reg4)           ,

            .bg_rstb_mxx                    (pinaka_analog_postboot_reg2[0])        , 
            .cdac_rstb_mxx                  (pinaka_analog_postboot_reg2[1])        , 
            .cifb_rstb_mxx                  (pinaka_analog_postboot_reg2[2])        , 
            .ciff_rstb_mxx                  (pinaka_analog_postboot_reg2[3])        , 
            .csdac_rstb_mxx                 (pinaka_analog_postboot_reg2[4])        , 
            .ldo12a_rstb_mxx                (pinaka_analog_postboot_reg2[5])        , 
            .ldo12b_rstb_mxx                (pinaka_analog_postboot_reg2[6])        , 
            .ldo18a_rstb_mxx                (pinaka_analog_postboot_reg2[7])        , 
            .ldo18b_rstb_mxx                (pinaka_analog_postboot_reg2[8])        , 
            .ldo25a_rstb_mxx                (pinaka_analog_postboot_reg2[9])        , 
            .ldo25b_rstb_mxx                (pinaka_analog_postboot_reg2[10])       , 
            .osc_rstb_mxx                   (pinaka_analog_postboot_reg2[11])       , 
            .pll_rstb_mxx                   (pinaka_analog_postboot_reg2[12])       , 
            .por_rstb_mxx                   (pinaka_analog_postboot_reg2[13])       , 
            .sar_rstb_mxx                   (pinaka_analog_postboot_reg2[14])       , 
            .tdc_rstb_mxx                   (pinaka_analog_postboot_reg2[15])       , 
            .vmon_rstb_mxx                  (pinaka_analog_postboot_reg2[16])       ,


//                              FROM THE IO PAD TOP

            .dftpina                        (ANA0)                                  , 
            .dftpinb                        (ANA1)                                  , 
            .dftpinc                        (ANA2)                                  , 
            .dftpind                        (ANA3)                                  , 
            .dftpine                        (ANA4)                                  , 
            .dftpinf                        (ANA5)                                  , 
            .dftping                        (ANA6)                                  , 
            .dftpinh                        (ANA7)                                  , 
            .dftpini                        (ANA8)                                  , 
            .dftpinj                        (ANA9)                                  ,
            .dftpink                        (LDO_1_2_ACAP)                          , 
            .dftpinl                        (LDO_1_2_DCAP)                          , 
            .dftpinm                        (LDO_1_8_ACAP)                          , 
            .dftpinn                        (LDO_1_8_DCAP)                          , 
            .dftpino                        (LDO_2_5_ACAP)                          , 
            .dftpinp                        (LDO_2_5_DCAP)                          , 
            .dftpinq                        (DAC_OUT)                               , 
            .dftpinr                        (VDD_1_2)                               , 
            .dftpins                        (VDD_1_8)                               , 
            .dftpint                        (VDD_2_5)                               ,
            .vdda_xx                        (VDD)                                   ,
            .vssa_xx                        (VSS)                                   ,
            .ref_clk_mxx                    (xtal_clk)                              ,
            .ana_vin_m00                    (ADC_IN)                                ,


//                      FOR THE POWERING DIGIAL FROM LDO_1_2 (NEED TO DISCUSS AND CONFORM)

            .vddd_12_m00                    ()              , 
            .vssa_xx_ext                    ()              


                                            )                                       ;





//-------------------------------------PINAKA TOP MODULE INSTANCE--------------------------------




pinaka      pinaka_top_instance             (


//                         EXTERNAL DEBUG SIGNALS FROM THE IO PAD

            .TCK                             (iopad_pinaka_tck)                     ,
            .TRSTN                           (iopad_pinaka_trstn)                   ,
            .TMS                             (iopad_pinaka_tms)                     ,
            .TDI                             (iopad_pinaka_tdi)                     ,


//                         EXTERNAL DEBUG SIGNALS TO THE IO PAD

            .TDO                             (pinaka_iopad_tdo)                     ,
       

//                              CLOCK FROM THE ANALOG MODULE

            .rc_clk                          (analog_pinaka_rc_osc_clk)             ,
            .pll_clk                         (analog_pinaka_pll_clk)                ,


//                              XTAL CLOCK FROM IO PAD

            .xtal_clk                        (xtal_clk)                             ,


//                              HARD RESET FROM THE IO PAD

            .hard_reset                      (iopad_pinaka_hard_reset)              ,


//                          POWER ON RESET FROM THE ANALOG MODULE

            .power_on_rst                    (analog_pinaka_por_vok)                ,
            .pll_lock_done                   (analog_pinaka_pll_lock)               ,


//                      ANALOG STATUS SIGNAL FROM ANALOG MODULE

            .analog_2_digital_dbg_1          (analog_pinaka_v12_vok)                ,
            .analog_2_digital_dbg_2          (analog_pinaka_v18_vok)                ,
            .analog_2_digital_dbg_3          (analog_pinaka_v25_vok)                ,
            .analog_2_digital_dbg_4          (analog_pinaka_rc_osc_clk_ok)          ,
            .analog_2_digital_dbg_5          (analog_pinaka_por_vok)                ,
            .analog_2_digital_dbg_6          (analog_pinaka_pll_lock)               ,


//                          FROM THE ANALOG TOP PINAKA TOP (REGISTER)

            .cifb_vout_m00_reg_in           (analog_pinaka_cifb_vout_m00)           ,
            .ciff_vout_m00_reg_in           (analog_pinaka_ciff_vout_m00)           ,
            .sar_vout_m00_reg_in            (analog_pinaka_sar_vout_m00)            ,
            .tdc_vout_m00_reg_in            (analog_pinaka_tdc_vout)                ,


//                          POSTBOOT ANALOG REGISTER OUT

            .analog_postboot_reg0            (pinaka_analog_postboot_reg0)          ,
            .analog_postboot_reg1            (pinaka_analog_postboot_reg1)          ,
            .analog_postboot_reg2            (pinaka_analog_postboot_reg2)          ,
            .analog_postboot_reg3            (pinaka_analog_postboot_reg3)          ,
            .analog_postboot_reg4            (pinaka_analog_postboot_reg4)          ,
            .analog_postboot_reserved_reg    (pinaka_analog_postboot_reserved_reg)  ,


//                          POSTBOOT CALIBRATE REGISTER TO THE ANALOG TOP

            .analog_calibrate_reg0            (pinaka_analog_calibrate_reg0)         ,
            .analog_calibrate_reg1            (pinaka_analog_calibrate_reg1)         ,
            .analog_calibrate_reg2            (pinaka_analog_calibrate_reg2)         ,
            .analog_calibrate_reg3            (pinaka_analog_calibrate_reg3)         ,
            .analog_calibrate_reg4            (pinaka_analog_calibrate_reg4)         ,
            .analog_calibrate_reg5            (pinaka_analog_calibrate_reg5)         ,


//                          PREBOOT ANALOG REGISTER OUT

            .analog_preboot_reg0             (pinaka_analog_preboot_reg0)           ,
            .analog_preboot_reg1             (pinaka_analog_preboot_reg1)           ,


//                              FROM THE IOPAD TOP (GPIO SIGNAL) 

            .gpio_pad_in                    (iopad_pinaka_gpio_pad_in)             ,


//                              TO THE IOPAD TOP (GPIO SIGNALS)

            .gpio_pad_out                   (pinaka_iopad_gpio_pad_out)            ,
            .gpio_pad_oe                    (pinaka_iopad_gpio_pad_oe)             ,
            .gpio_pull_en_out               (pinaka_iopad_pull_en)                     


                                            )                                       ;   





//-------------------------------------IO PAD TOP MODULEINSTANTIATION-------------------------------------




top_io_pad      io_pad_top_instance         (


//                          POWER SUPPLY AND GROUND PINS

                .VDDPST                     (VDD)                                   ,
                .VSSPST                     (VSS)                                   ,
                .VDD_1_2                    (VDD_1_2)                               ,
                .VDD_1_8                    (VDD_1_8)                               ,
                .VDD_2_5                    (VDD_2_5)                               ,


//                          HARD RESET FROM THE CHIP TOP

                .RESET_N                    (RESET_N)                               ,


//                          CRYTAL OSCILATOR CLK SIGNAL FROM CHIP TOP

                .XTAL_IN                    (XTAL_IN)                               ,


//                          CRYTAL OSCILATOR CLK SIGNAL TO CHIP TOP

                .XTAL_OUT                   (XTAL_OUT)                              ,


//                              ANALOG IO PADS

                .ANA0                       (ANA0)                                  ,
                .ANA1                       (ANA1)                                  ,
                .ANA2                       (ANA2)                                  ,
                .ANA3                       (ANA3)                                  ,
                .ANA4                       (ANA4)                                  ,
                .ANA5                       (ANA5)                                  ,
                .ANA6                       (ANA6)                                  ,
                .ANA7                       (ANA7)                                  ,
                .ANA8                       (ANA8)                                  ,
                .ANA9                       (ANA9)                                  ,
                .ADC_IN                     (ADC_IN)                                ,
                .DAC_OUT                    (DAC_OUT)                               ,
                .LDO_1_2_ACAP               (LDO_1_2_ACAP)                          ,
                .LDO_1_2_DCAP               (LDO_1_2_DCAP)                          ,
                .LDO_1_8_ACAP               (LDO_1_8_ACAP)                          ,
                .LDO_1_8_DCAP               (LDO_1_8_DCAP)                          ,
                .LDO_2_5_ACAP               (LDO_2_5_ACAP)                          ,
                .LDO_2_5_DCAP               (LDO_2_5_DCAP)                          ,

//                  DEBUG MODULE(JTAG) SIGNALS FROM CHIP TOP

                .TCK                        (TCK)                                   ,
                .TMS                        (TMS)                                   ,
                .TDI                        (TDI)                                   ,
                .TRST                       (TRST)                                  ,


//                  DEBUG MODULE(JTAG) SIGNAL TO THE CHIP TOP

                .TDO                        (TDO)                                   ,


//                              GPIO PINS 

                .GPIO0                      (GPIO0)                                 ,
                .GPIO1                      (GPIO1)                                 ,
                .GPIO2                      (GPIO2)                                 ,
                .GPIO3                      (GPIO3)                                 ,
                .GPIO4                      (GPIO4)                                 ,
                .GPIO5                      (GPIO5)                                 ,
                .GPIO6                      (GPIO6)                                 ,
                .GPIO7                      (GPIO7)                                 ,
                .GPIO8                      (GPIO8)                                 ,
                .GPIO9                      (GPIO9)                                 ,
                .GPIO10                     (GPIO10)                                ,
                .GPIO11                     (GPIO11)                                ,
                .GPIO12                     (GPIO12)                                ,
                .GPIO13                     (GPIO13)                                ,
                .GPIO14                     (GPIO14)                                ,
                .GPIO15                     (GPIO15)                                ,
                .GPIO16                     (GPIO16)                                ,
                .GPIO17                     (GPIO17)                                ,
                .GPIO18                     (GPIO18)                                ,
                .GPIO19                     (GPIO19)                                ,
                .GPIO20                     (GPIO20)                                ,
                .GPIO21                     (GPIO21)                                ,
                .GPIO22                     (GPIO22)                                ,


//                      CRYSTAL CLK TO ANALOG AND PINAKA TOP

                .xtal_in_btc                (xtal_clk)                              ,


//                      HARD RESET SIGNAL TO PINAKA TOP

                .reset_n_btc                (iopad_pinaka_hard_reset)               ,


//                          GPIO OE AND OUT FROM THE PINAKA TOP

                .gpio_pad_dir               (pinaka_iopad_gpio_pad_oe)              ,
                .gpio_pad_out               (pinaka_iopad_gpio_pad_out)             ,
                .gpio_pad_pull_en           (pinaka_iopad_pull_en)                  ,


//                              GPIO IN TO THE PINAKA TOP

                .gpio_pad_in                (iopad_pinaka_gpio_pad_in)              ,


//                          DEBUG MODULE(JTAG) SIGNALS TO PINAKA TOP

                .tck_jtag_btc               (iopad_pinaka_tck)                      ,
                .tms_jtag_btc               (iopad_pinaka_tms)                      ,
                .tdi_jtag_btc               (iopad_pinaka_tdi)                      ,
                .trst_jtag_btc              (iopad_pinaka_trstn)                    ,


//                          DEBUG MODULE(JTAG) SIGNAL FROM THE PINAKA TOP

                .tdo_jtag_bto               (pinaka_iopad_tdo)      
        
                                            )                                       ;





endmodule
