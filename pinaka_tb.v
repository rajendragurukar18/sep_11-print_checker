module pinaka_tb;


//		DEBUG MODULE CLOCKS AND RESET SIGNAL 

reg           TCK                     ;
reg           TRSTN                   ;

//      reg AND wire OF DEBUG MODULE

reg           TMS                     ;
reg           TDI                     ;
wire          TDO                     ;

//          EXTERNAL CLOCK

reg           rc_clk                  ;
reg           xtal_clk              ;
reg           pll_clk                 ;

//          POWER ON RESET

reg           power_on_rst            ;                                                                         
reg           pll_lock_done           ;
reg           hard_reset                ;

/*
//                  CONFIG REGISTER OUT TO THE ANALOG TOP

wire      [2:0]       ppl_config_reg_out              ;                          
wire      [31:0]      ds_adc_config0_reg_out          ;                     
wire      [15:0]      ds_adc_config1_reg_out          ;

//                  TRIM REGISTER OUT TO THE ANALOG TOP

wire      [17:0]      ds_adc_trim_reg_out             ;                         
wire      [2:0]       sar_adc_trim_reg_out            ;                               
wire      [11:0]      vtc_tdc_trim_reg_out            ;                        
wire      [2:0]       cs_dac_trim_reg_out             ;                         
wire      [2:0]       c_dac_trim_reg_out              ;                         
wire      [2:0]       opamp3v3_trim_reg_out           ;                        
wire      [2:0]       opampint_trim_reg_out           ;                          
wire      [2:0]       opamp2v5_trim_reg_out         ;
*/

//                      FROM THE GPIO PAD

reg       [22:0]      gpio_pad_in                     ;

//                      TO THE GPIO PAD

wire      [22:0]      gpio_pad_out                    ;
wire      [22:0]      gpio_pad_oe                     ;

//                  TO THE ANALOG BLOCKS

wire      [31:0]      gpio_pullup_out                 ;                   
wire      [31:0]      gpio_pulldown_out               ;                        
wire      [31:0]      gpio_opendrain_out              ;                          
wire      [31:0]      gpio_scmitt_out                 ;                          
wire      [31:0]      gpio_drv0_out                   ;                            
wire      [31:0]      gpio_drv1_out                   ;                              
wire      [31:0]      gpio_int_en_out                 ;                             
wire      [31:0]      gpio_int_status_out             ;                         
wire      [31:0]      gpio_rise_en_out                ;                         
wire      [31:0]      gpio_fall_en_out                ;                          
wire      [31:0]      gpio_high_en_out                ;                           
wire      [31:0]      gpio_low_en_out                 ;                            
wire      [31:0]      gpio_lock_out                   ;                             
wire      [31:0]      gpio_sel_out                      ;

wire                   analog_2_digital_dbg_1          ;
wire                   analog_2_digital_dbg_2          ;
wire                   analog_2_digital_dbg_3          ;
wire                   analog_2_digital_dbg_4          ;
wire                   analog_2_digital_dbg_5          ;
wire                   analog_2_digital_dbg_6          ;
/*
//          OTHER REGISTERS TO ANALOG TOP 

wire                  bg_rstb_mxx_reg_out             ;
wire                  cdac_rstb_mxx_reg_out           ;
wire      [11:0]      cdac_vin_mxx_reg_out            ;
wire                  cifb_rstb_mxx_reg_out           ;
wire                  ciff_rstb_mxx_reg_out           ;
wire                  csdac_rstb_mxx_reg_out          ;
wire      [11:0]      csdac_vin_mxx_reg_out           ;
wire                  ldo_12a_rstb_mxx_reg_out        ;
wire                  ldo_12b_rstb_mxx_reg_out        ;
wire                  ldo_18a_rstb_mxx_reg_out        ;
wire                  ldo_18b_rstb_mxx_reg_out        ;
wire                  ldo_25a_rstb_mxx_reg_out        ;
wire                  ldo_25b_rstb_mxx_reg_out        ;
wire                  osc_rstb_mxx_reg_out            ;
wire                  pll_rstb_mxx_reg_out            ;
wire                  por_rstb_mxx_reg_out            ;
wire                  sar_rstb_mxx_reg_out            ;
wire                  tdc_rstb_mxx_reg_out            ;
wire                  vmon_rst_mxx_reg_out            ;

//          PRE BOOT ANALOG REGISTER TO ANALO TOP

//wire      [4:0]       block_sel_reg_out               ;
//wire      [1:0]       mode_sel_reg_out                ;

*/
//          FROM THE ANALOG TOP PINAKA TOP REGISTER 

reg       [23:0]      cifb_vout_m00_reg_in            ;
reg       [23:0]      ciff_vout_m00_reg_in            ;
reg       [11:0]      sar_vout_m00_reg_in             ;
reg       [11:0]      tdc_vout_m00_reg_in             ;

//              POSTBOOT ANALOG REGISTER OUT

wire      [31:0]      analog_postboot_reg0            ;
wire      [31:0]      analog_postboot_reg1            ;
wire      [31:0]      analog_postboot_reg2            ;
wire      [31:0]      analog_postboot_reg3            ;
wire      [11:0]      analog_postboot_reg4            ;


//              PREBOOT ANALOG REGISTER OUT

wire      [31:0]      analog_preboot_reg0             ;
wire      [13:0]      analog_preboot_reg1             ;





pinaka  top_instance (

.TCK(TCK) ,
.TRSTN(TRSTN) ,
.TMS(TMS) ,
.TDO(TDO) ,
.TDI(TDI) ,

.rc_clk(rc_clk) ,
.xtal_clk(xtal_clk) ,
.pll_clk(pll_clk) ,

.power_on_rst(power_on_rst) ,
.pll_lock_done(pll_lock_done) ,
.hard_reset (hard_reset)    ,
/*
.ppl_config_reg_out( ppl_config_reg_out) ,                                    
.ds_adc_config0_reg_out ( ds_adc_config0_reg_out) ,                           
.ds_adc_config1_reg_out  (ds_adc_config1_reg_out) ,        
.ds_adc_trim_reg_out  ( ds_adc_trim_reg_out ) ,                                    
.sar_adc_trim_reg_out  ( sar_adc_trim_reg_out ) ,                                         
.vtc_tdc_trim_reg_out  (vtc_tdc_trim_reg_out) ,                                  
.cs_dac_trim_reg_out  ( cs_dac_trim_reg_out ) ,                                    
.c_dac_trim_reg_out  (  c_dac_trim_reg_out ) ,                                   
.opamp3v3_trim_reg_out ( opamp3v3_trim_reg_out ) ,                                  
.opampint_trim_reg_out ( opampint_trim_reg_out ) ,                                    
.opamp2v5_trim_reg_out (opamp2v5_trim_reg_out ) ,
*/
.gpio_pad_in (gpio_pad_in) ,
.gpio_pad_out ( gpio_pad_out ) ,                  
.gpio_pad_oe  ( gpio_pad_oe ) ,

.gpio_pullup_out ( gpio_pullup_out ) ,                                  
.gpio_pulldown_out ( gpio_pulldown_out ) ,                                     
.gpio_opendrain_out ( gpio_opendrain_out ) ,                                      
.gpio_scmitt_out(gpio_scmitt_out) ,                                       
.gpio_drv0_out(gpio_drv0_out) ,                                            
.gpio_drv1_out( gpio_drv1_out) ,                                               
.gpio_int_en_out ( gpio_int_en_out ) ,                                             
.gpio_int_status_out ( gpio_int_status_out ) ,                                    
.gpio_rise_en_out ( gpio_rise_en_out ) ,                                       
.gpio_fall_en_out ( gpio_fall_en_out ) ,                                        
.gpio_high_en_out ( gpio_high_en_out ) ,                                         
.gpio_low_en_out  ( gpio_low_en_out ) ,                                          
.gpio_lock_out  ( gpio_lock_out ) ,                                             
.gpio_sel_out ( gpio_sel_out) ,
.analog_2_digital_dbg_1 (analog_2_digital_dbg_1) ,
.analog_2_digital_dbg_2 (analog_2_digital_dbg_2) ,
.analog_2_digital_dbg_3 (analog_2_digital_dbg_3) ,
.analog_2_digital_dbg_4 (analog_2_digital_dbg_4) ,
.analog_2_digital_dbg_5 (analog_2_digital_dbg_5) ,
.analog_2_digital_dbg_6 (analog_2_digital_dbg_6) ,

/*
.bg_rstb_mxx_reg_out           (bg_rstb_mxx_reg_out)       ,             
.cdac_rstb_mxx_reg_out         (cdac_rstb_mxx_reg_out)       ,             
.cdac_vin_mxx_reg_out          (cdac_vin_mxx_reg_out)       ,             
.cifb_rstb_mxx_reg_out         (cifb_rstb_mxx_reg_out)       ,             
.ciff_rstb_mxx_reg_out         (ciff_rstb_mxx_reg_out)       ,             
.csdac_rstb_mxx_reg_out        (csdac_rstb_mxx_reg_out)       ,             
.csdac_vin_mxx_reg_out         (csdac_vin_mxx_reg_out)       ,             
.ldo_12a_rstb_mxx_reg_out      (ldo_12a_rstb_mxx_reg_out)       ,             
.ldo_12b_rstb_mxx_reg_out      (ldo_12b_rstb_mxx_reg_out)       ,             
.ldo_18a_rstb_mxx_reg_out      (ldo_18a_rstb_mxx_reg_out)       ,             
.ldo_18b_rstb_mxx_reg_out      (ldo_18b_rstb_mxx_reg_out)       ,             
.ldo_25a_rstb_mxx_reg_out      (ldo_25a_rstb_mxx_reg_out)       ,             
.ldo_25b_rstb_mxx_reg_out      (ldo_25b_rstb_mxx_reg_out)       ,             
.osc_rstb_mxx_reg_out          (osc_rstb_mxx_reg_out)       ,             
.pll_rstb_mxx_reg_out          (pll_rstb_mxx_reg_out)       ,             
.por_rstb_mxx_reg_out          (por_rstb_mxx_reg_out)       ,             
.sar_rstb_mxx_reg_out          (sar_rstb_mxx_reg_out)       ,             
.tdc_rstb_mxx_reg_out          (tdc_rstb_mxx_reg_out)       ,             
.vmon_rst_mxx_reg_out          (vmon_rst_mxx_reg_out)       ,
*/
.analog_postboot_reg0           (analog_postboot_reg0)      ,
.analog_postboot_reg1           (analog_postboot_reg1)      ,
.analog_postboot_reg2           (analog_postboot_reg2)      ,
.analog_postboot_reg3           (analog_postboot_reg3)      ,
.analog_postboot_reg4           (analog_postboot_reg4)      ,


.analog_preboot_reg0           (analog_preboot_reg0)      ,
.analog_preboot_reg1           (analog_preboot_reg1)      ,

.cifb_vout_m00_reg_in            (cifb_vout_m00_reg_in)      ,
.ciff_vout_m00_reg_in            (ciff_vout_m00_reg_in)      ,
.sar_vout_m00_reg_in             (sar_vout_m00_reg_in)      ,
.tdc_vout_m00_reg_in             (tdc_vout_m00_reg_in)      

) ;




initial begin
$shm_open("pinaka_wave.shm") ;
$shm_probe("ACTMF") ;
end

initial begin
    power_on_rst = 0 ; pll_lock_done = 0 ; hard_reset = 0 ;#100
    power_on_rst = 1 ; pll_lock_done = 1 ;  hard_reset = 1 ;
     
end

initial begin
    gpio_pad_in = 23'b000_0000_0000_0000_0000_0000 ; #100000
    gpio_pad_in = 23'b000_0000_0000_0000_0000_0010 ;  
end


initial begin
       TCK = 0 ;
        forever  #100 TCK = ~ TCK ;
   end

   initial begin
       rc_clk = 0 ;
        forever #50 rc_clk = ~ rc_clk ;
   end

   initial begin
       pll_clk = 0 ;
        forever #1 pll_clk = ~ pll_clk ;
   end

   initial begin
       xtal_clk = 0 ;
        forever #20 xtal_clk = ~ xtal_clk ;
   end

   //added by jeevan for core verification//
   
reg [1023:0] dmem_file;
initial begin
   if ($value$plusargs("DMEM_FILE=%s", dmem_file)) begin
          $readmemh(dmem_file, top_instance.axi_slave_wrapper_data_mem_instance.u_data_memory.mem  );
   end
end


   initial begin
       #1000000 $finish;
   end


endmodule
