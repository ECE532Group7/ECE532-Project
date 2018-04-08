`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2018 11:43:09 AM
// Design Name: 
// Module Name: interrupt_test
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


module interrupt_test(
        input clock,
        input reset,
        input [31:0] in_port,
        output reg [31:0] out_port,
        
        input button,
        output [4:0] leds
    );
    
    parameter MAX_VALUE = 307200 - 1;
    
    reg [18:0] address_counter = 0;
    reg [1:0] out_id = 1;
    
    wire [1:0] in_id;
    
    reg [63:0] timeout_counter;
    
    wire button_negedge;
    
    button_debouncer button_debouncer_inst (
        .clock(clock),
        .button(button),
        .stable_button(),
        .button_posedge(),
        .button_negedge(button_negedge)
    );
    
    
    assign in_id = in_port[25:24];
    assign leds[4] = in_id == out_id;
    assign leds[3:2] = in_id;
    assign leds[1:0] = out_id;
    
    always @(posedge clock) begin
        if(~reset) begin
            address_counter <= 0;
            out_id <= 1;
            out_port <= 0;
            timeout_counter <= 0;
        end
        else begin
            out_port <= {11'b0,out_id,address_counter};
            if(button_negedge) begin
                if(address_counter == MAX_VALUE) begin
                    address_counter <= 0;
                end
                else begin
                    address_counter <= address_counter + 1;
                end
                out_id <= out_id + 1;
            end
            else begin
                address_counter <= address_counter;
                out_id <= out_id;
            end
//            if(in_id == out_id) begin
//                if(address_counter == MAX_VALUE) begin
//                    address_counter <= 0;
//                end
//                else begin
//                    address_counter <= address_counter + 1;
//                end
//                out_id <= out_id + 1;
//                timeout_counter <= 0;
//            end
//            else if (timeout_counter >= TIMEOUT) begin
//                out_id <= out_id + 1;
//                timeout_counter <= 0;
//            end
//            else begin
//                address_counter <= address_counter;
//                out_id <= out_id;
//                timeout_counter <= timeout_counter + 1;
//            end
        end
    end
    
endmodule
