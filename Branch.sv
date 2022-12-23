module Branch(forwarded_A,forwarded_B,br_taken,opcode,fun3,intrrupt,opcode_E,fun3_E);
    input logic[31:0]forwarded_A,forwarded_B;
    input logic[6:0]opcode,opcode_E;
    input logic[2:0]fun3,fun3_E;
    output logic[1:0] br_taken;
    input logic intrrupt;

    always_comb begin 
        br_taken = 2'b0;
        if (intrrupt)begin
            br_taken = 2'b10;
        end
        else if (opcode_E == 7'b1110011)begin
            case (fun3_E)
                3'b000:br_taken = 2'b10;
            endcase
        end
        else begin
         if (opcode == 7'b1100011)begin
            case (fun3)
                3'b000:br_taken = (forwarded_A == forwarded_B) ? 2'b01 : 2'b00;
                3'b001:br_taken = (forwarded_A != forwarded_B) ? 2'b01 : 2'b00;
                3'b100:br_taken = ($signed(forwarded_A) <  $signed(forwarded_B)) ? 2'b01 : 2'b00;
                3'b101:br_taken = ($signed(forwarded_A) >  $signed(forwarded_B)) ? 2'b01 : 2'b00;
                3'b110:br_taken = (forwarded_A <  forwarded_B) ? 2'b01 : 2'b00;
                3'b111:br_taken = (forwarded_A >  forwarded_B) ? 2'b01 : 2'b00;
            endcase
        end
        else if (opcode == 7'b1101111)begin
            br_taken = 2'b01;
        end
        else if (opcode == 7'b1100111)begin
            br_taken = 2'b01;
        end
        end
    end


endmodule