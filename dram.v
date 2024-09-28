`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/14 00:10:30
// Design Name: 
// Module Name: dram
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

module dram # (
   parameter NUM_DATA = 512
    ) (
    input wire clk,              // 时钟信号
    input wire [7:0] data,       // 数据输入
    input wire [28:0] waddr_byte,       // 地址信号
    input wire [28:0] raddr_byte,
    input wire we,               // 写使能信号
    output reg [7:0] q           // 数据输出
);

    // 定义一个8位宽度、256字节深度的存储器
    reg [7:0] ram [0:NUM_DATA - 1];

    // RAM操作：同步写入，异步读取
    always @(posedge clk) begin
        if (we) begin
            ram[waddr_byte] <= data;   // 写操作
        end
        q <= ram[raddr_byte];          // 读操作
    end

endmodule


module dram_sec_conv  # (
   parameter NUM_DATA = 512
    )(
    input wire clk,              // 时钟信号
    input wire [15:0] data,       // 数据输入
    input wire [28:0] waddr_byte,       // 地址信号
    input wire [28:0] raddr_byte,
    input wire we,               // 写使能信号
    output wire [15:0] q           // 数据输出
);

    // 定义一个8位宽度、256字节深度的存储器
    (* ram_style = "block" *)reg [7:0] ram [0:NUM_DATA - 1];

    // RAM操作：同步写入，异步读取
    always @(posedge clk) begin
        if (we) begin
            ram[waddr_byte] <= data;   // 写操作
        end
               // 读操作
    end
    assign q = ram[raddr_byte];   

endmodule