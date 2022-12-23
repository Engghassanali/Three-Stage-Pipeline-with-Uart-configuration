module CSR_Regfile(csr_PC,csr_wdata,intrrupt,csr_inaddr,csr_rdata,epc,clk,csr_reg_wrMW,csr_reg_rdMW,reset,Flush_I,csr_mcause_ff,IR_E);
    input logic[31:0] csr_PC,csr_wdata,csr_inaddr,csr_mcause_ff,IR_E;
    input logic intrrupt,clk,reset,csr_reg_wrMW,csr_reg_rdMW;
    output logic [31:0]csr_rdata, epc;
    output logic Flush_I;
    logic[31:0] csr_mstatus_ff,csr_mip_ff,csr_mie_ff,csr_mepc_ff,csr_mtvec_ff,BASE;
    logic [31:0] csr_register_memory[0:6];
    logic [30:0] Exception_Code;
    logic [1:0] MODE;
    logic csr_mstatus_wr_flag,csr_mip_wr_flag,csr_mie_wr_flag,csr_mcause_wr_flag,csr_mtvec_wr_flag,csr_mepc_wr_flag,INTR;
    integer i;
        
    always_comb begin
        Flush_I = 0;
        MODE = csr_mtvec_ff[1:0];
        BASE = {csr_mtvec_ff[31:2],2'b00};
        INTR = csr_mcause_ff[31];
        Exception_Code = csr_mcause_ff[30:0];
        if (reset) begin
            for (i=0; i<6; i++)begin
                csr_register_memory[i] = 0;
            end
        end
        else begin
            if(intrrupt)begin
                Flush_I = 1;
                csr_mepc_ff = csr_PC;
                case (MODE)
                    2'b00:epc = BASE;
                    2'b01:epc = BASE + Exception_Code << 2;
                endcase
            end
            else begin
                case({IR_E[6:0],IR_E[14:12]})
                    10'b1110011_000:epc = csr_mepc_ff;
                endcase
            end
 
        end
    end
    //CSR Read Operation
    always_comb begin
        csr_rdata = 0;
        if (csr_reg_rdMW)begin
            case (csr_inaddr)
                12'h300 : csr_rdata = csr_mstatus_ff; 
                12'h344 : csr_rdata = csr_mip_ff; 
                12'h304 : csr_rdata = csr_mie_ff; 
                12'h342 : csr_rdata = csr_mcause_ff; 
                12'h305 : csr_rdata = csr_mtvec_ff; 
                12'h341 : csr_rdata = csr_mepc_ff;  
            endcase
        end
    end
    //CSR Write Operation
    always_comb begin 
        csr_mstatus_wr_flag = 1'b0;
        csr_mip_wr_flag     = 1'b0;
        csr_mie_wr_flag     = 1'b0;
        csr_mcause_wr_flag  = 1'b0;
        csr_mtvec_wr_flag   = 1'b0;
        csr_mepc_wr_flag    = 1'b0;
        if (~csr_reg_wrMW)begin
            case (csr_inaddr)
                12'h300 : csr_mstatus_wr_flag = 1'b1; 
                // 12'h344 : csr_mip_wr_flag     = 1'b1; 
                12'h304 : csr_mie_wr_flag     = 1'b1; 
                // 12'h342 : csr_mcause_wr_flag  = 1'b1; 
                12'h305 : csr_mtvec_wr_flag   = 1'b1; 
                // 12'h341 : csr_mepc_wr_flag    = 1'b1;  
            endcase
        end 
    end
    always_ff @( negedge clk, negedge reset ) begin
        if (reset)begin
            csr_mstatus_ff <= 0;
            // csr_mip_ff     <= 0;
            csr_mie_ff     <= 0;
            // csr_mcause_ff  <= 0;
            csr_mtvec_ff   <= 0;
            // csr_mepc_ff    <= 0;
        end
        else begin
            if(csr_mstatus_wr_flag)begin
                csr_mstatus_ff <= csr_wdata;
            end
            // if(csr_mip_wr_flag)begin
            //     csr_mip_ff <= csr_wdata;
            // end
            if(csr_mie_wr_flag)begin
                csr_mie_ff <= csr_wdata;
            end
            // if(csr_mcause_wr_flag)begin
            //     csr_mcause_ff <= csr_wdata;
            // end
            if(csr_mtvec_wr_flag)begin
                csr_mtvec_ff <= 1;//csr_wdata;
            end
            // if(csr_mepc_wr_flag)begin
            //     csr_mepc_ff <= csr_wdata;
            // end
        end          
    end

endmodule

// module mux_Enc(E_Interrupt, Timer_Interrupt, csr_mcause_ff):
//     input logic E_Interrupt, Timer_Interrupt;
//     output logic [31:0] csr_mcause_ff;
//     if (E_Interrupt)begin
//         csr_mcause_ff = 1;
//     end
//     else if(Timer_Interrupt)begin
//         csr_mcause_ff = 1;
//     end
// endmodule