module trace_log            (
    input logic        clk,
    input logic        rst,

     input logic [31:0] pc,
    input logic [31:0] instruction,

    // CONTROL
    input logic        stall,
    input logic        branch_flush,
    input logic        hazard_flush,
    input logic        branch,
    input logic        jump,

    input logic        regwrite,
    input logic        mem_write,
    input logic        mem_read,

    // REGISTER gpr
    input logic [4:0]  rd,
    input logic [31:0] rd_data,

    // MEMORY 
    input logic [31:0] mem_addr,
    input logic [31:0] mem_wdata,
    input logic [0:2]store_type,

    // CSR
    input logic         csr_write_en,
    input logic [11:0]  csr_wd,
    input logic [31:0]  csr_rd,

input logic [31:0] mstatus_o,
input logic [31:0] mepc_o,
input logic [31:0] mcause_o,
input logic [31:0] mtval_o,
input logic [31:0] mie_o,
//input logic [31:0] mip_o,
input logic [31:0] mscratch_o,
input logic [31:0] mtvec_o,
input logic [31:0] mhartid_o,
input logic [31:0] misa_o,
input logic [31:0] satp_o

);
localparam PC_ADDR = 32'h0000_0000;

integer fd;
string trace_file;

// DELAY PIPELINE

logic [31:0] pc_d1, pc_d2;
logic [31:0] instr_d1, instr_d2, instr_d3, instr_d4;
logic branch_1,branch_2,branch_3;
logic jump_1,jump_2,jump_3;

logic valid_d1;
logic valid_d2, valid_d3, valid_d4;
logic [11:0] csr_wd_1,csr_wd_2;
logic [31:0] csr_rd_1,csr_rd_2;
logic csr_write_en_1,csr_write_en_2,csr_write_en_3;
logic branch_flush_d1;
logic branch_flush_d2;
logic mem_write_1;
logic mem_read_1;
logic[31:0] mem_addr_1;
logic [31:0]mem_wdata_1;
logic [2:0] store_type_1;


logic [31:0] mstatus_1;
 logic [31:0] mepc_1;
 logic [31:0] mcause_1;
logic [31:0] mtval_1;
 logic [31:0] mie_1;
// logic [31:0] mip_1;
logic [31:0] mscratch_1;
 logic [31:0] mtvec_1;
logic [31:0] mhartid_1;
logic [31:0] misa_1;
logic [31:0] satp_1;


initial begin
 if (!$value$plusargs("trace_file=%s", trace_file)) begin
        trace_file = "rtl_trace.log";
    end

    fd = $fopen(trace_file, "w");

    if (fd == 0) begin
        $display("ERROR: Cannot open trace file");
        $finish;
    end

    $display("RTL TRACE FILE = %s", trace_file);

end
always_comb begin
    valid_d1 = !(branch_flush ||branch_flush_d1|| branch_flush_d2|| hazard_flush);
end
always @(posedge clk) begin

    if (rst) begin

       

        pc_d1 <= 0;
        pc_d2 <= 0;
       

        instr_d1 <= 32'h13;
        instr_d2 <= 32'h13;
        instr_d3 <= 32'h13;
        instr_d4 <= 32'h13;

        branch_1 <= 0;
        branch_2 <= 0;
        branch_3 <= 0;

        jump_1 <= 0;
        jump_2 <= 0;
        jump_3 <= 0;

        csr_wd_1 <=0;
        csr_wd_2 <=0;
branch_flush_d1<=0;
branch_flush_d2<=0;

csr_rd_1 <=0;
csr_rd_2 <=0;

csr_write_en_1<=0;
csr_write_en_2<=0;
csr_write_en_3<=0;

    end

else if (!stall) begin

    pc_d1    <= pc;
    instr_d1 <= instruction;
    branch_flush_d1<=branch_flush;
    branch_flush_d2<=branch_flush_d1;

    //  FLUSH 

if(branch_flush ||branch_flush_d1 || branch_flush_d2 || hazard_flush ) begin

   

    branch_1 <= 0;
    branch_2<=0;
    jump_1 <= 0;
    jump_2<=0;
   // csr_wd_1 <= 0;
   // csr_rd_1 <= 0;
   // csr_write_en_1  <= 0;
end

else begin

  
    
    pc_d1 <= pc;
    instr_d1 <= instruction;
    branch_1      <= branch;
    jump_1<=jump;
    csr_wd_1       <= csr_wd;
    csr_rd_1       <= csr_rd;
    csr_write_en_1 <= csr_write_en;

end

// PIPELINE SHIFT

            valid_d2 <= valid_d1;
            valid_d3 <= valid_d2;
            valid_d4 <= valid_d3;

    
    pc_d2 <= pc_d1;
    

    instr_d2 <= instr_d1;
    instr_d3 <= instr_d2;
    instr_d4 <= instr_d3;

    valid_d2 <= valid_d1;
    valid_d3 <= valid_d2;
    valid_d4 <= valid_d3;

    branch_1<=branch;
    branch_2<=branch_1;
    branch_3<=branch_2;

    jump_1 <= jump;
    jump_2 <= jump_1;
    jump_3 <= jump_2;

    csr_wd_2<=csr_wd_1;

    csr_rd_1<=csr_rd;
    csr_rd_2<=csr_rd_1;
csr_write_en_1<=csr_write_en;
    csr_write_en_2<=csr_write_en_1;
    csr_write_en_3<=csr_write_en_2;

    mem_write_1<=mem_write;
    mem_read_1<=mem_read;
    mem_addr_1<=mem_addr;
    mem_wdata_1<=mem_wdata;
    store_type_1<=store_type;

    mscratch_1<=mscratch_o;
mepc_1<=mepc_o;
mtval_1<=mtval_o;
mcause_1<=mcause_o;
mtvec_1<=mtvec_o;
//mip_1<=mip_o;
mstatus_1<=mstatus_o;
mie_1<=mie_o;
mhartid_1<=mhartid_o;
satp_1<=satp_o;
end

end

function string csr_name(input [11:0] addr);

begin
    case(addr)

        12'h300: csr_name="c768_mstatus";
        12'h304: csr_name="c772_mie";
        12'h305: csr_name="c773_mtvec";
        12'h340: csr_name="c832_mscratch";
        12'h341: csr_name="c833_mepc";
        12'h342: csr_name="c834_mcause";
        12'h343: csr_name="c835_mtval";
        //12'h344: csr_name="c836_mip";
        12'hF14: csr_name="c3860_mhartid";
        12'h301: csr_name="c769_misa";
        12'h180: csr_name="c384_satp";

        default:
            csr_name=$sformatf("c%0d",addr);

    endcase
end

endfunction
function automatic [31:0] csr_value(input [11:0] addr);

begin
    case(addr)

       12'h300: csr_value = mstatus_1;
        12'h301: csr_value = misa_1;
        12'h304: csr_value = mie_1;
        12'h305: csr_value = mtvec_1;

        12'h340: csr_value = mscratch_1;
        12'h341: csr_value = mepc_1;
        12'h342: csr_value = mcause_1;
        12'h343: csr_value = mtval_1;
        //12'h344: csr_value = mip_1;

        12'hF14: csr_value = mhartid_1;
        12'h180: csr_value= satp_1;

        default: csr_value = 32'h0;
    endcase
end
endfunction

logic csr_modify;

assign csr_modify =

(
    // CSRRW
    (instr_d3[14:12]==3'b001) ||

    // CSRRWI
    (instr_d3[14:12]==3'b101) ||

    // CSRRS rs1!=x0
    ((instr_d3[14:12]==3'b010) &&
     (instr_d3[19:15]!=5'd0)) ||

    // CSRRC rs1!=x0
    ((instr_d3[14:12]==3'b011) &&
     (instr_d3[19:15]!=5'd0)) ||

    // CSRRSI uimm!=0
    ((instr_d3[14:12]==3'b110) &&
     (instr_d3[19:15]!=5'd0)) ||

    // CSRRCI uimm!=0
    ((instr_d3[14:12]==3'b111) &&
     (instr_d3[19:15]!=5'd0))
);


always @(posedge clk) begin

    if (valid_d4 && stall==0) begin

        
        // STORE
        
        if (mem_write_1 && regwrite==0 ) begin

            case(instr_d3[14:12])
            3'b000://SB
            $fwrite(fd,"core   0: 3 0x%08x (0x%08x) mem 0x%08x 0x%08x\n",
                pc+ PC_ADDR,
                instr_d3,
                mem_addr_1,
                mem_wdata_1[7:0]
            );
             3'b001://SH
            $fwrite(fd,"core   0: 3 0x%08x (0x%08x) mem 0x%08x 0x%08x\n",
                pc+ PC_ADDR,
                instr_d3,
                mem_addr_1,
                mem_wdata_1[15:0]
            );
             3'b100://Sw
            $fwrite(fd,"core   0: 3 0x%08x (0x%08x) mem 0x%08x 0x%08x\n",
                pc+ PC_ADDR,
                instr_d3,
                mem_addr_1,
                mem_wdata_1
            );

            default:
        $fwrite(fd,
        "core   0: 3 0x%08x (0x%08x) mem 0x%08x 0x%08x\n",
            pc+ PC_ADDR,
            instr_d3,
            mem_addr_1,
            mem_wdata_1
        );
                endcase
                end
        
       // LOAD
    
       else if (mem_read_1) begin

    if (rd == 0) begin

        $fwrite(fd,
        "core   0: 3 0x%08x (0x%08x) mem 0x%08x\n",
        pc+ PC_ADDR,
        instr_d3,
        mem_addr_1
        );

    end

    else begin

        $fwrite(fd,
        "core   0: 3 0x%08x (0x%08x) x%0d 0x%08x mem 0x%08x\n",
        pc + PC_ADDR,
        instr_d3,
        rd,
        rd_data,
        mem_addr_1
        );

    end
end

        // BRANCH 
        

        else if (branch_2 ) begin

            $fwrite(fd,"core   0: 3 0x%08x (0x%08x)\n",
                pc+ PC_ADDR,
                instr_d3
            );
        end
// JUMP (JAL/JALR)

else if (jump_2) begin

   if (rd != 5'd0) begin

        $fwrite(fd,
        "core   0: 3 0x%08x (0x%08x) x%0d 0x%08x\n",
        pc + PC_ADDR,
        instr_d3,
        rd,
        rd_data
        );

    end
    else begin

        $fwrite(fd,
        "core   0: 3 0x%08x (0x%08x)\n",
        pc + PC_ADDR,
        instr_d3
        );

    end

end
    
         
  
else if (valid_d4 && csr_write_en_2 &&instr_d3[6:0]==7'b1110011 && instr_d3[14:12]!=3'b000) begin

    
    if(csr_modify) begin

        // CSR + GPR

        if(regwrite && (rd!=0)) begin

            $fwrite(fd,"core   0: 3 0x%08x (0x%08x) x%0d 0x%08x %s 0x%08x\n",

            pc+ PC_ADDR,
            instr_d3,
            rd,
            rd_data,
            csr_name(instr_d3[31:20]),
            csr_value(instr_d3[31:20])
            );

        end

        // CSR only

        else begin

            $fwrite(fd,"core   0: 3 0x%08x (0x%08x) %s 0x%08x\n",

            pc+ PC_ADDR,
            instr_d3,
            csr_name(instr_d3[31:20]),
            csr_value(instr_d3[31:20])
            );

        end

    end  

else begin

    //  GPR write
    if(regwrite && (rd!=0)) begin

        $fwrite(fd, "core   0: 3 0x%08x (0x%08x) x%0d 0x%08x\n",

        pc+ PC_ADDR,
        instr_d3,
        rd,
        rd_data
        );

    end

    // No GPR write
    else begin

        $fwrite(fd,"core   0: 3 0x%08x (0x%08x)\n",

        pc+ PC_ADDR,
        instr_d3
        );

    end

end

end


// ALU/CSR/JAL
       
        else if (regwrite) begin

            $fwrite(fd,"core   0: 3 0x%08x (0x%08x) x%0d 0x%08x\n",
                pc+ PC_ADDR,
                instr_d3,
                rd,
                rd_data
            );
        end
        
else begin
   // fence, nop, ecall, ebreak
   $fwrite(fd,
      "core   0: 3 0x%08x (0x%08x)\n",
      pc+ PC_ADDR,
      instr_d3);
end
    
    
    end
end
endmodule









