bind rv32i_core trace_log u_trace_log   (
   
    .clk(clk),
    .rst(!rst),
    .pc(last_commited_pc),
    .instruction(instr_id),
    .stall(stall_by_mmu),
    .branch_flush( hazard_if_id_flush),
    .hazard_flush(hazard_id_ex_flush),
    .branch(branch_ex_wires),
    .jump(jalr_ex || jal_ex),
    .regwrite(wb_write_en),
    .mem_write(mem_write_en),
    .mem_read(mem_read_en),
    .rd(wb_write_addr),
    .rd_data(wb_write_data),
    .mem_addr(data_mem_address),
    .mem_wdata(axi_slave_wrapper_data_mem_instance.u_data_memory.data_in),
    .csr_write_en(csr_write_en_o),
    .csr_wd(csr_addr_o),
    .csr_rd(csr_read_data_i),
    .store_type(mem_store_type_mem),
    .mscratch_o(csr_top_instance.csr_register_file_inst.mscratch_o),
    .mstatus_o(csr_top_instance.csr_register_file_inst.mstatus_o),
    .mepc_o(csr_top_instance.csr_register_file_inst.mepc_o),
    .mcause_o(csr_top_instance.csr_register_file_inst.mcause_o),
    .mtvec_o(csr_top_instance.csr_register_file_inst.mtvec_o),
    .mtval_o(csr_top_instance.csr_register_file_inst.mtval_o),
   // .mip_o(csr_top_instance.csr_register_file_inst.mip_o),
    .mie_o(csr_top_instance.csr_register_file_inst.mie_o),
    .misa_o(csr_top_instance.csr_register_file_inst.misa_o),
    .satp_o(csr_top_instance.csr_register_file_inst.satp_o)
);




