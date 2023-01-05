module RISC_V (clk,reset,intrrupt,out);
    input logic clk,reset,intrrupt;
    output logic [31:0]out;
    logic [31:0] rdata1,rdata2,Alu_out,Addr,instruction,wdata,PC,load,ST_W,LD_Byte,LD_UByte,LD_HW,LD_UHW,LD_W,addrL,data_wr,data_rd,readData2,readData1,PC_br,addrS,PC_D,IR_D,PC_E,Alu_out_E,WD,IR_E,forwarded_A,forwarded_B,store,Immediate_value,csr_data,csr_PC,csr_wdata,csr_addr,csr_inaddr,epc,csr_rdata,csr_mcause_ff,addrL_LSU,addrS_LSU;
    logic[6:0] opcode,fun7,opcode_E;
    logic[4:0] raddr1,raddr2,waddr;
    logic [2:0] fun3,fun3_E;
    logic alu_op,reg_wr,sel_B,cs,wr,sel_A,for_A,for_B,reg_wr_E,wr_E,cs_E,stall,stallWM,Flush,Flush_I,Data_Memory_on,Uart_on,byte_ready_i,t_byte_i,Tx,clk_o;
    logic [1:0] wb_sel,addr_dm,wb_sel_E,br_taken;
    logic [3:0] mask;
    logic [7:0] ST_Byte,data_in;
    logic [15:0] ST_HByte;
    logic [6:0] display;
    logic [7:0] anode;
    
    always_ff @( posedge clk_o ) begin 
        if (reset)begin
            PC <= 0;
        end        
        else begin
            PC <= PC_br;
        end
    end

    always_ff @(posedge clk_o) begin
       stallWM = stall;
    end

    always_ff @( posedge clk_o ) begin 
        if (~stall)begin
            IR_D <= instruction;
            PC_D <= PC;
        end
    end

    always_ff @( posedge clk_o ) begin 
        if (~stallWM) begin
            PC_E      <= PC_D;
            Alu_out_E <= Alu_out;
            WD        <= forwarded_B;
            IR_E      <= IR_D;
            fun3_E    <= fun3;
            opcode_E  <= opcode;
        end
    end
    always_ff @( posedge clk_o ) begin 
        if (Flush)begin
            IR_D <= 0;
        end        
    end
    always_ff @( posedge clk_o ) begin : blockName
        if (Flush_I) begin
            IR_D <= 0;
            IR_E <= 0;
        end
    end

    always_ff @( posedge clk_o ) begin 
        csr_data <= forwarded_A;
        csr_addr <= Immediate_value;
        
    end

    always_comb begin
        assign out = (Uart_on) ? Tx : wdata;
        assign raddr1    = IR_D[19:15];
        assign raddr2    = IR_D[24:20];
        assign waddr     = IR_E[11:7] ;
        assign opcode    = IR_D[6:0]  ;
        assign fun3      = IR_D[14:12];
        assign fun7      = IR_D[31:25];
        assign Addr      = PC[31:2];     
        assign addrL     = (IR_E[6:0] == 7'b0000011) ? Alu_out_E : 0;
        assign addrS     = (IR_E[6:0] == 7'b0100011) ? Alu_out_E : 0;
        assign addr_dm   = addrS[1:0];
        assign csr_PC    = PC_E;
        assign csr_wdata = csr_data;
        assign csr_inaddr= csr_addr;
        assign csr_mcause_ff = 1;
    end


    ALU AL(readData1,readData2,Alu_out,opcode,fun3,fun7,alu_op);
    controller CN(reset,alu_op,reg_wr,opcode,sel_B,wb_sel,cs,wr,sel_A,reg_wr_E,wr_E,cs_E ,wb_sel_E,clk_o,csr_reg_wr,csr_reg_rd,csr_reg_wrMW,csr_reg_rdMW);
    Data_memory DM(addrL_LSU,addrS_LSU,store,data_rd,wr_E,clk_o,cs_E,mask,Data_Memory_on);
    instruction_memory IM(Addr,instruction);
    register_file RF(raddr1,raddr2,waddr,wdata,rdata1,rdata2,clk_o,reg_wr_E);
    mux_I I_Type(sel_B,forwarded_B,Immediate_value,readData2);
    load_store_Unit LSU_addr(addrL,addrS, addrL_LSU,addrS_LSU, opcode_E,Data_Memory_on,Uart_on,byte_ready_i,WD,data_in);
    Ld_St_unit LSU(opcode_E,fun3_E,load,store,LD_Byte,LD_UByte,LD_HW,LD_UHW,LD_W,ST_Byte,ST_HByte,ST_W);
    LD_Sizing LDS(opcode_E,fun3_E,addr_dm,LD_Byte,LD_HW,LD_W,data_rd,LD_UByte,LD_UHW);
    ST_Sizing STS(opcode_E,fun3_E,mask,WD,addr_dm,ST_Byte,ST_HByte,ST_W);
    mux_LS mxLS(wb_sel_E,Alu_out_E,load,wdata,PC_E,csr_rdata);
    Branch_Mux Br_M(sel_A,forwarded_A,PC_D,readData1);
    Branch_taken Br_tk(Alu_out,PC_br,br_taken,PC,epc,stall);
    Branch Br(forwarded_A,forwarded_B,br_taken,opcode,fun3,intrrupt,opcode_E,fun3_E);
    mux_forA forA(rdata1,Alu_out_E,for_A,forwarded_A);
    mux_forB forB(rdata2,Alu_out_E,for_B,forwarded_B);
    Hazard_Unit HZU(IR_D,IR_E,for_A,for_B,reg_wr_E,stall,wb_sel_E,br_taken,Flush,t_byte_i);
    Imm_Generator Im_G(IR_D,Immediate_value);
    CSR_Regfile csr_RF(csr_PC,csr_wdata,intrrupt,csr_inaddr,csr_rdata,epc,clk_o,csr_reg_wrMW,csr_reg_rdMW,reset,Flush_I,csr_mcause_ff,IR_E);
    UART Uart_w_P(t_byte_i,byte_ready_i,Tx,data_in,clk_o,reset,Uart_on);
    // seven_seg SS(cathode,anode,out,clk_o,reset);
    ssd sd( clk, reset,out,anode,display);
    clock_div CD(clk,reset,clk_o);
endmodule