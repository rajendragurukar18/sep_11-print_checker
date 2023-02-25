module token_tx_checker (
    input logic       clk,
    input logic       rst_n,
    input logic       start,

    input logic       busy_r,
    input logic [5:0] cnt,
    input logic       done_r,
    input logic       busy,

    input logic [6:0] addr,
    input logic [6:0] addr_r,

    input logic [3:0] endp,
    input logic [3:0] endp_r,

    input tkn_sel_e   tkn_r,
    input tkn_sel_e   tkn_sel,
    input logic tx_bit,
    input logic [7:0] pid_byte,
    input logic [4:0] crc5,
    input logic tx_valid
    );


/*
//TX_01   reset asserted state

property tx_reset_check;
	!rst_n |->   (
			busy_r == 0  && done_r==0 &&  cnt==0 );   // |-> indicate that same cycle impliication
endproperty


A_TX_RESET :  assert property (
				   @(posedge clk)
				   tx_reset_check  );

*/

/*
	
property tx_start_check;
	(start && ! busy) |=> (busy_r==1) && (cnt ==0);
endproperty

A_TX_START :  assert property  (
	@(posedge clk)
	disable iff(!rst_n)
	tx_start_check
);




property tx_input_latch_check;
    (start && !busy_r) |=> (
        addr_r == $past(addr) &&
        endp_r == $past(endp) &&
        tkn_r  == $past(tkn_sel)
    );
endproperty


A_TX_INPUT_LATCH : assert property (
    @(posedge clk)
    disable iff (!rst_n)
    tx_input_latch_check
);


property tx_counter_check;

	(busy_r && cnt<31)  |=>  (cnt == $past(cnt) + 1'b1);
endproperty

A_TX_COUNTER_CHECK : assert property  (
					@(posedge clk)
					disable iff(!rst_n)
					tx_counter_check );


property tx_sync_check;

	(busy_r && cnt<8)
				|-> (tx_bit == USB_SYNC_BYTE[cnt]);
endproperty

A_TX_SYNC : assert property (
				@(posedge clk)
				disable iff (!rst_n)
				tx_sync_check );


*/


/*
property tx_pid_check;

	(busy_r   &&  cnt >= 8  &&  cnt < 16 )
				|-> (tx_bit == pid_byte[cnt-8]);
endproperty

A_TX_PID : assert property (
				@(posedge clk)
				disable iff (!rst_n)
				tx_pid_check );

*/


/*
property tx_addr_check;

	(busy_r   &&  cnt >= 16  &&  cnt < 23 )
				|-> (tx_bit == addr_r[cnt-16]);
endproperty

A_TX_ADDR : assert property (
				@(posedge clk)
				disable iff (!rst_n)
				tx_addr_check );
*/


/*
property tx_endpr_check;

	(busy_r   &&  cnt >= 23  &&  cnt < 27 )
				|-> (tx_bit == endp_r[cnt-23]);
endproperty

A_TX_ENDPR : assert property (
				@(posedge clk)
				disable iff (!rst_n)
				tx_endpr_check );
*/




/*
property tx_crc5_check;
	(busy_r   &&  cnt >= 27  &&  cnt < 32 )
				|-> (tx_bit == crc5[cnt-27]);
endproperty

A_TX_CRC5 : assert property (
				@(posedge clk)
				disable iff (!rst_n)
				tx_crc5_check );

*/

/*
property tx_valid_checker;
	tx_valid == busy_r;
endproperty

A_TX_VALID :  assert property (
				@(posedge clk)
				disable iff(!rst_n)
				tx_valid_checker );
*/


/*
property tx_complete_check;
    (busy_r && cnt == 31)
        		|=> (busy_r == 0 && done_r == 1);
endproperty

A_TX_COMPLETE : assert property (
   				 @(posedge clk)
   				 disable iff (!rst_n)
    				tx_complete_check
);

*/



/*

property tx_done_pulse_check;
    done_r |=> !done_r;
endproperty

A_TX_DONE_PULSE : assert property (
    					@(posedge clk)
    					disable iff (!rst_n)
    					tx_done_pulse_check  );
*/

// this one need to look on 


property tx_idle_after_done;
    done_r    |-> (
       				 busy_r == 0 &&
       				 cnt == 0 	 );
endproperty


A_TX_IDLE_AFTER_DONE : assert property (
  					  @(posedge clk)
 					  disable iff (!rst_n)   					 
   					  tx_idle_after_done    );




/*
property tx_32_cycle_check;
    (busy_r && cnt == 30) |=> (busy_r && cnt == 31);
endproperty

A_TX_32_CYCLES : assert property (
    					@(posedge clk)
    					disable iff (!rst_n)
    					tx_32_cycle_check    );

*/


/*
property tx_back_to_back_check;
    done_r && start |=> (
       				 busy_r == 1 &&
        			cnt == 0  );
endproperty

A_TX_BACK_TO_BACK : assert property (
   					 @(posedge clk)
   					 disable iff (!rst_n)
   					 tx_back_to_back_check  );
*/


/*
property tx_start_while_busy_check;
    (busy_r && start && cnt < 31)
        			|=> (cnt == $past(cnt) + 1'b1);
endproperty

A_TX_START_WHILE_BUSY : assert property (
  					  @(posedge clk)
   					 disable iff (!rst_n)
   					 tx_start_while_busy_check   );						
*/

endmodule	
	 				


bind token_tx token_tx_checker  tx_checker_instance (

	.clk(clk),
	.rst_n(rst_n),
	.start(start),
	.busy(busy),

	.done_r(done_r),
	.busy_r(busy_r),
	.cnt(cnt),
	
	.addr(addr),
	.addr_r(addr_r),
	.endp(endp),
	.endp_r(endp_r),
	.tkn_sel(tkn_sel),
	.tkn_r(tkn_r),
	
	.tx_bit(tx_bit),
   	.pid_byte(pid_byte),
    	.crc5(crc5),
    	.tx_valid(tx_valid)
);
