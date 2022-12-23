module controller(reset,alu_op,reg_wr,opcode,sel_B,wb_sel,cs,wr,sel_A,reg_wr_E,wr_E,cs_E ,wb_sel_E,clk,csr_reg_wr,csr_reg_rd,csr_reg_wrMW,csr_reg_rdMW);
    input logic reset,clk;
    input logic[6:0] opcode;
    output logic alu_op,reg_wr,reg_wr_E,sel_B,cs,cs_E,wr,wr_E,sel_A,csr_reg_wr,csr_reg_rd,csr_reg_wrMW,csr_reg_rdMW;
    output logic[1:0]wb_sel,wb_sel_E;

    always_comb 
    begin
        if (reset)begin
            alu_op = 0;
            reg_wr = 0;
            sel_B  = 0;
            sel_A  = 0;
            wb_sel = 2'b00;
        end
        else begin
            case (opcode)
            7'b0110011: begin alu_op = 1; reg_wr = 1; sel_A = 0;sel_B = 0; wb_sel = 2'b00;                   end 
            7'b0010011: begin alu_op = 1; reg_wr = 1; sel_B = 1; sel_A = 0; wb_sel = 2'b00;                  end
            7'b0000011: begin reg_wr = 1; wb_sel = 2'b01; cs = 0; wr = 0; sel_A = 0;alu_op = 1; sel_B = 1;   end
            7'b0100011: begin reg_wr = 0; wb_sel = 2'b00; cs = 0; wr = 1; sel_A = 0;alu_op = 1; sel_B = 1;   end
            7'b1100011: begin sel_A  = 1; alu_op = 1; reg_wr = 1; sel_B = 1;wb_sel = 2'b00;                  end
            7'b1101111: begin wb_sel = 2'b10; alu_op = 1; reg_wr = 1;sel_A = 1; sel_B = 1;                   end
            7'b1100111: begin wb_sel = 2'b10; alu_op = 1; reg_wr = 1; sel_A = 0; sel_B = 1;                  end 
            7'b0010111: begin sel_B = 1; sel_A = 1; end
            7'b0110111: begin sel_B = 1; end
            7'b1110011: begin sel_B = 1;csr_reg_wr = 0; csr_reg_rd = 1; wb_sel =2'b11; alu_op = 1; reg_wr = 1;end
            default:    begin alu_op = 1; reg_wr = 1;                                                         end
        endcase
        end
           
    end
    always_ff @( posedge clk ) begin 
        reg_wr_E     <= reg_wr;
        wr_E         <= wr;
        cs_E         <= cs;
        wb_sel_E     <= wb_sel;
        csr_reg_rdMW <= csr_reg_rd;
        csr_reg_wrMW <= csr_reg_wr;
    end

endmodule