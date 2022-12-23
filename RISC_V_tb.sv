module RISC_V_tb;
    logic clk,reset,intrrupt;
    logic[31:0] out;
    RISC_V dut(.clk(clk), .reset(reset), .intrrupt(intrrupt), .out(out));

    initial
	begin
		clk <= 0;
		forever  begin 
            #5 clk = ~clk;
        end
	end

    initial
    begin
        intrrupt = 0;
        reset <= 0;
        @(posedge clk);
        reset <= 1;
        repeat (1) @(posedge clk);
        reset <= 0;
        repeat(5)@(posedge clk);
        intrrupt <= 1;
        repeat (1) @(posedge clk);
        intrrupt <= 0;
        repeat (200) @(posedge clk);
        $stop;
    end

endmodule