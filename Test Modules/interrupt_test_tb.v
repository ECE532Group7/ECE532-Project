`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2018 11:53:13 AM
// Design Name: 
// Module Name: interrupt_test_tb
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


module interrupt_test_tb(

    );
    
    reg clock;
    reg reset;
    reg [31:0] in_port;
    wire [31:0] out_port;
    
    reg button;
    wire [4:0] leds;
    
    reg [31:0] previous_out_port;
    wire interrupt;
    
    interrupt_test inst(
        .clock(clock),
        .reset(reset),
        .in_port(in_port),
        .out_port(out_port),
        
        .button(button),
        .leds(leds)
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
    
    always @(posedge clock) begin
        previous_out_port <= out_port;
    end
    
    task acknowledge;
        begin
            @(posedge interrupt);
            wait_cycles(5);
            in_port[25:24] = out_port[20:19];
        end
    endtask
    
    task press_button;
        begin
            button = 1;
            wait_cycles(5);
            button = 0;
        end
    endtask
    
    assign interrupt = previous_out_port != out_port;
    initial begin
        reset = 0;
        in_port = 0;
        button = 0;
        
        wait_cycles(3);
        
        reset = 1;
        
        wait_cycles(3);
        
        press_button;
        acknowledge;
        
        wait_cycles(400);
        
        $finish;
    end
    
endmodule
