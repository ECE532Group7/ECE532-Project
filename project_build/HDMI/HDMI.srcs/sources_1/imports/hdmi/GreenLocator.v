`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2018 02:56:29 PM
// Design Name: 
// Module Name: GreenLocator
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



module GreenLocator#(
    parameter ROW_BITS = 9,
    parameter COL_BITS = 10,
    
    parameter MAX_ROW = 479,    
    parameter MAX_COL = 639
    )
    (
        //Clock and Reset
        input clock,
	    input reset, //Resets on posedge

        //Input Frame buffer I/O
        //output [18:0] pixel_addr,
        output [ROW_BITS-1:0] pixel_row,
        output [COL_BITS-1:0] pixel_col,
        output request,
        input valid,
        input [23:0] pixel_data,
        
        input start,
        output done,
        
        //Green Stuff
        output [ROW_BITS-1:0] green_row,
        output [COL_BITS-1:0] green_col,
        output [ROW_BITS-1:0] green_size
    );
    
    //Threshold in accepting pixel
    //Must be lower than red and blue thresholds, higher than green threshold
    //localparam RED_THRESHOLD = 25;
    //localparam GREEN_THRESHOLD = 225;
    //localparam BLUE_THRESHOLD = 25;
    localparam DIFF_THRESHOLD = 50;
    
    //Position counters
    reg [ROW_BITS-1:0] row, n_row;
    reg [18:0] addr_reg, n_addr_reg;
    reg [COL_BITS-1:0] col, n_col;
    
    //Position of the green object in outbound frame
    reg [ROW_BITS-1:0] green_row_out, n_green_row_out;
    reg [COL_BITS-1:0] green_col_out, n_green_col_out;
    reg [ROW_BITS-1:0] green_len_out, n_green_len_out;
    
    //Position of the green object in current frame
    reg [ROW_BITS-1:0] green_row_frame, n_green_row_frame;
    reg [COL_BITS-1:0] green_col_frame, n_green_col_frame;
    reg [ROW_BITS-1:0] green_len_frame, n_green_len_frame;
    
    //Longest segment of green in current row
    reg [COL_BITS-1:0] green_col_row, n_green_col_row;
    reg [ROW_BITS-1:0] green_len_row, n_green_len_row;
    
    //Position of current segment of green in current row 
    reg [COL_BITS-1:0] green_left_curr, n_green_left_curr;
    
    reg request_reg, n_request_reg;
    
    reg done_reg, n_done_reg;
    
    wire [7:0] red, green, blue;
    wire green_pixel;
    
    assign red = pixel_data[7:0];
    assign green = pixel_data[15:8];
    assign blue = pixel_data[23:16];
    
    //assign green_pixel = red < RED_THRESHOLD && green > GREEN_THRESHOLD && blue < BLUE_THRESHOLD;
    assign green_pixel = green > (red + DIFF_THRESHOLD) && green > (blue + DIFF_THRESHOLD); 
    
    //State will juggle between GREEN and NOT_GREEN when scanning the row for adjacent green lines
    //State will transition to RESET_COL when finished scanning the last pixel of a row
    //State will transition to RESET_FRAME when finished scanning the last row of the frame
    localparam RESET_FRAME = 0;
    localparam NOT_GREEN = 1;
    localparam GREEN = 2;
    localparam RESET_COL = 3;
    //Convert Reset Frame into a idle/start state.
    //Createa done signal, when in that state, except immediately after reset, done if at start
    
    reg [1:0] state, n_state;
    
    always @ (posedge clock) begin
        if(~reset) begin
            state <= RESET_FRAME;

            row <= 0;
            addr_reg <= 0;
            col <= 0;
            
    	    green_row_out <= 0;
    	    green_col_out <= 0;
    	    green_len_out <= 0;
    	    
    	    green_row_frame <= 0;
    	    green_col_frame <= 0;
    	    green_len_frame <= 0;
    	    
    	    green_col_row <= 0;
    	    green_len_row <= 0;
    	    
    	    green_left_curr <= 0;
    	    
    	    request_reg <= 0;
    	    done_reg <= 0;
        end
	else begin
            state <= n_state;

            row <= n_row;
            addr_reg <= n_addr_reg;
            col <= n_col;
            
    	    green_row_out <= n_green_row_out;
    	    green_col_out <= n_green_col_out;
    	    green_len_out <= n_green_len_out;
    	    
    	    green_row_frame <= n_green_row_frame;
    	    green_col_frame <= n_green_col_frame;
    	    green_len_frame <= n_green_len_frame;
    	    
    	    green_col_row <= n_green_col_row;
    	    green_len_row <= n_green_len_row;
    	    
    	    green_left_curr <= n_green_left_curr;
    	    
    	    request_reg <= n_request_reg;
    	    done_reg <= n_done_reg;
        end
    end
    
    always @(*) begin
	    n_state = state;

        n_row = row;
        n_addr_reg = addr_reg;
        n_col = col;
        
    	n_green_row_out = green_row_out;
    	n_green_col_out = green_col_out;
    	n_green_len_out = green_len_out;
        
    	n_green_row_frame = green_row_frame;
    	n_green_col_frame = green_col_frame;
    	n_green_len_frame = green_len_frame;
    	
    	n_green_col_row = green_col_row;
    	n_green_len_row = green_len_row;
    	
    	n_green_left_curr = green_left_curr;
    	
    	n_request_reg = request_reg;
    	n_done_reg = done_reg;
        case(state)
            RESET_FRAME: begin
                if(start) begin
                    n_state = NOT_GREEN;
                    n_done_reg = 0;
                    n_request_reg = 1;
                end
                else begin
                    n_state = RESET_FRAME;
                    n_done_reg = done_reg;
                    n_request_reg = 0;
                end
            
                n_row = 0;
                n_col = 0;
                n_addr_reg = 0;
                n_green_row_out = green_row_out;
                n_green_col_out = green_col_out;
                n_green_len_out = green_len_out;
                n_green_row_frame = 0;
                n_green_col_frame = 0;
                n_green_len_frame = 0;
                n_green_col_row = 0;
                n_green_len_row = 0;
            end
            NOT_GREEN: begin
                if(!valid || request) begin
                    n_state = NOT_GREEN;
                    
                    n_request_reg = 0;
                end
                else if (col >= MAX_COL) begin
                    n_state = RESET_COL;
                    
                    n_request_reg = 0;
                end
                else begin
                    n_request_reg = 1;
                    n_addr_reg = addr_reg + 1;
                    n_col = col + 1;
                    if(green_pixel) begin
                        n_state = GREEN;
                        
                        n_green_left_curr = col;
                    end
                    else begin
                        n_state = NOT_GREEN;
                    end
                end
            end
            GREEN: begin
                if(!valid || request) begin
                    n_state = GREEN;
                    
                    n_request_reg = 0;
                end
                else if (col >= MAX_COL) begin
                    n_state = RESET_COL;
                    
                    n_request_reg = 0;
                    if(col - green_left_curr > green_len_row) begin
                        n_green_len_row = col - green_left_curr + green_pixel;
                        n_green_col_row = green_left_curr;
                    end
                    else begin
                        n_green_len_row = green_len_row;
                        n_green_col_row = green_col_row;
                    end
                end
                else begin
                    n_request_reg = 1;
                    n_addr_reg = addr_reg + 1;
                    n_col = col + 1;
                    if(green_pixel) begin
                        n_state = GREEN;
                    end
                    else begin
                        n_state = NOT_GREEN;
                        if(col - green_left_curr > green_len_row) begin
                            n_green_len_row = col - green_left_curr;
                            n_green_col_row = green_left_curr;
                        end
                        else begin
                            n_green_len_row = green_len_row;
                            n_green_col_row = green_col_row;
                        end
                    end
                end
            end
            RESET_COL: begin
                n_col = 0;
                n_row = row + 1;
                n_addr_reg = addr_reg + 1;
                if(row >= MAX_ROW) begin
                    n_state = RESET_FRAME;
                    n_request_reg = 0;
                    n_done_reg = 1;
                    if(green_len_frame < green_len_row) begin
                        n_green_len_out = green_len_row;
                        n_green_col_out = green_col_row;
                        n_green_row_out = row;
                    end
                    else begin
                        n_green_len_out = green_len_frame;
                        n_green_col_out = green_col_frame;
                        n_green_row_out = green_row_frame;
                    end
                end
                else begin
                    n_state = NOT_GREEN;
                    n_request_reg = 1;
                    n_done_reg = 0;
                    if(green_len_frame < green_len_row) begin
                        n_green_len_frame = green_len_row;
                        n_green_col_frame = green_col_row;
                        n_green_row_frame = row;
                    end
                    else begin
                        n_green_len_frame = green_len_frame;
                        n_green_col_frame = green_col_frame;
                        n_green_row_frame = green_row_frame;
                    end
                end
            end
        endcase
    end
    
    assign request = request_reg;
    //assign pixel_addr = addr_reg;
    assign pixel_col = col;
    assign pixel_row = row;
    
    assign green_row = green_row_out;
    assign green_col = green_col_out;
    assign green_size = green_len_out;
    
    assign done = done_reg;
    
endmodule
