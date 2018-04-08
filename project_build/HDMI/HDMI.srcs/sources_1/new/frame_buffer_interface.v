`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2018 09:29:02 PM
// Design Name: 
// Module Name: frame_buffer_interface
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


module frame_buffer_interface #(
    )(
        //I/O interface to AXI GPIO block
        input clock,
        input reset, 
        input [31:0] in_port,
        output reg [31:0] out_port,
        
        //I/O interface to green locator
        //input [18:0] pixel_addr,
        input [8:0] pixel_row,
        input [9:0] pixel_col,
        input request,
        output reg valid,
        output reg [23:0] pixel_data
    );
    
    reg [1:0] id, n_id;
    reg [31:0] n_out_port;
    reg n_valid;
    reg [23:0] n_pixel_data;
    
    localparam VALID_PIXEL = 0;
    localparam FETCHING_REQUEST = 1;
    
    reg [0:0] state, n_state;
    
    always @(posedge clock) begin
        if(~reset) begin
            out_port = 0;
            state = VALID_PIXEL;
            valid = 0;
            pixel_data = 0;
            id = 1;
        end
        else begin
            out_port <= n_out_port;
            state <= n_state;
            valid <= n_valid;
            pixel_data <= n_pixel_data;
            id <= n_id;
        end
    end
    always @(*) begin
        n_out_port = out_port;
        n_state = state;
        n_valid = valid;
        n_pixel_data = pixel_data;
        n_id = id;
        
        case (state)
            VALID_PIXEL: begin
                if(request) begin
                    //n_out_port = {id,pixel_addr};
                    n_out_port = {id,pixel_col,pixel_row};
                    n_state = FETCHING_REQUEST;
                    
                    n_valid = 0;
                end
                else begin
                    n_out_port = out_port;
                    n_state = VALID_PIXEL;
                    
                    n_valid = valid;
                end
            end
            FETCHING_REQUEST: begin
                if(in_port[25:24] == id) begin
                    n_valid = 1;
                    n_pixel_data = in_port[23:0];
                    
                    n_state = VALID_PIXEL;
                    n_id = id + 1;
                end
                else begin
                    n_valid = 0;
                    n_pixel_data = pixel_data;
                    
                    n_state = FETCHING_REQUEST;
                    n_id = id;
                end
            end
            default: begin
                n_state = VALID_PIXEL;
            end
        endcase
    end
    
    //valid logic will be set to 0 on new request, turn high after microblaze return pulse for valid
    
    //Reading behaviour
    //behaviour will be gsl sends pixel address and pulses request.
    //On request pulse, deassert valid, send request to microblaze. Address sent to the microblaze will be the DDR address 
    //Microblaze fetches request, and sends it to out_port, along with pulsing bit for valid.
    //When frame_buffer_interface sees valid, set r_valid to 1 and hold pixel data.
    
    //all the logic goes here
    //Control logic needs to know there is a valid frame, then activate gsl, then activate downscale, then activate merge, then send done signal
    //Need to fetch frame, scan for green box, spit out coordinates
    //Need to take coordinates, downscale selfie image
    //Need to take coordinates, send message to microblaze to modify certain pixels

    //How to do interrupt (maybe)
    // add a new entry to const ivt_t ivt[] in video_demo.c, adding the id the interrupt triggers, the function it calls, etc.
    // add this functionfnEnableInterrupts(&intc, &ivt[0], sizeof(ivt)/sizeof(ivt[0])); to enable that interrupt, replacing 0 with the index in ivt[]
    // In theory, this should cause the processor to receive an interrupt whenever the interrupt bit at that id triggers
    
endmodule
