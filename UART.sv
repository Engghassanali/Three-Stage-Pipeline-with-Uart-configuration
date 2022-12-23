module UART(t_byte_i,byte_ready_i,Tx,data_in,clk,reset,Uart_on);
    input logic byte_ready_i,clk,reset,Uart_on;
    input logic[7:0] data_in;
    output logic Tx,t_byte_i;
    logic clear_baud_o,clear_o,counter_of_i,counter_baud_of_i,start_o,shift_o,load_xmt_shftreg_o,
    serial_out_o;
    always_comb begin
        t_byte_i = 0;
        if (counter_of_i && counter_baud_of_i)begin
            t_byte_i = 0; end
        else begin
            if (Uart_on) begin
                t_byte_i = 1;
            end
        end
        // end
    end
    controller_UART Controller_U(byte_ready_i,clear_baud_o,clear_o,t_byte_i,counter_of_i,counter_baud_of_i,start_o,shift_o,clk,reset,load_xmt_shftreg_o);
    mux M2x1(serial_out_o,start_o,Tx,clk);
    shift_reg Sh(shift_o,load_xmt_shftreg_o,data_in,serial_out_o,clk,reset);
    Baud_Counter Bd_C(clear_baud_o,counter_baud_of_i,clk);
    Bit_Counter Bi_C(clear_o,clk,counter_of_i);
    // reset_Uart rst_URT(counter_of_i,counter_baud_of_i,t_byte_i);
endmodule

module mux(serial_out_o,start_o,Tx,clk);
    input logic serial_out_o,start_o,clk;
    output logic Tx;
    always_comb begin 
        if(start_o)begin
            Tx = serial_out_o;
        end
        else begin
            Tx = 1'b1;
        end
    end
endmodule


module shift_reg(shift_o,load_xmt_shftreg_o,data_in,serial_out_o,clk,reset);
    input logic shift_o,load_xmt_shftreg_o,clk,reset;
    input logic [7:0] data_in;
    output logic serial_out_o;
    logic [7:0] shift;
    always_comb begin
        if(reset)begin
            serial_out_o <= 0;
            end
        else begin
            if(load_xmt_shftreg_o)begin
                shift <= data_in;
            end
        if (shift_o)begin
            serial_out_o <= shift[0];
            shift <= {1'b0,shift[7:1]};
            end
        end
    end
endmodule
module Baud_Counter(clear_baud_o,counter_baud_of_i,clk);
    input logic clear_baud_o,clk;
    output logic counter_baud_of_i;
    logic [2:0] baud_counter = 3'b0;
    always_ff @(posedge clk ) begin
        if(clear_baud_o)begin
            baud_counter <= baud_counter + 1'b1;
        if (baud_counter == 3'b100)begin
            counter_baud_of_i <= 1'b1;
            baud_counter <= 3'b0;
            end
        else begin
            counter_baud_of_i <= 1'b0;
            end
        end
    end
endmodule
module Bit_Counter(clear_o,clk,counter_of_i);
    input logic clear_o,clk;
    output logic counter_of_i;
    logic [3:0] bit_counter = 4'b0;
    always_ff @(posedge clk ) begin
        if(clear_o)begin
            bit_counter <= bit_counter + 1'b1;
            if(bit_counter == 4'b1000)begin
                counter_of_i <= 1'b1;
                bit_counter <= 3'b0;
            end
            else begin
                counter_of_i <= 1'b0;
            end
        end
    end
endmodule



module controller_UART(byte_ready_i,clear_baud_o,clear_o,t_byte_i,counter_of_i,counter_baud_of_i,start_o,shift_o,clk,reset,load_xmt_shftreg_o);
    input logic clk,reset,byte_ready_i,counter_baud_of_i,counter_of_i,t_byte_i;
    output logic load_xmt_shftreg_o,start_o,clear_o,clear_baud_o,shift_o;
    logic [1:0] state,next_State;
    localparam S0=2'b00;
    localparam S1=2'b01;
    localparam S2=2'b10;
    always_ff @( negedge clk ) begin
        if (reset)begin
            state <= S0;
        end
        else begin
            state <= next_State;
        end
    end
    always_ff @( posedge clk ) begin
        case (state)
            S0:if(!byte_ready_i)begin
                clear_baud_o <= 1'b1;
                clear_o <= 1'b1;
                load_xmt_shftreg_o <= 1'b1;
                next_State <= S0;
            end
            else if(byte_ready_i) begin
                clear_baud_o <= 1'b1;
                clear_o <= 1'b1;
                load_xmt_shftreg_o <= 1'b0;
                next_State <= S1;
            end
            S1:if(!t_byte_i)begin
                clear_o <= 1'b1;
                clear_baud_o <= 1'b1;
                load_xmt_shftreg_o <= 1'b1;
                next_State <= S1;
            end
            else if(t_byte_i)begin
                clear_o <= 1'b1;
                clear_baud_o <= 1'b1;
                load_xmt_shftreg_o <= 0;
                next_State <= S2;
            end
            S2: if(!counter_of_i && !counter_baud_of_i)begin
                start_o <= 1'b1;
                shift_o <= 1'b0;
                next_State <= S2;
            end
            else if(!counter_of_i && counter_baud_of_i)begin
                shift_o <= 1'b1;
                start_o <= 1'b1;
                next_State <= S2;
            end
            else if(counter_of_i && !counter_baud_of_i)begin
                start_o <= 1'b1;
                shift_o <= 1'b0;
                next_State <= S2;
            end
            else if(counter_of_i && counter_baud_of_i)begin
                start_o <= 1'b0;
                shift_o <= 1'b0;
                next_State <= S0;
            end
        endcase
    end
endmodule

// module reset_Uart(counter_of_i,counter_baud_of_i,t_byte_i);
//     input logic counter_baud_of_i,counter_of_i;
//     output logic t_byte_i;
//     always_comb begin 
//         if(counter_of_i && counter_baud_of_i)begin
//             t_byte_i = 0;
//         end
//     end
// endmodule