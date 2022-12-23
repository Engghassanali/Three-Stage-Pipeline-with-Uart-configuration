module Hazard_Unit(IR_D,IR_E,for_A,for_B,reg_wr_E,stall,wb_sel_E,br_taken,Flush,t_byte_i);
    input logic[31:0] IR_D,IR_E;
    input logic [1:0] wb_sel_E;
    input logic reg_wr_E,t_byte_i;
    input logic [1:0]br_taken;
    output logic for_A,for_B,stall,Flush;
    logic [4:0] rs1_D,rs2_D,rd_D,rs1_E,rs2_E,rd_E;
    assign rs1_D = IR_D[19:15];
    assign rs2_D = IR_D[24:20]; 
    assign rd_D  = IR_D[11:7];
    assign rs1_E = IR_E[19:15];
    assign rs2_E = IR_E[24:20]; 
    assign rd_E  = IR_E[11:7];

    always_comb begin 
        for_A   = 0;
        for_B   = 0;
        stall   = 0;
        Flush   = 0;
        if ((wb_sel_E == 2'b01 && (rd_E == rs1_D || rd_E == rs2_D)) || t_byte_i)begin
            stall   = 1;
        end

        else  begin
            if ((rs1_D == rd_E) && reg_wr_E && (rs1_D != 5'b0))begin
                for_A = 1;
            end
            else if ((rs2_D == rd_E) && reg_wr_E && (rs2_D != 5'b0))begin
                for_B = 1;
            end
        end
        
        if (br_taken == 1'b1)begin
            Flush = 1;
        end
        
    end

endmodule