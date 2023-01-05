module Ld_St_unit(opcode_E,fun3_E,load,store,LD_Byte,LD_UByte,LD_HW,LD_UHW,LD_W,ST_Byte,ST_HByte,ST_W);
    input logic[6:0] opcode_E;
    input logic[2:0]fun3_E;
    input logic [31:0] LD_Byte,LD_UByte,LD_HW,LD_UHW,LD_W;
    input logic [7:0]ST_Byte;
    input logic [15:0]ST_HByte;
    input logic [31:0]ST_W;
    output logic [31:0] load,store;

    always_comb begin 
        if (opcode_E == 7'b0000011)begin
            case (fun3_E)
                3'b000:load = LD_Byte; 
                3'b001:load = LD_HW;
                3'b010:load = LD_W;
                3'b100:load = LD_UByte;
                3'b101:load = LD_UHW;
            endcase
        end
        if (opcode_E == 7'b0100011)begin
            case (fun3_E)
                3'b000:store = ST_Byte; 
                3'b001:store = ST_HByte;
                3'b010:store = ST_W;
            endcase
        end
    end
endmodule

module load_store_Unit (addrL,addrS, addrL_LSU,addrS_LSU, opcode_E,Data_Memory_on,Uart_on,byte_ready_i,WD,data_in);
    input logic[31:0]addrL,addrS,WD;
    input logic[6:0] opcode_E;
    output logic [31:0]addrL_LSU,addrS_LSU;
    output logic [7:0] data_in;
    output logic Data_Memory_on,Uart_on,byte_ready_i;
    always_comb begin
        Data_Memory_on = 0;
        Uart_on        = 0;
        addrS_LSU      = 0;
        byte_ready_i   = 0;
        // t_byte_i       = 0;
        addrL_LSU = (opcode_E == 7'b0000011) ? addrL : 0;
        if (opcode_E == 7'b0100011)begin
            casex (addrS[31:12])
                20'd0:begin Data_Memory_on = 1;  addrS_LSU = addrS;end 
                20'd1:begin Uart_on = 1; byte_ready_i = 1'b1; data_in = WD[7:0];end
            endcase
        end
    end
endmodule

module LD_Sizing(opcode_E,fun3_E,addr_dm,LD_Byte,LD_HW,LD_W,data_rd,LD_UByte,LD_UHW);
    input logic[6:0]opcode_E;
    input logic[2:0]fun3_E;
    input logic[1:0]addr_dm;
    input logic[31:0]data_rd;
    output logic[31:0]LD_Byte,LD_HW,LD_W,LD_UByte,LD_UHW;
    always_comb begin 
        if (opcode_E == 7'b0000011)begin
            case (fun3_E)
                3'b000:LD_Byte  = (addr_dm    == 2'b00) ? {{24{data_rd[7]}},data_rd[7:0]} : 0;
                3'b100:LD_UByte = (addr_dm    == 2'b01) ? {24'b0,data_rd[7:0]}  : 0;
                3'b001:LD_HW    = (addr_dm[1] == 1'b0)  ? {{24{data_rd[15]}},data_rd[7:0]}: 0;
                3'b101:LD_UHW   = (addr_dm[1] == 1'b1)  ? {24'b0,data_rd[15:0]} : 0;
                3'b010:LD_W     = data_rd;
                default:LD_W    = data_rd;
            endcase
        end
    end
endmodule

module ST_Sizing(opcode_E,fun3_E,mask,WD,addr_dm,ST_Byte,ST_HByte,ST_W);
    input logic[1:0]addr_dm;
    input logic[6:0]opcode_E;
    input logic[2:0]fun3_E;
    input logic[31:0]WD;
    output logic[3:0]mask;
    output logic [7:0]ST_Byte;
    output logic [15:0]ST_HByte;
    output logic [31:0]ST_W;
    always_comb begin 
        if (opcode_E == 7'b0100011)begin
            case (fun3_E)
                3'b000:begin 
                    if (addr_dm == 2'b00) begin 
                         mask = 4'b0001;ST_Byte = WD[7:0];
                    end
                    else begin
                        if (addr_dm == 2'b11)begin
                            mask = 4'b0001;ST_Byte = WD[31:24];
                        end
                    end
                end
                3'b001:begin 
                    if (addr_dm[1] == 1'b0)begin
                        mask = 4'b0011;ST_HByte = WD[15:0];
                    end
                    else begin
                        if (addr_dm[1] == 1'b1) begin
                            mask = 4'b1100;ST_HByte = WD[15:0];
                        end
                    end
                end
                3'b010:begin mask = 4'b1111; ST_W = WD;  end
            endcase
        end
        
    end
endmodule