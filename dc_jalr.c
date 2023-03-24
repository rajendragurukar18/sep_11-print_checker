#include "peripheral.h"

int main(void)
{
    uint32_t read_data;
    uint32_t read_data1;
    uint32_t handshake_from_sv_to_c = 0;


        info_print(000000);   
/*    while(handshake_from_sv_to_c==0)
    {
        handshake_from_sv_to_c = wait_for_handshake_from_sv();
    }
        info_print(111111);
 */   

    //FORCE DEBUG_SEL AS 0 

    //WRITE INTO PER_ADDR , DEBUG_DIV_ENable is 0 and PER_div ratio is 4
    mmio_write(CLK_RST_BASE_ADDR + CLK_DIV_PER_ADDR, PER_DIV_ENABLE | PER_DIV_RATIO_4);
        info_print(CLK_RST_BASE_ADDR + CLK_DIV_PER_ADDR);  
        info_print(PER_DIV_ENABLE | PER_DIV_RATIO_4);  

/*    //read from status addr for debug sel 0 addr with ratio 0
    read_data = mmio_read(CLK_RST_BASE_ADDR + CLK_DIV_PER_ADDR);
    read_data1 = mmio_read(CLK_RST_BASE_ADDR + CLK_RST_STATUS_ADDR);
        info_print(read_data);  
	if(read_data=0x80000000)
	 info_print(1);  
	else
	 error_print(0); 
*/

    //WRITE INTO PER_ADDR , to toggle from core to debug
    mmio_write(CLK_RST_BASE_ADDR + CLK_DIV_PER_ADDR, PER_DIV_ENABLE | TOGGLE_TO_DEBUG | PER_DIV_RATIO_4);
        info_print(CLK_RST_BASE_ADDR + CLK_DIV_PER_ADDR);  
        info_print(TOGGLE_TO_DEBUG);  

    //read from CLK_DIV_PER_ADDR TO CHECK WHETHER IT IS TOGGLING TO DEBUG MODE
/*    read_data = mmio_read(CLK_RST_BASE_ADDR + CLK_DIV_PER_ADDR);
    read_data1 = mmio_read(CLK_RST_BASE_ADDR + CLK_RST_STATUS_ADDR);
        info_print(read_data);  
	if(read_data=0xC0000004)
	 info_print(1);  
	else
	 error_print(0); 
*/
//    send_handshake_to_sv ();

/*         while (handshake_from_sv_to_c == 0) {
         handshake_from_sv_to_c = wait_for_handshake_from_sv();
     }

    handshake_from_sv_to_c = 0;
*/   
    //pinmux configuration
     mmio_write(GPIO_BASE_ADDR + GPIO_PINMUX1_ADDR, TRACE_PINMUX_CFG);
  

     uint32_t expected_data = 0x3;

    mmio_write(TRACE_BASE_ADDR + TRACE_CTRL_OFFSET, expected_data);

    read_data = mmio_read(TRACE_BASE_ADDR + TRACE_CTRL_OFFSET);

    if (read_data == expected_data)
        info_print(1);       // PASS
    else
        error_print(0);      // FAIL

// ================================================================
// RV32I JALR Instruction Stimulus
// JALR ---> jump to target and skip instructions
// ================================================================

asm volatile (

    // ============================================================
    // Normal instructions before JALR
    // ============================================================

    "li t2, 0\n"
    "addi t2, t2, 1\n"
    "addi t2, t2, 1\n"
    "addi t2, t2, 1\n"


    // ============================================================
    // Prepare JALR target address
    // ============================================================

    "la t1, jalr_target\n"


    // ============================================================
    // JALR instruction
    // Jump to jalr_target
    // ============================================================

    "jalr ra, 0(t1)\n"


    // ============================================================
    // These 3 instructions MUST be skipped
    // ============================================================

    "addi t3, t3, 1\n"
    "addi t3, t3, 1\n"
    "addi t3, t3, 1\n"


    // ============================================================
    // JALR TARGET
    // ============================================================

    "jalr_target:\n"


    // ============================================================
    // 6 normal instructions after JALR target
    // ============================================================

    "addi t4, t4, 1\n"
    "addi t4, t4, 1\n"
    "addi t4, t4, 1\n"
    "addi t4, t4, 1\n"
    "addi t4, t4, 1\n"
    "addi t4, t4, 1\n"

);

send_handshake_to_sv();
//return 0;
}
