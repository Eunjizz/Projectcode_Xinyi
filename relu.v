`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 15:59:26
// Design Name: 
// Module Name: relu
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

/*
module relu#(
    parameter DATA_IN_WIDETH=32,
    parameter PARA_WIDTH=8,
    parameter DATA_OUT_WIDETH=8
) 
(
    input signed [DATA_IN_WIDETH-1:0] din,  
    input ivalid,
    input [PARA_WIDTH-1:0]scaler, //ÓÒÒÆ
    input [PARA_WIDTH-1:0]scalel,//×óÒÆ
    output  ovalid,   
    output  signed [DATA_OUT_WIDETH-1:0] dout
);


assign ovalid=ivalid;
assign dout=ivalid?(din[DATA_IN_WIDETH-1]?0:(din>>>scaler)<<<scalel):0;

//assign dout=ivalid?(din[DATA_IN_WIDETH-1]?0:din):0;

endmodule

*/

module relu#(
    parameter DATA_WIDTH =16
) 
(
    input wire signed [DATA_WIDTH -1:0] din,  
    output wire signed [DATA_WIDTH -1:0] dout
);

    wire valid = (din >= 0) ? 1 : 0; 
    assign dout = valid ? din : 0;


endmodule
