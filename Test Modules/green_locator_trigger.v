`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2018 06:36:17 PM
// Design Name: 
// Module Name: green_locator_trigger
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


module green_locator_trigger#(
    parameter ROW_BITS = 9,
    parameter COL_BITS = 10
)(
    //Clock and Reset
    input clock,
    input reset, //Resets on posedge
    input button,
    output [7:0] leds,

    output start,
    input done,

    //Green Stuff
    input [ROW_BITS-1:0] green_row,
    input [COL_BITS-1:0] green_col,
    input [ROW_BITS-1:0] green_size
    );
    
    wire button_negedge;
    reg start_reg;
    
    button_debouncer button_debouncer_inst (
        .clock(clock),
        .button(button),
        .stable_button(),
        .button_posedge(),
        .button_negedge(button_negedge)
    );
    
    always @(posedge clock) begin
        start_reg <= button_negedge;
    end
    //assign start = button_negedge;
    assign start = start_reg;
    
    assign leds[7] = done;
    assign leds[0] = &green_size;
    assign leds[3:1] = green_col[2:0];
    assign leds[6:4] = green_row[2:0];
endmodule
