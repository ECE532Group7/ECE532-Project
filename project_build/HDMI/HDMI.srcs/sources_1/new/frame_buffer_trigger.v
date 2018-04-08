`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2018 08:06:45 PM
// Design Name: 
// Module Name: frame_buffer_trigger
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


module frame_buffer_trigger(
        input clock,
        input reset,
        input button,
        output [7:0] leds,        
        
        output [18:0] pixel_addr,
        output request,
        input valid,
        input [23:0] pixel_data
    );
    
        
    parameter MAX_VALUE = 307200 - 1;
    
    reg [18:0] address_counter = 0;
    
    wire button_negedge;
    reg request_reg;
    
    button_debouncer button_debouncer_inst (
        .clock(clock),
        .button(button),
        .stable_button(),
        .button_posedge(),
        .button_negedge(button_negedge)
    );
    
    always @(posedge clock) begin
        if(~reset) begin
            address_counter <= 0;
            request_reg <= 0;
        end
        else begin
            if(button_negedge) begin
                request_reg <= 1;
                if(address_counter == MAX_VALUE) begin
                    address_counter <= 0;
                end
                else begin
                    address_counter <= address_counter + 1;
                end
            end
            else begin
                address_counter <= address_counter;
                request_reg <= 0;
            end
        end
    end
    
    assign pixel_addr = address_counter;
    assign request = request_reg;
    
    assign leds[7] = valid;
    assign leds[6:0] = address_counter[6:0]; 
    
endmodule
