`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 16:54:19
// Design Name: 
// Module Name: systolic_array
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


`include "sys_array_block.v"
module systolic_array #(
    parameter DATA_WIDTH = 8,
    parameter IMG_COL = 10
)(
    input wire clk,
    input wire rst,
    input wire transmit_en,
    input wire [DATA_WIDTH - 1:0] inp_west0,
    input wire [DATA_WIDTH - 1:0] inp_west4,
    input wire [DATA_WIDTH - 1:0] inp_west8,
    input wire [DATA_WIDTH - 1:0] inp_west12,
    input wire [DATA_WIDTH - 1:0] inp_north0,
    input wire [DATA_WIDTH - 1:0] inp_north1,
    input wire [DATA_WIDTH - 1:0] inp_north2,
    input wire [DATA_WIDTH - 1:0] inp_north3,
    output wire [DATA_WIDTH - 1:0] dout_c1,
    output wire [DATA_WIDTH - 1:0] dout_c2,
    output wire [DATA_WIDTH - 1:0] dout_c3,
    output wire [DATA_WIDTH - 1:0] dout_c4,
    output wire out_valid1,
    output wire out_valid2,
    output wire out_valid3,
    output wire out_valid4,
    output wire sys_done,
    output reg sys_en
);
	reg done;
	localparam LENGTH = IMG_COL * IMG_COL;
	reg [5:0] count;
	reg [15:0] vld_cnt1,vld_cnt2,vld_cnt3,vld_cnt4;
	
	assign sys_done = (vld_cnt1 >= LENGTH) && (vld_cnt2 >= LENGTH) && (vld_cnt3 >= LENGTH) && (vld_cnt4 >= LENGTH) ;

	wire time1 = count >= 16 ? ((count % 16 == 0) ? 1 : 0 ): 0;
	wire time2 = count >= 16 ? ((count % 16 == 1) ? 1 : 0 ): 0;
	wire time3 = count >= 16 ? ((count % 16 == 2) ? 1 : 0 ): 0;
	wire time4 = count >= 16 ? ((count % 16 == 3) ? 1 : 0 ): 0;
	wire time5 = count >= 16 ? ((count % 16 == 4) ? 1 : 0 ): 0;
	wire time6 = count >= 16 ? ((count % 16 == 5) ? 1 : 0 ): 0;
	wire time7 = count >= 16 ? ((count % 16 == 6) ? 1 : 0 ): 0;
	
	assign dout_c1 = time1 ? result0 : (time2 ? result4 : (time3 ? result8 : (time4 ? result12 : 0)));
	assign dout_c2 = time2 ? result1 : (time3 ? result5 : (time4 ? result9 : (time5 ? result13 : 0)));
	assign dout_c3 = time3 ? result2 : (time4 ? result6 : (time5 ? result10 : (time6 ? result14 : 0)));
	assign dout_c4 = time4 ? result3 : (time5 ? result7 : (time6 ? result11 : (time7 ? result15 : 0)));

	assign out_valid1 = vld_cnt1 < LENGTH ? (time1 | time2 | time3 | time4) : 0;
	assign out_valid2 = vld_cnt2 < LENGTH ? (time2 | time3 | time4 | time5) : 0;
	assign out_valid3 = vld_cnt3 < LENGTH ? (time3 | time4 | time5 | time6) : 0;
	assign out_valid4 = vld_cnt4 < LENGTH ? (time4 | time5 | time6 | time7) : 0;



	
	wire [DATA_WIDTH -1:0] outp_south0, outp_south1, outp_south2, outp_south3, outp_south4, outp_south5, outp_south6, outp_south7, outp_south8, outp_south9, outp_south10, outp_south11, outp_south12, outp_south13, outp_south14, outp_south15;
	wire [DATA_WIDTH -1:0] outp_east0, outp_east1, outp_east2, outp_east3, outp_east4, outp_east5, outp_east6, outp_east7, outp_east8, outp_east9, outp_east10, outp_east11, outp_east12, outp_east13, outp_east14, outp_east15;
	wire [DATA_WIDTH -1:0] result0, result1, result2, result3, result4, result5, result6, result7, result8, result9, result10, result11, result12, result13, result14, result15;
	
	
	
	//from north and west
	block P0 (inp_north0, inp_west0, clk, rst, outp_south0, outp_east0, result0);
	//from north
	block P1 (inp_north1, outp_east0, clk, rst, outp_south1, outp_east1, result1);
	block P2 (inp_north2, outp_east1, clk, rst, outp_south2, outp_east2, result2);
	block P3 (inp_north3, outp_east2, clk, rst, outp_south3, outp_east3, result3);
	
	//from west
	block P4 (outp_south0, inp_west4, clk, rst, outp_south4, outp_east4, result4);
	block P8 (outp_south4, inp_west8, clk, rst, outp_south8, outp_east8, result8);
	block P12 (outp_south8, inp_west12, clk, rst, outp_south12, outp_east12, result12);
	
	//no direct inputs
	//second row
	block P5 (outp_south1, outp_east4, clk, rst, outp_south5, outp_east5, result5);
	block P6 (outp_south2, outp_east5, clk, rst, outp_south6, outp_east6, result6);
	block P7 (outp_south3, outp_east6, clk, rst, outp_south7, outp_east7, result7);
	//third row
	block P9 (outp_south5, outp_east8, clk, rst, outp_south9, outp_east9, result9);
	block P10 (outp_south6, outp_east9, clk, rst, outp_south10, outp_east10, result10);
	block P11 (outp_south7, outp_east10, clk, rst, outp_south11, outp_east11, result11);
	//fourth row
	block P13 (outp_south9, outp_east12, clk, rst, outp_south13, outp_east13, result13);
	block P14 (outp_south10, outp_east13, clk, rst, outp_south14, outp_east14, result14);
	block P15 (outp_south11, outp_east14, clk, rst, outp_south15, outp_east15, result15);
	
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			done <= 0;
			count <= 0;
			sys_en <= 0;
			vld_cnt1 <= 0;
			vld_cnt2 <= 0;

			vld_cnt3 <= 0;

			vld_cnt4 <= 0;

		end
		else begin
			if(transmit_en) 
				sys_en <= 1;
			if (transmit_en && !sys_en)begin
				
						vld_cnt1 <= 0;
						vld_cnt2 <= 0;
						vld_cnt3 <= 0;
						vld_cnt4 <= 0;
			end
				if (sys_en)begin
					if (out_valid1)
						vld_cnt1 <= vld_cnt1 +1;
					if (out_valid2)
						vld_cnt2 <= vld_cnt2 +1;
					if (out_valid3)
						vld_cnt3 <= vld_cnt3 +1;
					if (out_valid4)
						vld_cnt4 <= vld_cnt4 +1;
					if(count == 22) begin //9
						done <= 1;
						count <= 0;
					end
					else begin
						done <= 0;
						count <= count + 1;
					end

					if (sys_done)begin
						sys_en <= 0;
						done <= 0;
						count <= 0;
					end
				end
		end	
	end 
	
		      
endmodule
		      
