`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/21 16:34:03
// Design Name: 
// Module Name: pooling
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


module pooling#(
    parameter IMG_COL = 28,//24
    parameter IMG_ROW = 28,
    parameter DATA_WIDTH = 16
    )(
    input               clk             ,
    input               rst_n           ,
    input               valid_input1, valid_input2, valid_input3, valid_input4,
    input   [DATA_WIDTH - 1:0]      input_data1, input_data2, input_data3, input_data4,
    output       reg       vflag1, vflag2, vflag3, vflag4       ,
    output  [DATA_WIDTH - 1:0]      out_data1,  out_data2, out_data3, out_data4
    );
    
    localparam COL_POOL = IMG_COL - 3;
    localparam ROW_POOL = IMG_ROW - 3;
    localparam IDX_WIDTH = $clog2(COL_POOL * IMG_ROW);
    localparam COL_WIDTH = $clog2(COL_POOL);
    localparam MX_COUNT = COL_POOL * ROW_POOL;
    localparam BUF_WIDTH = COL_POOL<<1;
 
    reg     [IDX_WIDTH - 1:0]      count1         ,count2, count3, count4 , count5  ;
    reg     [DATA_WIDTH - 1:0]      buffer1 [BUF_WIDTH-1:0], buffer2 [BUF_WIDTH-1:0], buffer3 [BUF_WIDTH-1:0],buffer4 [BUF_WIDTH-1:0]    ;
    wire    [DATA_WIDTH - 1:0]      max_col_1_reg1, max_col_1_reg2, max_col_1_reg3, max_col_1_reg4    ;
    wire    [DATA_WIDTH - 1:0]      max_col_2_reg1, max_col_2_reg2, max_col_2_reg3, max_col_2_reg4    ;
    wire       valid_flag1, valid_flag2, valid_flag3, valid_flag4;

    // reg     vflag1, vflag2, vflag3, vflag4;

//    reg     [DATA_WIDTH - 1:0]      win_pool1  [3:0], win_pool2  [3:0], win_pool3  [3:0], win_pool4  [3:0]  ;
    
// wire     [DATA_WIDTH - 1:0]      buffer1 [2*COL_POOL-1:0];
// assign buffer1[count1] = input_data1;
   always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            count1 <= 0;
            count2 <= 0;
            count3 <= 0;
            count4 <= 0;
            count5 <= 0;
            end
        else begin
            count2 <= count1;
                count3 <= count2;
                count4 <= count3;
                count5 <= count4;
            if (valid_input1) begin
                if (count1 < (COL_POOL << 1)-1 )
                    count1 <= count1 + 1'b1;
                else 
                    count1 <= 0;
                end
            else
                count1 <= count1;

        end
    end

always@(posedge clk)begin
                // if(!rst_n)begin
                //     buffer1 <= 0;
                //     buffer2 <= 0;
                //     buffer3 <= 0;
                //     buffer4 <= 0;
                //     end
               // else 
    if(valid_input1) 
        buffer1[count1] <= input_data1;
    if(valid_input2)     
        buffer2[count2] <= input_data2;
    if (valid_input3)
        buffer3[count3] <= input_data3;
    if(valid_input4)
        buffer4[count4] <= input_data4;

    vflag1 <= valid_flag1;
    vflag2 <= valid_flag2;
    vflag3 <= valid_flag3;
    vflag4 <= valid_flag4;

end


    assign valid_flag1 = (count1 > COL_POOL) ? ((count1 <= (COL_POOL << 1) - 1) ? ((count1 % 2 == 1) ? 1 : 0) : 0) : 0;
    assign valid_flag2 = (count2 > COL_POOL) ? ((count2 <= (COL_POOL << 1) - 1) ? ((count2 % 2 == 1) ? 1 : 0) : 0) : 0;
    assign valid_flag3 = (count3 > COL_POOL) ? ((count3 <= (COL_POOL << 1) - 1) ? ((count3 % 2 == 1) ? 1 : 0) : 0) : 0;
    assign valid_flag4 = (count4 > COL_POOL) ? ((count4 <= (COL_POOL << 1) - 1) ? ((count4 % 2 == 1) ? 1 : 0) : 0) : 0;

    wire [7:0] net_detc1, net_detc2,net_detc3, net_detc4,net_detc5, net_detc6,net_detc7, net_detc8;

    assign net_detc1 = count2 - 1;
    assign net_detc2 = count2;
    assign net_detc3 = count3 - 1;
    assign net_detc4 = count3;
    assign net_detc5 = count4 - 1;
    assign net_detc6 = count4;
    assign net_detc7 = count5 - 1;
    assign net_detc8 = count5;

    assign max_col_1_reg1 = vflag1 ? ( buffer1[net_detc1] > buffer1[net_detc1 - COL_POOL]? buffer1[net_detc1] : buffer1[net_detc1 - COL_POOL]) : 0;
    assign max_col_2_reg1 = vflag1 ? (buffer1[net_detc2] > buffer1[net_detc2 - COL_POOL]? buffer1[net_detc2] : buffer1[net_detc2 - COL_POOL]) : 0;
    assign out_data1 = vflag1 ? (max_col_1_reg1 > max_col_2_reg1 ? max_col_1_reg1: max_col_2_reg1) : 0;



    assign max_col_1_reg2 = vflag2 ? ( buffer2[net_detc3] > buffer2[net_detc3 - COL_POOL]? buffer2[net_detc3] : buffer2[net_detc3 - COL_POOL]) : 0;
    assign max_col_2_reg2 = vflag2 ? (buffer2[net_detc4] > buffer2[net_detc4 - COL_POOL]? buffer2[net_detc4] : buffer2[net_detc4 - COL_POOL]) : 0;
    assign out_data2 = vflag2 ? (max_col_1_reg2 > max_col_2_reg2 ? max_col_1_reg2: max_col_2_reg2) : 0;  
    


    assign max_col_1_reg3 = vflag3 ? ( buffer3[net_detc5] > buffer1[net_detc5 - COL_POOL]? buffer1[net_detc5] : buffer1[net_detc5 - COL_POOL]) : 0;
    assign max_col_2_reg3 = vflag3 ? (buffer3[net_detc6] > buffer1[net_detc6 - COL_POOL]? buffer1[net_detc6] : buffer1[net_detc6 - COL_POOL]) : 0;
    assign out_data3 = vflag3 ? (max_col_1_reg3 > max_col_2_reg3 ? max_col_1_reg3: max_col_2_reg3) : 0;  
  


    assign max_col_1_reg4 = vflag4 ? ( buffer4[net_detc7] > buffer4[net_detc7 - COL_POOL]? buffer4[net_detc7] : buffer4[net_detc7 - COL_POOL]) : 0;
    assign max_col_2_reg4 = vflag4 ? (buffer4[net_detc8] > buffer4[net_detc8 - COL_POOL]? buffer4[net_detc8] : buffer4[net_detc8 - COL_POOL]) : 0;
    assign out_data4 = vflag4 ? (max_col_1_reg4 > max_col_2_reg4 ? max_col_1_reg4: max_col_2_reg4) : 0;  

endmodule
    /*
    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            max_cnt1 <= 0;
        else 
        if (count1 >= (COL_POOL + 1) && count1 <= (MX_COUNT) && max_cnt1 == COL_POOL)
            max_cnt1 <= 1;
        else if (count1 >= (COL_POOL + 1) && count1 <= (MX_COUNT))
            max_cnt1 <= max_cnt1 + 1'b1;
        else
            max_cnt1 <= max_cnt1;
        
    end

    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            out_flag1 <= 1'd0;
            else if (max_cnt1 >= 1 && max_cnt1 <= COL_POOL)
            out_flag1 <= ~ out_flag1;
        else
            out_flag1 <= 1'b0;
    end



    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            max_cnt2 <= 0;
        else if (count2 >= (COL_POOL + 1) && count2 <= (MX_COUNT) && max_cnt2 == COL_POOL)
            max_cnt2 <= 1;
        else if (count2 >= (COL_POOL + 1) && count2 <= (MX_COUNT))
            max_cnt2 <= max_cnt2 + 1'b1;
        else
            max_cnt2 <= max_cnt2;
    end

    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            out_flag2 <= 1'd0;
            else if (max_cnt2 >= 1 && max_cnt2 <= COL_POOL)
            out_flag2 <= ~ out_flag2;
        else
            out_flag2 <= 1'b0;
    end



    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            max_cnt3 <= 0;
        else if (count3 >= (COL_POOL + 1) && count3 <= (MX_COUNT) && max_cnt3 == COL_POOL)
            max_cnt3 <= 1;
        else if (count3 >= (COL_POOL + 1) && count3 <= (MX_COUNT))
            max_cnt3 <= max_cnt3 + 1'b1;
        else
            max_cnt3 <= max_cnt3;
    end

    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            out_flag3 <= 1'd0;
            else if (max_cnt3 >= 1 && max_cnt3 <= COL_POOL)
            out_flag3 <= ~ out_flag3;
        else
            out_flag3 <= 1'b0;
    end


        always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            max_cnt4 <= 0;
        else if (count4 >= (COL_POOL + 1) && count4 <= (MX_COUNT) && max_cnt4 == COL_POOL)
            max_cnt4 <= 1;
        else if (count4 >= (COL_POOL + 1) && count4 <= (MX_COUNT))
            max_cnt4 <= max_cnt4 + 1'b1;
        else
            max_cnt4 <= max_cnt4;
    end

    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            out_flag4 <= 1'd0;
            else if (max_cnt4 >= 1 && max_cnt4 <= COL_POOL)
            out_flag4 <= ~ out_flag4;
        else
            out_flag4 <= 1'b0;
    end


 


    // always @ (posedge clk or negedge rst_n)begin
    //     if (!rst_n)begin
    //         win_pool1[0] <= 0;
    //         win_pool1[1] <= 0;
    //         win_pool1[2] <= 0;
    //         win_pool1[3] <= 0;
    //     end
    //     else if (count1 >= (COL_POOL + 1) && count1 <= (COL_POOL*2))begin
    //         win_pool1[0] <= buffer1[(count1 -1) % COL_POOL];
    //         win_pool1[1] <= buffer1[((count1 - 1) % COL_POOL) + COL_POOL];
    //         win_pool1[2] <= win_pool1[0];
    //         win_pool1[3] <= win_pool1[1];
    //     end
    //     else begin
    //         win_pool1[0] <= win_pool1[0];
    //         win_pool1[1] <= win_pool1[1];
    //         win_pool1[2] <= win_pool1[2];
    //         win_pool1[3] <= win_pool1[3];
    //     end
    // end

    // assign max_col_1_reg1 = win_pool1[0] > win_pool1[1] ? win_pool1[0] : win_pool1[1];
    // assign max_col_2_reg1 = win_pool1[2] > win_pool1[3] ? win_pool1[2] : win_pool1[3];
    // assign out_data1      = out_valid1 == 1'b0 ? 0 : max_col_2_reg1 > max_col_1_reg1 ? max_col_2_reg1 : max_col_1_reg1;
    // assign out_valid1     = count1 >= COL_POOL && max_cnt1 >= 2 && max_cnt1 <= COL_POOL && out_flag1 ? 1'b1 : 1'b0;
    
    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            win_pool2[0] <= 0;
            win_pool2[1] <= 0;
            win_pool2[2] <= 0;
            win_pool2[3] <= 0;
        end
        else if (count2 >= (COL_POOL + 1) && count2 <= (MX_COUNT))begin
            win_pool2[0] <= buffer2[(count2 -1) % COL_POOL];
            win_pool2[1] <= buffer2[((count2 - 1) % COL_POOL) + COL_POOL];
            win_pool2[2] <= win_pool2[0];
            win_pool2[3] <= win_pool2[1];
        end
        else begin
            win_pool2[0] <= win_pool2[0];
            win_pool2[1] <= win_pool2[1];
            win_pool2[2] <= win_pool2[2];
            win_pool2[3] <= win_pool2[3];
        end
    end

    assign max_col_1_reg2 = win_pool2[0] > win_pool2[1] ? win_pool2[0] : win_pool2[1];
    assign max_col_2_reg2 = win_pool2[2] > win_pool2[3] ? win_pool2[2] : win_pool2[3];
    assign out_data2      = out_valid2 == 1'b0 ? 0 : max_col_2_reg2 > max_col_1_reg2 ? max_col_2_reg2 : max_col_1_reg2;
    assign out_valid2     = count2 >= COL_POOL && max_cnt2 >= 2 && max_cnt2 <= COL_POOL && out_flag2 ? 1'b1 : 1'b0;

    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            win_pool3[0] <= 0;
            win_pool3[1] <= 0;
            win_pool3[2] <= 0;
            win_pool3[3] <= 0;
        end
        else if (count3 >= (COL_POOL + 1) && count3 <= (MX_COUNT))begin
            win_pool3[0] <= buffer3[(count3 -1) % COL_POOL];
            win_pool3[1] <= buffer3[((count3 - 1) % COL_POOL) + COL_POOL];
            win_pool3[2] <= win_pool3[0];
            win_pool3[3] <= win_pool3[1];
        end
        else begin
            win_pool3[0] <= win_pool3[0];
            win_pool3[1] <= win_pool3[1];
            win_pool3[2] <= win_pool3[2];
            win_pool3[3] <= win_pool3[3];
        end
    end

    assign max_col_1_reg3 = win_pool3[0] > win_pool3[1] ? win_pool3[0] : win_pool3[1];
    assign max_col_2_reg3 = win_pool3[2] > win_pool3[3] ? win_pool3[2] : win_pool3[3];
    assign out_data3      = out_valid3 == 1'b0 ? 0 : max_col_2_reg3 > max_col_1_reg3 ? max_col_2_reg3 : max_col_1_reg3;
    assign out_valid3     = count3 >= COL_POOL && max_cnt3 >= 2 && max_cnt3 <= COL_POOL && out_flag3 ? 1'b1 : 1'b0;
    

    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            win_pool4[0] <= 0;
            win_pool4[1] <= 0;
            win_pool4[2] <= 0;
            win_pool4[3] <= 0;
        end
        else if (count4 >= (COL_POOL + 1) && count4 <= (MX_COUNT))begin
            win_pool4[0] <= buffer4[(count4 -1) % COL_POOL];
            win_pool4[1] <= buffer4[((count4 - 1) % COL_POOL) + COL_POOL];
            win_pool4[2] <= win_pool4[0];
            win_pool4[3] <= win_pool4[1];
        end
        else begin
            win_pool4[0] <= win_pool4[0];
            win_pool4[1] <= win_pool4[1];
            win_pool4[2] <= win_pool4[2];
            win_pool4[3] <= win_pool4[3];
        end
    end

    assign max_col_1_reg4 = win_pool4[0] > win_pool4[1] ? win_pool4[0] : win_pool4[1];
    assign max_col_2_reg4 = win_pool4[2] > win_pool4[3] ? win_pool4[2] : win_pool4[3];
    assign out_data4      = out_valid4 == 1'b0 ? 0 : max_col_2_reg4 > max_col_1_reg4 ? max_col_2_reg4 : max_col_1_reg4;
    assign out_valid4     = count4 >= COL_POOL && max_cnt4 >= 2 && max_cnt4 <= COL_POOL && out_flag4 ? 1'b1 : 1'b0;

endmodule
*/

    
/*
module pooling#(
    parameter IMG_COL = 6,//24
    parameter IMG_ROW = 6,
    parameter DATA_WIDTH = 16
    )(
    input               clk             ,
    input               rst_n           ,
    input               valid_input, 
    input   [DATA_WIDTH - 1:0]      input_data1, input_data2, input_data3, input_data4,
    output              out_valid, 
    output  [DATA_WIDTH - 1:0]      out_data1,  out_data2, out_data3, out_data4
    );
    
    localparam COL_POOL = IMG_COL - 3;
    localparam ROW_POOL = IMG_ROW - 3;
    localparam IDX_WIDTH = $clog2(COL_POOL * IMG_ROW);
    localparam COL_WIDTH = $clog2(COL_POOL);
    localparam MX_COUNT = COL_POOL * ROW_POOL;
 
    reg     [IDX_WIDTH - 1:0]      count1         ,count2, count3, count4   ;
    reg     [COL_WIDTH - 1:0]      max_cnt1,   max_cnt2,   max_cnt3,   max_cnt4  ;
    reg                 out_flag1, out_flag2, out_flag3, out_flag4          ;
    reg     [DATA_WIDTH - 1:0]      buffer1 [2*COL_POOL-1:0], buffer2 [2*COL_POOL-1:0], buffer3 [2*COL_POOL-1:0],buffer4 [2*COL_POOL-1:0]    ;

    wire    [DATA_WIDTH - 1:0]      max_col_1_reg1, max_col_1_reg2, max_col_1_reg3, max_col_1_reg4    ;
    wire    [DATA_WIDTH - 1:0]      max_col_2_reg1, max_col_2_reg2, max_col_2_reg3, max_col_2_reg4    ;

    reg     [DATA_WIDTH - 1:0]      win_pool1  [3:0], win_pool2  [3:0], win_pool3  [3:0], win_pool4  [3:0]  ;
    

   always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            count <= 0;
            end
        else if (valid_input1) begin
                count <= count + 1'b1;
                end
            else
                count <= count;
        end
    end
        always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            max_cnt <= 0;
        else if (count >= (COL_POOL + 1) && count <= (MX_COUNT) && max_cnt == COL_POOL)
            max_cnt <= 1;
        else if (count >= (COL_POOL + 1) && count <= (MX_COUNT))
            max_cnt <= max_cnt + 1'b1;
        else
            max_cnt <= max_cnt;
    end

    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)
            out_flag <= 1'd0;
            else if (max_cnt >= 1 && max_cnt <= COL_POOL)
            out_flag <= ~ out_flag;
        else
            out_flag <= 1'b0;
    end

always@(posedge clk or negedge rst_n)begin
                // if(!rst_n)begin
                //     buffer1 <= 0;
                //     buffer2 <= 0;
                //     buffer3 <= 0;
                //     buffer4 <= 0;
                //     end
               // else 
                if(valid_input1 || valid_input4) begin
                    buffer1[count] <= input_data1;
                     
                    buffer2[count] <= input_data2;
                   
                    buffer3[count] <= input_data3;

                    buffer4[count] <= input_data4;
                end
               
            end


    always @ (posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            win_pool[0] <= 0;
            win_pool[1] <= 0;
            win_pool[2] <= 0;
            win_pool[3] <= 0;
        end
        else if (count >= (COL_POOL + 1) && count <= (MX_COUNT))begin
            win_pool[0] <= buffer[(count -1) % COL_POOL];
            win_pool[1] <= buffer[((count - 1) % COL_POOL) + COL_POOL];
            win_pool[2] <= win_pool[0];
            win_pool[3] <= win_pool[1];
        end
        else begin
            win_pool[0] <= win_pool[0];
            win_pool[1] <= win_pool[1];
            win_pool[2] <= win_pool[2];
            win_pool[3] <= win_pool[3];
        end
    end

    assign max_col_1_reg = win_pool[0] > win_pool[1] ? win_pool[0] : win_pool[1];
    assign max_col_2_reg = win_pool[2] > win_pool[3] ? win_pool[2] : win_pool[3];
    assign out_data      = out_valid == 1'b0 ? 0 : max_col_2_reg > max_col_1_reg ? max_col_2_reg : max_col_1_reg;
    assign out_valid     = count >= COL_POOL && max_cnt >= 2 && max_cnt <= COL_POOL && out_flag ? 1'b1 : 1'b0;

endmodule
*/
