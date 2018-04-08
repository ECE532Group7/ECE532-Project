`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2018 06:54:06 PM
// Design Name: 
// Module Name: frame_buffer_interface_tb
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


module frame_buffer_interface_tb(

    );
    reg clock;
    reg reset;
    reg [31:0] in_port;
    wire [31:0] out_port;
    
    reg [31:0] previous_out_port;
    wire interrupt;
    
    reg [18:0] pixel_addr;
    reg request;
    wire valid;
    wire [23:0] pixel_data;
    
    reg [1:0] id;
    reg [19:0] address;
    reg [23:0] generated_data;
    
    parameter DATA1 = {8'h24, 8'h12, 8'hf2};
    parameter DATA2 = {8'hf4, 8'hc2, 8'hfa};
    parameter IMAGE = {
        DATA1,
        DATA2
    };
    
    reg error;
    
    frame_buffer_interface dut(
        //I/O interface to AXI GPIO block
        .clock(clock),
        .reset(reset), 
        .in_port(in_port),
        .out_port(out_port),
                
        //I/O interface to green locator
        .pixel_addr(pixel_addr),
        .request(request),
        .valid(valid),
        .pixel_data(pixel_data)
    );
    
    initial begin
        clock = 0;
        forever begin
            #5 clock = ~clock;
        end
    end
    
    task wait_cycles;
        input [31:0] cycles;
        begin
            repeat (cycles) begin
                @(posedge clock);
            end
        end
    endtask
    
    always @(posedge clock) begin
        previous_out_port <= out_port;
    end
    assign interrupt = previous_out_port != out_port;
    
    always @(posedge interrupt) begin
        id <= out_port[20:19];
        address <= out_port[18:0];
    end
    
    task fetch_pixel;
        input [18:0] task_address;
        begin
            request = 1;
            pixel_addr = task_address;
            
            wait_cycles(1);
            
            request = 0;
            
            @(posedge interrupt);
            wait_cycles(8);
            
            //in_port = {id,DATA};
            in_port = {id,IMAGE[(24*pixel_addr) +: 24]};
            
            @(posedge valid);
            
            //compare here if need be
            error = error | (pixel_data != IMAGE[(24*pixel_addr) +: 24]);
            
            wait_cycles(1);
        end 
    endtask
    
    initial begin
        reset = 0;
        in_port = 0;
        pixel_addr = 0;
        request = 0;
        error = 0;
        
        wait_cycles(5);
        
        reset = 1;
        
        wait_cycles(5);
        
        fetch_pixel('h0);
        fetch_pixel('h1);      
        
        wait_cycles(100);
       
       
       $finish; 
    end
    
    
endmodule
