module img2col #(
    parameter IMG_COL = 28,
    parameter IMG_ROW = 28,
    parameter DATA_WIDTH = 16
    )(
    input wire clk,
    input wire rst,
    input wire start,
    input wire ker_valid,
    input wire [DATA_WIDTH - 1:0] img_data,
    input wire [DATA_WIDTH - 1 : 0] kernel1, kernel2, kernel3, kernel4,
    output reg [DATA_WIDTH - 1:0] inp_west0, inp_west4, inp_west8, inp_west12, w4reg, w8reg1, w8reg2, w12reg1, w12reg2, w12reg3,
    output reg [DATA_WIDTH - 1:0] inp_north0, inp_north1, inp_north2, inp_north3, n1reg, n2reg1, n2reg2, n3reg1, n3reg2, n3reg3,
    output reg done,
    output reg transmit_en
);
    localparam STEPPER_COL = IMG_COL - 4;
    localparam STEPPER_ROW = IMG_ROW - 4;
    localparam NUM_STEPPER = (STEPPER_COL + 1) * (STEPPER_ROW + 1); // 9 blocks for 6*6
    localparam NUM_SET = (NUM_STEPPER >> 2) + (NUM_STEPPER % 4);
    localparam NUM_LST_SET = NUM_STEPPER % 4;
    localparam IDX_WIDTH = $clog2(IMG_COL*IMG_ROW);
    localparam TOTAL_LENGTH = IMG_ROW * IMG_COL;

    reg [10:0]cnt;
    reg [DATA_WIDTH - 1:0] north0[0:15];
    reg [DATA_WIDTH - 1:0] north1[0:15];
    reg [DATA_WIDTH - 1:0] north2[0:15];
    reg [DATA_WIDTH - 1:0] north3[0:15];
  
        integer i;
    reg [15:0] index; 
    // reg transmit_en ; 
    wire [IDX_WIDTH-1:0] idx_west0;
    wire [IDX_WIDTH-1:0] idx_west4;
    wire [IDX_WIDTH-1:0] idx_west8;
    wire [IDX_WIDTH-1:0] idx_west12;
    
    reg [DATA_WIDTH - 1:0] image[0:IMG_COL * IMG_ROW-1] ;


    assign idx_west0 = (cnt << 2) / (STEPPER_COL +1) * IMG_COL + (cnt << 2) % (STEPPER_COL + 1) + index + ((index >> 2) * STEPPER_COL);
    assign idx_west4 = ((cnt << 2) + 1) / (STEPPER_COL +1) * IMG_COL + ((cnt << 2) + 1) % (STEPPER_COL +1) + index + ((index >> 2) * STEPPER_COL);
    assign idx_west8 =  ((cnt << 2) + 2) / (STEPPER_COL +1) * IMG_COL + ((cnt << 2) + 2) % (STEPPER_COL +1) + index + ((index >> 2) * STEPPER_COL);
    assign idx_west12 = ((cnt << 2) + 3) / (STEPPER_COL +1) * IMG_COL + ((cnt << 2) + 3) % (STEPPER_COL +1) + index + ((index >> 2) * STEPPER_COL);

   // assign  valid = start && transmit_en;

    reg [31:0] img_idx;  // ÓÃÓÚ×·×ÙÊäÈëÍ¼ÏñÊý¾ÝµÄË÷
    reg loading;    // ±êÖ¾Î»£¬±íÊ¾ÊÇ·ñÕýÔÚ¼ÓÔØÍ¼ÏñÊý¾Ý
    reg [4:0]ker_idx;
    reg no_transmit_to_ker;
    // wire add = (row == 3) ? 1 : 0;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            index <= 0; 
            img_idx <= 0;
            ker_idx <= 0;
            loading <= 1;
            transmit_en <= 0;
            inp_west0 <= 0;
            inp_west4 <= 0;
            inp_west8 <= 0;
            inp_west12 <= 0;
            inp_north0 <= 0;
            inp_north1 <= 0;
            inp_north2 <= 0;
            inp_north3 <= 0;
            cnt <= 0;
            w4reg <= 0;
            w8reg1 <= 0;
            w8reg2 <= 0;
            w12reg1 <= 0;
            w12reg2 <= 0;
            w12reg3 <= 0;
            n1reg <= 0;
            n2reg1 <= 0;
            n2reg2 <= 0;
            n3reg1 <= 0;
            n3reg2 <= 0;
            n3reg3 <= 0;
            no_transmit_to_ker <= 0;
        end 
        else begin 
            w4reg <= inp_west4;
            w8reg1 <= inp_west8;
            w8reg2 <= w8reg1;
            w12reg1 <= inp_west12;
            w12reg2 <= w12reg1;
            w12reg3 <= w12reg2;

            n1reg <=  inp_north1;
            n2reg1 <= inp_north2;
            n2reg2 <= n2reg1;
            n3reg1 <= inp_north3;
            n3reg2 <= n3reg1;
            n3reg3 <= n3reg2;
            if (ker_valid)begin
                if ((img_idx >= 0) && (img_idx <= 15))
                    north0[img_idx] <= kernel1;
                if ((img_idx >= 16) && (img_idx <= 31))
                    north1[img_idx -16] <= kernel2;
                if ((img_idx >= 32) && (img_idx <= 47))
                    north2[img_idx -32] <= kernel3;
                if ((img_idx >= 48) && (img_idx <= 63))
                    north3[img_idx -48] <= kernel4;
                img_idx <= img_idx + 1;
                if (img_idx >= 63)begin
                    img_idx <= 0;
                    no_transmit_to_ker <= 1;
                end
            end
            if (start) begin
                if (loading) begin
                    done <= 0;

                    if (img_idx <= TOTAL_LENGTH + 63 ) begin
                        if (img_idx <= TOTAL_LENGTH - 1 )
                            image[img_idx] <= img_data;
                        if (!no_transmit_to_ker)begin
                            if ((img_idx >= TOTAL_LENGTH - 1) && (img_idx <= TOTAL_LENGTH + 15))
                                north0[img_idx - TOTAL_LENGTH + 1] <= kernel1;
                            if ((img_idx >= TOTAL_LENGTH + 15) && (img_idx <= TOTAL_LENGTH + 31))
                                north1[img_idx - TOTAL_LENGTH - 15] <= kernel2;
                            if ((img_idx >= TOTAL_LENGTH + 31) && (img_idx <= TOTAL_LENGTH + 47))
                                north2[img_idx - TOTAL_LENGTH - 31] <= kernel3;
                            if ((img_idx >= TOTAL_LENGTH + 47) && (img_idx <= TOTAL_LENGTH + 63))
                                north3[img_idx - TOTAL_LENGTH - 47] <= kernel4;
                        end
                        img_idx <= img_idx + 1;
                    end
                    else begin
                         loading <= 0;  
                         img_idx <= 0;
                         transmit_en <= 1;
                     end
                end 
                else begin
                    // ½«Í¼ÏñÊý¾Ý°´ÁÐË³ÐòÊä³ö        
                    if (transmit_en)begin
                        


                        if (cnt == (NUM_SET - 1))begin
                            if (NUM_LST_SET == 0)begin
                                inp_west0 <= image[idx_west0];
                                inp_west4 <= image[idx_west4];
                                inp_west8 <= image[idx_west8];
                                inp_west12 <= image[idx_west12];
                                inp_north0 <= north0[index];
                                inp_north1 <= north1[index];
                                inp_north2 <= north2[index];
                                inp_north3 <= north3[index];
                                if (index == 15) begin
                                    transmit_en <= 0;
                                    cnt <= 0;
                                end
                            end
                            else begin
                                inp_west0  <= image[idx_west0];
                                inp_west4  <= 0;
                                inp_west8  <= 0;
                                inp_west12 <= 0;
                                inp_north0 <= north0[index];
                                inp_north1 <= north1[index];//0;
                                inp_north2 <= north2[index];//0;
                                inp_north3 <= north3[index];//0;
                                if (index == 15) begin
                                    transmit_en <= 0;
                                    cnt <= 0;
                                end
                            end
                        end
                        else begin
                            inp_west0 <= image[idx_west0];
                            inp_west4 <= image[idx_west4];
                            inp_west8 <= image[idx_west8];
                            inp_west12 <= image[idx_west12];
                            inp_north0 <= north0[index];
                            inp_north1 <= north1[index];
                            inp_north2 <= north2[index];
                            inp_north3 <= north3[index];
                        end
                        if (index == 15) begin
                            index <= 0;
                            if (cnt != (NUM_SET - 1))
                                cnt <= cnt + 1;
                        end 
                        else begin
                            index <= index + 1;

                        end 
                    end
                    else    
                        done <= 1;
                end
            end
        end
    end

endmodule
