`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2018 06:01:33 PM
// Design Name: 
// Module Name: GreenLocator_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GreenLocator_tb(

    );
    parameter ROW_BITS = 9;
    parameter COL_BITS = 10;
    
    parameter MAX_ROW = 2;
    parameter MAX_COL = 2;
    
    parameter GREEN = {8'h8, 8'hff, 8'h7};
    parameter NOT_GREEN = {8'h24, 8'h10, 8'h39};
    
    parameter IMAGE = {
        NOT_GREEN,
        GREEN,
        NOT_GREEN,
        GREEN,
        GREEN,
        GREEN,
        NOT_GREEN,
        GREEN,
        NOT_GREEN
    };
    
    reg clock;
    reg reset;
    
    wire [18:0] pixel_addr;
    wire request;
    reg valid;
    reg [23:0] pixel_data;
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;
    
    reg start;
    wire done;
    
    wire [ROW_BITS-1:0] green_row;
    wire [ROW_BITS-1:0] green_col;
    wire [ROW_BITS-1:0] green_size;
        
    reg error;

    GreenLocator#(
        .ROW_BITS(ROW_BITS),
        .COL_BITS(COL_BITS),
        
        .MAX_ROW(MAX_ROW),
        .MAX_COL(MAX_COL)
    ) dut (
        .clock(clock),
        .reset(reset),
    
        .pixel_addr(pixel_addr),
        .request(request),
        .valid(valid),
        .pixel_data(pixel_data),
        
        .start(start),
        .done(done),

        .green_row(green_row),
        .green_col(green_col),
        .green_size(green_size)
    );
    
    initial begin
        clock = 0;
    end
    
    always @(*) begin
        #5 clock <= ~clock;
    end
    
    task wait_cycles;
        input [31:0] cycles;
        begin
            repeat (cycles) begin
                @(posedge clock);
            end        
        end
    endtask
    
    task fetch_pixel;
        input [31:0] repeats;
        begin
            repeat (repeats) begin
                @(posedge request);
                
                wait_cycles(1);
                valid = 0;
                
                wait_cycles(5);
                
                valid = 1;
                pixel_data = IMAGE[(24*pixel_addr) +: 24];
                
            end
        end 
    endtask 
    
    initial begin
        valid = 0;
        pixel_data = 0;
        reset = 0;
        error = 0;
        start = 0;
        
        wait_cycles(3);
        
        reset = 1;
        
        wait_cycles(3);
        
        start = 1;
        wait_cycles(1);
        start = 0;
        
        fetch_pixel(20);
        
        wait_cycles(40);
        
        $finish;
    end
endmodule
