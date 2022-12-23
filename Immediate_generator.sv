module Imm_Generator(IR_D,Immediate_value);
    input logic [31:0] IR_D;
    output logic [31:0] Immediate_value;
    always_comb begin
        case (IR_D[6:0])
        //I Type
            7'b0010011, 7'b1100111, 7'b0000011, 7'b1110011: Immediate_value = {{20{IR_D[31]}}, IR_D[31:20]};
        //S Type
            7'b0100011: Immediate_value = {{20{IR_D[31]}}, IR_D[31:25], IR_D[11:7]};
        //B Type
            7'b1100011: Immediate_value = {{20{IR_D[31]}},{IR_D[7],IR_D[30:25],IR_D[11:8],1'b0}};
        //J Type
            7'b1101111: Immediate_value = {{12{IR_D[31]}},{IR_D[19:12],IR_D[20],IR_D[30:21],1'b0}};
        //U Type
            7'b0010111, 7'b0110111: Immediate_value = {IR_D[31:12],12'b0};
            default: Immediate_value = 0;
        endcase
        
    end

endmodule