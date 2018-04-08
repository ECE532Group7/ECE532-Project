`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2018 08:07:16 PM
// Design Name: 
// Module Name: frame_buffer_trigger_tb
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


module frame_buffer_trigger_tb(

    );
    
    reg clock;
    reg reset;
    reg [31:0] in_port;
    wire [31:0] out_port;
    
    wire [18:0] pixel_addr;
    wire request;
    wire valid;
    wire [23:0] pixel_data;
    
    reg button;
    wire [7:0] leds;
    
    reg [31:0] previous_out_port;
    wire interrupt;
    
    frame_buffer_trigger dut(
        .clock(clock),
        .reset(reset),
        .button(button),
        .leds(leds),
        
        .pixel_addr(pixel_addr),
        .request(request),
        .valid(valid),
        .pixel_data(pixel_data)
    );
    defparam dut.button_debouncer_inst.MAX_TIME = 16'h2;
    
    frame_buffer_interface inst(
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
    
    parameter DATA1 = {8'h24, 8'h12, 8'hf2};
    parameter DATA2 = {8'hf4, 8'hc2, 8'hfa};
    parameter IMAGE = {
        DATA1,
        DATA2,
        DATA2,
        DATA1,
        DATA2
    };
    reg error;
    
    always @(posedge clock) begin
        previous_out_port <= out_port;
    end
    
    task acknowledge;
        begin
            @(posedge interrupt);
            wait_cycles(5);
            in_port[25:24] = out_port[20:19];
            in_port[23:0] = IMAGE[(24*pixel_addr) +: 24];
        end
    endtask
    
    task press_button;
        begin
            button = 1;
            wait_cycles(5);
            button = 0;
        end
    endtask
    
    task validate;
        begin
            @(posedge valid);
            error = error | (pixel_data != IMAGE[(24*pixel_addr) +: 24]);
            wait_cycles(1);
        end
    endtask
    
    task fetch_pixel;
        begin
            press_button;
            acknowledge;
            validate;
        end 
    endtask 
    assign interrupt = previous_out_port != out_port;
    initial begin
        reset = 0;
        in_port = 0;
        button = 0;
        error = 0;
        
        wait_cycles(3);
        
        reset = 1;
        
        wait_cycles(3);
        
        fetch_pixel;
        fetch_pixel;
        
        wait_cycles(40);
        
        $finish;
    end
endmodule
