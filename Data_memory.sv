module Data_memory(addrL_LSU,addrS_LSU,store,data_rd,wr_E,clk_o,cs_E,mask,Data_Memory_on);
    input logic[31:0]addrL_LSU,addrS_LSU,store;
    output logic [31:0] data_rd;
    input logic wr_E,cs_E,clk_o,Data_Memory_on;
    input logic[3:0] mask;

    logic [31:0] data_mem[0:255];
    initial begin
        $readmemb("Data_memory.mem",data_mem);
    end
    
    always_comb begin//ff @( posedge clk_o  or negedge reset) begin
        if (Data_Memory_on)begin
            data_rd = (~cs_E && ~wr_E) ? data_mem[addrL_LSU] : 0;
        end
    end
    always_ff @( negedge clk_o ) begin
        if (~cs_E && wr_E && Data_Memory_on)begin
            if (mask[0])begin
                data_mem[addrS_LSU][7:0] <= store[7:0];
            end
            if (mask[1])begin
                data_mem[addrS_LSU][15:8] <= store[15:8];
            end
            if (mask[2])begin
                data_mem[addrS_LSU][23:16] <= store[23:16];
            end
            if (mask[3])begin
                data_mem[addrS_LSU][31:24] <= store[31:24];
            end
        end        
    end
endmodule