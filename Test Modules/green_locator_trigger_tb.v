`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2018 07:59:02 PM
// Design Name: 
// Module Name: green_locator_trigger_tb
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


module green_locator_trigger_tb(

    );
    parameter ROW_BITS = 9;
    parameter COL_BITS = 10;
    
    parameter MAX_ROW = 2;
    parameter MAX_COL = 2;
        
    parameter NUM_LOOP = (MAX_ROW + 1) * (MAX_COL + 1);
    
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
    reg [31:0] in_port;
    wire [31:0] out_port;
    
    wire [18:0] pixel_addr;
    wire request;
    wire valid;
    wire [23:0] pixel_data;
    
    reg [31:0] previous_out_port;
    wire interrupt;
    
    wire start;
    wire done;
    
    reg button;
    wire [7:0] leds;
    
    wire [ROW_BITS-1:0] green_row;
    wire [ROW_BITS-1:0] green_col;
    wire [ROW_BITS-1:0] green_size;
    
    green_locator_trigger #(
        .ROW_BITS(ROW_BITS),
        .COL_BITS(COL_BITS)
    ) dut (
        //Clock and Reset
        .clock(clock),
        .reset(reset), //Resets on posedge
        .button(button),
        .leds(leds),
    
        .start(start),
        .done(done),
    
        //Green Stuff
        .green_row(green_row),
        .green_col(green_col),
        .green_size(green_size)
    );
    defparam dut.button_debouncer_inst.MAX_TIME = 16'h2;
        
    GreenLocator#(
        .ROW_BITS(ROW_BITS),
        .COL_BITS(COL_BITS),
            
        .MAX_ROW(MAX_ROW),
        .MAX_COL(MAX_COL)
    ) gsl_inst (
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
        
     frame_buffer_interface fbi_inst(
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
              repeat(NUM_LOOP) begin
                acknowledge;
              end
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
          
          wait_cycles(40);
          
          $finish;
      end
endmodule
