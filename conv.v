`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/20 16:55:50
// Design Name: 
// Module Name: conv
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

module conv #(
    parameter IMG_COL = 8,
    parameter IMG_ROW = 8,
    parameter DATA_WIDTH = 16

    )(
    input wire clk,
    input wire rst,
    input wire start,
    input wire ker_valid,
    input wire [DATA_WIDTH - 1:0] img_data,
    input wire [DATA_WIDTH - 1 : 0] kernel1, kernel2, kernel3, kernel4,
    output wire conv_done,
    output wire [DATA_WIDTH - 1:0] conv_dout1,conv_dout2,conv_dout3,conv_dout4,
    output  wire conv_ovalid1, conv_ovalid2, conv_ovalid3, conv_ovalid4,
    output wire fst_conv_opvld, im2co_done
);
    localparam TOTAL_LENGTH = IMG_ROW * IMG_COL;

    wire [DATA_WIDTH - 1:0] inp_west0, inp_west4, inp_west8, inp_west12, inp_north0, inp_north1, inp_north2, inp_north3;
    wire transmit_en;
    wire sys_ovalid1, sys_ovalid2, sys_ovalid3, sys_ovalid4;

    assign conv_ovalid1 = sys_ovalid1;
    assign conv_ovalid2 = sys_ovalid2;
    assign conv_ovalid3 = sys_ovalid3;
    assign conv_ovalid4 = sys_ovalid4;

    wire [DATA_WIDTH - 1 : 0] ker1, ker2, ker3, ker4;

    assign ker1 = kernel1;
    assign ker2 = kernel2;
    assign ker3 = kernel3;
    assign ker4 = kernel4;



    img2col #(
        .IMG_COL(IMG_COL),
        .IMG_ROW(IMG_ROW),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_img2col (
        .clk(clk),
        .rst(rst),
        .start(start),
        .ker_valid(ker_valid),
        .img_data(img_data),
        .kernel1(ker1),
        .kernel2(ker2),
        .kernel3(ker3),
        .kernel4(ker4),
        .inp_west0(inp_west0),
        .w4reg(inp_west4),
        .w8reg2(inp_west8),
        .w12reg3(inp_west12),
        .inp_north0(inp_north0),
        .n1reg(inp_north1),
        .n2reg2(inp_north2),
        .n3reg3(inp_north3),
        .transmit_en(transmit_en),
        .done(im2co_done)
    );


    systolic_array #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_COL(IMG_COL - 3)
    ) u_systolic_array (
        .inp_west0(inp_west0),
        .inp_west4(inp_west4),
        .inp_west8(inp_west8),
        .inp_west12(inp_west12),
        .inp_north0(inp_north0),
        .inp_north1(inp_north1),
        .inp_north2(inp_north2),
        .inp_north3(inp_north3),
        .dout_c1(conv_dout1),
        .dout_c2(conv_dout2),
        .dout_c3(conv_dout3),
        .dout_c4(conv_dout4),
        .out_valid1(sys_ovalid1),
        .out_valid2(sys_ovalid2),
        .out_valid3(sys_ovalid3),
        .out_valid4(sys_ovalid4),
        .clk(clk),
        .rst(rst),
        .sys_done(conv_done),
        .sys_en (fst_conv_opvld),
        .transmit_en(transmit_en)
    );


endmodule
