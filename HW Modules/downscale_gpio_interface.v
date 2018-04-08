`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2018 02:49:58 PM
// Design Name: 
// Module Name: downscale_gpio_interface
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


module downscale_gpio_interface(
        input clock,
        input reset,
        
        input in_port,
        output [31:0] out_port,
        output [31:0] out_port_2,
        
        output ready,
        input [18:0] group_address,
        input [12:0] selfie_address,
        input done
    );
    
    assign ready = in_port;
    assign out_port = group_address;
    assign out_port_2 = {done, {18{1'b0}}, selfie_address};
    
    
endmodule
