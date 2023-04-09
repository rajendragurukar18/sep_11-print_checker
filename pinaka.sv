
import axi_typedef_pkg::*;


module	 	    pinaka 		            (


// DFT TEST MODE SIGNAL

input                   Test_mode                       ,
input                   scan_in_1                       ,
input                   scan_in_2                       ,
input                   scan_in_3                       ,
input                   scan_in_4                       ,
input                   scan_in_5                       ,
input                   scan_in_6                       ,

output                  scan_out_1                      ,
output                  scan_out_2                      ,
output                  scan_out_3                      ,
output                  scan_out_4                      ,
output                  scan_out_5                      ,
output                  scan_out_6                      ,

input                   scan_enable                     ,

//		DEBUG MODULE CLOCKS AND RESET SIGNAL 

input                   TCK                             ,
input                   TRSTN                           ,


//      INPUT AND OUTPUT OF DEBUG MODULE

input                   TMS                             ,
input                   TDI                             ,
output                  TDO                             ,


//                  EXTERNAL CLOCK

input                   rc_clk                          ,
input                   xtal_clk                        ,
input                   pll_clk                         ,


//                  POWER ON RESET

input                   power_on_rst                    ,


//                  HARD RESET TO CLK RST BYPASS MODULE

input                   hard_reset                      ,


//                  PPL LOCK DONE SIGNAL

input                   pll_lock_done                   ,


//              STATUS SIGNAL FROM ANALOG TOP TO GPIO PINMUX

input                   analog_2_digital_dbg_1          ,
input                   analog_2_digital_dbg_2          ,
input                   analog_2_digital_dbg_3          ,
input                   analog_2_digital_dbg_4          ,
input                   analog_2_digital_dbg_5          ,
input                   analog_2_digital_dbg_6          ,


//              POSTBOOT ANALOG REGISTER OUT

output      [50:0]      analog_postboot_reg0            ,
output      [50:0]      analog_postboot_reg1            ,
output      [16:0]      analog_postboot_reg2            ,
output      [11:0]      analog_postboot_reg3            ,
output      [11:0]      analog_postboot_reg4            ,
output      [50:0]      analog_postboot_reserved_reg    ,


//              ANALOG CALIBRATION REGISTER OUT

output      [31:0]      analog_calibrate_reg0           ,
output      [31:0]      analog_calibrate_reg1           ,
output      [31:0]      analog_calibrate_reg2           ,
output      [31:0]      analog_calibrate_reg3           ,
output      [31:0]      analog_calibrate_reg4           ,
output      [31:0]      analog_calibrate_reg5           ,


//              PREBOOT ANALOG REGISTER OUT

output      [29:0]      analog_preboot_reg0             ,
output      [15:0]      analog_preboot_reg1             ,


//          FROM THE ANALOG TOP PINAKA TOP REGISTER 

input       [23:0]      cifb_vout_m00_reg_in            ,
input       [23:0]      ciff_vout_m00_reg_in            ,
input       [11:0]      sar_vout_m00_reg_in             ,
input       [11:0]      tdc_vout_m00_reg_in             ,


//                      FROM THE GPIO PAD

input       [22:0]      gpio_pad_in                     ,


//                      TO THE GPIO PAD

output      [22:0]      gpio_pad_out                    ,
output      [22:0]      gpio_pad_oe                     ,
output      [22:0]      gpio_pull_en_out           



				) 	                                    ;



//---------------------------------------------------PARAMETERS----------------------------------------------




// 			                        MMU PARAMETER

parameter 		MMU_VPN_WIDTH 			    = 	20 						        ;
parameter 		MMU_PPN_WIDTH 			    = 	20 						        ;
parameter 		MMU_ACCESS_WIDTH 	    	= 	3 						        ;
parameter 		MMU_ASID_WIDTH 		    	= 	9 						        ;
parameter 		MMU_L1_ENTRIES 		    	= 	16 						        ;
parameter 		MMU_L2_ENTRIES 		    	= 	32 						        ;


//			                        CSR TOP MODULE PARAETER

parameter 		CSR_ADDR_WIDTH    		    = 	12 						        ;
parameter 		CSR_DATA_WIDTH        		= 	32 						        ;
parameter 		CSR_INSTRUCTION_WIDTH 		= 	32 						        ;
parameter 		CSR_PC_WIDTH          		= 	32 						        ;


//			                        AXI PARAMETER

parameter 		AXI_DATA_WIDTH		    	= 	32						        ;
parameter 		AXI_ADDR_WIDTH			    =	32						        ;
parameter		STROBE_WIDTH			    =	4						        ;


//			                        AXI-APB BRIDGE PARAMETER

parameter 		BRIDGE_FIFO_DEPTH  		    = 	4 						        ;
parameter 		BRIDGE_FIFO_WIDTH  		    = 	AXI_ADDR_WIDTH + AXI_DATA_WIDTH ;


//			                        APB TIME OUT IN BRIDGE


parameter 		APB_TIMEOUT_COUNT_WIDTH		= 	6						        ;
parameter 		APB_TIMEOUT_VALUE		    =   (APB_TIMEOUT_COUNT_WIDTH)'(50)  ;


// 			                        I2C PARAMETER

parameter 		I2C_ADDR_WIDTH 			    = 	8 						        ;
parameter 		I2C_DATA_WIDTH 			    = 	32 						        ;


//			                        SPI PARAMETER

parameter 		SPI_ADDR_WIDTH 		    	= 	8 						        ;
parameter 		SPI_DATA_WIDTH 		    	= 	32 						        ;


//                                  CLK AND RST CTRL PARAMETER

parameter       CLK_RST_CTRL_HARD_RST_COUNT =   5                               ;
parameter       CLK_RST_CTRL_RATIO          =   4                               ;


//			                        DATA MEMORY 

parameter 		DATA_MEMORY_ADDR_WIDTH 		= 	16 						        ;


//			                        INSTRUCTION MEMORY

parameter 		INST_MEMORY_ADDR_WIDTH 		= 	16 						        ;


//			                    MEMORY MAPPED ADDRESS RANGES
			                        
parameter       TOP_REG_MIN_ADDRESS         =   32'h0008_0000                   ;
parameter       TOP_REG_MAX_ADDRESS         =   32'h0008_0FFF                   ;
parameter       CLK_RST_CTRL_MIN_ADDRESS    =   32'h0008_1000                   ;
parameter       CLK_RST_CTRL_MAX_ADDRESS    =   32'h0008_1FFF                   ;
parameter 		UART_MIN_ADDRESS 	    	= 	32'h0008_3000 					;
parameter 		UART_MAX_ADDRESS 		    = 	32'h0008_3FFF 					;
parameter 		I2C_MIN_ADDRESS 	    	= 	32'h0008_4000 					;
parameter 		I2C_MAX_ADDRESS 	    	= 	32'h0008_4FFF 					;
parameter 		SPI_MIN_ADDRESS 	    	= 	32'h0008_5000 					;
parameter 		SPI_MAX_ADDRESS 	    	= 	32'h0008_5FFF 					;
parameter       GPIO_REG_MIN_ADDRESS        =   32'h0008_6000                   ;
parameter       GPIO_REG_MAX_ADDRESS        =   32'h0008_6FFF                   ;
parameter 		WATCHDOG_MIN_ADDRESS		= 	32'h0008_7000					;
parameter 		WATCHDOG_MAX_ADDRESS		= 	32'h0008_7FFF					;
parameter       MMR_REGISTER_MIN_ADDRESS    =   32'h0008_9000                   ;
parameter       MMR_REGISTER_MAX_ADDRESS    =   32'h0008_9FFF                   ;
parameter       ANALOG_REGISTER_MIN_ADDRESS =   32'h0008_2000                   ;
parameter       ANALOG_REGISTER_MAX_ADDRESS =   32'h0008_2FFF                   ;
parameter       IP_TRACE_MIN_ADDRESS        =   32'h0008_8000                   ;
parameter       IP_TRACE_MAX_ADDRESS        =   32'h0008_8FFF                   ;
parameter       CORE_TRACE_MIN_ADDRESS      =   32'h0008_A000                   ;
parameter       CORE_TRACE_MAX_ADDRESS      =   32'h0008_AFFF                   ;


parameter 		PTE_MIN_ADDRESS			    = 	32'h0002_4000					;
parameter 		PTE_MAX_ADDRESS			    = 	32'h0002_4FFF					;


parameter       PREBOOT_REG_START_ADDRESS   =   32'h0002_5000                   ;
parameter       PREBOOT_REG_END_ADDRESS     =   32'h0002_5FFF                   ;


parameter 		DATA_MEMORY_MIN_ADDRESS		= 	32'h0001_0000					;
parameter 		DATA_MEMORY_MAX_ADDRESS		= 	DATA_MEMORY_MIN_ADDRESS + (2 ** DATA_MEMORY_ADDR_WIDTH) - 1			;


parameter 		INST_MEMORY_MIN_ADDRESS		= 	32'h0000_0000					;
parameter 		INST_MEMORY_MAX_ADDRESS		= 	INST_MEMORY_MIN_ADDRESS + (2 ** INST_MEMORY_ADDR_WIDTH) - 1			;




//------------------------------------------------------------------------------------------------------------------



//----------------------------------------------INTERNAL WIRES--------------------------------




//			            VIRTUAL ADDRESSES OF INSTRUCTION AND DATA MEMORY BY CORE TO MMU

wire 	[31:0] 				            core_mmu_inst_mem_virtual_address	;
wire 	[31:0] 				            core_mmu_data_mem_virtual_address 	;

//--------------------------------------------------------------


//				                DATA MEMORY READ AND WRITE BY CORE

wire 					                core_mmu_axi_mem_read_en 			;
wire 					                core_mmu_axi_mem_write_en 			;
wire                                    core_mmu_inst_req                   ;
wire                                    mmu_tlb_flush                       ;

//--------------------------------------------------------


// 				            PHYSICAL ADDRESSES HIT SIGNAL BY MMU

wire 					                mmu_data_memory_hit 			    ;
wire 				                	mmu_instruction_hit 			    ;

//--------------------------------------------------------


//		                20 BIT PHYSICAL PAGE NUMBER OF BOTH INSTRUCTION MEMORY AND DATA MEMORY BY MMU 

wire 	[MMU_PPN_WIDTH -1 :0] 	    	mmu_ppn_inst_mem_address 			;
wire 	[MMU_PPN_WIDTH -1 :0] 	    	mmu_ppn_data_mem_address 			;

//--------------------------------------------------------


//		                FINAL PHYSICAL ADDRESS OF BOTH INSTRUCTION MEMORY AND DATA MEMORY

wire 	[31:0] 				            mmu_axi_physical_address_inst_mem 	;
wire 	[31:0] 				            mmu_axi_physical_address_data_mem 	;

//--------------------------------------------------------


//--------------------------AXI MASTER AND BRIDGE INTERFACE SIGNALS---------------------


// 				            WRITE ADDRESS CHANNEL 

wire 					                axi_bridge_awvalid 				    ;
wire 	[AXI_ADDR_WIDTH -1:0] 		    axi_bridge_awaddr 				    ;
wire 					                bridge_axi_awready 				    ;


//			            	WRITE DATA CHANNEL 

wire 					                axi_bridge_wvalid 				    ;
wire 	[AXI_DATA_WIDTH-1:0] 		    axi_bridge_wdata 				    ;
wire 	[STROBE_WIDTH-1:0] 		        axi_bridge_wstrb 				    ;
wire 					                bridge_axi_wready 				    ;


//				            WRITE RESPONSE CHANNEL

wire 					                axi_bridge_bready 				    ;
wire 	[1:0]				            bridge_axi_bresp 				    ;
wire 					                bridge_axi_bvalid 				    ;


//				            READ ADDRESS CHANNEL

wire 					                axi_bridge_arvalid 				    ;
wire 	[AXI_ADDR_WIDTH-1:0] 		    axi_bridge_araddr 				    ;
wire 					                bridge_axi_arready 				    ;


//				            READ DATA CHANNEL

wire 					                axi_bridge_rready 				    ;
wire 					                bridge_axi_rvalid 				    ;
wire 	[AXI_DATA_WIDTH-1:0] 		    bridge_axi_rdata 				    ;
wire 	[1:0]				            bridge_axi_rresp 				    ;
wire                                    bridge_axi_rlast                    ;


//--------------------------AXI AND DATA MEMORY INTERFACE -------------------------------


// 				            WRITE ADDRESS CHANNEL 

wire 					                axi_data_mem_awvalid			    ;
wire 	[AXI_ADDR_WIDTH -1:0] 		    axi_data_mem_awaddr 			    ;
wire 					                data_mem_axi_awready			    ;
wire	[2:0]				            common_awsize					    ;

//				            WRITE DATA CHANNEL 

wire 					                axi_data_mem_wvalid 			    ;
wire 	[AXI_DATA_WIDTH-1:0] 		    axi_data_mem_wdata 			        ;
wire 	[STROBE_WIDTH-1:0] 		        axi_data_mem_wstrb 			        ;
wire 					                data_mem_axi_wready 			    ;

//				            WRITE RESPONSE CHANNEL

wire 					                axi_data_mem_bready 			    ;
wire 	[1:0]				            data_mem_axi_bresp 			        ;
wire 					                data_mem_axi_bvalid 			    ;

//				            READ ADDRESS CHANNEL

wire 					                axi_data_mem_arvalid			    ;
wire 	[AXI_ADDR_WIDTH-1:0] 		    axi_data_mem_araddr 			    ;
wire 					                data_mem_axi_arready 			    ;

//				            READ DATA CHANNEL

wire 					                axi_data_mem_rready 			    ;
wire 					                data_mem_axi_rvalid 			    ;
wire 	[AXI_DATA_WIDTH-1:0] 		    data_mem_axi_rdata			        ;
wire 	[1:0]				            data_mem_axi_rrsep			        ;


//--------------------------APB MASTER INTERFACE------------------


wire 					                bridge_peripheral_psel 				;
wire 	[AXI_ADDR_WIDTH-1:0] 		    bridge_peripheral_paddr 			;
wire 	[AXI_DATA_WIDTH-1:0] 		    bridge_peripheral_pwdata 			;
wire 					                bridge_peripheral_penable 			;
wire 					                bridge_peripheral_pwrite 			;
wire 					                peripheral_bridge_pready 			;
wire 	[AXI_DATA_WIDTH-1:0] 		    peripheral_bridge_prdata 			;
wire 					                peripheral_bridge_pslverr 			;

//----------------------------------------------------------------------------


//------------------APB BRIDGE TO PERIPHERALS INTERFACE SIGNALS------------------------


//			            APB BRIDGE TO UART INTERFACE SIGNALS

wire 					                uart_psel 				            ;
wire 	[31:0] 	                        uart_prdata 				        ;
wire 					                uart_pready 				        ;
wire 					                uart_pslverr 				        ;


//			            APB BRIDGE TO I2C INTERFACE SIGNALS

wire 					                i2c_psel 				            ;
wire 	[I2C_DATA_WIDTH - 1 :0] 	    i2c_prdata 				            ;
wire 					                i2c_pready 				            ;
wire 					                i2c_pslverr 				        ;


//		            	APB BRIDGE TO SPI INTERFACE SIGNALS

wire 					                spi_psel 				            ;
wire 	[SPI_DATA_WIDTH-1:0] 		    spi_prdata 				            ;
wire 					                spi_pready 				            ;
wire 				                	spi_pslverr 				        ;

//			            APB BRIDGE TO WATCHDOG TIMER INTERFACE SIGNALS

wire 					                watchdog_psel 				        ;
wire 	[31:0] 		                    watchdog_prdata 				    ;
wire 					                watchdog_pready 				    ;
wire 				                	watchdog_pslverr 				    ;

//			            APB BRIDGE TO WATCHDOG TIMER INTERFACE SIGNALS

wire 					                clk_rst_ctrl_psel 				    ;
wire 	[31:0] 		                    clk_rst_ctrl_prdata 				;
wire 					                clk_rst_ctrl_pready 				;
wire 				                	clk_rst_ctrl_pslverr 				;

//			            APB BRIDGE TO TOP REGISTER INTERFACE SIGNALS

wire 					                top_reg_psel 				        ;
wire 	[31:0] 		                    top_reg_prdata 				        ;
wire 					                top_reg_pready 				        ;
wire 				                	top_reg_pslverr 				    ;

//			            APB BRIDGE TO GPIO REGISTER INTERFACE SIGNALS

wire 					                gpio_reg_psel 				        ;
wire 	[31:0] 		                    gpio_reg_prdata 				    ;
wire 					                gpio_reg_pready 				    ;
wire 				                	gpio_reg_pslverr 				    ;

//                      APB SLAVE PSEL WRAPPER TO MMR REGISTER SIGNALS

wire 					                mmr_reg_psel 				        ;
wire 	[31:0] 		                    mmr_reg_prdata 				        ;
wire 					                mmr_reg_pready 				        ;
wire 				                	mmr_reg_pslverr 				    ;

//                      APB SLAVE PSEL WRAPPER TO MMR REGISTER SIGNALS

wire 					                analog_reg_psel 				    ;
wire 	[31:0] 		                    analog_reg_prdata 				    ;
wire 					                analog_reg_pready 				    ;
wire 				                	analog_reg_pslverr 				    ;

//                      APB SLAVE PSEL WRAPPER TO IP TRACE SIGNALS

wire 					                ip_trace_psel 				        ;
wire 	[31:0] 		                    ip_trace_prdata 				    ;
wire 					                ip_trace_pready 				    ;
wire 				                	ip_trace_pslverr 				    ;

//                      APB SLAVE PSEL WRAPPER TO CORE TRACE SIGNALS

wire 					                core_trace_psel 				    ;
wire 	[31:0] 		                    core_trace_prdata 				    ;
wire 					                core_trace_pready 				    ;
wire 				                	core_trace_pslverr 				    ;

//-------------------------------------------------------------------------------------------------


//-------------------------------CORE AND CSR INTERFACE--------------------

wire 	[CSR_DATA_WIDTH-1:0] 		    csr_core_read_data 			        ;
wire 					                core_csr_read_en 			        ;
wire 					                core_csr_write_en 			        ;
wire 	[11:0]  		                core_csr_addr			            ;
wire 	[CSR_DATA_WIDTH-1:0] 		    core_csr_write_data 		        ;
wire 					                core_csr_set_bit 			        ;
wire 					                core_csr_clear_bit 		            ;
wire 					                core_csr_e_break_valid 		        ;
wire 					                core_csr_mret_valid 			    ;
wire    [31:0]                          csr_core_mepc                       ;                                 
wire    [31:0]                          csr_core_dpc                        ;
wire    [31:0]                          core_csr_mepc_in                    ;                               
wire    [7:0]                           csr_core_mcause                     ;
wire    [31:0]                          csr_core_mtvec                      ;
wire                                    core_csr_mcause_write_en            ;
wire                                    core_csr_mstatus_mie_clear           ;
wire                                    core_csr_mstatus_mie_set            ;
wire                                    core_csr_mepc_write_en              ;
wire                                    core_csr_interrupt_valid            ;
wire                                    core_csr_dpc_valid                  ;
wire    [31:0]                          core_csr_dpc                        ;
wire    [31:0]                          core_csr_exception_inst             ;
wire                                    core_csr_exception_inst_valid       ;
wire    [7:0]                           core_csr_active_level_priority      ;
wire    [7:0]                           core_csr_trap_id                    ;

//-------------------------------------------------------------------------------------------------


//------------------------------DEBUG AXI AND INSTRUCTION MEMORY AXI INTERFACE---------------------


// 	                            WRITE ADDRESS CHANNEL 

wire 					                debug_axi_inst_mem_awvalid			;
wire 	[AXI_ADDR_WIDTH -1:0] 		    debug_axi_inst_mem_awaddr 			;
wire 					                debug_axi_inst_mem_awready			;

//				                WRITE DATA CHANNEL 

wire 					                inst_mem_debug_axi_wvalid 			;
wire 	[AXI_DATA_WIDTH-1:0] 		    inst_mem_debug_axi_wdata 			;
wire 	[STROBE_WIDTH-1:0] 		        debug_axi_inst_mem_wstrb 			;
wire 					                debug_axi_inst_mem_wready 			;

//				                WRITE RESPONSE CHANNEL

wire 					                debug_axi_inst_mem_bready 			;
wire 	[1:0]				            inst_mem_debug_axi_bresp 			;
wire 					                inst_mem_debug_axi_bvalid 			;

//				                READ ADDRESS CHANNEL

wire 					                debug_axi_inst_mem_arvalid			;
wire 	[AXI_ADDR_WIDTH-1:0] 		    debug_axi_inst_mem_araddr 			;
wire 					                inst_mem_debug_axi_arready 			;

//				                READ DATA CHANNEL

wire 					                debug_axi_inst_mem_rready 			;
wire 					                inst_mem_debug_axi_rvalid 			;
wire 	[AXI_DATA_WIDTH-1:0] 		    inst_mem_debug_axi_rdata 			;
wire 	[1:0]				            inst_mem_debug_axi_rresp 			;


//------------------------------CORE AND INSTRUCTION MEMORY AXI INTERFACE SIGNALS-------------------------------

//				                        READ DATA CHANNEL

wire 					                core_axi_inst_mem_rready 		    ;
wire 					                inst_mem_core_axi_rvalid 			;
wire 	[1:0]				            inst_mem_core_axi_rresp 			;

//-------------------------------------------------------------------------------------------------

//---------------------------JTAG AND AXI WRAPPER INTERFACE SIGNALS-----------------------------

wire    [31:0]                          debug_axi_address_in                ;
wire                                    debug_axi_read_en                   ;
wire                                    debug_axi_write_en                  ;
wire                                    debug_axi_req_valid                 ;
wire    [31:0]                          debug_axi_write_data                ;
wire    [3:0]                           debug_axi_byte_en                   ;
wire    [31:0]                          axi_debug_read_data                 ;
wire    [1:0]                           axi_debug_read_resp                 ;
wire    [1:0]                           axi_debug_write_resp                ;
wire                                    axi_debug_read_valid                ;
wire                                    axi_debug_read_ready                ;
wire                                    axi_debug_write_valid               ;
wire                                    axi_debug_write_ready               ;

//--------------------------------DEBUG AND CSR CONNECTION----------------------

wire                                    debug_csr_write_en                  ;
wire    [31:0]                          debug_csr_write_data                ;
wire    [31:0]                          csr_debug_read_data                 ;
wire                                    csr_debug_read_valid                ;
wire                                    debug_clk_ctrl_int_ctrl_ndm_reset   ;

//-------------------------DEBUG TO CSR AND GPR COMMON SIGNAL----------------------

wire    [15:0]                          debug_csr_gpr_address               ;
wire                                    debug_csr_gpr_read_en               ;

//--------------------------------------------------------------------------------------------------

wire                                    inst_mem_core_axi_arready           ;
wire 	[3:0] 				            core_axi_wstrobe 				    ;	//	BYTE ENABLE SIGNAL FROM CORE NEED TO CHANGE ACCORDING TO THE AXI INTERFACE
wire 	[31:0] 				            instruction_to_core 				;	//	FINAL INSTRUCTION TO THE CORE
wire    [31:0]                          instruction_from_mem                ;   //  INSTRUCTION FROM THE INSTRUCTION MEMORY
wire                                    inst_mem_req_valid                  ;   //  INSTRUCTION REQUEST VALID FOR INSTRUCTION MEMORY
wire 	[31:0] 				            mem_write_data_core 			    ;	//	WRIRE DATA TO THE TARGETED MEMORY ADDRESS
wire 	[31:0] 				            axi_core_mem_read_data 		        ;	//	DATA FROM THE REQUESTED MEMORY ADDRESS
wire                                    exception_flush                     ;

//-----------------------------------CSR AMD MMU CONNECTIONS----------------

wire					                mmu_enable 				            ;	// 	MMU ENABLE BY CSR
wire                                    mmu_busy                            ;
wire 	[21:0]				            csr_mmu_base_ppn 				    ;	//	PAGE TABLE ENTRIES BASE PPN ADDRESS TO MMU BY CSR
wire 	[8:0]				            csr_mmu_current_asid 				;	//	CURRENT ASID TO MMU FROM CSR

//---------------------------STALL SIGNAL USED FOR GLUE LOGIC---------------------------

wire 					                stall_by_axi_data_mem_read 		    ;	//	STALL SIGNAL BY DATA MEMORY READ
wire					                stall_by_axi_data_mem_write		    ;	//	STALL SIGNAL BY DATA MEMORY WRITE
wire					                stall_by_load_store			        ;	//	STALL SIGNAL BY BOTH READ AND WRITE BY DATA MEMORY
wire 					                stall_the_core_pipeline				; 
wire					                axi_master_select			        ;
wire                                    data_mem_addr_slverr                ;

//--------------------------CORE TO AXI MASTER WRAPPER REQUEST VALID SIGNALS

wire 					                axi_data_mem_req_valid			    ;	//	AXI MASTER WRAPPER OF DATA MEMORY INPUT VALID BIT

//-------------------------VALID,READY AND RESPONSE SIGNALS FROM THE AXI MASTER WRAPPER OF DATA MEMORY SIDE


wire	[1:0]				            axi_core_rresp			            ;		//	READ RESPONSE SIGNAL
wire	[1:0]				            axi_core_bresp			            ;		//	WRITE_RESPONSE SIGNAL
wire					                axi_core_rvalid			            ;		//	READ VALID SIGNAL
wire 					                axi_core_rready			            ;		//	READ READY SIGNAL
wire					                axi_core_bready			            ;		//	WRITE RESPONSE READY SIGNAL
wire 					                axi_core_bvalid			            ;		//	WRITE RESPONSE VALID SIGNAL
wire	[2:0]				            core_axi_awsize			            ;

//----------------------------DEBUG MODULE TO PTE CONNNECTIONS----------------------------

wire                                    debug_pte_valid_in                  ;
wire    [31:0]                          debug_pte_address                   ;
wire                                    debug_pte_write_en                  ;
wire    [31:0]                          debug_pte_write_data                ;
wire    [1:0]                           pte_debug_write_resp                ;
wire                                    pte_debug_write_valid               ;
wire                                    debug_pte_read_en                   ;
wire    [31:0]                          pte_debug_read_data                 ;
wire    [1:0]                           pte_debug_read_resp                 ;
wire                                    pte_debug_read_valid                ;

//--------------------------------MMU TO PTE MEMORY CONNECTIONS------------------------------

wire                                    mmu_pte_req_valid                   ;
wire    [31:0]                          mmu_pte_req_address                 ;
wire                                    pte_mmu_resp_valid                  ;
wire    [23:0]                          pte_mmu_read_data                   ;


//-------------------------------DEBUG AND INSTRUCTION MEMORY CONNECTION USED BY BOOT LOADER----------------------

wire    [31:0]                          inst_mem_debug_read_data            ;
wire                                    debug_inst_mem_req_valid            ;
wire                                    debug_inst_mem_write_en             ;
wire    [31:0]                          debug_inst_mem_address_in           ;
wire    [31:0]                          debug_inst_mem_write_data           ;

//--------------DEBUG AND DATA MEMORY & PREBBOT ANALOG REGISTER  CONNECTION USED BY BOOT LOADER----------------------

wire    [31:0]                          preboot_dmem_read_data              ;
wire                                    debug_data_mem_req_valid            ;
wire                                    debug_data_mem_write_en             ;
wire    [31:0]                          debug_data_mem_address_in           ;
wire    [31:0]                          debug_data_mem_write_data           ;
wire                                    debug_dmem_preboot_valid            ;
wire    [31:0]                          preboot_analog_reg_debug_rdata      ;
wire    [31:0]                          data_mem_debug_read_data            ;
wire                                    debug_preboot_analog_req_valid      ;

//-------------------------------CLK RST BYPASS MODUELE SIGNALS--------------------

wire                                    boot_load_enable                    ;
wire                                    memory_clk                          ;
wire                                    ctrl_bypass_debug_clk               ;
wire                                    ctrl_bypass_debug_rstn              ;
wire                                    rst_for_clk_ctrl                    ;
wire                                    preboot_analog_rstn                 ;

//------------------------------CLK RST CONTROLLER MODULE SIGNALS------------------------

wire                                    core_clk                            ;
wire                                    core_rstn                           ;
wire                                    debug_clk                           ;
wire                                    debug_rstn                          ;
wire                                    pclk                                ;
wire                                    presetn                             ;
wire                                    clk_to_clk_rst_ctrl                 ;

//----------------------------I2C IO PAD SIGNALS--------------------

wire                                    i2c_scl                             ;
wire                                    i2c_sda_in                          ;
wire                                    i2c_sda_out                         ;
wire                                    i2c_sda_oe                          ;

//-----------------------------SPI TO PAD SIGNALS-------------------

wire                                    spi_mosi                            ;
wire                                    spi_miso                            ;
wire                                    spi_ss                              ;
wire                                    spi_sclk                            ;

//-----------------------------UART TO PAD SIGNALS----------------------

wire                                    uart_tx                             ;
wire                                    uart_rx                             ;

//---------------------------MMU AND TOP REGISTER SIGNALS-----------------------------

wire                                    mmu_prefetch_enable                 ;
wire                                    mmu_ptw_timeout_enable              ;
wire                                    mmu_ptw_timeout                     ;
wire  					                instruction_execute_permission_fault;
wire 					                mem_read_permission_fault 		    ; 
wire 					                mem_write_permission_fault 		    ;
wire					                inst_page_fault				        ;
wire					                mem_page_fault				        ;

//-------------------------------EXCEPTIONS OF THE MEMORY TO TOP REGISTER-------------------------

wire					                req_data_mem_address_decode_error	;	//	DATA MEMORY ADDRESS DECODE ERROR
wire 					                data_mem_read_addr_slverr			;	//	DATA MEMORY SLAVE ERROR DUE TO READ OPERATION
wire					                data_mem_write_addr_slverr			;	//	DATA MEMORY SLAVE ERROR DUE TO WRITE OPERATION
wire                                    inst_mem_addr_decode_error          ;   //  INSTRUCTION MEMORY ADDRESS OUT OF RANGE INDICATION

//----------------------------------GPIO & CLK RST BYPASS SIGNALS----------------------------

wire                                    gpio_presetn                        ;
wire                                    gpio_boot_gpio0                     ;
wire                                    gpio_boot_gpio1                     ;

//----------------------------------DEBUG TO CORE SIGNALS------------------------------

wire                                    debug_core_pb_valid                 ;                        
wire    [31:0]                          debug_core_pb_instruction           ;
wire                                    debug_core_csr_halt_request         ;
wire                                    debug_core_csr_reset_halt           ;  
wire                                    debug_core_resume_req               ;
wire    [31:0]                          debug_core_pc_addr                  ;

//------------------------------------CORE TO DEBUG SIGNALS--------------------------------

wire    [31:0]                          core_debug_read_data                ;                      
wire                                    core_debug_read_valid               ;          
wire                                    core_debug_hart_halted              ;                    
wire                                    core_debug_hart_reset               ;                     
wire                                    debug_mode_en                       ;
wire                                    core_inst_mem_csr_int_ctrl_debug_mode_en;

//-----------------------------------READ DATA AND VALID SIGNALS FROM CSR OR GPR TO DEBUG MODULE-------------------

wire    [31:0]                          csr_gpr_debug_read_data             ;
wire                                    csr_gpr_debug_read_valid            ;

//----------------------------------CORE TO WATCHDOG TIMER SIGNALS-------------------------

wire    [31:0]                          core_watchdog_last_commited_pc      ;
wire                                    core_watchdog_commit_valid          ;

//---------------------------------WIRES USED FOR GLUE LOGIC-------------------------------

wire                                    axi_debug_read_valid_in             ;
wire                                    axi_debug_write_valid_in            ;

//----------------------------------CORE & INTERRUPT SIGNALS------------------------------

wire                                    int_ctrl_core_interrupt_req         ;
wire    [7:0]                           int_ctrl_core_current_int_id        ;
wire                                    core_int_ctrl_eoi_write_valid       ;
wire    [7:0]                           core_int_ctrl_eoi_id                ;
wire    [7:0]                           int_ctrl_core_highest_pending_lvl_pr;

//----------------------------------CSR INTERRUPT CONTROLLER SIGNALS-------------------------

wire    [7:0]                           csr_int_ctrl_active_lvl_pr          ;
wire    [15:0]                          csr_int_ctrl_global_int_enable_bit  ;

//-------------------------------CSR, CORE & INTERRUPT CONTROLLER SIGNAL------------------ 

wire                                    csr_core_int_ctrl_mstatus_mie       ;

//---------------------------------MMR REGISTER TO INTERRUPT CONTROLLER SIGNALS---------------------------

wire                                    mmr_int_ctrl_write_en               ;
wire    [15:0]                          mmr_int_ctrl_write_addr             ;
wire    [7:0]                           mmr_int_ctrl_write_data             ;
wire                                    mmr_int_ctrl_read_en                ;
wire    [15:0]                          mmr_int_ctrl_read_addr              ;
wire    [7:0]                           int_ctrl_mmr_read_data              ;
wire                                    int_ctrl_mmr_read_resp              ;

//---------------------------------WATCHDOG TIMER TO INTERRUPT CONTROLLER SINALS--------------------------

wire                                    wdt_reset                           ;
wire    [2:0]                           wdt_clk_rst_ctrl_reset_scope        ;

//----------------------------------PERIPHERAL RESETS FROM CLK RST CONTROLLER---------------------

wire                                    i2c_presetn                         ;
wire                                    spi_presetn                         ;
wire                                    uart_presetn                        ;

//----------------------------------IP TRACE TO GPIO PINMUX SIGNAL----------------------------

wire    [15:0]                          ip_trace_gpio_dgb_data              ;
wire                                    ip_trace_gpio_dbg_valid             ;
wire                                    ip_trace_gpio_dbg_trigger           ;

//--------------------------------FROM DIFFERENT IP TO DEBUG TRACE IP--------------------------------

wire    [31:0]                          mmu_ip_trace_data                   ;
wire    [31:0]                          spi_ip_trace_data                   ;
wire    [31:0]                          bridge_ip_trace_data                ;
wire    [31:0]                          int_ctrl_ip_trace_data              ;
wire    [31:0]                          i2c_ip_trace_data                   ;
wire    [31:0]                          debug_ip_trace_data                 ;
wire    [31:0]                          uart_ip_trace_data                  ;
wire    [31:0]                          wdt_ip_trace_data                   ;

wire    [7:0]                           mmu_ip_trace_event                  ;
wire    [7:0]                           spi_ip_trace_event                  ;
wire    [7:0]                           bridge_ip_trace_event               ;
wire    [7:0]                           int_ctrl_ip_trace_event             ;
wire    [7:0]                           i2c_ip_trace_event                  ;
wire    [7:0]                           debug_ip_trace_event                ;
wire    [7:0]                           uart_ip_trace_event                 ;
wire    [7:0]                           wdt_ip_trace_event                  ;

//---------------------------------CORE AND DEBUG TRACE SIGNALS--------------------------

wire    [3:0]                           core_debug_trace_itype              ;
wire    [15:0]                          core_debug_trace_iaddr              ;
wire    [7:0]                           core_debug_trace_cause              ;
wire    [1:0]                           core_debug_trace_context            ;
wire                                    core_debug_trace_ienable            ;
wire                                    core_debug_trace_itype_valid        ;
wire                                    core_debug_trace_Ist_instrn_valid   ;
wire    [19:0]                          core_debug_trace_delta_addr         ;
wire                                    core_debug_trace_del_adr_valid      ;

//-----------------------------GPIO PINMUX AND CORE DEBUG TRACE SIGNALS------------------

wire                                    gpio_core_trace_atready             ;
wire                                    core_trace_gpio_afready             ;
wire                                    gpio_core_trace_afvalid             ;
wire                                    core_trace_gpio_atvalid             ;
wire    [15:0]                          core_trace_gpio_atdata              ;

//-----------------------------GPIO PINMUX TO INTERRUPT CONTROLLER SIGNALS-----------------------

wire    [5:0]                           gpio_int_ctrl_irq                   ;


//------------------------------------CSR TO CORE TRACE IP-----------------------------

wire    [31:0]                          csr_debug_trace_tval                ;

//-----------------------------------CLK RST BYPASS TO GPIO PINMUX---------------------------

wire                                    boot_gpio_dbg1                      ;
wire                                    boot_gpio_dbg2                      ;
wire                                    boot_gpio_dbg3                      ;
wire                                    boot_gpio_dbg4                      ;
wire                                    boot_gpio_dbg5                      ;
wire                                    boot_gpio_dbg6                      ;

//------------------------------USED FOR GLUE BTWN THE POSR AND PRE BOOT REGSITER--------------------

wire    [15:0]                          analog_preboot_reg1_w               ;
wire    [6:0]                           analog_postboot_reg5                ;
wire    [6:0]                           analog_pre_post_boot_reg1_w         ;
wire                                    pre_post_boot_mux_sel               ;

//-----------------------------EXPECTIONS AND FAULTS SIGNALS TO TOP REGISTER AFTER REGISTERED---------------

reg     [31:0]                         reg_physical_address_inst_mem           ;
reg     [31:0]                         reg_physical_address_data_mem           ;
reg                                    reg_mmu_timeout                         ;
reg                                    reg_data_memory_page_fault              ;
reg                                    reg_data_memory_read_permission_fault   ;
reg                                    reg_data_memory_write_permission_fault  ;
reg                                    reg_data_memory_addr_decode_error       ;
reg                                    reg_data_memory_read_slave_error        ;
reg                                    reg_data_memory_write_slave_error       ;
reg                                    reg_instruction_page_fault              ;
reg                                    reg_inst_execution_fault                ;
reg                                    reg_inst_addr_decode_error              ;
reg                                    reg_sync_1_boot_load_en                 ;
reg                                    reg_sync_2_boot_load_en                 ;


//------------------------------------SIGNAL USED FOR RESET SYNCHRONIZER----------------------

reg                                     rst_sync_reg1                           ;
reg                                     rst_sync_reg2                           ;

//-----------------------------------DFT SIGNALS USED IN CLK RST CONTROLLER MODULE------------------------------------

logic                                    test_mode_soc_rst                   ;
logic                                    test_mode_soc_rst_en                ;
logic                                    test_mode_peripheral_rst            ;
logic                                    test_mode_peripheral_rst_en         ; 
logic                                    test_mode_debug_rst                 ;
logic                                    test_mode_debug_rst_en              ;       
logic                                    test_mode_clk_peripheral_mux        ;
logic                                    test_mode_clk_soc_mux               ;
logic                                    test_mode_en_peripheral_mux         ; 
logic                                    test_mode_en_soc_mux                ;
logic                                    test_mode_div_peripheral            ;
logic                                    test_mode_div_debug                 ;
logic                                    test_mode_spi_rstn                  ;
logic                                    test_mode_spi_rstn_en               ;
logic                                    test_mode_uart_rstn_en              ;
logic                                    test_mode_uart_rstn                 ;
logic                                    test_mode_i2c_rstn_en               ;
logic                                    test_mode_i2c_rstn                  ;

logic                                    tm_clk_rst_prstn_sync               ;
logic                                    tm_clk_rst_prstn_sync_en            ;
                            
logic                                    tm_clk_rst_soc_rstn_sync_en         ;
logic                                    tm_clk_rst_soc_rstn_sync            ;
                            
logic                                    tm_clk_rst_prstn_por_sync           ;
logic                                    tm_clk_rst_prstn_por_sync_en        ;
                            
logic                                    tm_clk_rst_dbg_rstn_sync            ;
logic                                    tm_clk_rst_dbg_rstn_sync_en         ;



// ----------------------- CLK_RST_BYPASS DFT TEST SIGNALS -----------------------------------
logic                                   tm_mem_rc_clk_mux_en_i              ;
logic                                   tm_mem_rc_clk_mux_i                 ;
logic                                   tm_pll_xtal_clk_mux_en_i            ;
logic                                   tm_pll_xtal_clk_mux_i               ;
logic                                   tm_dbg_rc_clk_mux_en_i              ;
logic                                   tm_dbg_rc_clk_mux_i                 ;
logic                                   tm_jtag_dbg_pulse_rstn_en           ;
logic                                   tm_jtag_dbg_pulse_rstn              ;

logic                                   tm_bypass_rc_rstn_sync              ;  
logic                                   tm_bypass_rc_rstn_sync_en           ;
logic                                   tm_bypass_xtal_rstn_sync            ;
logic                                   tm_bypass_xtal_rstn_sync_en            ;
logic                                   tm_bypass_mem_rstn_sync_en          ;   
logic                                   tm_bypass_mem_rstn_sync             ;
logic                                   tm_bypass_dbg_rstn_sync_en          ;
logic                                   tm_bypass_dbg_rstn_sync             ;
logic                                   tm_bypass_boot_pulse_rstn_sync      ;
logic                                   tm_bypass_boot_pulse_rstn_sync_en   ;
logic                                   tm_bypass_pulse_gen_rstn_sync_en    ;
logic                                   tm_bypass_pulse_gen_rstn_sync       ;
logic                                   tm_bypass_pll_rstn_sync_en          ;
logic                                   tm_bypass_pll_rstn_sync             ;
logic                                   tm_bypass_bt_pulse_gen_rstn_en      ;
logic                                   tm_bypass_bt_pulse_gen_rstn         ;
logic                                   tm_bypass_preboot_analog_rstn_en    ;
logic                                   tm_bypass_preboot_analog_rstn       ;
logic                                   tm_bypass_pulse_clk_rst             ;
logic                                   tm_bypass_pulse_clk_rst_en          ;

// --------------------- AXI2APB DFT TEST SIGNALS------------------------------
logic                                   tm_bridge_prstn_sync_en                  ;
logic                                   tm_bridge_prstn_sync                     ;

// ---------------------PINAKA TOP RESET SYNC DFT ---------------------------
logic                                   tm_pinaka_rstn_en                   ;
logic                                   tm_pinaka_rstn                      ;
// ------------------------ UART DFT TEST SIGNALS -------------------------------------------
logic                                   tm_uart_bclk_en_i                   ;
logic                                   tm_uart_bclk_i                      ;
logic                                   tm_uart_brstn_en                    ;
logic                                   tm_uart_brstn                       ;

// ------------------------GPIO DFT TEST SIGNALS --------------------------------------------
logic                                   tm_gpio_prstn_en                    ;
logic                                   tm_gpio_prstn                       ;

//---------------------------------------------------------------------------------------------


//------------------------------------------------GLUE LOGICS---------------------------------------------




//                                  INSTRUCTION PPN REQUESTING TO MMU GLUE LOGIC

assign  core_mmu_inst_req                       =   ~reg_sync_2_boot_load_en & ~mmu_busy                          ;


//		            STALL LOGIC FOR THE CORE TO STALL UNTIL LOAD AND STORE IS COMPLETE

assign 	stall_by_axi_data_mem_read 	            = 	core_mmu_axi_mem_read_en & ~( axi_core_rvalid & axi_core_rready & (axi_core_rresp == 2'b00) ) ;
	
assign 	stall_by_axi_data_mem_write 	        = 	core_mmu_axi_mem_write_en & ~( axi_core_bvalid & axi_core_bready & ( axi_core_bresp == 2'b00) )	;

assign 	stall_by_load_store 		            = 	stall_by_axi_data_mem_read | stall_by_axi_data_mem_write ;


//			                OVERALL STALL THE CORE BY INSTRUCTION OR DATA MEMORY ACCESS

assign 	stall_the_core_pipeline		            =	 !mmu_instruction_hit | ~inst_mem_core_axi_rvalid  | stall_by_load_store	;


//			                    FINAL PHYSICAL ADDRESS DEPENDING ON THE MMU ENABLE

assign 	mmu_axi_physical_address_inst_mem 		= 	{ mmu_ppn_inst_mem_address  , core_mmu_inst_mem_virtual_address[11:0] } 		;
assign 	mmu_axi_physical_address_data_mem 		= 	{ mmu_ppn_data_mem_address  , core_mmu_data_mem_virtual_address[11:0] } 		;


//                                      INSTRUCTION TO CORE 

assign  instruction_to_core                     =   ( (inst_mem_core_axi_rresp == 2'b00) && inst_mem_core_axi_rvalid && inst_mem_core_axi_arready ) ? instruction_from_mem : 32'd0 ;


//			        THIS SIGNAL TELLS THE REQUESTED ADDRESS IS VALID OR NOT TO THE AXI WRAPPERS

assign 	axi_data_mem_req_valid		            = 	mmu_data_memory_hit & ((core_mmu_axi_mem_read_en & ~ mem_read_permission_fault )|( core_mmu_axi_mem_write_en & ~mem_write_permission_fault));

assign 	inst_mem_req_valid		                = 	mmu_instruction_hit &&  ~instruction_execute_permission_fault && ~ inst_page_fault  && ( ( mmu_axi_physical_address_inst_mem <= INST_MEMORY_MAX_ADDRESS ) && ( mmu_axi_physical_address_inst_mem >= INST_MEMORY_MIN_ADDRESS ) );

assign 	inst_mem_addr_decode_error              = 	mmu_instruction_hit && ~( ( mmu_axi_physical_address_inst_mem <= INST_MEMORY_MAX_ADDRESS ) && ( mmu_axi_physical_address_inst_mem >= INST_MEMORY_MIN_ADDRESS ) );


//			                    MEMORY READ AND WRITE SLAVE ERROR

assign 	data_mem_read_addr_slverr		        = 	axi_core_rvalid & axi_core_rready & (axi_core_rresp == 2'b10) 	;

assign 	data_mem_write_addr_slverr		        =	axi_core_bvalid & axi_core_bready & (axi_core_bresp == 2'b10) 	;

assign  data_mem_addr_slverr                    =   data_mem_read_addr_slverr | data_mem_write_addr_slverr          ;


//                  READ DATA AND VALID TO DEBUG MODULE FROM CSR OR GPR SELECTING ONE OD THE DATA AND VALID

assign  csr_gpr_debug_read_data                 =   (debug_csr_gpr_address[15:12] == 4'd0) ? csr_debug_read_data : core_debug_read_data ;

assign  csr_gpr_debug_read_valid                =   (debug_csr_gpr_address[15:12] == 4'd0) ? csr_debug_read_valid : core_debug_read_valid ;


//                      AXI MASTER SELECT LOGIC WHETHER IT IS A CORE MODE OR DEBUG MODE 

assign  axi_master_select                       =   debug_mode_en & ~core_mmu_axi_mem_write_en & ~core_mmu_axi_mem_read_en ;


//                      READ AND WRITE VALID SIGNALS TO DEBUG MODULE FROM AXI MASTER WRAPPER

assign  axi_debug_read_valid_in                 =   axi_debug_read_valid & axi_debug_read_ready             ;

assign  axi_debug_write_valid_in                =   axi_debug_write_valid & axi_debug_write_ready           ;


//                      DEBUG MODULE TO DATA MEMORY REQUEST VALID SIGNAL LOGIC

assign  debug_data_mem_req_valid                =   ( (debug_data_mem_address_in >= DATA_MEMORY_MIN_ADDRESS) && (debug_data_mem_address_in <= DATA_MEMORY_MAX_ADDRESS) ) ? debug_dmem_preboot_valid : 1'b0 ;


//                      DEBUG MODULE TO PREBOOT ANALOG REGISTER REQUEST VALID SIGNAL LOGIC

assign  debug_preboot_analog_req_valid          =   ( (debug_data_mem_address_in >= PREBOOT_REG_START_ADDRESS) && (debug_data_mem_address_in <= PREBOOT_REG_END_ADDRESS) ) ? debug_dmem_preboot_valid : 1'b0 ;


//                          SELECTING THE READ DATA BETWEEN DATA MEMORY AND PREBOOT ANALOG REGISTER TO DEBUG MODULE

assign  preboot_dmem_read_data                  =   ( (debug_data_mem_address_in >= PREBOOT_REG_START_ADDRESS) && (debug_data_mem_address_in <= PREBOOT_REG_END_ADDRESS) ) ? preboot_analog_reg_debug_rdata : data_mem_debug_read_data ;


//                          SELECTING THE PRE BOOT OR POST BOOT REGISTER GLUE LOGIC

assign  analog_pre_post_boot_reg1_w             =   pre_post_boot_mux_sel ? analog_postboot_reg5 : analog_preboot_reg1_w[6:0]  ;


//                          CONCATINATINGOF THE BLOCK AND MODE SELECT FROM GLUE LOGIC

assign analog_preboot_reg1                      =   { analog_pre_post_boot_reg1_w[6:2] ,analog_preboot_reg1_w[10:2] , analog_pre_post_boot_reg1_w[1:0] }           ;





//-------------------------------------CONSTANT GLUE LOGIC OF THE DFT SIGNALS---------------------------------

/*



assign test_mode_soc_rst_en         = Test_mode ? 1'b1 : 1'b0;
assign test_mode_soc_rst            = Test_mode ? 1'b1 : 1'b0;


assign test_mode_peripheral_rst_en  = Test_mode ? 1'b1 : 1'b0;
assign test_mode_peripheral_rst     = Test_mode ? 1'b1 : 1'b0;

assign test_mode_debug_rst_en       = Test_mode ? 1'b1 : 1'b0;
assign test_mode_debug_rst          = Test_mode ? 1'b1 : 1'b0;


assign test_mode_en_peripheral_mux  = Test_mode ? 1'b1 : 1'b0;
assign test_mode_clk_peripheral_mux = pll_clk;

assign test_mode_en_soc_mux         = Test_mode ? 1'b1 : 1'b0;
assign test_mode_clk_soc_mux        = pll_clk;

assign test_mode_div_peripheral     = Test_mode ? 1'b1 : 1'b0;

assign test_mode_div_debug          = Test_mode ? 1'b1 : 1'b0;

assign test_mode_spi_rstn_en        = Test_mode ? 1'b1 : 1'b0;
assign test_mode_spi_rstn           = Test_mode ? 1'b1 : 1'b0;


assign test_mode_uart_rstn_en       = Test_mode ? 1'b1 : 1'b0;
assign test_mode_uart_rstn          = Test_mode ? 1'b1 : 1'b0;


assign test_mode_i2c_rstn_en        = Test_mode ? 1'b1 : 1'b0;
assign test_mode_i2c_rstn           = Test_mode ? 1'b1 : 1'b0;



assign tm_mem_rc_clk_mux_en_i       = Test_mode ? 1'b1 : 1'b0;
assign tm_mem_rc_clk_mux_i          = pll_clk ;
assign tm_pll_xtal_clk_mux_en_i     = Test_mode ? 1'b1 : 1'b0;
assign tm_pll_xtal_clk_mux_i        = pll_clk;
assign tm_dbg_rc_clk_mux_en_i       = Test_mode ? 1'b1 : 1'b0;
assign tm_dbg_rc_clk_mux_i          = pll_clk;

assign tm_uart_bclk_en_i            = Test_mode ? 1'b1 : 1'b0;
assign tm_uart_bclk_i               = pll_clk;


*/

always_comb begin
    if(Test_mode) begin

        test_mode_soc_rst             = 1'b1 ;
        test_mode_soc_rst_en          = 1'b1 ;
        test_mode_peripheral_rst      = 1'b1 ;
        test_mode_peripheral_rst_en   = 1'b1 ;
        test_mode_debug_rst           = 1'b1 ;
        test_mode_debug_rst_en        = 1'b1 ;
//        test_mode_clk_peripheral_mux  = 1'b1 ;
//        test_mode_clk_soc_mux         = 1'b1 ;
        test_mode_en_peripheral_mux   = 1'b1 ;
        test_mode_en_soc_mux          = 1'b1 ;
        test_mode_div_peripheral      = 1'b1 ;
        test_mode_div_debug           = 1'b1 ;
        test_mode_spi_rstn            = 1'b1 ;
        test_mode_spi_rstn_en         = 1'b1 ;
        test_mode_uart_rstn_en        = 1'b1 ;
        test_mode_uart_rstn           = 1'b1 ;
        test_mode_i2c_rstn_en         = 1'b1 ;
        test_mode_i2c_rstn            = 1'b1 ;
                                      
        tm_mem_rc_clk_mux_en_i        = 1'b1 ;
//        tm_mem_rc_clk_mux_i           = 1'b1 ;
        tm_pll_xtal_clk_mux_en_i      = 1'b1 ;
//        tm_pll_xtal_clk_mux_i         = 1'b1 ;
        tm_dbg_rc_clk_mux_en_i        = 1'b1 ;
//        tm_dbg_rc_clk_mux_i           = 1'b1 ;
        tm_jtag_dbg_pulse_rstn        = 1'b1;
        tm_jtag_dbg_pulse_rstn_en     = 1'b1;

        tm_bypass_rc_rstn_sync          = 1'b1; 
        tm_bypass_rc_rstn_sync_en       = 1'b1; 
        tm_bypass_xtal_rstn_sync_en        = 1'b1; 
        tm_bypass_xtal_rstn_sync        = 1'b1; 
        tm_bypass_mem_rstn_sync_en      = 1'b1; 
        tm_bypass_mem_rstn_sync         = 1'b1; 
        tm_bypass_dbg_rstn_sync_en      = 1'b1    ;
        tm_bypass_dbg_rstn_sync         = 1'b1    ;
        tm_bypass_boot_pulse_rstn_sync    = 1'b1  ;
        tm_bypass_boot_pulse_rstn_sync_en = 1'b1  ;
        tm_bypass_pulse_gen_rstn_sync_en  = 1'b1  ;
        tm_bypass_pulse_gen_rstn_sync     = 1'b1  ;
        tm_bypass_pll_rstn_sync_en        = 1'b1  ;
        tm_bypass_pll_rstn_sync           = 1'b1  ;
        tm_bypass_bt_pulse_gen_rstn_en     = 1'b1 ;
        tm_bypass_bt_pulse_gen_rstn        = 1'b1 ;
        tm_bypass_preboot_analog_rstn_en   = 1'b1 ;
        tm_bypass_preboot_analog_rstn      = 1'b1 ;
        tm_bypass_pulse_clk_rst            = 1'b1 ;
        tm_bypass_pulse_clk_rst_en         = 1'b1 ;



        tm_bridge_prstn_sync_en            = 1'b1;
        tm_bridge_prstn_sync               = 1'b1;

        tm_uart_bclk_en_i             = 1'b1 ;
        tm_uart_brstn_en              = 1'b1;
        tm_uart_brstn                 = 1'b1;

        tm_clk_rst_prstn_sync           = 1'b1;
        tm_clk_rst_prstn_sync_en        = 1'b1;
        
        tm_clk_rst_soc_rstn_sync_en     = 1'b1;
        tm_clk_rst_soc_rstn_sync        = 1'b1;
        
        tm_clk_rst_prstn_por_sync       = 1'b1;
        tm_clk_rst_prstn_por_sync_en    = 1'b1;
        
        tm_clk_rst_dbg_rstn_sync        = 1'b1;
        tm_clk_rst_dbg_rstn_sync_en     = 1'b1;

        tm_gpio_prstn_en                = 1'b1    ;
        tm_gpio_prstn                   = 1'b1    ;



    end else begin

        test_mode_soc_rst             = 1'b0 ;
        test_mode_soc_rst_en          = 1'b0 ;
        test_mode_peripheral_rst      = 1'b0 ;
        test_mode_peripheral_rst_en   = 1'b0 ;
        test_mode_debug_rst           = 1'b0 ;
        test_mode_debug_rst_en        = 1'b0 ;
//        test_mode_clk_peripheral_mux  = 1'b0 ;
//        test_mode_clk_soc_mux         = 1'b0 ;
        test_mode_en_peripheral_mux   = 1'b0 ;
        test_mode_en_soc_mux          = 1'b0 ;
        test_mode_div_peripheral      = 1'b0 ;
        test_mode_div_debug           = 1'b0 ;
        test_mode_spi_rstn            = 1'b0 ;
        test_mode_spi_rstn_en         = 1'b0 ;
        test_mode_uart_rstn_en        = 1'b0 ;
        test_mode_uart_rstn           = 1'b0 ;
        test_mode_i2c_rstn_en         = 1'b0 ;
        test_mode_i2c_rstn            = 1'b0 ;
                                    
        tm_mem_rc_clk_mux_en_i        = 1'b0 ;
//        tm_mem_rc_clk_mux_i           = 1'b0 ;
        tm_pll_xtal_clk_mux_en_i      = 1'b0 ;
//        tm_pll_xtal_clk_mux_i         = 1'b0 ;
        tm_dbg_rc_clk_mux_en_i        = 1'b0 ;
//        tm_dbg_rc_clk_mux_i           = 1'b0 ;
        tm_jtag_dbg_pulse_rstn        = 1'b0;
        tm_jtag_dbg_pulse_rstn_en     = 1'b0;

        tm_bypass_rc_rstn_sync          = 1'b0; 
        tm_bypass_rc_rstn_sync_en       = 1'b0; 
        tm_bypass_xtal_rstn_sync_en        = 1'b0; 
        tm_bypass_xtal_rstn_sync        = 1'b0; 
        tm_bypass_mem_rstn_sync_en      = 1'b0; 
        tm_bypass_mem_rstn_sync         = 1'b0; 
        tm_bypass_dbg_rstn_sync_en      = 1'b0    ;
        tm_bypass_dbg_rstn_sync         = 1'b0    ;
        tm_bypass_boot_pulse_rstn_sync    = 1'b0  ;
        tm_bypass_boot_pulse_rstn_sync_en = 1'b0  ;
        tm_bypass_pulse_gen_rstn_sync_en  = 1'b0  ;
        tm_bypass_pulse_gen_rstn_sync     = 1'b0  ;
        tm_bypass_pll_rstn_sync_en        = 1'b0  ;
        tm_bypass_pll_rstn_sync           = 1'b0  ;
        tm_bypass_bt_pulse_gen_rstn_en     = 1'b0 ;
        tm_bypass_bt_pulse_gen_rstn        = 1'b0 ;
        tm_bypass_preboot_analog_rstn_en   = 1'b0 ;
        tm_bypass_preboot_analog_rstn      = 1'b0 ;
        tm_bypass_pulse_clk_rst            = 1'b0 ;
        tm_bypass_pulse_clk_rst_en         = 1'b0 ;


        tm_bridge_prstn_sync_en            = 1'b0;
        tm_bridge_prstn_sync               = 1'b0;

        tm_uart_bclk_en_i             = 1'b0;
        tm_uart_brstn_en              = 1'b0;
        tm_uart_brstn                 = 1'b0;

        tm_clk_rst_prstn_sync           = 1'b0;
        tm_clk_rst_prstn_sync_en        = 1'b0;
        
        tm_clk_rst_soc_rstn_sync_en     = 1'b0;
        tm_clk_rst_soc_rstn_sync        = 1'b0;
        
        tm_clk_rst_prstn_por_sync       = 1'b0;
        tm_clk_rst_prstn_por_sync_en    = 1'b0;
        
        tm_clk_rst_dbg_rstn_sync        = 1'b0;
        tm_clk_rst_dbg_rstn_sync_en     = 1'b0;

        tm_gpio_prstn_en                = 1'b0    ;
        tm_gpio_prstn                   = 1'b0    ;



    end
end





assign test_mode_clk_peripheral_mux = pll_clk;
assign test_mode_clk_soc_mux        = pll_clk;
assign tm_mem_rc_clk_mux_i          = pll_clk;
assign tm_pll_xtal_clk_mux_i        = pll_clk;
assign tm_dbg_rc_clk_mux_i          = pll_clk;
assign tm_uart_bclk_i               = pll_clk;




//assign       test_mode_soc_rst                  =   1'b0                      ;
//assign       test_mode_soc_rst_en               =   1'b0                      ;
//assign       test_mode_peripheral_rst           =   1'b0                      ;
//assign       test_mode_peripheral_rst_en        =   1'b0                      ; 
//assign       test_mode_debug_rst                =   1'b0                      ;
//assign       test_mode_debug_rst_en             =   1'b0                      ;       
//assign       test_mode_clk_peripheral_mux       =   1'b0                      ;
//assign       test_mode_clk_soc_mux              =   1'b0                      ;
//assign       test_mode_en_peripheral_mux        =   1'b0                      ; 
//assign       test_mode_en_soc_mux               =   1'b0                      ;
//assign       test_mode_div_peripheral           =   1'b0                      ;
//assign       test_mode_div_debug                =   1'b0                      ;
//assign       test_mode_spi_rstn                 =   1'b0                      ;         
//assign       test_mode_spi_rstn_en              =   1'b0                      ; 
//assign       test_mode_uart_rstn_en             =   1'b0                      ; 
//assign       test_mode_uart_rstn                =   1'b0                      ; 
//assign       test_mode_i2c_rstn_en              =   1'b0                      ; 
//assign       test_mode_i2c_rstn                 =   1'b0                      ; 




//--------------------------ALWAYS BLOCK USED TO REGISTER THE SIGNAL WHICH REQUIRED FOR CDC---------------




always_ff@(posedge core_clk or negedge core_rstn)
begin

    if(!core_rstn) begin

        reg_physical_address_inst_mem                   <=      32'd0       ;
        reg_physical_address_data_mem                   <=      32'd0       ;
        reg_mmu_timeout                                 <=      1'd0        ;
        reg_data_memory_page_fault                      <=      1'd0        ;
        reg_data_memory_read_permission_fault           <=      1'd0        ;
        reg_data_memory_write_permission_fault          <=      1'd0        ;
        reg_data_memory_addr_decode_error               <=      1'd0        ;
        reg_data_memory_read_slave_error                <=      1'd0        ;
        reg_data_memory_write_slave_error               <=      1'd0        ;
        reg_instruction_page_fault                      <=      1'd0        ;
        reg_inst_execution_fault                        <=      1'd0        ;
        reg_inst_addr_decode_error                      <=      1'd0        ;
        reg_sync_1_boot_load_en                         <=      1'd0        ;
        reg_sync_2_boot_load_en                         <=      1'd0        ;


    end

    else begin

        reg_physical_address_inst_mem                   <=      mmu_axi_physical_address_inst_mem       ;
        reg_physical_address_data_mem                   <=      mmu_axi_physical_address_data_mem       ;
        reg_mmu_timeout                                 <=      mmu_ptw_timeout                         ;
        reg_data_memory_page_fault                      <=      mem_page_fault                          ;
        reg_data_memory_read_permission_fault           <=      mem_read_permission_fault               ;
        reg_data_memory_write_permission_fault          <=      mem_write_permission_fault              ;
        reg_data_memory_addr_decode_error               <=      req_data_mem_address_decode_error       ;
        reg_data_memory_read_slave_error                <=      data_mem_read_addr_slverr               ;
        reg_data_memory_write_slave_error               <=      data_mem_write_addr_slverr              ;
        reg_instruction_page_fault                      <=      inst_page_fault                         ;
        reg_inst_execution_fault                        <=      instruction_execute_permission_fault    ;
        reg_inst_addr_decode_error                      <=      inst_mem_addr_decode_error              ;
        reg_sync_1_boot_load_en                         <=      boot_load_enable                        ;
        reg_sync_2_boot_load_en                         <=      reg_sync_1_boot_load_en                 ;

    end

end

logic rst_sync_reg0;

always_ff@(posedge rc_clk or negedge rst_for_clk_ctrl)
begin

    if(!rst_for_clk_ctrl) begin
        rst_sync_reg0   <=  1'b0            ;
        rst_sync_reg1   <=  1'b0            ;
    end

    else begin
        rst_sync_reg0   <=  1'b1            ;
        rst_sync_reg1   <=  rst_sync_reg0   ;
    end

end

//assign rst_sync_reg2 = tm_pinaka_rstn_en ? tm_pinaka_rstn : rst_sync_reg1;

CKMUX2D1 i0_CKMUX2D1 (
        .I0(rst_sync_reg1),
        .I1(tm_pinaka_rstn),
        .S(tm_pinaka_rstn_en), // clk_0_clksel_latch | clk_1_clksel_latch),
        .Z(rst_sync_reg2)
        );


/*
    reset_sync i_pinaka_por_rstn_sync (
                                .clk_i(rc_clk),
                                .rstn_i(rst_for_clk_ctrl),
                                .tm_rstn_en_i(tm_pinaka_rstn_en),
                                .tm_rstn_i(tm_pinaka_rstn),
                                .sync_rstn_o(rst_sync_reg2)
                          );
*/


//--------------------------------------------MODULES INSTANTIATIONS---------------------------------------------------




//-------------------------------------CLOCK AND RESET BYBASS MODULE INSTANTIATION--------------------------------                                              




PINAKA_CLK_RST_BYPASS_TOP     clk_rst_bypass_top_instance     (


//                          FROM THE TOP MODULE INPUTS

            .rc_clk_in                          (rc_clk)                                        ,
            .xtal_clk_in                        (xtal_clk)                                      ,
            .pll_clk_in                         (pll_clk)                                       ,
            .por_in                             (power_on_rst)                                  ,
            .pll_lock_done_in                   (pll_lock_done)                                 ,
            .hard_rst_n                         (hard_reset)                                    ,

//                      DFT TEST MODE SIGNALS

            .tm_mem_rc_clk_mux_en_i             (tm_mem_rc_clk_mux_en_i)                        ,
            .tm_mem_rc_clk_mux_i                (tm_mem_rc_clk_mux_i)                           ,
            .tm_pll_xtal_clk_mux_en_i           (tm_pll_xtal_clk_mux_en_i)                      ,
            .tm_pll_xtal_clk_mux_i              (tm_pll_xtal_clk_mux_i)                         ,
            .tm_dbg_rc_clk_mux_en_i             (tm_dbg_rc_clk_mux_en_i)                        ,
            .tm_dbg_rc_clk_mux_i                (tm_dbg_rc_clk_mux_i)                           ,
            .tm_jtag_dbg_pulse_rstn_i           (tm_jtag_dbg_pulse_rstn)                      ,
            .tm_jtag_dbg_pulse_rstn_en_i        (tm_jtag_dbg_pulse_rstn_en)                   ,
            .tm_rc_rstn_sync_i                 (tm_bypass_rc_rstn_sync)                         ,
            .tm_rc_rstn_sync_en_i              (tm_bypass_rc_rstn_sync_en)                      ,
            .tm_xtal_rstn_sync_i               (tm_bypass_xtal_rstn_sync)                       ,
            .tm_xtal_rstn_sync_en_i            (tm_bypass_xtal_rstn_sync_en)                        ,
            .tm_mem_rstn_sync_en_i             (tm_bypass_mem_rstn_sync_en)                    ,
            .tm_mem_rstn_sync_i                (tm_bypass_mem_rstn_sync)                       ,
            .tm_dbg_rstn_sync_en_i             (tm_bypass_dbg_rstn_sync_en)                     ,
            .tm_dbg_rstn_sync_i                (tm_bypass_dbg_rstn_sync)                        ,
            .tm_boot_pulse_rstn_sync_en_i     (tm_bypass_boot_pulse_rstn_sync_en)                       ,
            .tm_boot_pulse_rstn_sync_i        (tm_bypass_boot_pulse_rstn_sync)                          ,
            .tm_pulse_gen_rstn_sync_en_i      (tm_bypass_pulse_gen_rstn_sync_en)                        ,
            .tm_pulse_gen_rstn_sync_i         (tm_bypass_pulse_gen_rstn_sync)                         ,
            .tm_pll_rstn_sync_en_i            (tm_bypass_pll_rstn_sync_en)                      ,
            .tm_pll_rstn_sync_i               (tm_bypass_pll_rstn_sync)                         ,
            .tm_bt_pulse_gen_rstn_i           (tm_bypass_bt_pulse_gen_rstn)                     ,
            .tm_bt_pulse_gen_rstn_en_i        (tm_bypass_bt_pulse_gen_rstn_en)                         ,
            .tm_preboot_analog_rstn           (tm_bypass_preboot_analog_rstn)                          ,
            .tm_preboot_analog_rstn_en_i      (tm_bypass_preboot_analog_rstn_en)                       ,
            .tm_pulse_clk_rst_i               (tm_bypass_pulse_clk_rst),
            .tm_pulse_clk_rst_en_i            (tm_bypass_pulse_clk_rst_en),
 



//                          FROM THE CLK RST CONTROLLER MODULE

            .debug_clk_in                       (debug_clk)                                     ,
            .mem_clk_in                         (core_clk)                                      ,
            .debug_rst_in                       (debug_rstn)                                    ,

//                          FROM THE GPIO MODULE

            .gpio_1_in                          (gpio_boot_gpio1)                               ,
            .gpio_0_in                          (gpio_boot_gpio0)                               ,

//                          TO THE AXI SLAVE WRAPPERS MODULE

            .clk_for_mem_out                    (memory_clk)                                    ,

//                          TO THE DEBUG MODULE & PREBOOT ANALOG REGISTER

            .clk_for_jtag                       (ctrl_bypass_debug_clk)                         ,

//                                  TO THE DEBUG MODULE

            .mux_jtag_debug_pulse_out           (ctrl_bypass_debug_rstn)                        ,

//                          TO THE CLK RST CONTROLLER MODULE

            .clk_for_clk_rst_ctrl               (clk_to_clk_rst_ctrl)                           ,
            .pulse_for_clk_rst_ctrl             (rst_for_clk_ctrl)                              ,

//                          RESET SIGNAL TO THE PREBOOT ANALOG REGISTER

            .preboot_analog_rstn                (preboot_analog_rstn)                           ,

//                          TO THE GPIO PINMUX MODULE

            .pulse_for_top_toprst               (gpio_presetn)                                  ,
            .boot_debug_start1                  (boot_gpio_dbg1)                                ,
            .boot_debug_start2                  (boot_gpio_dbg2)                                ,
            .boot_debug_start3                  (boot_gpio_dbg3)                                ,
            .boot_debug_start4                  (boot_gpio_dbg4)                                ,
            .boot_debug_start5                  (boot_gpio_dbg5)                                ,
            .boot_debug_start6                  (boot_gpio_dbg6)                                ,                               

//                          TO AXI SLAVE WRAPPERS, GPIO AND DEBUG MODULE

            .boot_en_out                        (boot_load_enable)                              

            
                                                )                                               ;



//------------------------------------CLOCK RESET CONTROLLER TOP INSTANTIATION-----------------------




top_clk_rst_ctrl                                #(

            .HARD_RST_COUNTER                   (CLK_RST_CTRL_HARD_RST_COUNT)                   ,
            .RATIO                              (CLK_RST_CTRL_RATIO)   

                                                )
                                                
            clk_rst_ctrl_top_instance           (

//                      FROM THE CLK RST CONTROLLER MODULE

            .pclk_i                             (pclk)                                          ,

//                      FROM THE AXI-APB BRIDGE MODULE

            .paddr_i                            (bridge_peripheral_paddr[7:0])                  ,
            .penable_i                          (bridge_peripheral_penable)                     ,
            .pwrite_i                           (bridge_peripheral_pwrite)                      ,
            .pwdata_i                           ({bridge_peripheral_pwdata[31:30],bridge_peripheral_pwdata[5:0]})                      ,

//                      FROM THE APB PSEL SLAVE WRAPPER MODULE

            .psel_i                             (clk_rst_ctrl_psel)                             ,

//                      TO THE APB PSEL SLAVE WRAPPER MODULE

            .prdata_o                           (clk_rst_ctrl_prdata)                           ,
            .pready_o                           (clk_rst_ctrl_pready)                           ,
            .pslverr_o                          (clk_rst_ctrl_pslverr)                          ,

//                      FROM THE CLK RST BYPASS MODULE

            .sys_clk_i                          (clk_to_clk_rst_ctrl)                           ,
            .por_ni                             (rst_for_clk_ctrl)                              ,
            .mem_clksel_rst_ctrl_i              (boot_load_enable)                              ,

//                          FROM THE TOP INPUT PIN

            .rc_clk_i                           (rc_clk)                                        ,
            .rstn_rc_clk_por_i                  (rst_sync_reg2)                                 ,

//                              FROM THE CORE 

            .debug_clksel_i                     (debug_mode_en)                                 ,

//                              FROM THE WATCHDOG RESET MODULE

            .wdt_rst_scope_i                    (wdt_clk_rst_ctrl_reset_scope)                  ,
            .wdt_rst_req_i                      (wdt_reset)                                     ,

//                              FROM THE DEBUG MODULE

            .non_dbg_rst_req_i                  (debug_clk_ctrl_int_ctrl_ndm_reset)             ,
            
//                  CLK AND RST TO THE CORE AND OTHER CORE RELATED MODULES  

            .clk_soc_o                          (core_clk)                                      ,
            .rstn_soc_sync_o                    (core_rstn)                                     ,

//                  CLK AND RST TO THE PERIPHERALS AND RELATED MODULES

            .clk_per_o                          (pclk)                                          ,                 
            .rstn_peripheral_sync_o             (presetn)                                       ,   

//                  TO THE CLK RST BYPASS MODULE & IP AND CORE TRACE UNIT

            .clk_for_debug_o                    (debug_clk)                                     ,
            .rstn_debug_sync_o                  (debug_rstn)                                    ,

//                              TO THE I2C MODULE

            .rstn_i2c_sync_o                    (i2c_presetn)                                   ,

//                              TO THE UART MODULE

            .rstn_uart_sync_o                   (uart_presetn)                                  ,

//                              TO THE SPI MODULE

            .rstn_spi_sync_o                    (spi_presetn)                                   ,

//              DFT PURPOSE SIGNALS, AS OF KNOW TIED TO 0'S

            .test_mode_soc_rst_i                (test_mode_soc_rst)                             , 
            .test_mode_soc_rst_en_i             (test_mode_soc_rst_en)                          ,

            .test_mode_peripheral_rst_i         (test_mode_peripheral_rst)                      ,
            .test_mode_peripheral_rst_en_i      (test_mode_peripheral_rst_en)                   ,        
            
            .test_mode_debug_rst_i              (test_mode_debug_rst)                           , 
            .test_mode_debug_rst_en_i           (test_mode_debug_rst_en)                        ,

            .test_mode_clk_peripheral_mux_i     (test_mode_clk_peripheral_mux)                  ,   
            .test_mode_clk_soc_mux_i            (test_mode_clk_soc_mux)                         ,   
            
            .test_mode_en_peripheral_mux_i      (test_mode_en_peripheral_mux)                   ,   
            .test_mode_en_soc_mux_i             (test_mode_en_soc_mux)                          ,   

            .test_mode_div_peripheral_i         (test_mode_div_peripheral)                      ,   
            .test_mode_div_debug_i              (test_mode_div_debug)                           ,

            .test_mode_spi_rstn_en_i            (test_mode_spi_rstn_en)                         ,
            .test_mode_spi_rstn_i               (test_mode_spi_rstn)                            ,

            .test_mode_uart_rstn_en_i           (test_mode_uart_rstn_en)                        ,
            .test_mode_uart_rstn_i              (test_mode_uart_rstn)                           ,

            .test_mode_i2c_rstn_en_i            (test_mode_i2c_rstn_en)                         ,
            .test_mode_i2c_rstn_i               (test_mode_i2c_rstn)                            ,

            .tm_clk_rst_prstn_sync_i            (tm_clk_rst_prstn_sync)                         ,
            .tm_clk_rst_prstn_sync_en_i         (tm_clk_rst_prstn_sync_en)                      ,
            
            .tm_clk_rst_soc_rstn_sync_en_i      (tm_clk_rst_soc_rstn_sync_en)                   ,
            .tm_clk_rst_soc_rstn_sync_i         (tm_clk_rst_soc_rstn_sync)                      ,
            
            .tm_clk_rst_prstn_por_sync_i        (tm_clk_rst_prstn_por_sync)                   ,
            .tm_clk_rst_prstn_por_sync_en_i     (tm_clk_rst_prstn_por_sync_en)                  ,
            
            .tm_clk_rst_dbg_rstn_sync_i         (tm_clk_rst_dbg_rstn_sync)                      ,
            .tm_clk_rst_dbg_rstn_sync_en_i      (tm_clk_rst_dbg_rstn_sync_en)



                                                )                                               ;
      


//------------------------------------------DEBUG MODULE INSTANTIATION--------------------------------




debug_module		                            #(

            .PTE_START_ADDR                     (PTE_MIN_ADDRESS)                               ,
            .PTE_END_ADDR                       (PTE_MAX_ADDRESS)                               ,
            .IMEM_START_ADDR                    (INST_MEMORY_MIN_ADDRESS)                       ,
            .IMEM_END_ADDR                      (INST_MEMORY_MAX_ADDRESS)                       ,
            .DMEM_START_ADDR                    (DATA_MEMORY_MIN_ADDRESS)                       ,
            .DMEM_END_ADDR                      (DATA_MEMORY_MAX_ADDRESS)                       ,
            .PREBOOT_REG_START_ADDR             (PREBOOT_REG_START_ADDRESS)                     ,
            .PREBOOT_REG_END_ADDR               (PREBOOT_REG_END_ADDRESS)                       

                                                ) 

                    debug_module_instance		(


//                          FROM THE TOP INPUTS

			.tck					            (TCK)                                           ,
			.trst_n					            (TRSTN)                                         ,
			.tms					            (TMS)                                           ,
			.tdi					            (TDI)                                           ,

//                          TO THE TOP OUTPUT

			.tdo					            (TDO)                                           ,
			
//                      FROM THE CLK RST BYPASS MODULE

			.dbg_clk				            (ctrl_bypass_debug_clk)                         ,
			.dbg_resetn				            (ctrl_bypass_debug_rstn)                        ,
            .boot_load_enable                   (boot_load_enable)                              ,

//                      FROM THE PTE MEMORY WRAPPER MODULE 
                          
			.pte_read_data_out			        (pte_debug_read_data)                           ,
			.pte_read_resp				        (pte_debug_read_resp)                           ,
			.pte_write_resp				        (pte_debug_write_resp)                          , 
			.pte_read_valid                     (pte_debug_read_valid)                          ,
            .pte_write_valid                    (pte_debug_write_valid)                         ,

//                      TO THE PTE MEMORY WRAPPER MODULE

            .pte_valid                          (debug_pte_valid_in)                            ,
            .pte_write_en                       (debug_pte_write_en)                            ,
            .pte_read_en                        (debug_pte_read_en)                             ,
            .pte_address                        (debug_pte_address)                             ,
            .pte_write_data                     (debug_pte_write_data)                          ,

//                      FROM THE AXI MASTER WRAPPER MODULE
                      
            .axi_read_data_out			        (axi_debug_read_data)                           ,
			.axi_read_resp				        (axi_debug_read_resp)                           ,
			.axi_write_resp				        (axi_debug_write_resp)                          ,

//                              FROM THE GLUE LOGIC 

            .axi_read_valid                     (axi_debug_read_valid_in)                       ,
            .axi_write_valid                    (axi_debug_write_valid_in)                      ,

//                      TO THE AXI MASTER WRAPPER MODULE

            .axi_valid                          (debug_axi_req_valid)                           ,
            .axi_write_en                       (debug_axi_write_en)                            ,
            .axi_read_en                        (debug_axi_read_en)                             ,
            .axi_address                        (debug_axi_address_in)                          ,
            .axi_write_data                     (debug_axi_write_data)                          ,
            .axi_byte_enable                    (debug_axi_byte_en)                             ,

//                      FROM THE AXI SLAVE WRAPPER OF INSTRUCTION MEMORY MODULE
                      
            .imem_read_data                     (inst_mem_debug_read_data)                      ,

//                      TO THE AXI SLAVE WRAPPER OF INSTRUCTION MEMORY MODULE

            .imem_valid                         (debug_inst_mem_req_valid)                      ,
            .imem_write_en                      (debug_inst_mem_write_en)                       ,
            .imem_address                       (debug_inst_mem_address_in)                     ,
            .imem_write_data                    (debug_inst_mem_write_data)                     ,

//          FROM THE GLUE LOGIC SELECT READ DATA BETWEEN DATA MEMORY OR PREBOOT ANALOG REGISTER
                      
            .dmem_read_data                     (preboot_dmem_read_data)                        ,

//              VALID SIGNAL TO GLUE LOGIC TO GIVE VALID TO DATA MEMORY OR PREBOOT ANALOG REGISTER    

            .dmem_valid                         (debug_dmem_preboot_valid)                      ,

//                      TO THE AXI SLAVE WRAPPER OF DATA MEMORY MODULE

            .dmem_write_en                      (debug_data_mem_write_en)                       ,
            .dmem_address                       (debug_data_mem_address_in)                     ,
            .dmem_write_data                    (debug_data_mem_write_data)                     ,

//                                  TO THE CORE

			.pb_insn_valid				        (debug_core_pb_valid)                           ,
			.pb_insn				            (debug_core_pb_instruction)                     ,
            .resumereq                          (debug_core_resume_req)                         ,
            .addr_core                          (debug_core_pc_addr)                            ,

//                                  FROM THE CORE 

			.hart_halted				        (core_debug_hart_halted)                        ,
			.hart_reset				            (core_debug_hart_reset)                         ,

//                                 TO THE CSR MODULE 

			.dbg_reg_write				        (debug_csr_write_en)                            ,
			.dbg_reg_wdata				        (debug_csr_write_data)                          ,

//                              TO THE CSR AND CORE MODULE

			.dbg_reg_read				        (debug_csr_gpr_read_en)                         ,
			.dbg_reg_addr				        (debug_csr_gpr_address)                         ,
            .haltreq                            (debug_core_csr_halt_request)                   ,
            .resethaltreq                       (debug_core_csr_reset_halt)                     ,

//                      TO THE CLK AND RST CONTROLLER & INTERRUPT CONTROLLER MODULES

            .ndmreset                           (debug_clk_ctrl_int_ctrl_ndm_reset)             ,

//                      FROM THE GLUE LOGIC SELECT WHICH VALID AND DATA FROM CSR AND GPR

			.dbg_reg_rdata				        (csr_gpr_debug_read_data)                       ,
			.dbg_reg_ready				        (csr_gpr_debug_read_valid)                      ,

//                          TO THE IP DEBUG TRACE MODULE

            .dbg_event_id                       (debug_ip_trace_event)                          ,
            .dbg_event_data                     (debug_ip_trace_data)    

                                                )                                               ;



//-----------------------------------------RISC V BASIC CORE INSTANTIATION---------------------------------------




rv32i_core 	    basic_isa_instance 			    (


//                                  FROM THE CLK RST CONTROLLER MODULE

    		.clk					            (core_clk)					                    ,
    		.rst					            (core_rstn)					                    ,

//      STALL SIGNAL TO CORE WHEN THE CORE REQUESTING DATA FROM MEMORIES STALL UNTIL CORE GETS VALID LOAD OR STORE

			.stall_by_mmu				        (stall_the_core_pipeline) 			            ,

//                      FROM AXI SLAVE WRAPPER OF INSTRUCTION MEMORY MODULE AFTER GLUE LOGIC

			.instruction				        (instruction_to_core) 				            ,

//                          TO THE AXI INSTRUCTION MEMORY WRAPPER

            .axi_inst_read_ready                (core_axi_inst_mem_rready)                      ,

//                                  TO THE MMU MODULE

     		.pc					                (core_mmu_inst_mem_virtual_address)		        ,
   			.data_mem_address			        (core_mmu_data_mem_virtual_address) 		    ,  
            .sfence_flush_o				        (mmu_tlb_flush) 				                ,

//                          TO THE MMU AND AXI MASTER WRAPPER MODULES

			.mem_write_en				        (core_mmu_axi_mem_write_en) 			        ,
			.mem_read_en				        (core_mmu_axi_mem_read_en) 			            ,

//                              TO AXI MASTER WRAPPER SIGNALS MODULE

			.byte_enable				        (core_axi_wstrobe) 				                ,
			.mem_write_data				        (mem_write_data_core) 			                ,
			.awsize					            (core_axi_awsize)			                    ,
            .exception_flush_core_o             (exception_flush)                               ,

//                              FROM THE AXI MASTER WRAPPPER MODULE 

    		.data_from_mem				        (axi_core_mem_read_data) 		                ,

//                              TO THE WATCHDOG TIMER MODULE

            .last_commited_pc                   (core_watchdog_last_commited_pc)                ,
            .last_commit_pc_valid               (core_watchdog_commit_valid)                    ,

//                                  FROM THE CSR MODULE             
			                              
            .csr_read_data_i			        (csr_core_read_data)			                ,
            .mepc_i                             (csr_core_mepc)                                 ,
            .dpc_i                              (csr_core_dpc)                                  ,
            .csr_mtvec_i                        (csr_core_mtvec)                                ,
            .mcause_id_i                        (csr_core_mcause)                               ,
            .mie_i                              (csr_core_int_ctrl_mstatus_mie)                 ,

//                                  TO THE CSR MODULE

            .csr_read_en_o				        (core_csr_read_en)			                    ,
            .csr_write_en_o				        (core_csr_write_en)		                        ,
            .csr_addr_o				            (core_csr_addr)			                        ,
            .csr_write_data_o			        (core_csr_write_data)		                    ,
            .csr_set_bit_o				        (core_csr_set_bit)			                    ,
            .csr_clear_bit_o			        (core_csr_clear_bit)		                    ,
            .e_break_valid_o			        (core_csr_e_break_valid)		                ,
            .mret_valid_o				        (core_csr_mret_valid)                           ,
            .core_to_int_o                      (core_csr_mepc_in)                              ,
            .csr_mcause_write_en_o              (core_csr_mcause_write_en)                      ,  
            .csr_mstatus_mie_clear_o            (core_csr_mstatus_mie_clear)                    ,
            .csr_mstatus_mie_set_o              (core_csr_mstatus_mie_set)                      ,  
            .mepc_write_en_o                    (core_csr_mepc_write_en)                        ,
            .interrupt_valid_o                  (core_csr_interrupt_valid)                      , 
            .dpc_valid_out                      (core_csr_dpc_valid)                            ,
            .dpc_out                            (core_csr_dpc)                                  ,
            .exception_inst_o                   (core_csr_exception_inst)                       ,
            .exception_inst_valid_o             (core_csr_exception_inst_valid)                 ,
            .active_level_priority_o            (core_csr_active_level_priority)                ,
            .trap_id_o                          (core_csr_trap_id)                              ,

//                                  FROM THE DEBUG MODULE   

            .pb_insn_valid_i                    (debug_core_pb_valid)                           ,
            .pb_insn_i                          (debug_core_pb_instruction)                     ,
            .dbg_reg_read_en_i                  (debug_csr_gpr_read_en)                         ,
            .dbg_reg_read_addr_i                ({debug_csr_gpr_address[15:12],debug_csr_gpr_address[4:0]})     ,
            .halt_req_i                         (debug_core_csr_halt_request)                   ,
            .reset_halt_i                       (debug_core_csr_reset_halt)                     ,
            .resume_req_i                       (debug_core_resume_req)                         ,
            .first_pc_i                         (debug_core_pc_addr)                            ,

//                                  TO THE DEBUG SIGNALS                             

            .dbg_reg_read_data_o                (core_debug_read_data)                          ,
            .dbg_reg_read_valid_o               (core_debug_read_valid)                         ,
            .hart_halted_o                      (core_debug_hart_halted)                        ,
            .hart_reset_o                       (core_debug_hart_reset)                         ,

//              TO THE CSR, CLK RST CONTROLLER, AXI SLAVE WRAPPER OF INSTRUCTION MEMORY AND WATCHDOG TIMER
            
            .dbg_mode_o                         (debug_mode_en)                                 ,


            .dbg_mode_axi_csr_o                 (core_inst_mem_csr_int_ctrl_debug_mode_en)      , 

//                              FROM THE INTERRUPT CONTROLLER MODULE

            .int_req_i                          (int_ctrl_core_interrupt_req)                   ,
            .int_id_i                           (int_ctrl_core_current_int_id)                  ,
            .active_level_priority_i            (int_ctrl_core_highest_pending_lvl_pr)          ,

//                                  TO THE INTERRUPT CONTROLLER MODULE

            .eoi_write_valid_o                  (core_int_ctrl_eoi_write_valid)                 ,      
            .eoi_id_o                           (core_int_ctrl_eoi_id)                          ,

//                                  TO THE CORE DEBUG TRACE MODULE

            .it_type_o                          (core_debug_trace_itype)                        ,
            .it_iaddr                           (core_debug_trace_iaddr)                        ,
            .it_cause                           (core_debug_trace_cause)                        , 
            .it_context                         (core_debug_trace_context)                      , 
            .it_ienable_in                      (core_debug_trace_ienable)                      , 
            .it_itype_valid                     (core_debug_trace_itype_valid)                  , 
            .it_first_instrn_valid_in           (core_debug_trace_Ist_instrn_valid)             , 
            .it_delta_addr                      (core_debug_trace_delta_addr)                   , 
            .it_del_adr_valid                   (core_debug_trace_del_adr_valid)


   						 		                )					                            ;



//---------------------------------------INTERRUPT CONTROLLER INSTANTIATION----------------------------------




soc_interrupt_control       interrupt_controller_instance       (


//                      FROM THE CLK RST CONTROLLER MODULE

            .soc_clk				            (core_clk)                                      ,
            .soc_rst				            (core_rstn)                                     ,

//                      FROM THE MMR APB WRAPPER MODULE

            .soc_mmr_write_en_i		            (mmr_int_ctrl_write_en)                         ,
            .soc_mmr_write_addr_i	            (mmr_int_ctrl_write_addr)                       ,
            .soc_mmr_write_data_i	            (mmr_int_ctrl_write_data)                       ,
            .soc_mmr_read_en_i		            (mmr_int_ctrl_read_en)                          ,
            .soc_mmr_read_addr_i		        (mmr_int_ctrl_read_addr)                        ,

//                      TO THE MMR APB WRAPPER MODULE

            .soc_mmr_read_data_o		        (int_ctrl_mmr_read_data)                        ,
            .soc_read_rsp_o                     (int_ctrl_mmr_read_resp)                        ,

//                              FROM THE CORE

            .soc_eoi_valid_i			        (core_int_ctrl_eoi_write_valid)                 ,
            .soc_eoi_id_i			            (core_int_ctrl_eoi_id)                          ,
            .debug_mode_valid_i                 (core_inst_mem_csr_int_ctrl_debug_mode_en)      ,
              
//                          INTERNAL EXCEPTIONS AND FAULTS

            .ext_int0_i			                (wdt_reset)                                     ,	  
            .ext_int1_i			                (mmu_ptw_timeout)                               ,	  
            .ext_int2_i			                (mem_page_fault)                                ,	  
            .ext_int3_i			                (mem_read_permission_fault)                     ,	  
            .ext_int4_i			                (mem_write_permission_fault)                    ,	  
            .ext_int5_i			                (req_data_mem_address_decode_error)             ,	  
            .ext_int6_i			                (data_mem_addr_slverr)                          ,	  
            .ext_int7_i			                (inst_page_fault)                               ,	  
            .ext_int8_i			                (instruction_execute_permission_fault)          ,	  
            .ext_int9_i			                (inst_mem_addr_decode_error)                    ,

//                          EXTERNAL INTERRUPT FROM THE GPIO PINMUX

            .ext_int10_i			            (gpio_int_ctrl_irq[0])                          ,	  
            .ext_int11_i			            (gpio_int_ctrl_irq[1])                          ,	  
            .ext_int12_i			            (gpio_int_ctrl_irq[2])                          ,	  
            .ext_int13_i			            (gpio_int_ctrl_irq[3])                          ,	  
            .ext_int14_i			            (gpio_int_ctrl_irq[4])                          ,	  
            .ext_int15_i			            (gpio_int_ctrl_irq[5])                          ,

//                                      TO THE CORE 

            .interrupt_request_o		        (int_ctrl_core_interrupt_req)                   ,
            .current_int_id_o                   (int_ctrl_core_current_int_id)                  ,
            .highest_pending_lvl_pr_o	        (int_ctrl_core_highest_pending_lvl_pr)          ,

//                                      TO THE CSR MODULE

            .active_lvl_pr_i			        (csr_int_ctrl_active_lvl_pr)                    ,
            .global_int_enable_valid_i	        (csr_core_int_ctrl_mstatus_mie)                 ,
            .global_int_enable_bit_i	        (csr_int_ctrl_global_int_enable_bit)            ,       

//                                      TO THE IP DEBUG TRACE MODULE

            .trace_data_int_o                   (int_ctrl_ip_trace_data)                        ,
            .trace_event_int_o                  (int_ctrl_ip_trace_event)                       

                                  

                                                )                                               ;                                                



//-------------------------------------------CSR MODULE INSTANTIATION-----------------------------------------




soc_csr_top 		 					        #(


			.CSR_ADDR_WIDTH				        (CSR_ADDR_WIDTH)			                    ,
			.DATA_WIDTH				            (CSR_DATA_WIDTH)			                    ,
			.INSTRUCTION_WIDTH			        (CSR_INSTRUCTION_WIDTH)			                ,
			.PC_WIDTH				            (CSR_PC_WIDTH)

								                )

			csr_top_instance			        (

//                              FROM THE CLK RST CONTROLLER MODULE

           .csr_clk				                (core_clk) 					                    ,
           .csr_rstn				            (core_rstn)					                    ,

//                                      TO THE CORE MODULE

           .csr_read_data_o			            (csr_core_read_data)			                ,
           .csr_mepc_o				            (csr_core_mepc)		                            ,
           .csr_mtvec_o				            (csr_core_mtvec)		                        ,
           .csr_mcause_o				        (csr_core_mcause)		                        ,
           .dpc_o					            (csr_core_dpc)		                            ,

//                                  TO THE CORE & INTERRUPT CONTROLLER MODULES

           .mstatus_mie_o				        (csr_core_int_ctrl_mstatus_mie)		            ,

//                                  FROM THE CORE MODULE

           .csr_write_en_in			            (core_csr_write_en)		                        ,   		
           .csr_addr_in				            (core_csr_addr)			                        ,
           .csr_read_en_in				        (core_csr_read_en)			                    ,
           .csr_write_data_in			        (core_csr_write_data)		                    ,		
           .csr_set_bit_in				        (core_csr_set_bit)			                    ,		
           .csr_clear_bit_in			        (core_csr_clear_bit)		                    ,
           .csr_mepc_in				            (core_csr_mepc_in)		                        ,
           .mret_valid_i				        (core_csr_mret_valid) 			                ,
           .ebreak_valid_i				        (core_csr_e_break_valid)		                ,
           .dbg_mode_valid_i			        (core_inst_mem_csr_int_ctrl_debug_mode_en)      ,      
           .interrupt_valid_in			        (core_csr_interrupt_valid) 		                ,	
           .mie_set				                (core_csr_mstatus_mie_set)		                ,	
           .mie_clear				            (core_csr_mstatus_mie_clear)		            ,	
           .csr_mepc_write_valid			    (core_csr_mepc_write_en) 		                ,
           .interrupt_id_write_valid_i		    (core_csr_mcause_write_en)		                ,
           .dpc_valid_i                         (core_csr_dpc_valid)                            ,
           .dpc_i                               (core_csr_dpc)                                  ,
           .mtval_i                             (core_csr_exception_inst)                       ,
           .mtval_write_valid                   (core_csr_exception_inst_valid)                 ,
           .interrupt_code_in			        (core_csr_trap_id)	                            ,
           .interrupt_lvl_pr_i			        (core_csr_active_level_priority)		        ,

//                                      TO THE MMU MODULE

           .satp_mode_o				            (mmu_enable)				                    ,
           .satp_asid_o				            (csr_mmu_current_asid)				            ,
           .satp_ppn_o				            (csr_mmu_base_ppn)				                ,

//                                      FROM THE DEBUG MODULE 

           .dbg_mode_write_en_i			        (debug_csr_write_en)					        ,    
           .dbg_mode_write_data_i			    (debug_csr_write_data)					        ,
           .dbg_mode_csr_addr_i			        (debug_csr_gpr_address)					        ,
           .dbg_mode_read_en_i			        (debug_csr_gpr_read_en)					        ,
           .reset_haltreq_valid_i			    (debug_core_csr_reset_halt)		                ,
           .haltreq_valid_i			            (debug_core_csr_halt_request)		            ,

//                                  TO THE DEBUG MODULE
                                 
           .dbg_mode_read_data_o			    (csr_debug_read_data)					        ,
           .dbg_csr_read_valid_o			    (csr_debug_read_valid)					        ,


//                              TO THE INTERRUPT CONTROLLER MODULE

            .int_active_level_priority_o	    (csr_int_ctrl_active_lvl_pr)	                ,
            .mie_to_int_ctrl_o                  (csr_int_ctrl_global_int_enable_bit)            ,


//                              TO THE CORE TRACE UNIT

            .mtval_o                            (csr_debug_trace_tval)                         


								                )					                            ;



//----------------------------------------------MMU INSTANTIATION-----------------------------------------------




mmu_core 		 					            #(


			.VPN_WIDTH				            (MMU_VPN_WIDTH)				                    ,
			.PPN_WIDTH				            (MMU_PPN_WIDTH)				                    ,
			.ASID_WIDTH				            (MMU_ASID_WIDTH)			                    ,
			.ACCESS_WIDTH				        (MMU_ACCESS_WIDTH)			                    ,
			.L1_ENTRIES				            (MMU_L1_ENTRIES)			                    ,
			.L2_ENTRIES				            (MMU_L2_ENTRIES)			

								                )

			mmu_instance				        (

//                              FROM THE CLK RST CONTROLLER MODULE

			.clk					            (core_clk) 					                    ,
			.rst_n					            (core_rstn) 					                ,

//				                FROM THE CSR MODULE 

			.pt_base_ppn				        (csr_mmu_base_ppn) 				                ,
			.mmu_enable				            (mmu_enable) 				                    ,
			.current_asid				        (csr_mmu_current_asid) 				            ,

//                              FROM THE TOP REGISTER MODULE

			.prefetch_enable			        (mmu_prefetch_enable)                           ,
			.ptw_timeout_enable			        (mmu_ptw_timeout_enable)		                ,

//					            FROM THE CORE MODULE

			.mem_read_en				        (core_mmu_axi_mem_read_en) 			            ,
			.mem_write_en				        (core_mmu_axi_mem_write_en) 			        ,
			.tlb_flush				            (mmu_tlb_flush)      				            ,
            .timeout_flush                      (exception_flush)                               ,
			.i_if_vpn				            (core_mmu_inst_mem_virtual_address[31:12]) 	    ,
			.i_mem_vpn				            (core_mmu_data_mem_virtual_address[31:12]) 	    ,

//                          TO THE AXI SLAVE WRAPPPER OF INSTRUCTION MEMORY MODULE

			.o_if_ppn				            (mmu_ppn_inst_mem_address) 			            ,
			.o_if_hit				            (mmu_instruction_hit) 			                ,

//                          TO THE AXI MASTER WRAPPER MODULE

			.o_mem_ppn				            (mmu_ppn_data_mem_address) 			            ,

//                  USED FOR GLUE LOIC OF ARVALID SIGNAL FOR THE AXI MASTER WRAPPER MODULE

			.o_mem_hit				            (mmu_data_memory_hit) 			                ,

//                      USED FOR GLUE LOGIC TO GIVE NEW REQUST FOR MMU

			.o_mmu_busy				            (mmu_busy)		                                ,

//                            TAKEN FROM THE GLUE LOGIC

			.inst_vpn_req				        (core_mmu_inst_req)				                ,


//				                TO THE PTE MEMORY WRAPPER MODULE
				
			.pte_req_valid				        (mmu_pte_req_valid) 		                    ,
			.pte_req_addr				        (mmu_pte_req_address)		                    ,

//                              FROM THE PTE MEMORY WRAPPER MODULE

			.mem_resp_valid				        (pte_mmu_resp_valid) 		                    ,
			.mem_resp_ppn				        (pte_mmu_read_data[23:4]) 		                ,
			.mem_resp_validbit			        (pte_mmu_read_data[0]) 		                    ,
			.mem_resp_access			        (pte_mmu_read_data[3:1])		                ,
			
//					    TO THE TOP REGISTER MODULE & INTERRUPT CONTROLLER
	
			.ptw_timeout_event			        (mmu_ptw_timeout)		                        ,
			.inst_execute_permission_fault		(instruction_execute_permission_fault) 	        ,
			.mem_read_permission_fault		    (mem_read_permission_fault) 		            ,
			.mem_write_permission_fault		    (mem_write_permission_fault)		            ,
			.inst_page_fault			        (inst_page_fault)			                    ,
			.mem_page_fault				        (mem_page_fault)                                ,

//                                  TO THE IP DEBUG TRACE MODULE

            .mmu_debug_event                    (mmu_ip_trace_event)                            ,
            .mmu_debug_data                     (mmu_ip_trace_data)     


								                )                                               ;

 

//------------------------------------------PAGE TABLE MEMORY INSTANTIATION---------------------------------------




pte_wrapper     pte_wrapper_instance            (


//                              FROM THE CLK RST CONTROLLER MODULE

            .clk                                (core_clk)                                      ,
            .rst_n                              (core_rstn)                                    ,

//                              FROM THE DEBUG MODULE                              
  
            .dbg_valid                          (debug_pte_valid_in)                            ,
            .dbg_addr                           (debug_pte_address)                             ,
            .dbg_write_en                       (debug_pte_write_en)                            ,
            .dbg_wdata                          (debug_pte_write_data)                          ,
            .dbg_read_en                        (debug_pte_read_en)                             ,

//                                  TO THE DEBUG MODULE

            .dbg_write_resp                     (pte_debug_write_resp)                          ,
            .dbg_write_valid                    (pte_debug_write_valid)                         ,
            .dbg_rdata                          (pte_debug_read_data)                           ,
            .dbg_read_resp                      (pte_debug_read_resp)                           ,
            .dbg_read_valid                     (pte_debug_read_valid)                          ,

//                                  FROM THE MMU MODULE

            .ptw_req_valid                      (mmu_pte_req_valid)                             ,
            .ptw_req_addr                       (mmu_pte_req_address)                           ,

//                                  TO THE MMU MODULE

            .ptw_rdata                          (pte_mmu_read_data)                             ,
            .ptw_resp_valid                     (pte_mmu_resp_valid)                            

                                                )                                               ;



//---------------------------------------AXI SLAVE WRAPPER WITH DATA MEMORY INSTANTIATION----------------------------




axi_instmem_wrapper						        #(

			.INST_MEMORY_ADDR_WIDTH				(INST_MEMORY_ADDR_WIDTH)	

								                )
		

			axi_slave_wrapper_inst_mem_instance	(

//                          CLOCK SIGNAL FROM THE CLK RST BYPASS MODULE

			.ACLK					            (memory_clk)					                ,

//                          RESET FROM THE CLK RST CONTROLLER MODULE

			.ARESETN				            (core_rstn)					                    ,

//                              FROM THE CORE 

			.debug_mode_en				        (core_inst_mem_csr_int_ctrl_debug_mode_en)       ,


//------------------------------------------AXI MASTER INTERFACE---------------------------------


//	            		            WRITE ADDRESS CHANNEL

			.AWADDR					            (debug_axi_inst_mem_awaddr)			            ,
			.AWVALID				            (debug_axi_inst_mem_awvalid)		            ,
			.AWREADY				            (debug_axi_inst_mem_awready)		            ,
			
//			                        WRITE DATA CHANNEL

			.WDATA					            (inst_mem_debug_axi_wdata)			            ,
			.WSTRB					            (debug_axi_inst_mem_wstrb)			            ,
			.WVALID					            (inst_mem_debug_axi_wvalid)			            ,
			.WREADY					            (debug_axi_inst_mem_wready)			            ,
			
//		            	            WRITE RESPONSE CHANNEL

			.BRESP					            (inst_mem_debug_axi_bresp)			            ,
			.BVALID					            (inst_mem_debug_axi_bvalid)			            ,
			.BREADY					            (debug_axi_inst_mem_bready)			            ,
			
//	            		            READ ADDRESS CHANNEL

			.debug_ARADDR				        (debug_axi_inst_mem_araddr)			            ,
			.debug_ARVALID				        (debug_axi_inst_mem_arvalid)		            ,
			.debug_ARREADY				        (inst_mem_debug_axi_arready)		            ,
			
//	            		            READ DATA CHANNEL

			.debug_RDATA				        (inst_mem_debug_axi_rdata)			            ,
			.debug_RRESP				        (inst_mem_debug_axi_rresp)			            ,
			.debug_RVALID				        (inst_mem_debug_axi_rvalid)			            ,
			.debug_RREADY				        (debug_axi_inst_mem_rready)			            ,

//----------------------------------------------------------------------------------------------------


//------------------------------CORE READ ONLY INTERFACES----------------------------------------------

//	                                READ ADDRESS CHANNEL		                    

			.core_ARADDR				        (mmu_axi_physical_address_inst_mem)	            ,
			.core_ARVALID				        (inst_mem_req_valid)			                ,
			.core_ARREADY				        (inst_mem_core_axi_arready)			            ,
			
//			                        READ DATA CHANNEL

			.core_RDATA				            (instruction_from_mem)			                ,
			.core_RRESP				            (inst_mem_core_axi_rresp)			            ,
			.core_RVALID				        (inst_mem_core_axi_rvalid)			            ,
			.core_RREADY				        (core_axi_inst_mem_rready)		                ,

//---------------------------------------------------------------------------------------------------------

//                              FROM THE CLK RST BYASS MODULE

            .boot_en                            (boot_load_enable)                              ,

//                              FROM THE DEBUG MODULE       

            .imem_boot_valid                    (debug_inst_mem_req_valid)                      ,
            .imem_boot_we                       (debug_inst_mem_write_en)                       ,
            .imem_boot_addr                     (debug_inst_mem_address_in)                     ,
            .imem_boot_wr_data                  (debug_inst_mem_write_data)                     ,

//                                  TO THE DEBUG MODULE

            .imem_boot_rdata                    (inst_mem_debug_read_data)


								                )					                            ;
                                           


//-----------------------------------AXI MASTER WRAPPER INSTANTIATION OF THE DATA MEMORY------------------------------




axi_wrapper_top 						        #(


			.UART_START_ADDR			        (UART_MIN_ADDRESS)			                    ,
			.UART_END_ADDR				        (UART_MAX_ADDRESS)			                    ,
			
			.SPI_START_ADDR				        (SPI_MIN_ADDRESS)			                    ,
			.SPI_END_ADDR				        (SPI_MAX_ADDRESS)			                    ,
			
			.I2C_START_ADDR				        (I2C_MIN_ADDRESS)			                    ,
			.I2C_END_ADDR				        (I2C_MAX_ADDRESS)			                    ,

            .WATCHDOG_START_ADDR                (WATCHDOG_MIN_ADDRESS)                          ,
            .WATCHDOG_END_ADDR                  (WATCHDOG_MAX_ADDRESS)                          ,

            .CLK_RST_CTRL_START_ADDR            (CLK_RST_CTRL_MIN_ADDRESS)                      ,
            .CLK_RST_CTRL_END_ADDR              (CLK_RST_CTRL_MAX_ADDRESS)                      ,

			.DMEM_START_ADDR			        (DATA_MEMORY_MIN_ADDRESS)		                ,
			.DMEM_END_ADDR				        (DATA_MEMORY_MAX_ADDRESS)		                ,
	
			.IMEM_START_ADDR			        (INST_MEMORY_MIN_ADDRESS)		                ,
			.IMEM_END_ADDR				        (INST_MEMORY_MAX_ADDRESS)		                ,

            .GPIO_REG_START_ADDR                (GPIO_REG_MIN_ADDRESS)                          ,
            .GPIO_REG_END_ADDR                  (GPIO_REG_MAX_ADDRESS)                          ,

            .TOP_REG_START_ADDR                 (TOP_REG_MIN_ADDRESS)                           ,
            .TOP_REG_END_ADDR                   (TOP_REG_MAX_ADDRESS)                           ,

            .MMR_REGISTER_START_ADDR            (MMR_REGISTER_MIN_ADDRESS)                      ,
            .MMR_REGISTER_END_ADDR              (MMR_REGISTER_MAX_ADDRESS)                      ,               

            .ANALOG_REGISTER_START_ADDR         (ANALOG_REGISTER_MIN_ADDRESS)                   ,
            .ANALOG_REGISTER_END_ADDR           (ANALOG_REGISTER_MAX_ADDRESS)                   ,

            .IP_TRACE_START_ADDR                (IP_TRACE_MIN_ADDRESS)                          ,
            .IP_TRACE_END_ADDR                  (IP_TRACE_MAX_ADDRESS)                          ,

            .CORE_TRACE_START_ADDR              (CORE_TRACE_MIN_ADDRESS)                        ,
            .CORE_TRACE_END_ADDR                (CORE_TRACE_MAX_ADDRESS)                        
            

								                )	


		axi_master_wrapper_data_mem_instance    (


//                          FROM THE CLK RST CONTROLLER MODULE

			.clk					            (core_clk)					                    ,
			.rst_n					            (core_rstn)					                    ,

//                      THIS SIGNAL SELECT THE MASTER, 0 FOR CORE AND 1 FOR THE DEBUG MODULE

			.master_select				        (axi_master_select)				                ,

//                              TO THE TOP REGISTER MODULE

            .core_illegal_addr                  (req_data_mem_address_decode_error)             ,
			
//                          REQUEST VALID SIGNAL USING GLUE LOGIC

			.core_valid				            (axi_data_mem_req_valid)			            ,

//						        FROM THE MMU MODULE

			.core_addr				            (mmu_axi_physical_address_data_mem)			    ,

//                                  FROM THE CORE

			.core_write_en				        (core_mmu_axi_mem_write_en)			            ,
			.core_read_en				        (core_mmu_axi_mem_read_en)			            ,
			.core_awsize				        (core_axi_awsize)			                    ,
			.core_wdata				            (mem_write_data_core)			                ,
			.core_byte_en				        (core_axi_wstrobe)				                ,
            .flush                              (exception_flush)                               ,

//                              USED FOR THE GLUE LOGIC 

			.core_read_data				        (axi_core_mem_read_data)		                ,
			.core_read_resp				        (axi_core_rresp)			                    ,
			.core_read_valid_out			    (axi_core_rvalid) 			                    ,
			.core_read_ready_out			    (axi_core_rready) 			                    ,

			.core_write_ready_out			    (axi_core_bready)			                    ,
			.core_write_valid_out			    (axi_core_bvalid) 			                    ,
			.core_write_resp			        (axi_core_bresp)			                    ,

//                              FROM THE DEBUG MODULE   

  			.jtag_addr				            (debug_axi_address_in) 				            ,
   		 	.jtag_read_en				        (debug_axi_read_en)				                ,
   		 	.jtag_write_en				        (debug_axi_write_en) 			                ,   
   		 	.jtag_valid				            (debug_axi_req_valid)			                ,
   		 	.jtag_wdata				            (debug_axi_write_data)			                ,
   		 	.jtag_byte_en				        (debug_axi_byte_en)				                ,

//                              TO THE DEBUG MODULE

   		 	.jtag_read_data				        (axi_debug_read_data)			                ,
   		 	.jtag_read_resp				        (axi_debug_read_resp)			                ,
   		 	.jtag_write_resp			        (axi_debug_write_resp)			                ,
   		 	.jtag_read_valid_out			    (axi_debug_read_valid)			                ,
   		 	.jtag_read_ready_out			    (axi_debug_read_ready)			                ,
   		 	.jtag_write_valid_out			    (axi_debug_write_valid)			                ,
   		 	.jtag_write_ready_out			    (axi_debug_write_ready)			                ,

			
//--------------------------------AXI-ABP BRIDGE INTERFACE-----------------------------------		


//						        WRITE ADDRESS CHANNEL
			
			.bg_axi_awaddr				        (axi_bridge_awaddr)				                ,
			.bg_axi_awvalid				        (axi_bridge_awvalid)		    	            ,
			.bg_axi_awready				        (bridge_axi_awready)			                ,
						
//						        WRITE DATA CHANNEL
			
			.bg_axi_wdata				        (axi_bridge_wdata)				                ,
			.bg_axi_wstrb				        (axi_bridge_wstrb)				                ,
			.bg_axi_wvalid				        (axi_bridge_wvalid)				                ,
			.bg_axi_wready				        (bridge_axi_wready)				                ,
			
//						        WRITE RESPONSE CHANNEL
			
			.bg_axi_bresp				        (bridge_axi_bresp)				                ,
			.bg_axi_bvalid				        (bridge_axi_bvalid)				                ,
			.bg_axi_bready				        (axi_bridge_bready)				                ,
			
//						        READ ADDRESS CHANNEL
			
			.bg_axi_araddr				        (axi_bridge_araddr)				                ,
			.bg_axi_arvalid				        (axi_bridge_arvalid)			                ,
			.bg_axi_arready				        (bridge_axi_arready)			                ,
			
//						        READ DATA CHANNEL
			
			.bg_axi_rdata				        (bridge_axi_rdata)				                ,
			.bg_axi_rresp				        (bridge_axi_rresp)				                ,
			.bg_axi_rvalid				        (bridge_axi_rvalid)				                ,
			.bg_axi_rready				        (axi_bridge_rready)				                ,
            .bg_axi_rlast                       (bridge_axi_rlast)                              ,


//-------------------------------AXI SLAVE WRAPPER OF DATA MEMORY INTERFACE--------------------

//						        WRITE ADDRESS CHANNEL
			
			.dm_axi_awaddr				        (axi_data_mem_awaddr)			                ,
			.dm_axi_awvalid				        (axi_data_mem_awvalid)			                ,
			.dm_axi_awready				        (data_mem_axi_awready)			                ,
			.dm_axi_awsize				        (common_awsize)				                    ,
			
//						        WRITE DATA CHANNEL
			
			.dm_axi_wdata				        (axi_data_mem_wdata)			                ,   
			.dm_axi_wstrb				        (axi_data_mem_wstrb)			                ,
			.dm_axi_wvalid				        (axi_data_mem_wvalid)			                ,
			.dm_axi_wready				        (data_mem_axi_wready)			                ,
			
//						        WRITE RESPONSE CHANNEL
			
			.dm_axi_bresp				        (data_mem_axi_bresp)			                ,
			.dm_axi_bvalid				        (data_mem_axi_bvalid)			                ,
			.dm_axi_bready				        (axi_data_mem_bready)			                ,
			
//					            READ ADDRESS CHANNEL
			
			.dm_axi_araddr				        (axi_data_mem_araddr)			                ,
			.dm_axi_arvalid				        (axi_data_mem_arvalid)			                ,
			.dm_axi_arready				        (data_mem_axi_arready)			                ,
			
//						        READ DATA CHANNEL
			
			.dm_axi_rdata				        (data_mem_axi_rdata)			                ,
			.dm_axi_rresp				        (data_mem_axi_rrsep)			                ,
			.dm_axi_rvalid				        (data_mem_axi_rvalid)			                ,
			.dm_axi_rready				        (axi_data_mem_rready)			                ,


//----------------------------AXI SLAVE WRAPPER OF INSTRUCTION MEMORY INTERFACE---------------------


//                              WRITE ADDRESS CHANNEL

			.im_axi_awaddr				        (debug_axi_inst_mem_awaddr)			            ,
			.im_axi_awvalid				        (debug_axi_inst_mem_awvalid)		            ,
			.im_axi_awready				        (debug_axi_inst_mem_awready)		            ,
						
//                              WRITE DATA CHANNEL

			.im_axi_wdata				        (inst_mem_debug_axi_wdata)			            ,
			.im_axi_wstrb				        (debug_axi_inst_mem_wstrb)			            ,
			.im_axi_wvalid				        (inst_mem_debug_axi_wvalid)			            ,
			.im_axi_wready				        (debug_axi_inst_mem_wready)			            ,
			
//          			        WRITE RESPONSE CHANNEL

			.im_axi_bresp				        (inst_mem_debug_axi_bresp)			            ,
			.im_axi_bvalid				        (inst_mem_debug_axi_bvalid)			            ,
			.im_axi_bready				        (debug_axi_inst_mem_bready)			            ,
			
//          	                READ ADDRESS CHANNEL

			.im_axi_araddr				        (debug_axi_inst_mem_araddr)			            ,
			.im_axi_arvalid				        (debug_axi_inst_mem_arvalid)		            ,
			.im_axi_arready				        (inst_mem_debug_axi_arready)		            ,
			
//          			        READ DATA CHANNEL

			.im_axi_rdata				        (inst_mem_debug_axi_rdata)			            ,
			.im_axi_rresp				        (inst_mem_debug_axi_rresp)			            ,
			.im_axi_rvalid				        (inst_mem_debug_axi_rvalid)			            ,
			.im_axi_rready				        (debug_axi_inst_mem_rready)			

	
								                )					                            ;



//------------------------------------AXI SLAVE WRAPPER WITH DATA MEMORY INSTANTIATION-----------------------------




axi_datamem_wrapper						        #(

			.DATA_MEMORY_ADDR_WIDTH				(DATA_MEMORY_ADDR_WIDTH)		

								                )
		

			axi_slave_wrapper_data_mem_instance	(


//                          FROM THE CLK RST BYPASS MODULE

			.ACLK					            (memory_clk)					                ,

//                          FROM THE CLK RST CONTROLLER MODULE

			.ARESETN				            (core_rstn)					                    ,
			
//----------------------------------AXI INTERFACE------------------------------------------------

//                          WRITE ADDRESS CANNEL

			.AWADDR					            (axi_data_mem_awaddr)			                ,
			.AWVALID				            (axi_data_mem_awvalid)			                ,
			.AWREADY				            (data_mem_axi_awready)			                ,
			
//			                WRITE DATA CHANNEL
    
			.WDATA					            (axi_data_mem_wdata)			                ,
			.WSTRB					            (axi_data_mem_wstrb)			                ,
			.WVALID					            (axi_data_mem_wvalid)			                ,
			.WREADY					            (data_mem_axi_wready)			                ,
			
//              		    WRITE RESPONSE CHANNEL

			.BRESP					            (data_mem_axi_bresp)			                ,
			.BVALID					            (data_mem_axi_bvalid)			                ,
			.BREADY					            (axi_data_mem_bready)			                ,
			
//              	        READ ADDRESS CHANNEL

			.ARADDR					            (axi_data_mem_araddr)			                ,
			.ARVALID				            (axi_data_mem_arvalid)			                ,
			.ARREADY				            (data_mem_axi_arready)			                ,
			
//              	        READ DATA CHANNEL

			.RDATA					            (data_mem_axi_rdata)			                ,
			.RRESP					            (data_mem_axi_rrsep)			                ,
			.RVALID					            (data_mem_axi_rvalid)			                ,
			.RREADY					            (axi_data_mem_rready)                           ,

//                          FROM THE CLK RST BYPASS MODULE

            .boot_en                            (boot_load_enable)                              ,

//                              FROM THE DEBUG MODULE

            .dmem_boot_valid                    (debug_data_mem_req_valid)                      ,
            .dmem_boot_we                       (debug_data_mem_write_en)                       ,
            .dmem_boot_addr                     (debug_data_mem_address_in)                     ,
            .dmem_boot_wr_data                  (debug_data_mem_write_data)                     ,

//                              TO THE DEBUG MODULE

            .dmem_boot_rdata                    (data_mem_debug_read_data)                      
			

							                	)                                               ;



//----------------------------------------AXI TO APB BRIDGE INSTANTIATION---------------------------------------




top_bridge 							            #(

			.FIFO_DEPTH				            (BRIDGE_FIFO_DEPTH)			                    ,
			.ADDR_WIDTH				            (AXI_ADDR_WIDTH)			                    ,
			.DATA_WIDTH				            (AXI_DATA_WIDTH)			                    ,
			.STRB_WIDTH				            (STROBE_WIDTH)				                    ,
			.FIFO_WIDTH				            (BRIDGE_FIFO_WIDTH) 			                ,
			.TIMEOUT_CNT_WIDTH			        (APB_TIMEOUT_COUNT_WIDTH)		                ,
			.TIMEOUT_VALUE				        (APB_TIMEOUT_VALUE)			

								                )
	
			axi2apb_instance			        (

//                      FROM THE CLK RST CONTROLLER MODULE

			.pclk				            	(pclk)					                        ,
			.aclk					            (core_clk)					                    ,
			.resetn					            (core_rstn)					                    ,
// ----------------------------DFT TEST SIGNALS -----------------------------------------------

            .tm_bridge_prstn_sync_en_i               (tm_bridge_prstn_sync_en)                          ,
			.tm_bridge_prstn_sync_i                  (tm_bridge_prstn_sync)                             ,

//--------------------------------------AXI INTERFACE SIGNALS--------------------------------- 


//                              WRITE ADDRESS CHANNEL

			.awvalid				            (axi_bridge_awvalid)			                ,
			.awaddr					            (axi_bridge_awaddr)				                ,
			.awlen					            (8'd0)					                        ,
			.awsize					            (common_awsize)				                    ,
			.awburst				            (FIXED)					                        ,
			.awready				            (bridge_axi_awready)			                ,
			
//			                    WRITE DATA CHANNEL
			            
			.wvalid					            (axi_bridge_wvalid)				                ,
			.wdata					            (axi_bridge_wdata)				                ,
			.wstrb					            (axi_bridge_wstrb)				                ,
			.wlast					            (1'd1)					                        ,
			.wready					            (bridge_axi_wready)				                ,
			
//          			        WRITE RESPONSE CHANNEL 
    
			.bready					            (axi_bridge_bready)				                ,
			.bresp					            (bridge_axi_bresp)				                ,
			.bvalid					            (bridge_axi_bvalid)				                ,
			
//          			        READ ADDRESS CHANNEL

			.arvalid				            (axi_bridge_arvalid)			                ,
			.araddr					            (axi_bridge_araddr)				                ,
			.arlen					            (8'd0)					                        ,
			.arsize					            (3'b010)				                        ,
			.arburst				            (FIXED)					                        ,
			.arready				            (bridge_axi_arready)			                ,
			
//			                    READ DATA CHANNEL 

			.rready					            (axi_bridge_rready)				                ,
			.rvalid					            (bridge_axi_rvalid)				                ,
			.rdata					            (bridge_axi_rdata)				                ,
			.rresp					            (bridge_axi_rresp)				                ,
			.rlast					            (bridge_axi_rlast)				                ,
			
//              	            APB INTERFACE 

			.pwdata					            (bridge_peripheral_pwdata)				        ,
			.penable				            (bridge_peripheral_penable)			            ,
			.pwrite					            (bridge_peripheral_pwrite)				        ,

//                              TO THE APB PSEL SLAVE WRAPPER MODULE

			.psel					            (bridge_peripheral_psel)				        ,
			.paddr					            (bridge_peripheral_paddr)				        ,

//                              FROM THE APB PSEL SLAVE WRAPPER MODULE

			.pready					            (peripheral_bridge_pready)				        ,
			.prdata					            (peripheral_bridge_prdata)				        ,
			.pslverr				            (peripheral_bridge_pslverr)                     ,

//                              TO THE IP DEBUG TRACE MODULE

            .trace_id_o                         (bridge_ip_trace_event)                         ,
            .trace_data_o                       (bridge_ip_trace_data)      



								                )					                            ;



//--------------------------------------APB SLAVE PSEL WRAPPER INSTANTIATION--------------------------------------------




apb_slave_psel_wrapper						    #(

			.I2C_MIN_ADDRESS			        (I2C_MIN_ADDRESS) 			                    ,
			.I2C_MAX_ADDRESS			        (I2C_MAX_ADDRESS) 			                    ,
			.SPI_MIN_ADDRESS			        (SPI_MIN_ADDRESS) 			                    ,
			.SPI_MAX_ADDRESS			        (SPI_MAX_ADDRESS) 			                    ,
			.UART_MIN_ADDRESS			        (UART_MIN_ADDRESS)			                    ,
			.UART_MAX_ADDRESS			        (UART_MAX_ADDRESS)                              ,
            .WATCHDOG_MIN_ADDRESS               (WATCHDOG_MIN_ADDRESS)                          ,
            .WATCHDOG_MAX_ADDRESS               (WATCHDOG_MAX_ADDRESS)                          ,
            .CLK_RST_CTRL_MIN_ADDRESS           (CLK_RST_CTRL_MIN_ADDRESS)                      ,
            .CLK_RST_CTRL_MAX_ADDRESS           (CLK_RST_CTRL_MAX_ADDRESS)                      ,
            .TOP_REG_MAX_ADDRESS                (TOP_REG_MAX_ADDRESS)                           ,
            .TOP_REG_MIN_ADDRESS                (TOP_REG_MIN_ADDRESS)                           ,
            .GPIO_REG_MAX_ADDRESS               (GPIO_REG_MAX_ADDRESS)                          ,
            .GPIO_REG_MIN_ADDRESS               (GPIO_REG_MIN_ADDRESS)                          ,
            .MMR_REGISTER_MIN_ADDRESS           (MMR_REGISTER_MIN_ADDRESS)                      ,
            .MMR_REGISTER_MAX_ADDRESS           (MMR_REGISTER_MAX_ADDRESS)                      ,                   
            .ANALOG_REGISTER_MIN_ADDRESS        (ANALOG_REGISTER_MIN_ADDRESS)                   ,
            .ANALOG_REGISTER_MAX_ADDRESS        (ANALOG_REGISTER_MAX_ADDRESS)                   ,
            .IP_TRACE_MIN_ADDRESS               (IP_TRACE_MIN_ADDRESS)                          ,
            .IP_TRACE_MAX_ADDRESS               (IP_TRACE_MAX_ADDRESS)                          ,         
            .CORE_TRACE_MIN_ADDRESS             (CORE_TRACE_MIN_ADDRESS)                        ,
            .CORE_TRACE_MAX_ADDRESS             (CORE_TRACE_MAX_ADDRESS)                                 

								                )

			apb_wrapper_instance			    (


//                          FROM THE AXI-APB BRIDGE MODULE

			.psel					            (bridge_peripheral_psel)				        ,
			.paddr					            (bridge_peripheral_paddr) 				        ,

//                          TO THE AXI_APB BRIDGE MODULE

			.pready					            (peripheral_bridge_pready) 			            ,
			.pslverr				            (peripheral_bridge_pslverr) 			        ,
			.prdata					            (peripheral_bridge_prdata) 			            ,

//                          PRDATA SIGNALS FROM DIFFERENT PERIPHERALS

			.I2C_prdata				            (i2c_prdata) 				                    ,
			.SPI_prdata				            (spi_prdata)				                    ,
			.UART_prdata				        (uart_prdata)				                    ,
            .watchdog_prdata                    (watchdog_prdata)                               ,
            .clk_rst_ctrl_prdata                (clk_rst_ctrl_prdata)                           ,
            .top_reg_prdata                     (top_reg_prdata)                                ,
            .gpio_reg_prdata                    (gpio_reg_prdata)                               ,
            .mmr_reg_prdata                     (mmr_reg_prdata)                                ,
            .analog_reg_prdata                  (analog_reg_prdata)                             ,
            .ip_trace_prdata                    (ip_trace_prdata)                               ,
            .core_trace_prdata                  (core_trace_prdata)                             ,

//                          PREADY SIGNALS FROM DIFFERENT PERIPHERALS    

			.I2C_pready				            (i2c_pready)				                    ,
			.SPI_pready				            (spi_pready) 				                    ,
			.UART_pready				        (uart_pready)				                    ,
            .watchdog_pready                    (watchdog_pready)                               ,
            .clk_rst_ctrl_pready                (clk_rst_ctrl_pready)                           ,
            .top_reg_pready                     (top_reg_pready)                                ,
            .gpio_reg_pready                    (gpio_reg_pready)                               ,
            .mmr_reg_pready                     (mmr_reg_pready)                                ,
            .analog_reg_pready                  (analog_reg_pready)                             ,
            .ip_trace_pready                    (ip_trace_pready)                               ,
            .core_trace_pready                  (core_trace_pready)                             ,

//                          PSLVERR SIGNALS FROM DIFFERENT PERIPHERALS     

			.I2C_pslverr				        (i2c_pslverr) 				                    ,
			.SPI_pslverr				        (spi_pslverr) 				                    ,
			.UART_pslverr				        (uart_pslverr) 				                    ,
            .watchdog_pslverr                   (watchdog_pslverr)                              ,
            .clk_rst_ctrl_pslverr               (clk_rst_ctrl_pslverr)                          ,
            .top_reg_pslverr                    (top_reg_pslverr)                               ,
            .gpio_reg_pslverr                   (gpio_reg_pslverr)                              ,
            .mmr_reg_pslverr                    (mmr_reg_pslverr)                               ,
            .analog_reg_pslverr                 (analog_reg_pslverr)                            ,
            .ip_trace_pslverr                   (ip_trace_pslverr)                              ,
            .core_trace_pslverr                 (core_trace_pslverr)                            , 

//                          PSEL SIGNALS TO DIFFERENT PERIPHERALS  

			.I2C_psel				            (i2c_psel) 				                        ,
			.SPI_psel				            (spi_psel) 				                        ,
			.UART_psel				            (uart_psel)                                     ,
            .watchdog_psel                      (watchdog_psel)                                 ,
            .clk_rst_ctrl_psel                  (clk_rst_ctrl_psel)                             ,
            .top_reg_psel                       (top_reg_psel)                                  ,
            .gpio_reg_psel                      (gpio_reg_psel)                                 ,
            .mmr_reg_psel                       (mmr_reg_psel)                                  ,
            .analog_reg_psel                    (analog_reg_psel)                               ,
            .ip_trace_psel                      (ip_trace_psel)                                 ,
            .core_trace_psel                    (core_trace_psel)   


								                )	                                            ;



//-------------------------------------I2C WITH APB INTERFACE INSTANTIATION---------------------------------------------




i2c_wrapper 							        #(

			.ADDR_WIDTH				            (I2C_ADDR_WIDTH)			                    ,
  			.DATA_WIDTH				            (I2C_DATA_WIDTH)

								                )

			i2c_wrapper_instance			    (		
						

//              	        FROM THE CLK RST CONTROLLER MODULE

   			.pclk					            (pclk)					                        ,
    		.presetn				            (i2c_presetn)					                ,

//                          FROM THE AXI-APB BRIDGE MODULE

    		.paddr					            (bridge_peripheral_paddr[I2C_ADDR_WIDTH-1:0])	,
            .penable				            (bridge_peripheral_penable)			            ,
   			.pwrite					            (bridge_peripheral_pwrite)				        ,
   			.pwdata					            (bridge_peripheral_pwdata[I2C_DATA_WIDTH-1:0])	,

//                         FROM THE APB PSEL SLAVE WRAPPER MODULE

    		.psel					            (i2c_psel)				                        ,

//                          TO THE APB PSEL SLAVE WRAPPER MODULE

   			.prdata					            (i2c_prdata)				                    ,
  		    .pready					            (i2c_pready)				                    ,
    		.pslverr				            (i2c_pslverr)				                    ,

//      			        FROM GPIO PINMUX MODULE
      				    
            .sda_in                             (i2c_sda_in)                                    ,

//                          TO GPIO PINMUX MODULE

            .scl					            (i2c_scl)                                       ,
		    .sda_out					        (i2c_sda_out)				                    , 
            .sda_en                             (i2c_sda_oe)                                    ,

//                          TO THE IP DEBUG TRACE MODULE

            .trace_event_o                      (i2c_ip_trace_event)                            ,
            .trace_data_o                       (i2c_ip_trace_data)
			

								                )                                               ;



//--------------------------------------SPI WITH APB SLAVE INSTANTIATION---------------------------------------------




spi_wrapper 							        #(

			.ADDR_WIDTH				            (SPI_ADDR_WIDTH)			                    ,
			.DATA_WIDTH				            (SPI_DATA_WIDTH)			                    

								                )

			spi_wrapper_instance			    (


//          		            FROM THE CLK RST CONTROLLER MODULE

			.pclk					            (pclk)					                        ,
			.presetn				            (spi_presetn)					                ,

//                              FROM THE AXI-APB BRIDGE MODULE

			.paddr					            (bridge_peripheral_paddr[SPI_ADDR_WIDTH-1:0])	,
			.penable				            (bridge_peripheral_penable)			            ,
			.pwrite					            (bridge_peripheral_pwrite)				        ,
			.pwdata					            (bridge_peripheral_pwdata[SPI_DATA_WIDTH-1:0])	,

//                              FROM THE APB PSEL SLAVE WRAPPER MODULE

			.psel					            (spi_psel)				                        ,

//                              TO THE APB PSEL SLAVE WRAPPER MODULE

			.prdata					            (spi_prdata)				                    ,
			.pready					            (spi_pready)				                    ,
			.pslverr				            (spi_pslverr)				                    ,

//                                  TO THE IP TRACE MODULE

            .trace_event                        (spi_ip_trace_event)                            ,
            .trace_debug                        (spi_ip_trace_data)                             ,

//              			    FROM THE GPIO PINMUX MODULE
              			
			.miso					            (spi_miso)				                        ,

//                              TO THE GPIO PINMUX MODULE

			.mosi					            (spi_mosi)				                        ,
			.sclk					            (spi_sclk)				                        ,
			.ss					                (spi_ss)

								                )					                            ;



//---------------------------------------UART WITH APB SLAVE INSTANTIATION----------------------------------------------




uart_top 	uart_wrapper_instance			    (

//                          FROM THE CLK RST CONTROLLER MODULE

			.pclk					            (pclk)					                        ,         
			.presetn				            (uart_presetn)					                ,

//                          DFT TEST MODE SIGNALS

            .tm_clk_i                           (tm_uart_bclk_i)                                ,
            .tm_en_i                            (tm_uart_bclk_en_i)                             ,
            .tm_uart_brstn_en_i                 (tm_uart_brstn_en)                              ,
            .tm_uart_brstn_i                      (tm_uart_brstn)                                 ,

//                          FROM THE AXI-APB BRIDGE MODULE

			.paddr					            (bridge_peripheral_paddr[7:0])	                ,
			.penable				            (bridge_peripheral_penable) 			        ,
			.pwrite					            (bridge_peripheral_pwrite)				        ,
			.pwdata					            (bridge_peripheral_pwdata[7:0])	                ,

//                          FROM THE APB PSEL SLAVE WRAPPER MODULE

			.psel					            (uart_psel)				                        ,

//                          TO THE APB PSEL SLAVE WRAPPER MODULE

			.prdata					            (uart_prdata)				                    ,
			.pready					            (uart_pready)				                    ,
			.pslverr				            (uart_pslverr)                                  ,

//                          FROM THE GPIO PINMUX MODULE

            .rx					                (uart_rx)				                        ,

//                          TO THE GPIO PINMUX MODULE

			.tx_out					            (uart_tx)	                                    ,

//                          TO THE IP DEBUG TRACE MODULE

            .dbg_event_id                       (uart_ip_trace_event)                           ,
            .dbg_payload                        (uart_ip_trace_data)        


								                )			                            		;



//-------------------------------------WATCHDOG TIMER MODULE INSTANTIATION------------------------------------- 




watchdog_timer  watchdog_timer_instance         (
    

//                      FROM THE CLK RST CONTROLLER MODULE

            .pclk                               (pclk)                                          ,
            .presetn                            (presetn)                                       ,

//                      FROM THE AXI-APB BRIDGE MODULE

            .penable                            (bridge_peripheral_penable)                     ,
            .pwrite                             (bridge_peripheral_pwrite)                      ,
            .paddr                              (bridge_peripheral_paddr[7:0])                  ,
            .pwdata                             (bridge_peripheral_pwdata)                      ,

//                      FROM THE APB PSEL SLAVE WRAPPER MODULE

            .psel                               (watchdog_psel)                                 ,

//                      TO THE APB PSEL SLAVE WRAPPER MODULE

            .prdata                             (watchdog_prdata)                               ,
            .pready                             (watchdog_pready)                               ,
            .pslverr                            (watchdog_pslverr)                              ,

//                          WATCHDOG CLK AND RST SIGNALS

            .wdt_clk                            (rc_clk)                                        ,
            .wdt_rstn                           (rst_sync_reg2)                                 ,

//                              FROM THE CORE 

            .cpu_dbg_halt                       (debug_mode_en)                                 ,
            .cpu_commit_pc                      (core_watchdog_last_commited_pc)                ,
            .cpu_commit_valid                   (core_watchdog_commit_valid)                    ,

//                              TO THE INTERRUPT CONTROLLER AND CLK RST TOP MODULES
                              
            .wdt_reset                          (wdt_reset)                                     ,

//                              TO THE CLK RST CONTROLLER MODULE

            .reset_scope                        (wdt_clk_rst_ctrl_reset_scope)                  ,

//                              TO THE IP DEBUG TRACE

            .trace_event_id                     (wdt_ip_trace_event)                            ,
            .trace_data                         (wdt_ip_trace_data)             

                                                )                                               ;
                       


//----------------------------------------GPIO PINMUX INSTANTIATION-------------------------------------




gpio_top_regfile    gpio_top_reg_instance       (
    
     
//                      FROM THE CLK RST CONTROLLER MODULE

            .pclk                               (pclk)                                          ,
            .clk_out_w                          (debug_clk)                                     ,
            .atclk_w                            (debug_clk)                                     ,

// ----------------- DFT TEST SIGNALS -----------------------------------------------------------
            .tm_gpio_prstn_i                    (tm_gpio_prstn)                                 ,
            .tm_gpio_prstn_en_i                 (tm_gpio_prstn_en)                              ,


//                      FROM THE CLK RST BYPASS MODULE

            .presetn                            (gpio_presetn)                                  ,   

//                      FROM THE AXI-APB BRIDGE MODULE

            .paddr                              (bridge_peripheral_paddr[7:0])                  ,
            .pwrite                             (bridge_peripheral_pwrite)                      ,
            .pwdata                             (bridge_peripheral_pwdata)                      ,            
            .penable                            (bridge_peripheral_penable)                     ,

//                      FROM THE APB PSEL SLAVE WRAPPER MODULE

            .psel                               (gpio_reg_psel)                                 ,   

//                      TO THE APB PSEL SLAVE WRAPPEER MODULE

            .prdata                             (gpio_reg_prdata)                               ,
            .pready                             (gpio_reg_pready)                               ,
            .pslverr                            (gpio_reg_pslverr)                              ,

//                              FROM THE TOP INPUT PINS

            .gpio_pad_in_w                      (gpio_pad_in)                                   ,

//                              TO THE TOP OUTPUT PINS

            .gpio_pad_out_w                     (gpio_pad_out)                                  ,
            .gpio_pad_oe_w                      (gpio_pad_oe)                                   ,
            .gpio_pull_en_out_w                 (gpio_pull_en_out)                              ,

//                          TO THE CLK RST CONTROLLER MODULE

            .pll_clk_fail_out                   (gpio_boot_gpio0)                               ,
            .boot_load_done_out                 (gpio_boot_gpio1)                               ,

//                          FROM THE UART PERIPHERAL 

            .uart_tx_w                          (uart_tx)                                       ,

//                          FROM THE SPI PERIPHERAL

            .spi_cs_w                           (spi_ss)                                        ,
            .spi_clk_w                          (spi_sclk)                                      ,
            .spi_mosi_w                         (spi_mosi)                                      ,
            
//                          FROM THE I2C PERIPHERAL

            .i2c_scl_w                          (i2c_scl)                                       ,
            .i2c_sda_oe_w                       (i2c_sda_oe)                                    ,
            .i2c_sda_in_w                       (i2c_sda_out)                                   ,

//                          TO THE UART PERIPHERAL

            .uart_rx_w                          (uart_rx)                                       ,

//                          TO THE SPI PERIPHERAL

            .spi_miso_w                         (spi_miso)                                      ,

//                          TO THE I2C PERIPHERAL

            .i2c_sda_out_w                      (i2c_sda_in)                                    ,

//                          FROM THE TOP INPUT PINS

            .ana2dig_dbg1_w                     (analog_2_digital_dbg_1)                        ,             
            .ana2dig_dbg2_w                     (analog_2_digital_dbg_2)                        ,
            .ana2dig_dbg3_w                     (analog_2_digital_dbg_3)                        ,
            .ana2dig_dbg4_w                     (analog_2_digital_dbg_4)                        ,
            .ana2dig_dbg5_w                     (analog_2_digital_dbg_5)                        ,
            .ana2dig_dbg6_w                     (analog_2_digital_dbg_6)                        ,

//                          FROM THE CLK RST BYPASSS MODULE

            .boot_dbg1_w                        (boot_gpio_dbg1)                                ,
            .boot_dbg2_w                        (boot_gpio_dbg2)                                ,
            .boot_dbg3_w                        (boot_gpio_dbg3)                                ,
            .boot_dbg4_w                        (boot_gpio_dbg4)                                ,
            .boot_dbg5_w                        (boot_gpio_dbg5)                                ,
            .boot_dbg6_w                        (boot_gpio_dbg6)                                ,

//                              FROM THE IP DEBUG TRACE MODULE

            .debug_w                            (ip_trace_gpio_dgb_data)                        ,
            .dob_valid_w                        (ip_trace_gpio_dbg_valid)                       ,
            .dob_trigger_w                      (ip_trace_gpio_dbg_trigger)                     ,

//                              TO THE CORE DEBUG TRACE MODULE                

            .afvalid_w                          (gpio_core_trace_afvalid)                       ,
            .atready_w                          (gpio_core_trace_atready)                       ,

//                              FROM THE CORE DEBUG TRACE MODULE

            .atdata_w                           (core_trace_gpio_atdata)                        ,
            .atvalid_w                          (core_trace_gpio_atvalid)                       ,
            .afready_w                          (core_trace_gpio_afready)                       ,

//                              TO THE INTERRUPT CONTRROLLER MODULE

            .irq_in_w                           (gpio_int_ctrl_irq)                             ,
            
// DFT gpio's for scan insertion            
            .test_mode_w    (Test_mode),
            .scan_in_1_w    (scan_in_1),
            .scan_in_2_w    (scan_in_2),
            .scan_in_3_w    (scan_in_3),
            .scan_in_4_w    (scan_in_4),
            .scan_in_5_w    (scan_in_5),
            .scan_in_6_w    (scan_in_6),
 
            .scan_out_1_w    (scan_out_1),
            .scan_out_2_w    (scan_out_2),
            .scan_out_3_w    (scan_out_3),
            .scan_out_4_w    (scan_out_4),
            .scan_out_5_w    (scan_out_5),
            .scan_out_6_w    (scan_out_6),
            .scan_enable_w     (scan_enable)
    
                                                )                                               ;



//-----------------------------------------TOP REGISTER INSTANTIATION-------------------------------




top_register_cdc    top_register_instance       (

//                              FROM THE CLK RST CONTROLLER MODULE

            .pclk                               (pclk)                                          ,
            .presetn                            (presetn)                                       ,

            .sys_clk                            (core_clk)                                      ,
            .sys_rst_n                          (core_rstn)                                     ,

//                              FROM THE AXI-APB BRIDGE MODULE

            .paddr                              (bridge_peripheral_paddr[7:0])                  ,
            .penable                            (bridge_peripheral_penable)                     ,
            .pwrite                             (bridge_peripheral_pwrite)                      ,
            .pwdata                             (bridge_peripheral_pwdata)                      ,

//                              FROM THE APB PSEL SLAVE WRAPPER MODULE

            .psel                               (top_reg_psel)                                  ,

//                              TO THE APB PSEL SLAVE WRAPPER MODULE 

            .prdata                             (top_reg_prdata)                                ,
            .pready                             (top_reg_pready)                                ,
            .pslverr                            (top_reg_pslverr)                               ,

//                                  FROM THE MMU MODULE AFTER REGISTERED

            .ptw_timeout_event                  (reg_mmu_timeout)                               ,
            .instr_page_fault                   (reg_instruction_page_fault)                    ,
            .mem_page_fault                     (reg_data_memory_page_fault)                    ,
            .instr_permission_fault             (reg_inst_execution_fault)                      ,
            .read_permission_fault              (reg_data_memory_read_permission_fault)         ,
            .write_permission_fault             (reg_data_memory_write_permission_fault)        ,
            .addr_error                         (reg_physical_address_data_mem)                 ,
            .captured_instr_error_pc            (reg_physical_address_inst_mem)                 , 

//                              TO THE MMU MODULE

            .pre_fetch_en                       (mmu_prefetch_enable)                           ,
            .mmu_timeout_enable                 (mmu_ptw_timeout_enable)                        ,
            
//                              MEMORIES FAULTS SIGNALS AFTER REGISTERED

            .instr_mem_addr_decode_error        (reg_inst_addr_decode_error)                    ,            
            .mem_addr_decode_error              (reg_data_memory_addr_decode_error)             ,
            .mem_addr_read_slverr               (reg_data_memory_read_slave_error)              ,
            .mem_addr_write_slverr              (reg_data_memory_write_slave_error)                    


                                                )                                               ;

            

//----------------------------------------INTERRUPT MMR REGISTER INSTANTIATION-------------------------------  




soc_mmr_apb_wrapper     mmr_register_instance   (

//                          FROM THE CLK RST CONTROLLER MODULE

            .pclk                               (pclk)                                          ,
            .presetn                            (presetn)                                       ,

//                          FROM THE AXI-APB BRIDGE MODULE

            .paddr                              (bridge_peripheral_paddr[15:0])                 ,
            .penable                            (bridge_peripheral_penable)                     ,
            .pwrite                             (bridge_peripheral_pwrite)                      ,
            .pwdata                             (bridge_peripheral_pwdata[7:0])                 ,

//                          FROM THE APB SLAVE PSEL WRAPPER MODULE

            .psel                               (mmr_reg_psel)                                  ,

//                          TO THE APB SLAVE PSEL WRAPPER MODULE

            .prdata                             (mmr_reg_prdata)                                ,
            .pready                             (mmr_reg_pready)                                ,
            .pslverr                            (mmr_reg_pslverr)                               ,

//                          TO THE INTERRUPT CONTROLLER MODULE

            .soc_mmr_write_en_i                 (mmr_int_ctrl_write_en)                         ,
            .soc_mmr_write_addr_i               (mmr_int_ctrl_write_addr)                       ,
            .soc_mmr_write_data_i               (mmr_int_ctrl_write_data)                       ,
            .soc_mmr_read_en_i                  (mmr_int_ctrl_read_en)                          ,
            .soc_mmr_read_addr_i                (mmr_int_ctrl_read_addr)                        ,

//                          FROM THE INTERRUPT CONTROLLER MODULE

            .soc_mmr_read_data_o                (int_ctrl_mmr_read_data)                        ,    
            .soc_read_rsp_i                     (int_ctrl_mmr_read_resp)    

                                                )                                               ;



//-------------------------------------DEBUG TRACE FOR IPs MODULE INSTANTITION--------------------------------   
 



trace_system_top    ip_debug_trace_instance     (


//                          FROM THE CLK RST CONTROLLER MODULE

            .sys_clk                            (core_clk)                                      ,
            .sys_rst_n                          (core_rstn)                                     ,

            .pclk                               (pclk)                                          ,
            .presetn                            (presetn)                                       ,

            .debug_clk                          (debug_clk)                                     ,
            .debug_rst                          (debug_rstn)                                    ,

//                          FROM THE AXI-APB BRIDGE MODULE

            .paddr                              (bridge_peripheral_paddr[7:0])                  ,
            .penable                            (bridge_peripheral_penable)                     ,
            .pwrite                             (bridge_peripheral_pwrite)                      ,
            .pwdata                             (bridge_peripheral_pwdata)                      ,

//                          FROM THE APB SLAVE PSEL WRAPPER MODULE

            .psel                               (ip_trace_psel)                                 ,

//                          TO THE APB SLAVE PSEL WRAPPER MODUL

            .prdata                             (ip_trace_prdata)                               ,
            .pready                             (ip_trace_pready)                               ,
            .pslverr                            (ip_trace_pslverr)                              ,

//                              FROM THE WATCHDOG TIMER MODULE

            .watchdog_data_i                    (wdt_ip_trace_data)                             ,
            .watchdog_event_i                   (wdt_ip_trace_event)                            ,

//                                  FROM THE I2C MODULE

            .i2c_data_i                         (i2c_ip_trace_data)                             ,
            .i2c_event_i                        (i2c_ip_trace_event)                            ,

//                                  FROM THE SPI MODULE

            .spi_data_i                         (spi_ip_trace_data)                             ,
            .spi_event_i                        (spi_ip_trace_event)                            ,

//                                  FROM THE MMU MODULE

            .mmu_data_i                         (mmu_ip_trace_data)                             ,
            .mmu_event_i                        (mmu_ip_trace_event)                            ,

//                                  FROM THE UART MODULE

            .uart_data_i                        (uart_ip_trace_data)                            ,
            .uart_event_i                       (uart_ip_trace_event)                           ,

//                              FROM THE INTERRUPT CONTROLLER MODULE

            .intr_data_i                        (int_ctrl_ip_trace_data)                        ,
            .intr_event_i                       (int_ctrl_ip_trace_event)                       ,

//                              FROM THE AXI-APB BRIDGE MODULE

            .bridge_data_i                      (bridge_ip_trace_data)                          ,
            .bridge_event_i                     (bridge_ip_trace_event)                         ,

//                                  FROM THE DEBUG MODULE

            .debug_data_i                       (debug_ip_trace_data)                           ,
            .debug_event_i                      (debug_ip_trace_event)                          ,

//                              TO THE GPIO PINMUX MODULE

            .gpio_data_o                        (ip_trace_gpio_dgb_data)                        ,
            .gpio_valid_o                       (ip_trace_gpio_dbg_valid)                       ,
            .dob_trigger_o                      (ip_trace_gpio_dbg_trigger)

                                                )                                               ;



//--------------------------------------CORE DEBUG TRACE MODULE INSTANTITION--------------------------




top_core_trace          core_debug_trace_instance       (

//                          FROM THE CLK RST CONTROLLER MODULE

            .it_clk                             (debug_clk)                                     ,
            .it_rst_n                           (debug_rstn)                                    ,


            .pclk_i                             (pclk)                                          ,
            .presetn_i                          (presetn)                                       ,

//                          FROM THE AXI-APB BRIDGE MODULE

            .paddr_i                            (bridge_peripheral_paddr[7:0])                  ,
            .penable_i                          (bridge_peripheral_penable)                     ,
            .pwrite_i                           (bridge_peripheral_pwrite)                      ,
            .pwdata_i                           (bridge_peripheral_pwdata[1:0])                 ,

//                          FROM THE APB SLAVE PSEL WRAPPER MODULE

            .psel_i                             (core_trace_psel)                               ,

//                          TO THE APB SLAVE PSEL WRAPPER MODULE

            .prdata_o                           (core_trace_prdata)                             ,
            .pready_o                           (core_trace_pready)                             ,
            .pslverr_o                          (core_trace_pslverr)                            ,

//                          FROM THE RV32I CORE MODULE

            .it_itype                           (core_debug_trace_itype)                        ,
            .it_iaddr                           (core_debug_trace_iaddr)                        ,
            .it_cause                           (core_debug_trace_cause)                        ,
            .it_context                         (core_debug_trace_context)                      ,
            .it_ienable_in                      (core_debug_trace_ienable)                      ,       
            .it_itype_valid                     (core_debug_trace_itype_valid)                  ,
            .it_first_instrn_valid_in           (core_debug_trace_Ist_instrn_valid)             ,
            .it_delta_addr                      (core_debug_trace_delta_addr)                   ,
            .it_del_adr_valid                   (core_debug_trace_del_adr_valid)                ,

//                                  FROM THE CSR MODULE

            .it_tval                            (csr_debug_trace_tval)                         ,

//                          FROM THE GPIO PINMUX MODULE

            .afvalid_i                          (gpio_core_trace_afvalid)                       ,
            .atready_i                          (gpio_core_trace_atready)                       ,

//                          TO THE GPIO PINMUX MODULE

            .afready_o                          (core_trace_gpio_afready)                       ,           
            .atdata_o                           (core_trace_gpio_atdata)                        ,
            .atvalid_o                          (core_trace_gpio_atvalid)                       

                                                )                                               ;
    


//----------------------------------------ANALOG REGISTER INSTANTIATION-----------------------------------




analog_register     postboot_analog_register_instance        (


//                          FROM THE CLK RST CONTROLLER MODULE

            .pclk                               (pclk)                                          ,
            .presetn                            (presetn)                                       ,

//                          FROM THE AXI-APB BRIDGE MODULE

            .paddr                              (bridge_peripheral_paddr[7:0])                  ,
            .penable                            (bridge_peripheral_penable)                     ,
            .pwrite                             (bridge_peripheral_pwrite)                      ,
            .pwdata                             (bridge_peripheral_pwdata)                      ,

//                          FROM THE APB SLAVE PSEL WRAPPER MODULE

            .psel                               (analog_reg_psel)                               ,

//                          TO THE APB SLAVE PSEL WRAPPER MODULE

            .prdata                             (analog_reg_prdata)                             ,
            .pready                             (analog_reg_pready)                             ,
            .pslverr                            (analog_reg_pslverr)                            ,

//                          ANALOG REGISTER OUT TO ANALOG TOP

            .analog_reg_postboot_0              (analog_postboot_reg0)                          ,
            .analog_reg_postboot_1              (analog_postboot_reg1)                          ,
            .analog_reg_postboot_2              (analog_postboot_reg2)                          ,
            .analog_reg_postboot_3              (analog_postboot_reg3)                          ,
            .analog_reg_postboot_4              (analog_postboot_reg4)                          ,
            .reserved_reg_51                    (analog_postboot_reserved_reg)                  ,

//                          ALALOG REGISTER TO THE ANALOG TOP FOR CALIBRATION

            .analog_calibrate_reg0              (analog_calibrate_reg0)                         ,
            .analog_calibrate_reg1              (analog_calibrate_reg1)                         ,
            .analog_calibrate_reg2              (analog_calibrate_reg2)                         ,
            .analog_calibrate_reg3              (analog_calibrate_reg3)                         ,
            .analog_calibrate_reg4              (analog_calibrate_reg4)                         ,
            .analog_calibrate_reg5              (analog_calibrate_reg5)                         ,

//                              ANALOG INPUTS FROM THE TOP

            .cifb_vout_m00                      (cifb_vout_m00_reg_in)                          ,
            .ciff_vout_m00                      (ciff_vout_m00_reg_in)                          ,
            .sar_vout_m00                       (sar_vout_m00_reg_in)                           ,
            .tdc_vout_m00                       (tdc_vout_m00_reg_in)                           ,

//                      TO THE GLUE LOGIC TO SELECT BTWN THE PRE OR POST BOOT REGISTERS

            .post_block_sel_reg                 (analog_postboot_reg5[6:2])                     ,
            .post_mode_sel_reg                  (analog_postboot_reg5[1:0])                     ,
            .reg_mux_sel                        (pre_post_boot_mux_sel)      


                                                )                                               ;



//---------------------------------PREBOOT ANALOG REGISTER REGISTER INSTANTIATION---------------




analog_preboot      preboot_analog_register_instance        (


//                              CLK & RST SIGNALS FROM CLK RST BYPASS MODULE

            .debug_clk                          (ctrl_bypass_debug_clk)                         ,
            .debug_rst_n                        (preboot_analog_rstn)                           ,

//                              FROM THE DEBUG MODULE

            .debug_valid                        (debug_preboot_analog_req_valid)                ,
            .debug_write_en                     (debug_data_mem_write_en)                       ,
            .debug_addr                         (debug_data_mem_address_in[7:0])                ,
            .debug_wdata                        (debug_data_mem_write_data)                     ,

//                                  TO DEBUG MODULE

            .debug_rdata                        (preboot_analog_reg_debug_rdata)                ,


//                                  TO THE ANALOG TOP

            .analog_reg_preboot_0               (analog_preboot_reg0)                           ,
            .analog_reg_preboot_1               (analog_preboot_reg1_w)               



                                                )                                               ;



endmodule
