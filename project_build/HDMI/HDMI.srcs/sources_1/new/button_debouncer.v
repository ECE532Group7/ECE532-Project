`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2018 05:07:50 PM
// Design Name: 
// Module Name: button_debouncer
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


module button_debouncer#(
        parameter MAX_TIME = 16'hffff
)(
        input clock,
        input button,
        
        output stable_button,
        output button_posedge,
        output button_negedge
    );
    
    reg [1:0] button_delay;
    always @(posedge clock) begin
        button_delay <= {button_delay[0],button};
    end
    wire synchronized_button = button_delay[1];
    
    reg button_state = 0;
    reg [15:0] counter = 0;
    
    wire button_idle = button_state == synchronized_button;
    wire counter_max = counter == MAX_TIME;
    
    always @(posedge clock) begin
        if(button_idle) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
            if(counter_max) begin
               button_state <= ~button_state; 
            end
        end
    end 
    
    assign stable_button = button_state;
    assign button_posedge = ~button_idle & counter_max & ~button_state;
    assign button_negedge = ~button_idle & counter_max & button_state;
    
endmodule
