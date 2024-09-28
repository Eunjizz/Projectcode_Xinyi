`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/22 19:20:48
// Design Name: 
// Module Name: full_connect
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

module full_connect#(
    parameter LENGTH_FC = 64,
    parameter DATA_WIDTH = 16,
    parameter FILTERBATCH = 4
    )
    (
    input wire clk, rst_n, start_to_cal,
    input wire ivalid1, ivalid2, ivalid3, ivalid4, 
    input wire [DATA_WIDTH - 1 : 0] data1, data2, data3, data4,
    input wire [DATA_WIDTH - 1 : 0] weight,
    input wire [DATA_WIDTH - 1 : 0] bias,
    input wire weight_valid,
    output wire [DATA_WIDTH * 2 - 1 : 0] result,
    output reg done
    );

    // wire [DATA_WIDTH * 2 - 1 : 0] out [0 : FILTERBATCH - 1][0 : LENGTH_FC - 1];
    reg [DATA_WIDTH - 1 : 0] data_array [0 : LENGTH_FC - 1];
    reg signed [DATA_WIDTH - 1 : 0] bia_reg ;
    reg signed [DATA_WIDTH - 1 : 0] weight_array [0 : FILTERBATCH - 1][0 : LENGTH_FC - 1];
    reg [DATA_WIDTH * 2 - 1 : 0] out [0 : FILTERBATCH - 1][0 : LENGTH_FC - 1];
    reg [$clog2(LENGTH_FC) - 1:0] cnt, cnt1, cnt2, cnt3 , cnt_o;
    reg [2:0] out_cnt;
    reg vldout;
    reg [5:0] cnt_w;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_w <= 0;
            end
        else begin
            if (weight_valid)begin
                if (cnt_w <= (LENGTH_FC << 2)) begin
                    if (cnt_w <= LENGTH_FC - 1) 
                        weight_array[0][cnt_w] <= weight;
                    if ((cnt_w <= (LENGTH_FC << 1) - 1) && (cnt_w >= LENGTH_FC))
                        weight_array[1][cnt_w - LENGTH_FC] <= weight;
                    if ((cnt_w <= (LENGTH_FC * 3) - 1) && (cnt_w >= (LENGTH_FC << 1)))
                        weight_array[2][cnt_w - (LENGTH_FC << 1)] <= weight;
                    if ((cnt_w <= (LENGTH_FC << 2) - 1) && (cnt_w >= (LENGTH_FC * 3)))
                        weight_array[3][cnt_w - (LENGTH_FC << 1) - LENGTH_FC] <= weight;
                    if  (cnt_w == (LENGTH_FC << 2))
                        bia_reg <= bias;
                    cnt_w <= cnt_w + 1;
                end
            end
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 0;
            cnt1 <= 0;
            cnt2 <= 0;
            cnt3 <= 0;
            out_cnt <= 0;
            cnt_o <= 0;
            done <= 0;
            vldout<=0;
            end
        else begin
            cnt1 <= cnt;
            cnt2 <= cnt1;
            cnt3 <= cnt2;

            if (ivalid2)
                    //out[1][cnt1] <= data2 * weight_array[1][cnt1] + biasArray[1];
                    out[1][cnt1] <= data2 * weight_array[1][cnt1] + bia_reg;
            if (ivalid3)
                    out[2][cnt2] <= data3 * weight_array[2][cnt2] + bia_reg;
                    
            if (ivalid4)
                    out[3][cnt3] <= data4 * weight_array[3][cnt3] + bia_reg;

            if (ivalid1)begin
                done <= 0;
                    out[0][cnt] <= data1 * weight_array[0][cnt] + bia_reg;
                cnt <= cnt + 1;
                if(cnt >= LENGTH_FC - 1) begin
                    cnt <= 0;
                    vldout <= 1;
                end
            end
            if (vldout)begin
                cnt_o <= cnt_o + 1;
                if (cnt_o >= LENGTH_FC - 1) begin
                    out_cnt <= out_cnt + 1;
                    cnt_o <= 0;
                    if (out_cnt == 3) begin
                        out_cnt <= 0;
                        vldout <= 0;
                        done <= 1;
                    end
                end
            end
        end
    end


     assign result = vldout ? out[out_cnt][cnt_o] : 0;
endmodule



/*
    parameter IMG_COL = 6,
    parameter IMG_ROW = 6,
    parameter DATA_WIDTH = 16,
    parameter LENGTH = IMG_COL * IMG_ROW,
    //parameter BITWIDTH = 8,
    //parameter LENGTH = 25,
    parameter FILTERBATCH = 1
    )
    (
    input valid_input,
    //input [DATA_WIDTH * LENGTH - 1 : 0] data,
    input [DATA_WIDTH - 1 : 0] data,
    input [DATA_WIDTH * LENGTH * FILTERBATCH - 1 : 0] weight,
    input [DATA_WIDTH * FILTERBATCH - 1 : 0] bias,
    // output [DATA_WIDTH * 2 * FILTERBATCH - 1 : 0] result
    output [DATA_WIDTH * 2 - 1 : 0] result


    );


    wire [DATA_WIDTH * 2 - 1:0] out [0:FILTERBATCH - 1][0:LENGTH - 1];
    wire signed [DATA_WIDTH - 1:0] biasArray[0:FILTERBATCH - 1];
    reg signed [DATA_WIDTH * 2 - 1:0] resultArray [0:FILTERBATCH - 1];

    reg [DATA_WIDTH - 1 : 0] data_array [0 : LENGTH - 1];
    reg [DATA_WIDTH * 2 - 1] result_array [];

    
    
    
    genvar i, j;
    generate
        for(i = 0; i < FILTERBATCH; i = i + 1) begin
            assign biasArray[i] = bias[(i + 1) * DATA_WIDTH - 1: i * DATA_WIDTH];
            assign result[(i + 1) * DATA_WIDTH * 2 - 1: i * DATA_WIDTH * 2] = resultArray[i];
        end
    endgenerate
    
    generate 
        for(i = 0; i < FILTERBATCH; i = i + 1) begin
            for(j = 0; j < LENGTH; j = j + 1) begin
                //Mult#(DATA_WIDTH) mult(data[(j + 1) * DATA_WIDTH - 1:j * DATA_WIDTH], weight[(i * LENGTH + j) * DATA_WIDTH + DATA_WIDTH - 1 : (i * LENGTH + j) * DATA_WIDTH], out[i][j]);

                assign out[i][j] = data[(j + 1) * DATA_WIDTH - 1:j * DATA_WIDTH] * weight[(i * LENGTH + j) * DATA_WIDTH + DATA_WIDTH - 1 : (i * LENGTH + j) * DATA_WIDTH];
            end
        end
    endgenerate
    
    integer sum, m, n;
    always @(*) begin
        for(m = 0; m < FILTERBATCH; m = m + 1) begin
            sum = 0;
            for(n = 0; n < LENGTH; n = n + 1) begin
                sum = sum + out[m][n];
            end
            sum = sum + biasArray[m];
            resultArray[m] = sum;
        end
    end
    
    // always @(posedge clk) begin
    //     if(clken == 1) begin
    //         result = out2;
    //     end
    // end 
    
endmodule
*/




/*
module full_connect#(
    parameter DATA_WIDTH = 16,
    parameter IMG_COL = 6,
    parameter IMG_ROW = 6//,
    //parameter FILTERBATCH = 1
)

(
    input [DATA_WIDTH * IMG_COL * IMG_ROW - 1 : 0] data,
    input [DATA_WIDTH * IMG_COL * IMG_ROW - 1 : 0] weight,
    input [DATA_WIDTH - 1 : 0] bias,
    output [DATA_WIDTH * 2  - 1 : 0] result
);
    
    // Intermediate signals
    wire [DATA_WIDTH * 2 - 1:0] out [0:IMG_COL * IMG_ROW - 1];
    wire signed [DATA_WIDTH - 1:0] biasValue;
    reg signed [DATA_WIDTH * 2 - 1:0] resultValue;
    
    // Assign bias value
    assign biasValue = bias;
    assign result = resultValue;
    
    // Generating multipliers
    genvar i;
    generate 
        for (i = 0; i < IMG_COL * IMG_ROW; i = i + 1) begin
            // Performing the multiplication directly
            assign out[i] = data[(i + 1) * DATA_WIDTH - 1 : i * DATA_WIDTH] * weight[(i + 1) * DATA_WIDTH - 1 : i * DATA_WIDTH];
        end
    endgenerate
    
    // Accumulating the results
    integer sum, j;
    always @(*) begin
        sum = 0;
        for (j = 0; j < IMG_COL * IMG_ROW; j = j + 1) begin
            sum = sum + out[j];
        end
        sum = sum + biasValue;
        resultValue = sum;
    end
    
endmodule

*/
