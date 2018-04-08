`timescale 1ns / 1ps

module pmod_gpio_interface(

    input [7:0] ja,
    input [7:0] jb,
    input clk,
    output reg [31:0] pixelData,
    output reg wen,
    output wire [3:0] wen_a,
    output reg [31:0] addr,
    output [7:0] led

    ); 

    localparam FIRST_BYTE = 2'b00, SECOND_BYTE = 2'b01, THIRD_BYTE = 2'b10;    

    wire reset;
    assign reset = jb[1];

    reg [1:0] state;
    reg [1:0] n_state;
    reg pi_wen;
    reg [31:0] pi_pixelData;

    assign wen_a = {wen,wen,wen,wen};

    //Test input with leds
    //assign led[0] = pi_wen;
    //assign led[1] = wen;
    //assign led[3:2] = state;
    assign led = pi_pixelData[7:0];

    //FSM - Resets state, changes state, and manages BRAM signals
    always@(posedge jb[0]) begin

        addr <= addr;
        //pi_wen <= 'b0;  

        if(reset) begin

            state <= FIRST_BYTE;
            //Start at 0x4
            addr <= 'h0;
            //pi_wen <= 'b0;
            
        end else begin
        
            state <= n_state;

            //Will result in several writes but all to same addr so its fine (because of 100MHz bram clock)
            if(state == THIRD_BYTE) begin
    
                addr <= addr + 'd4;
                //pi_wen <= 'b1;
    
            end          
        end
    end
    
    always@(posedge jb[0]) begin
        
        pi_wen <= 'b0;
        if(reset) begin
            pi_wen <= 'b0;
        end
        else
        begin
            if(state == THIRD_BYTE) begin
                pi_wen <= 'b1;
            end
        end
    
    end

    //Synchronize write enable across clock domains
    always@(posedge clk) begin
        if(pi_wen) begin
            wen <= 1'b1;
            pixelData <= pi_pixelData;
        end 
        else if(pi_wen == 1'b0)
        begin
            wen <= 1'b0; 
            pixelData <= pixelData;
        end
    end


    always@(*) begin

            case(state)

                2'bxx: n_state = FIRST_BYTE;

                FIRST_BYTE: n_state = SECOND_BYTE;

                SECOND_BYTE: n_state = THIRD_BYTE;

                THIRD_BYTE: n_state = FIRST_BYTE;

                default: n_state = FIRST_BYTE;     

            endcase

    end

    //On trigger collect byte
    always@(posedge jb[0]) begin

        //Zero stuff remaining bits
        pi_pixelData <= {8'b0, pi_pixelData[23:0]};
    
        if(state == FIRST_BYTE)
        begin

            pi_pixelData[7:0] <= ja;

        end
        else if(state == SECOND_BYTE)
        begin

            pi_pixelData[15:8] <= ja;

        end
        else if(state == THIRD_BYTE)
        begin

            pi_pixelData[23:16] <= ja;

        end

    end

endmodule
