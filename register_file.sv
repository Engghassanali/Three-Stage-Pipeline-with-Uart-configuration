module register_file(raddr1,raddr2,waddr,wdata,rdata1,rdata2,clk_o,reg_wr_E);
    input logic[4:0] raddr1,raddr2,waddr;
    input logic[31:0] wdata;
    output logic[31:0]rdata1,rdata2;
    input logic reg_wr_E,clk_o;

    logic [31:0] register_memory[0:31];

    initial begin
        $readmemb("main.mem",register_memory);
    end 

    always_ff @( negedge clk_o ) begin 
        if (reg_wr_E)begin
            if (|waddr)begin
                register_memory[waddr] <= wdata;
            end
            else begin
                register_memory[waddr] <= 1'b0;
            end
        end
    end

    always_comb begin
        if (reg_wr_E)begin
            begin 
                rdata1 = (|raddr1)? register_memory[raddr1]:32'b0;
                rdata2 = (|raddr2)? register_memory[raddr2]:32'b0;  
                
            end
        end
    end
endmodule