module ALU(readData1,readData2,Alu_out,opcode,fun3,fun7,alu_op);
    input logic[31:0] readData1,readData2;
    input logic[6:0] opcode,fun7;
    input logic[2:0]fun3;
    input logic alu_op;
    output logic[31:0] Alu_out;

    always_comb 
    begin 
        if(alu_op)begin
            //R Type Instructions
            if (opcode == 7'b0110011 && fun7 == 7'b0000000)begin
                case (fun3)
                    3'b000:Alu_out = readData1 + readData2;                  //Add instruction
                    3'b001:Alu_out = readData1 << readData2;                 //SLL instruction
                    3'b010:Alu_out = $signed(readData1) < $signed(readData2);//SLT instruction
                    3'b011:Alu_out = readData1 < readData2;                  //SLTU instruction
                    3'b100:Alu_out = readData1 ^ readData2;                  //XOR instruction
                    3'b101:Alu_out = readData1 >> readData2;                 //SRL instruction
                    3'b110:Alu_out = readData1 | readData2;                  //OR instruction
                    3'b111:Alu_out = readData1 & readData2;                  //AND instruction
                endcase
            end
            if (opcode == 7'b0110011 && fun7 == 7'b0100000)begin
                case (fun3)
                    3'b000:Alu_out = readData1 - readData2;                  //SUB instruction
                    3'b101:Alu_out = readData1 >>> readData2;                //SRA instruction
                endcase
            end

            //I Type Instructions
            if (opcode == 7'b0010011)begin
                case (fun3)
                    3'b000:Alu_out = readData1 + readData2;                  //AddI instruction
                    3'b010:Alu_out = $signed(readData1) < $signed(readData2);//SLTI instruction
                    3'b011:Alu_out = readData1 < readData2;                  //SLTUI instruction
                    3'b100:Alu_out = readData1 ^ readData2;                  //XORI instruction
                    3'b110:Alu_out = readData1 | readData2;                  //ORI instruction
                    3'b111:Alu_out = readData1 & readData2;                  //ANDI instruction
                endcase
            end
            if (opcode == 7'b0010011 && fun7 == 7'b0000000)begin
                case (fun3)
                    3'b001:Alu_out = readData1 << readData2;                 //SLLI instruction
                    3'b101:Alu_out = readData1 >> readData2;                 //SRLI instruction 
                endcase
            end
            if (opcode == 7'b0010011 && fun7 == 7'b0100000)begin
                case (fun3)
                    3'b101:Alu_out = readData1 >>> readData2;                //SRAI instruction  
                endcase
            end
            //Load
            if (opcode == 7'b0000011) begin
                    Alu_out = readData1 + readData2;
            end
            //Store
            if (opcode == 7'b0100011)begin
                    Alu_out = readData1 + readData2;
            end

            //B Type
            if (opcode == 7'b1100011)begin
                    Alu_out = readData1 + readData2;
            end

            //LUI Type Instructions
            if (opcode == 7'b0110111)begin
                    Alu_out = readData2;
            end
            //AUIPC Type Instruction
            if (opcode == 7'b0010111)begin
                    Alu_out = readData1 + readData2;
            end
            //J Type Instruction
            if (opcode == 7'b1101111)begin
                    Alu_out = readData1 + readData2;
            end
            if (opcode == 7'b1100111)begin
                case (fun3)
                    3'b000: begin Alu_out = readData1 + readData2; end
                endcase       
            end
            
        end
    end
endmodule