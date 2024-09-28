`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/28 16:55:50
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


module cnn #(
    parameter IMG_COL = 28,
    parameter IMG_ROW = 28,
    parameter DATA_WIDTH = 16,
    parameter FILTERBATCH = 4

    )(
    input wire clk,
    input wire rst,
    // input wire start,
    // input wire [DATA_WIDTH - 1 : 0] kernel1, kernel2, kernel3, kernel4,
    // input wire[DATA_WIDTH - 1 : 0] weight,
    // input wire [DATA_WIDTH - 1 : 0] bias,
    // input wire [DATA_WIDTH - 1:0] img_data,
    output wire done,

    output reg [2:0]  o_cnn_arid,
    output reg [31:0] o_cnn_araddr,
    output reg [7:0]  o_cnn_arlen,
    output reg [2:0]  o_cnn_arsize,
    output reg [1:0]  o_cnn_arburst,
    output reg        o_cnn_arlock,
    output reg [3:0]  o_cnn_arcache,
    output reg [2:0]  o_cnn_arprot,
    output reg [3:0]  o_cnn_arregion,
    output reg [3:0]  o_cnn_arqos,
    output reg        o_cnn_arvalid,
    input wire        i_cnn_arready,

    input wire [3:0]   i_cnn_rid,
    input wire [63:0]  i_cnn_rdata,
    input wire [1:0]   i_cnn_rresp,
    input wire         i_cnn_rlast,
    input wire         i_cnn_rvalid,
    output reg        o_cnn_rready,


    input wire [31:0] wb_cnn_adr_i,
    input wire [31:0] wb_cnn_dat_i,
    input wire [3:0] wb_cnn_sel_i,
    input wire  wb_cnn_we_i,
    input wire   wb_cnn_cyc_i,
    input wire   wb_cnn_stb_i,
    input wire [2:0] wb_cnn_cti_i,
    input wire [1:0] wb_cnn_bte_i,
    output wire [31:0] wb_cnn_dat_o,
    output wire     wb_cnn_ack_o,
    output wire     wb_cnn_err_o,
    output wire     wb_cnn_rty_o
);  


    wire adralign = (wb_cnn_adr_i[1:0] == 2'b0) && (wb_cnn_sel_i == 4'hf);
    wire valid = wb_cnn_cyc_i && wb_cnn_stb_i;
    assign wb_cnn_ack_o = adralign && valid ;
    assign wb_cnn_err_o = (!adralign) && valid ;

    reg START_READ;

    always @(posedge clk or posedge rst) begin
    if (rst) begin
        START_READ <= 0;
    end
    else begin
        if (wb_cnn_ack_o && wb_cnn_we_i) begin
            case (wb_cnn_adr_i[3:2])
                2'b00:START_READ <= wb_cnn_dat_i[0];
                default:;
            endcase // wb_cnn_adr_i[3:2]
        end
    end
end




    localparam COL_SEC = IMG_COL - 3;
    localparam ROW_SEC = IMG_ROW - 3 ;
    localparam CONV_SEC_LENGTH = COL_SEC * ROW_SEC;
    localparam TOTAL_LENGTH = IMG_ROW * IMG_COL;
    localparam LENGTH_POOLING = (IMG_ROW - 3) * (IMG_COL - 3);
    localparam LENGTH_FC = ((ROW_SEC - 3)/2) * ((COL_SEC - 3) / 2);
    localparam NUM_DATA = TOTAL_LENGTH + 65 + 256 + (LENGTH_FC << 2); //image data + the first conv + the second conv + weight in FC + bias


    // �????�???
    parameter IDLE = 2'b00;
    parameter READ_ADDRESS = 2'b01;
    parameter READ_DATA = 2'b11;
    parameter WAIT_STATE = 2'b10;
    reg start;
    reg [1:0] axi_state;
    reg [31:0] start_addr = 32'h0000_8000;
    reg [28 : 0] rd_cnt;
    //reg [28 : 0] rk_cnt1, rk_cnt2, rk_cnt3, rk_cnt4;

    // �????�?
    always @(posedge clk or posedge rst) begin
    if (rst) begin
        axi_state <= IDLE;
        o_cnn_arid     <= 3'b000;
        o_cnn_araddr   <= 32'h0000_8000;  // 读地�?初始�?
        o_cnn_arlen    <= 8'b00000000;    // 传输长度初始化为1个传�?
        o_cnn_arsize   <= 3'b011;         // 每次传输64位（8字节�?
        o_cnn_arburst  <= 2'b01;          // INCR模式
        o_cnn_arlock   <= 1'b0;           // 正常访问
        o_cnn_arcache  <= 4'b0000;        // 缓存属�?��?�合于普通内�?
        o_cnn_arprot   <= 3'b000;         // 正常访问
        o_cnn_arregion <= 4'b0000;        // 读地�?区域
        o_cnn_arqos    <= 4'b0000;        // 质量服务QOS
        
        o_cnn_arvalid <= 0;
        o_cnn_rready <= 0;

    end else begin
        // 默认信号
        case (axi_state)
            IDLE: begin
                if (d_addr > NUM_DATA) begin

                    axi_state <= WAIT_STATE;
                end else begin
                    //if (START_READ) begin
                    o_cnn_arvalid <= 1;
                    axi_state <= READ_ADDRESS;
                    //end else
                    //axi_state <= IDLE;
                end
            end

            READ_ADDRESS: begin
                
                if (i_cnn_arready) begin
                    o_cnn_arvalid <= 0;
                    o_cnn_rready <= 1;
                    axi_state <= READ_DATA;
                end
            end

            READ_DATA: begin
                
                if (i_cnn_rvalid && i_cnn_rlast) begin
                    o_cnn_rready <= 0;
                    o_cnn_araddr <= o_cnn_araddr + 32'h8;
                    axi_state <= IDLE;
                end
            end

            WAIT_STATE: begin

                axi_state <= WAIT_STATE;
            end

            default: axi_state <= IDLE;
        endcase

        // 控制读取操作的开始和计数�?
        
    end
end


    wire        i_cnn_arready;
    wire [3:0]   i_cnn_rid;
    wire [63:0]  i_cnn_rdata;
    wire [1:0]   i_cnn_rresp;
    wire         i_cnn_rlast;
    wire         i_cnn_rvalid;


    axi_mem_wrapper #(
        .ID_WIDTH(0),
        .MEM_SIZE(32'h10000),
        .mem_clear(0),
        .INIT_FILE("mem_cnn.mem")
    ) uut (
        .clk(clk),
        .rst_n(!rst),

        .i_arid(o_cnn_arid),
        .i_araddr(o_cnn_araddr),
        .i_arlen(o_cnn_arlen),
        .i_arsize(o_cnn_arsize),
        .i_arburst(o_cnn_arburst),
        .i_arvalid(o_cnn_arvalid),
        .o_arready(i_cnn_arready),

        .o_rid(i_cnn_rid),
        .o_rdata(i_cnn_rdata),
        .o_rresp(i_cnn_rresp),
        .o_rlast(i_cnn_rlast),
        .o_rvalid(i_cnn_rvalid),
        .i_rready(o_cnn_rready)
    );

    wire [28:0] d_addr = o_cnn_araddr[31:3] - start_addr[31:3];

    wire [DATA_WIDTH - 1 : 0] kernel1, kernel2, kernel3, kernel4,
                                kernel1_1, kernel1_2, kernel1_3, kernel1_4,
                                kernel2_1, kernel2_2, kernel2_3, kernel2_4,
                                kernel3_1, kernel3_2, kernel3_3, kernel3_4,
                                kernel4_1, kernel4_2, kernel4_3, kernel4_4;
    wire [DATA_WIDTH - 1 : 0] weight;
    wire [DATA_WIDTH - 1 : 0] bias;
    wire [DATA_WIDTH - 1:0] img_data;
    wire [DATA_WIDTH - 1 : 0] mem_dout, mem_dout1, mem_dout2, mem_dout3, mem_dout4;
    wire ker_valid1;
    wire weight_valid;

    assign img_data = (rd_cnt) <= TOTAL_LENGTH ? mem_dout : 0;
    assign kernel1 = (rd_cnt <= TOTAL_LENGTH + 16) && (rd_cnt > TOTAL_LENGTH) ? mem_dout : 0;
    assign kernel2 =  (rd_cnt <= TOTAL_LENGTH + 32) && (rd_cnt > TOTAL_LENGTH + 16) ? mem_dout : 0;
    assign kernel3 =  (rd_cnt <= TOTAL_LENGTH + 48) && (rd_cnt > TOTAL_LENGTH + 32) ? mem_dout : 0;
    assign kernel4 =  (rd_cnt <= TOTAL_LENGTH + 64) && (rd_cnt > TOTAL_LENGTH + 48) ? mem_dout : 0;
    //assign weight = (rd_cnt < (TOTAL_LENGTH << 1) + 64) && (rd_cnt >= TOTAL_LENGTH + 64) ? mem_dout : 0;
    //assign bias = (rd_cnt == (TOTAL_LENGTH << 1) + 65) ? mem_dout : 0;

    assign weight = (rd_cnt <= (TOTAL_LENGTH + 64 + (LENGTH_FC << 2))) && (rd_cnt > TOTAL_LENGTH + 64) ? mem_dout : 0;
    assign bias = (rd_cnt == (TOTAL_LENGTH + 65 + (LENGTH_FC << 2))) ? mem_dout : 0;
    

    assign kernel1_1 = (rd_cnt <= TOTAL_LENGTH + 16) && (rd_cnt > TOTAL_LENGTH) ? mem_dout1 : 0;
    assign kernel1_2 =  (rd_cnt <= TOTAL_LENGTH + 32) && (rd_cnt > TOTAL_LENGTH + 16) ? mem_dout1 : 0;
    assign kernel1_3 =  (rd_cnt <= TOTAL_LENGTH + 48) && (rd_cnt > TOTAL_LENGTH + 32) ? mem_dout1 : 0;
    assign kernel1_4 =  (rd_cnt <= TOTAL_LENGTH + 64) && (rd_cnt > TOTAL_LENGTH + 48) ? mem_dout1 : 0;

    assign kernel2_1 = (rd_cnt <= TOTAL_LENGTH + 16) && (rd_cnt > TOTAL_LENGTH) ? mem_dout2 : 0;
    assign kernel2_2 =  (rd_cnt <= TOTAL_LENGTH + 32) && (rd_cnt > TOTAL_LENGTH + 16) ? mem_dout2 : 0;
    assign kernel2_3 =  (rd_cnt <= TOTAL_LENGTH + 48) && (rd_cnt > TOTAL_LENGTH + 32) ? mem_dout2 : 0;
    assign kernel2_4 =  (rd_cnt <= TOTAL_LENGTH + 64) && (rd_cnt > TOTAL_LENGTH + 48) ? mem_dout2 : 0;

    assign kernel3_1 = (rd_cnt <= TOTAL_LENGTH + 16) && (rd_cnt > TOTAL_LENGTH) ? mem_dout3 : 0;
    assign kernel3_2 =  (rd_cnt <= TOTAL_LENGTH + 32) && (rd_cnt > TOTAL_LENGTH + 16) ? mem_dout3 : 0;
    assign kernel3_3 =  (rd_cnt <= TOTAL_LENGTH + 48) && (rd_cnt > TOTAL_LENGTH + 32) ? mem_dout3 : 0;
    assign kernel3_4 =  (rd_cnt <= TOTAL_LENGTH + 64) && (rd_cnt > TOTAL_LENGTH + 48) ? mem_dout3 : 0;

    assign kernel4_1 = (rd_cnt <= TOTAL_LENGTH + 16) && (rd_cnt > TOTAL_LENGTH) ? mem_dout4 : 0;
    assign kernel4_2 =  (rd_cnt <= TOTAL_LENGTH + 32) && (rd_cnt > TOTAL_LENGTH + 16) ? mem_dout4 : 0;
    assign kernel4_3 =  (rd_cnt <= TOTAL_LENGTH + 48) && (rd_cnt > TOTAL_LENGTH + 32) ? mem_dout4 : 0;
    assign kernel4_4 =  (rd_cnt <= TOTAL_LENGTH + 64) && (rd_cnt > TOTAL_LENGTH + 48) ? mem_dout4 : 0;

    assign ker_valid1 = (rd_cnt <= TOTAL_LENGTH + 64) && (rd_cnt > TOTAL_LENGTH) ? 1 : 0;
    assign weight_valid = (rd_cnt <= (TOTAL_LENGTH + 65 + (LENGTH_FC << 2))) && (rd_cnt > TOTAL_LENGTH + 64) ? 1 : 0;

    wire [28:0] ker_cnt1 = rd_cnt + 65 + (LENGTH_FC << 2);
    wire [28:0] ker_cnt2 = rd_cnt + 129 + (LENGTH_FC << 2);
    wire [28:0] ker_cnt3 = rd_cnt + 193 + (LENGTH_FC << 2);
    wire [28:0] ker_cnt4 = rd_cnt + 257 + (LENGTH_FC << 2);
    dram #(
        .NUM_DATA(NUM_DATA)

        ) u_ram(
        .clk(clk),
        .data(i_cnn_rdata[7:0]),
        .waddr_byte(d_addr),
        .raddr_byte(rd_cnt),
        .we(i_cnn_rvalid),
        .q(mem_dout)
    );
    
    dram  #(
        .NUM_DATA(NUM_DATA)

        )  u_ram_1(
        .clk(clk),
        .data(i_cnn_rdata[7:0]),
        .waddr_byte(d_addr),
        .raddr_byte(ker_cnt1),
        .we(i_cnn_rvalid),
        .q(mem_dout1)
    );
    dram  #(
        .NUM_DATA(NUM_DATA)

        )  u_ram_2(
        .clk(clk),
        .data(i_cnn_rdata[7:0]),
        .waddr_byte(d_addr),
        .raddr_byte(ker_cnt2),
        .we(i_cnn_rvalid),
        .q(mem_dout2)
    );
    
    dram  #(
        .NUM_DATA(NUM_DATA)

        )  u_ram_3(
        .clk(clk),
        .data(i_cnn_rdata[7:0]),
        .waddr_byte(d_addr),
        .raddr_byte(ker_cnt3),
        .we(i_cnn_rvalid),
        .q(mem_dout3)
    );
    
    dram  #(
        .NUM_DATA(NUM_DATA)

        )  u_ram_4(
        .clk(clk),
        .data(i_cnn_rdata[7:0]),
        .waddr_byte(d_addr),
        .raddr_byte(ker_cnt4),
        .we(i_cnn_rvalid),
        .q(mem_dout4)
    );
    

    // reg START;
    
    //wire [DATA_WIDTH - 1:0] inp_west0, inp_west4, inp_west8, inp_west12, inp_north0, inp_north1, inp_north2, inp_north3;
    //wire transmit_en;
    wire [DATA_WIDTH - 1:0] conv_dout1, conv_dout2, conv_dout3, conv_dout4;
    wire conv_done;
    wire [DATA_WIDTH - 1:0] relu_dout1, relu_dout2, relu_dout3, relu_dout4;

    wire [DATA_WIDTH - 1:0] conv1_dout1, conv1_dout2, conv1_dout3, conv1_dout4,
                            conv2_dout1, conv2_dout2, conv2_dout3, conv2_dout4,
                            conv3_dout1, conv3_dout2, conv3_dout3, conv3_dout4,
                            conv4_dout1, conv4_dout2, conv4_dout3, conv4_dout4;

    wire [DATA_WIDTH - 1:0] relu1_dout1, relu1_dout2, relu1_dout3, relu1_dout4,
                            relu2_dout1, relu2_dout2, relu2_dout3, relu2_dout4,
                            relu3_dout1, relu3_dout2, relu3_dout3, relu3_dout4,
                            relu4_dout1, relu4_dout2, relu4_dout3, relu4_dout4;


    wire conv_ovalid1, conv_ovalid2, conv_ovalid3, conv_ovalid4;
    wire [DATA_WIDTH - 1:0] pool_din1, pool_din2, pool_din3, pool_din4;
    wire [DATA_WIDTH - 1:0] pool_dout1, pool_dout2, pool_dout3, pool_dout4;
    wire pool_ovalid1, pool_ovalid2, pool_ovalid3, pool_ovalid4;
    wire fc_cal;

    wire [DATA_WIDTH * 2 - 1 : 0] cnn_result;


    assign pool_din1 = relu1_dout1 + relu2_dout1 + relu3_dout1 + relu4_dout1;
    assign pool_din2 = relu1_dout2 + relu2_dout2 + relu3_dout2 + relu4_dout2;
    assign pool_din3 = relu1_dout3 + relu2_dout3 + relu3_dout3 + relu4_dout3;
    assign pool_din4 = relu1_dout4 + relu2_dout4 + relu3_dout4 + relu4_dout4;
    




    reg [1:0] state ;
    parameter IDLE1 = 2'b00;
    parameter CONV1 = 2'b01;
    parameter CONV2 = 2'b11;
    parameter WAIT_DONE = 2'b10;
    reg start_conv2 , start_conv1;

    always @(posedge clk or posedge rst) begin : proc_
        if(rst) begin
            start_conv1 <= 0;
            start_conv2 <= 0;
            rd_cnt <= 0;
            start <= 0;
            state <= IDLE1;
        end else begin
            if (start) begin
                rd_cnt <= rd_cnt + 1;
                if (rd_cnt == (TOTAL_LENGTH + 65 + (LENGTH_FC << 2))) begin
                    rd_cnt <= 0;
                    start <= 0;
                end
            end
            case (state)
                IDLE1 :begin
                    if (axi_state == WAIT_STATE)begin
                        start <= 1;
                    end
                    if (start)begin
                        start_conv1 <= 1;
                        state <= CONV1;
                    end
                end
                CONV1: begin
                    if (fst_conv_done)begin 
                        start_conv1 <= 0;
                        start_conv2 <= 1;
                        state <= CONV2;
                    end
                end
                CONV2:begin
                    if (sec_conv_done)begin
                        start_conv2 <= 0;
                        state <= WAIT_DONE;
                    end
                end
                WAIT_DONE:begin
                    if (done)begin
                        state <= IDLE1; 
                    end
                    end
            endcase // state
        end
    end
    wire fst_conv_opvld;
    wire fst_conv_done,sec_conv_done;
    conv #(
        .IMG_COL(IMG_COL),
        .IMG_ROW(IMG_ROW),
        .DATA_WIDTH(DATA_WIDTH)
        ) conv_fst (
        .clk(clk),
        .rst(rst),
        .start(start_conv1),
        .img_data(img_data),
        .kernel1(kernel1),
        .kernel2(kernel2),
        .kernel3(kernel3),
        .kernel4(kernel4),
        .conv_dout1(conv_dout1),
        .conv_dout2(conv_dout2),
        .conv_dout3(conv_dout3),
        .conv_dout4(conv_dout4),
        .conv_done(fst_conv_done),
        .conv_ovalid1(conv_ovalid1),
        .conv_ovalid2(conv_ovalid2),
        .conv_ovalid3(conv_ovalid3),
        .conv_ovalid4(conv_ovalid4)
        );

 

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_relu1 (
        .din(conv_dout1),
        .dout(relu_dout1)
    );
    
    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_relu2 (
        .din(conv_dout2),
        .dout(relu_dout2)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_relu3 (
        .din(conv_dout3),
        .dout(relu_dout3)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_relu4 (
        .din(conv_dout4),
        .dout(relu_dout4)
    );

    wire conv2_im2co_done;
    // 信号定义
wire conv2_ovalid1, conv2_ovalid2, conv2_ovalid3, conv2_ovalid4;
reg [28:0] conv1_wcnt, conv1_rcnt;
reg [28:0] conv2_wcnt, conv2_rcnt;
reg [28:0] conv3_wcnt, conv3_rcnt;
reg [28:0] conv4_wcnt, conv4_rcnt;
wire [7:0] conv1_img_data, conv2_img_data, conv3_img_data, conv4_img_data;

// This block is for reading the data in second conv layer buffer, with 8 counters,each 2 of them are to conv1,2,3,4.
// As those counters reach the length of the parameter gave(numbers of image data for now), it is done.
always @(posedge clk or posedge rst) begin 
    if(rst) begin
        conv1_wcnt <= 0;
        conv1_rcnt <= 0;
        conv2_wcnt <= 0;
        conv2_rcnt <= 0;
        conv3_wcnt <= 0;
        conv3_rcnt <= 0;
        conv4_wcnt <= 0;
        conv4_rcnt <= 0;
    end else begin
        // conv1 逻辑
        if (start_conv1 && conv_ovalid1)
            conv1_wcnt <= conv1_wcnt + 1;
        if (start_conv2)
            conv1_rcnt <= conv1_rcnt + 1;
        if (conv1_wcnt == CONV_SEC_LENGTH)
            conv1_wcnt <= 0;
        if (conv1_rcnt == CONV_SEC_LENGTH)
            conv1_rcnt <= 0;

        // conv2 逻辑
        if (start_conv1 && conv_ovalid2)
            conv2_wcnt <= conv2_wcnt + 1;
        if (start_conv2)
            conv2_rcnt <= conv2_rcnt + 1;
        if (conv2_wcnt == CONV_SEC_LENGTH)
            conv2_wcnt <= 0;
        if (conv2_rcnt == CONV_SEC_LENGTH)
            conv2_rcnt <= 0;

        // conv3 逻辑
        if (start_conv1 && conv_ovalid3)
            conv3_wcnt <= conv3_wcnt + 1;
        if (start_conv2)
            conv3_rcnt <= conv3_rcnt + 1;
        if (conv3_wcnt == CONV_SEC_LENGTH)
            conv3_wcnt <= 0;
        if (conv3_rcnt == CONV_SEC_LENGTH)
            conv3_rcnt <= 0;

        // conv4 逻辑
        if (start_conv1 && conv_ovalid4)
            conv4_wcnt <= conv4_wcnt + 1;
        if (start_conv2) // 注意：这里根据具体需求设置下�?个过�?
            conv4_rcnt <= conv4_rcnt + 1;
        if (conv4_wcnt == CONV_SEC_LENGTH)
            conv4_wcnt <= 0;
        if (conv4_rcnt == CONV_SEC_LENGTH)
            conv4_rcnt <= 0;
    end
end

// 实例化四�? dram_sec_conv 模块
dram_sec_conv #(
    .NUM_DATA(CONV_SEC_LENGTH)
    ) mem_conv1_img(
    .clk(clk),
    .data(relu_dout1),
    .waddr_byte(conv1_wcnt),
    .raddr_byte(conv1_rcnt),
    .we(conv_ovalid1),
    .q(conv1_img_data)
);

dram_sec_conv #(
    .NUM_DATA(CONV_SEC_LENGTH)
    )mem_conv2_img(
    .clk(clk),
    .data(relu_dout2),
    .waddr_byte(conv2_wcnt),
    .raddr_byte(conv2_rcnt),
    .we(conv_ovalid2),
    .q(conv2_img_data)
);

dram_sec_conv #(
    .NUM_DATA(CONV_SEC_LENGTH)
    )mem_conv3_img(
    .clk(clk),
    .data(relu_dout3),
    .waddr_byte(conv3_wcnt),
    .raddr_byte(conv3_rcnt),
    .we(conv_ovalid3),
    .q(conv3_img_data)
);

dram_sec_conv #(
    .NUM_DATA(CONV_SEC_LENGTH)
    )mem_conv4_img(
    .clk(clk),
    .data(relu_dout4),
    .waddr_byte(conv4_wcnt),
    .raddr_byte(conv4_rcnt),
    .we(conv_ovalid4),
    .q(conv4_img_data)
);


    conv #(
        .IMG_COL(COL_SEC),
        .IMG_ROW(ROW_SEC),
        .DATA_WIDTH(DATA_WIDTH)
        ) conv_sec1 (
        .clk(clk),
        .rst(rst),  
        .start(start_conv2),
        .ker_valid(ker_valid1),
        .img_data(conv1_img_data),
        .kernel1(kernel1_1),
        .kernel2(kernel1_2),
        .kernel3(kernel1_3),
        .kernel4(kernel1_4),
        .conv_dout1(conv1_dout1),
        .conv_dout2(conv1_dout2),
        .conv_dout3(conv1_dout3),
        .conv_dout4(conv1_dout4),
        .conv_ovalid1(conv2_ovalid1),
        .conv_ovalid2(conv2_ovalid2),
        .conv_ovalid3(conv2_ovalid3),
        .conv_ovalid4(conv2_ovalid4),
        .im2co_done(conv2_im2co_done),
        .conv_done(sec_conv_done)
        );

    conv #(
        .IMG_COL(COL_SEC),
        .IMG_ROW(ROW_SEC),
        .DATA_WIDTH(DATA_WIDTH)
        ) conv_sec2 (
        .clk(clk),
        .rst(rst),
        .start(start_conv2),
        .ker_valid(ker_valid1),
        .img_data(conv2_img_data),
        .kernel1(kernel2_1),
        .kernel2(kernel2_2),
        .kernel3(kernel2_3),
        .kernel4(kernel2_4),
        .conv_dout1(conv2_dout1),
        .conv_dout2(conv2_dout2),
        .conv_dout3(conv2_dout3),
        .conv_dout4(conv2_dout4),
        .im2co_done(conv2_im2co_done)
        );
    conv #(
        .IMG_COL(COL_SEC),
        .IMG_ROW(ROW_SEC),
        .DATA_WIDTH(DATA_WIDTH)
        ) conv_sec3 (
        .clk(clk),
        .rst(rst),
        .start(start_conv2),
        .ker_valid(ker_valid1),
        .img_data(conv3_img_data),
        .kernel1(kernel3_1),
        .kernel2(kernel3_2),
        .kernel3(kernel3_3),
        .kernel4(kernel3_4),
        .conv_dout1(conv3_dout1),
        .conv_dout2(conv3_dout2),
        .conv_dout3(conv3_dout3),
        .conv_dout4(conv3_dout4),
        .im2co_done(conv2_im2co_done)
        );

    conv #(
        .IMG_COL(COL_SEC),
        .IMG_ROW(ROW_SEC),
        .DATA_WIDTH(DATA_WIDTH)
        ) conv_sec4 (
        .clk(clk),
        .rst(rst),
        .start(start_conv2),
        .ker_valid(ker_valid1),
        .img_data(conv4_img_data),
        .kernel1(kernel4_1),
        .kernel2(kernel4_2),
        .kernel3(kernel4_3),
        .kernel4(kernel4_4),
        .conv_dout1(conv4_dout1),
        .conv_dout2(conv4_dout2),
        .conv_dout3(conv4_dout3),
        .conv_dout4(conv4_dout4),
        .im2co_done(conv2_im2co_done)
        );


    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu1_1 (
        .din(conv1_dout1),
        .dout(relu1_dout1)
    );
    
    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu1_2 (
        .din(conv1_dout2),
        .dout(relu1_dout2)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu1_3 (
        .din(conv1_dout3),
        .dout(relu1_dout3)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu1_4 (
        .din(conv1_dout4),
        .dout(relu1_dout4)
    );



    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu2_1 (
        .din(conv2_dout1),
        .dout(relu2_dout1)
    );
    
    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu2_2 (
        .din(conv2_dout2),
        .dout(relu2_dout2)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu2_3 (
        .din(conv2_dout3),
        .dout(relu2_dout3)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu2_4 (
        .din(conv2_dout4),
        .dout(relu2_dout4)
    );



    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu3_1 (
        .din(conv3_dout1),
        .dout(relu3_dout1)
    );
    
    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu3_2 (
        .din(conv3_dout2),
        .dout(relu3_dout2)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu3_3 (
        .din(conv3_dout3),
        .dout(relu3_dout3)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu3_4 (
        .din(conv3_dout4),
        .dout(relu3_dout4)
    );




    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu4_1 (
        .din(conv4_dout1),
        .dout(relu4_dout1)
    );
    
    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu4_2 (
        .din(conv4_dout2),
        .dout(relu4_dout2)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu4_3 (
        .din(conv4_dout3),
        .dout(relu4_dout3)
    );

    relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u2_relu4_4 (
        .din(conv4_dout4),
        .dout(relu4_dout4)
    );



    pooling #(
        .IMG_COL(COL_SEC),
        .IMG_ROW(ROW_SEC),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_pooling (
        .clk(clk),
        .rst_n(!rst),
        .valid_input1(conv2_ovalid1),
        .valid_input2(conv2_ovalid2),
        .valid_input3(conv2_ovalid3),
        .valid_input4(conv2_ovalid4),
        .input_data1(pool_din1),
        .input_data2(pool_din2), 
        .input_data3(pool_din3), 
        .input_data4(pool_din4),
        .out_data1(pool_dout1),  
        .out_data2(pool_dout2), 
        .out_data3(pool_dout3), 
        .out_data4(pool_dout4),
        .vflag1(pool_ovalid1),
        .vflag2(pool_ovalid2),
        .vflag3(pool_ovalid3),
        .vflag4(pool_ovalid4)



    );

    wire fc_vldout;
    full_connect #(
        .LENGTH_FC(LENGTH_FC),
        .DATA_WIDTH(DATA_WIDTH),
        .FILTERBATCH(FILTERBATCH)

    ) u_full_connect (
        .clk(clk), 
        .rst_n(!rst), 
        .start_to_cal(fc_cal),
        .ivalid1(pool_ovalid1),
        .ivalid2(pool_ovalid2),
        .ivalid3(pool_ovalid3),
        .ivalid4(pool_ovalid4),
        .weight_valid(weight_valid),
        .data1(pool_dout1),
        .data2(pool_dout2),
        .data3(pool_dout3),
        .data4(pool_dout4),
        .weight(weight),
        .bias(bias),
        .result(cnn_result),
        .done(done)
    );


endmodule

