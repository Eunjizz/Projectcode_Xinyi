`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 16:52:52
// Design Name: 
// Module Name: sys_array_block
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


module block(inp_north, inp_west, clk, rst, outp_south, outp_east, result);
	parameter DATA_WIDTH = 8;
	input wire [DATA_WIDTH - 1:0] inp_north, inp_west;
	output reg [DATA_WIDTH - 1:0] outp_south, outp_east;
	input wire clk, rst;
	output reg [2 * DATA_WIDTH - 1:0] result;
	wire [2 * DATA_WIDTH - 1:0] multi;
	always @(posedge rst or posedge clk) begin
		if(rst) begin
			result <= 0;
			outp_east <= 0;
			outp_south <= 0;
		end
		else begin
			result <= result + multi;
			outp_east <= inp_west;
			outp_south <= inp_north;
		end
	end
	assign multi = inp_north*inp_west;
endmodule
