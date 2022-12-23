module instruction_memory (Addr,instruction);
    input logic [31:0] Addr;
    output logic [31:0] instruction;
    logic [31:0] inst_mem [0:127];

    initial begin 
        $readmemh("machine_code.txt", inst_mem);
    end

    always_comb begin 
        assign instruction = inst_mem[Addr];
    end
    
endmodule