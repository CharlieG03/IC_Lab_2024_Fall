module TMIP(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    
    image,
    template,
    image_size,
	action,
	
    // output signals
    out_valid,
    out_value
    );

input            clk, rst_n;
input            in_valid, in_valid2;

input      [7:0] image;
input      [7:0] template;
input      [1:0] image_size;
input      [2:0] action;

output reg       out_valid;
output reg       out_value;

//==================================================================
// parameter & integer
//==================================================================
parameter IDLE = 0;
parameter SELECT = 1;
parameter MAX_POOL = 2;
parameter NEGATIVE = 3;
parameter H_FLIP = 4;
parameter MEDIAN = 5;
parameter CONV = 6;

parameter FIRST_ACTION = 1;
parameter SECOND_ACTION = 2;
parameter THIRD_ACTION = 3;
parameter FOURTH_ACTION = 4;
parameter FIFTH_ACTION = 5;
parameter SIXTH_ACTION = 6;
parameter SINGLE_ACTION = 7;
parameter FINAL_ACTION = 8;
//==================================================================
// reg & wire
//==================================================================
reg in_valid_reg0, in_valid_reg1, in_valid_reg2;
reg [1:0] image_size_reg, image_size_reg_copy;
reg [7:0] mem_di[15:0], mem_do[15:0];
reg [5:0]  mem_addr;
reg mem_web;
reg [7:0] img_reg0, img_reg2;
reg [9:0] img_reg1;
reg [1:0] rgb_counter;
reg [127:0] row_reg0, row_reg1, row_reg2;
reg [7:0] template_reg[8:0];
reg [8:0] action_counter;
reg [2:0] action_reg[6:0];
reg [2:0] action_nxt;
reg action_done;
reg [2:0] action_num;
reg [2:0] action_lat;
reg [4:0] conv_counter;
reg [19:0] output_reg; 
//==================================================================
// design
//==================================================================
reg [2:0] state0, state0_nxt;
reg [3:0] state1, state1_nxt;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state0 <= IDLE;
        state1 <= IDLE;
    end else begin
        state0 <= state0_nxt;
        state1 <= state1_nxt;
    end
end
always @(*) begin
    state0_nxt = state0;
    case(state0)
    IDLE: begin
        if(in_valid2) begin
            state0_nxt = SELECT;
        end
    end
    SELECT: begin
            state0_nxt = action - 1;
    end
    endcase
    if(action_done) begin
        if(in_valid2) begin
            if(action_lat == 0) begin
                state0_nxt = action - 1;
            end else begin
                state0_nxt = action_reg[action_nxt] - 1;
            end
        end else if(state0 == CONV) begin
            state0_nxt = IDLE;
        end else begin
            state0_nxt = action_reg[action_nxt] - 1;
        end
    end
end
always @(*) begin
    state1_nxt = state1;
    if(state1 == IDLE & in_valid2) begin
        if(state0 == SELECT) begin
            state1_nxt = FIRST_ACTION;
        end
        if(action - 1 == CONV) begin
            state1_nxt = SINGLE_ACTION;
        end
    end else if(state1 != FINAL_ACTION && state1 != SINGLE_ACTION) begin
        if(action_done) begin
            if(~in_valid2 & action_reg[action_nxt] - 1 == CONV) begin
                state1_nxt = FINAL_ACTION;
            end else if(in_valid2 & action - 1 == CONV & action_lat == 0) begin
                state1_nxt = FINAL_ACTION;
            end else begin
                state1_nxt = state1 + 1;
            end
        end
    end else if(action_done) begin
            state1_nxt = IDLE;
    end
end
always@(*) begin
    action_nxt = 0;
    case(state1)
    IDLE: action_nxt = 0; FIRST_ACTION: action_nxt = 1; SECOND_ACTION: action_nxt = 2; THIRD_ACTION: action_nxt = 3;
    FOURTH_ACTION: action_nxt = 4; FIFTH_ACTION: action_nxt = 5; SIXTH_ACTION: action_nxt = 6;
    endcase
end
mem_64X128 MEM_64X128(.A0(mem_addr[0]), .A1(mem_addr[1]), .A2(mem_addr[2]), .A3(mem_addr[3]), .A4(mem_addr[4]), .A5(mem_addr[5]), 
                      .DO0(mem_do[0][0]), .DO1(mem_do[0][1]), .DO2(mem_do[0][2]), .DO3(mem_do[0][3]), .DO4(mem_do[0][4]), .DO5(mem_do[0][5]), .DO6(mem_do[0][6]), .DO7(mem_do[0][7]),
                      .DO8(mem_do[1][0]), .DO9(mem_do[1][1]), .DO10(mem_do[1][2]), .DO11(mem_do[1][3]), .DO12(mem_do[1][4]), .DO13(mem_do[1][5]), .DO14(mem_do[1][6]), .DO15(mem_do[1][7]),
                      .DO16(mem_do[2][0]), .DO17(mem_do[2][1]), .DO18(mem_do[2][2]), .DO19(mem_do[2][3]), .DO20(mem_do[2][4]), .DO21(mem_do[2][5]), .DO22(mem_do[2][6]), .DO23(mem_do[2][7]),
                      .DO24(mem_do[3][0]), .DO25(mem_do[3][1]), .DO26(mem_do[3][2]), .DO27(mem_do[3][3]), .DO28(mem_do[3][4]), .DO29(mem_do[3][5]), .DO30(mem_do[3][6]), .DO31(mem_do[3][7]),
                      .DO32(mem_do[4][0]), .DO33(mem_do[4][1]), .DO34(mem_do[4][2]), .DO35(mem_do[4][3]), .DO36(mem_do[4][4]), .DO37(mem_do[4][5]), .DO38(mem_do[4][6]), .DO39(mem_do[4][7]),
                      .DO40(mem_do[5][0]), .DO41(mem_do[5][1]), .DO42(mem_do[5][2]), .DO43(mem_do[5][3]), .DO44(mem_do[5][4]), .DO45(mem_do[5][5]), .DO46(mem_do[5][6]), .DO47(mem_do[5][7]),
                      .DO48(mem_do[6][0]), .DO49(mem_do[6][1]), .DO50(mem_do[6][2]), .DO51(mem_do[6][3]), .DO52(mem_do[6][4]), .DO53(mem_do[6][5]), .DO54(mem_do[6][6]), .DO55(mem_do[6][7]),
                      .DO56(mem_do[7][0]), .DO57(mem_do[7][1]), .DO58(mem_do[7][2]), .DO59(mem_do[7][3]), .DO60(mem_do[7][4]), .DO61(mem_do[7][5]), .DO62(mem_do[7][6]), .DO63(mem_do[7][7]),
                      .DO64(mem_do[8][0]), .DO65(mem_do[8][1]), .DO66(mem_do[8][2]), .DO67(mem_do[8][3]), .DO68(mem_do[8][4]), .DO69(mem_do[8][5]), .DO70(mem_do[8][6]), .DO71(mem_do[8][7]),
                      .DO72(mem_do[9][0]), .DO73(mem_do[9][1]), .DO74(mem_do[9][2]), .DO75(mem_do[9][3]), .DO76(mem_do[9][4]), .DO77(mem_do[9][5]), .DO78(mem_do[9][6]), .DO79(mem_do[9][7]),
                      .DO80(mem_do[10][0]), .DO81(mem_do[10][1]), .DO82(mem_do[10][2]), .DO83(mem_do[10][3]), .DO84(mem_do[10][4]), .DO85(mem_do[10][5]), .DO86(mem_do[10][6]), .DO87(mem_do[10][7]),
                      .DO88(mem_do[11][0]), .DO89(mem_do[11][1]), .DO90(mem_do[11][2]), .DO91(mem_do[11][3]), .DO92(mem_do[11][4]), .DO93(mem_do[11][5]), .DO94(mem_do[11][6]), .DO95(mem_do[11][7]),
                      .DO96(mem_do[12][0]), .DO97(mem_do[12][1]), .DO98(mem_do[12][2]), .DO99(mem_do[12][3]), .DO100(mem_do[12][4]), .DO101(mem_do[12][5]), .DO102(mem_do[12][6]), .DO103(mem_do[12][7]),
                      .DO104(mem_do[13][0]), .DO105(mem_do[13][1]), .DO106(mem_do[13][2]), .DO107(mem_do[13][3]), .DO108(mem_do[13][4]), .DO109(mem_do[13][5]), .DO110(mem_do[13][6]), .DO111(mem_do[13][7]),
                      .DO112(mem_do[14][0]), .DO113(mem_do[14][1]), .DO114(mem_do[14][2]), .DO115(mem_do[14][3]), .DO116(mem_do[14][4]), .DO117(mem_do[14][5]), .DO118(mem_do[14][6]), .DO119(mem_do[14][7]),
                      .DO120(mem_do[15][0]), .DO121(mem_do[15][1]), .DO122(mem_do[15][2]), .DO123(mem_do[15][3]), .DO124(mem_do[15][4]), .DO125(mem_do[15][5]), .DO126(mem_do[15][6]), .DO127(mem_do[15][7]),
                      .DI0(mem_di[0][0]), .DI1(mem_di[0][1]), .DI2(mem_di[0][2]), .DI3(mem_di[0][3]), .DI4(mem_di[0][4]), .DI5(mem_di[0][5]), .DI6(mem_di[0][6]), .DI7(mem_di[0][7]),
                      .DI8(mem_di[1][0]), .DI9(mem_di[1][1]), .DI10(mem_di[1][2]), .DI11(mem_di[1][3]), .DI12(mem_di[1][4]), .DI13(mem_di[1][5]), .DI14(mem_di[1][6]), .DI15(mem_di[1][7]),
                      .DI16(mem_di[2][0]), .DI17(mem_di[2][1]), .DI18(mem_di[2][2]), .DI19(mem_di[2][3]), .DI20(mem_di[2][4]), .DI21(mem_di[2][5]), .DI22(mem_di[2][6]), .DI23(mem_di[2][7]),
                      .DI24(mem_di[3][0]), .DI25(mem_di[3][1]), .DI26(mem_di[3][2]), .DI27(mem_di[3][3]), .DI28(mem_di[3][4]), .DI29(mem_di[3][5]), .DI30(mem_di[3][6]), .DI31(mem_di[3][7]),
                      .DI32(mem_di[4][0]), .DI33(mem_di[4][1]), .DI34(mem_di[4][2]), .DI35(mem_di[4][3]), .DI36(mem_di[4][4]), .DI37(mem_di[4][5]), .DI38(mem_di[4][6]), .DI39(mem_di[4][7]),
                      .DI40(mem_di[5][0]), .DI41(mem_di[5][1]), .DI42(mem_di[5][2]), .DI43(mem_di[5][3]), .DI44(mem_di[5][4]), .DI45(mem_di[5][5]), .DI46(mem_di[5][6]), .DI47(mem_di[5][7]),
                      .DI48(mem_di[6][0]), .DI49(mem_di[6][1]), .DI50(mem_di[6][2]), .DI51(mem_di[6][3]), .DI52(mem_di[6][4]), .DI53(mem_di[6][5]), .DI54(mem_di[6][6]), .DI55(mem_di[6][7]),
                      .DI56(mem_di[7][0]), .DI57(mem_di[7][1]), .DI58(mem_di[7][2]), .DI59(mem_di[7][3]), .DI60(mem_di[7][4]), .DI61(mem_di[7][5]), .DI62(mem_di[7][6]), .DI63(mem_di[7][7]),
                      .DI64(mem_di[8][0]), .DI65(mem_di[8][1]), .DI66(mem_di[8][2]), .DI67(mem_di[8][3]), .DI68(mem_di[8][4]), .DI69(mem_di[8][5]), .DI70(mem_di[8][6]), .DI71(mem_di[8][7]),
                      .DI72(mem_di[9][0]), .DI73(mem_di[9][1]), .DI74(mem_di[9][2]), .DI75(mem_di[9][3]), .DI76(mem_di[9][4]), .DI77(mem_di[9][5]), .DI78(mem_di[9][6]), .DI79(mem_di[9][7]),
                      .DI80(mem_di[10][0]), .DI81(mem_di[10][1]), .DI82(mem_di[10][2]), .DI83(mem_di[10][3]), .DI84(mem_di[10][4]), .DI85(mem_di[10][5]), .DI86(mem_di[10][6]), .DI87(mem_di[10][7]),
                      .DI88(mem_di[11][0]), .DI89(mem_di[11][1]), .DI90(mem_di[11][2]), .DI91(mem_di[11][3]), .DI92(mem_di[11][4]), .DI93(mem_di[11][5]), .DI94(mem_di[11][6]), .DI95(mem_di[11][7]),
                      .DI96(mem_di[12][0]), .DI97(mem_di[12][1]), .DI98(mem_di[12][2]), .DI99(mem_di[12][3]), .DI100(mem_di[12][4]), .DI101(mem_di[12][5]), .DI102(mem_di[12][6]), .DI103(mem_di[12][7]),
                      .DI104(mem_di[13][0]), .DI105(mem_di[13][1]), .DI106(mem_di[13][2]), .DI107(mem_di[13][3]), .DI108(mem_di[13][4]), .DI109(mem_di[13][5]), .DI110(mem_di[13][6]), .DI111(mem_di[13][7]),
                      .DI112(mem_di[14][0]), .DI113(mem_di[14][1]), .DI114(mem_di[14][2]), .DI115(mem_di[14][3]), .DI116(mem_di[14][4]), .DI117(mem_di[14][5]), .DI118(mem_di[14][6]), .DI119(mem_di[14][7]),
                      .DI120(mem_di[15][0]), .DI121(mem_di[15][1]), .DI122(mem_di[15][2]), .DI123(mem_di[15][3]), .DI124(mem_di[15][4]), .DI125(mem_di[15][5]), .DI126(mem_di[15][6]), .DI127(mem_di[15][7]),
                      .CK(clk), .WEB(mem_web), .OE(1'b1), .CS(1'b1));

reg [7:0] mein0 [8:0], mein1 [8:0], mein2 [8:0], mein3 [8:0];
reg [7:0] meout0, meout1, meout2, meout3;
reg [7:0] maxima00, maxima01, maxima10, maxima11, maxima20, maxima21, maxima30, maxima31;
median median0(mein0[0], mein0[1], mein0[2], mein0[3], mein0[4], mein0[5], mein0[6], mein0[7], mein0[8], meout0, maxima00, maxima01);
median median1(mein1[0], mein1[1], mein1[2], mein1[3], mein1[4], mein1[5], mein1[6], mein1[7], mein1[8], meout1, maxima10, maxima11);
median median2(mein2[0], mein2[1], mein2[2], mein2[3], mein2[4], mein2[5], mein2[6], mein2[7], mein2[8], meout2, maxima20, maxima21);
median median3(mein3[0], mein3[1], mein3[2], mein3[3], mein3[4], mein3[5], mein3[6], mein3[7], mein3[8], meout3, maxima30, maxima31);
reg [7:0] nein [3:0];
reg [7:0] neout [3:0];
negative4 negative4(nein[0], nein[1], nein[2], nein[3], neout[0], neout[1], neout[2], neout[3]);
reg [1:0] target_map;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        target_map <= 0;
    end else begin
        target_map <= (state0_nxt == SELECT) ? action : target_map;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        image_size_reg <= 0;
    end else begin
        if(in_valid & action_counter == 0 & rgb_counter == 0) begin
            image_size_reg <= image_size;
            image_size_reg_copy <= image_size;
        end else if(state0 == MAX_POOL && action_done) begin
            if(image_size_reg > 0) begin
                image_size_reg <= image_size_reg - 1;
            end
        end else if(state1 == FINAL_ACTION && action_done) begin
            image_size_reg <= image_size_reg_copy;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        in_valid_reg0 <= 0; 
        in_valid_reg1 <= 0;
        in_valid_reg2 <= 0;
    end else begin
        in_valid_reg0 <= in_valid;
        in_valid_reg1 <= in_valid_reg0;
        in_valid_reg2 <= in_valid_reg1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rgb_counter <= 0;
    end else begin
        if(in_valid | in_valid_reg1) begin
            rgb_counter <= (rgb_counter == 2) ? 0 : rgb_counter + 1;
        end
        if(in_valid2) begin
            rgb_counter <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        img_reg0 <= 0;
        img_reg1 <= 0;
        img_reg2 <= 0;
    end else begin
        case(rgb_counter)
            0: begin
                img_reg0 <= image;
                img_reg1 <= image;
                img_reg2 <= image / 4;
            end
            1: begin
                img_reg0 <= image > img_reg0 ? image : img_reg0;
                img_reg1 <= img_reg1 + image;
                img_reg2 <= img_reg2 + image / 2;
            end
            2: begin
                img_reg0 <= image > img_reg0 ? image : img_reg0;
                img_reg1 <= img_reg1 + image;
                img_reg2 <= img_reg2 + image / 4;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        action_lat <= 0;
    end else begin
        if(in_valid2) begin
            if(~action_done) begin
                if(state0 > 1) begin
                    action_lat <= action_lat + 1;
                end
            end
        end else begin
            action_lat <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        conv_counter <= 0;
    end else begin
        if(state0 == CONV) begin
            conv_counter <= conv_counter == 19 ? 0 : conv_counter + 1;
        end else begin
            conv_counter <= 0;
        end
    end
end
// ----------------- action -----------------
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        action_counter <= 0;
    end else begin
        if(in_valid_reg1 | in_valid) begin
            if(rgb_counter == 2) begin
                action_counter <= action_counter + 1;
            end
        end else if(~in_valid) begin
            if(state0 == SELECT) begin
                action_counter <= 0;
            end else begin
                case(state0) 
                    MAX_POOL: begin
                        if(image_size_reg == 0) begin
                            action_counter <= 0;
                        end else if(image_size_reg == 1) begin
                            action_counter <= action_counter == 7 ? 0 : action_counter + 1;
                        end else if(image_size_reg == 2) begin
                            action_counter <= action_counter == 31 ? 0 : action_counter + 1;
                        end
                    end
                    NEGATIVE: begin
                        if(image_size_reg == 0) begin
                            action_counter <= action_counter == 5 ? 0 : action_counter + 1;
                        end else if(image_size_reg == 1) begin
                            action_counter <= action_counter == 19 ? 0 : action_counter + 1;
                        end else if(image_size_reg == 2) begin
                            action_counter <= action_counter == 79 ? 0 : action_counter + 1;
                        end
                    end
                    H_FLIP: begin
                        if(image_size_reg == 0) begin
                            action_counter <= action_counter == 2 ? 0 : action_counter + 1;
                        end else if(image_size_reg == 1) begin
                            action_counter <= action_counter == 7 ? 0 : action_counter + 1;
                        end else if(image_size_reg == 2) begin
                            action_counter <= action_counter == 31 ? 0 : action_counter + 1;
                        end
                    end
                    MEDIAN: begin
                        if(image_size_reg == 0) begin
                            action_counter <= action_counter == 5 ? 0 : action_counter + 1;
                        end else if(image_size_reg == 1) begin
                            action_counter <= action_counter == 21 ? 0 : action_counter + 1;
                        end else if(image_size_reg == 2) begin
                            action_counter <= action_counter == 94 ? 0 : action_counter + 1;
                        end
                    end
                    CONV: begin
                        if(image_size_reg == 0) begin
                            if(action_counter == 16 & conv_counter == 19) begin
                                action_counter <= 0;
                            end else begin
                                action_counter <= conv_counter == 19 ? action_counter + 1 : action_counter;
                            end
                        end else if(image_size_reg == 1) begin
                            if(action_counter == 64 & conv_counter == 19) begin
                                action_counter <= 0;
                            end else begin
                                action_counter <= conv_counter == 19 ? action_counter + 1 : action_counter;
                            end
                        end else if(image_size_reg == 2) begin
                            if(action_counter == 256 & conv_counter == 19) begin
                                action_counter <= 0;
                            end else begin
                                action_counter <= conv_counter == 19 ? action_counter + 1 : action_counter;
                            end
                        end
                    end
                    default: begin
                        action_counter <= 0;
                    end
                endcase
            end
        end
    end 
end
always @(*) begin
    action_done = 0;
    case(state0) 
        MAX_POOL: begin
            if(image_size_reg == 0) begin
                action_done = 1;
            end else if(image_size_reg == 1) begin
                action_done = action_counter == 7;
            end else if(image_size_reg == 2) begin
                action_done = action_counter == 31;
            end
        end
        NEGATIVE: begin
            if(image_size_reg == 0) begin
                action_done = action_counter == 5;
            end else if(image_size_reg == 1) begin
                action_done = action_counter == 19;
            end else if(image_size_reg == 2) begin
                action_done = action_counter == 79;
            end
        end
        H_FLIP: begin
            if(image_size_reg == 0) begin
                action_done = action_counter == 2;
            end else if(image_size_reg == 1) begin
                action_done = action_counter == 7;
            end else if(image_size_reg == 2) begin
                action_done = action_counter == 31;
            end
        end
        MEDIAN: begin
            if(image_size_reg == 0) begin
                action_done = action_counter == 5;
            end else if(image_size_reg == 1) begin
                action_done = action_counter == 21;
            end else if(image_size_reg == 2) begin
                action_done = action_counter == 94;
            end
        end
        CONV: begin
            if(image_size_reg == 0) begin
                action_done = (action_counter == 16) && (conv_counter == 19);
            end else if(image_size_reg == 1) begin
                action_done = (action_counter == 64) && (conv_counter == 19);
            end else if(image_size_reg == 2) begin
                action_done = (action_counter == 256) && (conv_counter == 19);
            end
        end
    endcase
end
// ----------------- general_reg -----------------
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        row_reg0 <= 0; row_reg1 <= 0; row_reg2 <= 0;
    end else begin
        if(in_valid_reg0) begin
            if(rgb_counter == 0) begin
                row_reg0[7:0] <= row_reg0[15:8]; row_reg0[15:8] <= row_reg0[23:16]; row_reg0[23:16] <= row_reg0[31:24]; row_reg0[31:24] <= row_reg0[39:32]; 
                row_reg0[39:32] <= row_reg0[47:40]; row_reg0[47:40] <= row_reg0[55:48]; row_reg0[55:48] <= row_reg0[63:56]; row_reg0[63:56] <= row_reg0[71:64];
                row_reg0[71:64] <= row_reg0[79:72]; row_reg0[79:72] <= row_reg0[87:80]; row_reg0[87:80] <= row_reg0[95:88]; row_reg0[95:88] <= row_reg0[103:96];
                row_reg0[103:96] <= row_reg0[111:104]; row_reg0[111:104] <= row_reg0[119:112]; row_reg0[119:112] <= row_reg0[127:120]; row_reg0[127:120] <= img_reg0;
                row_reg1[7:0] <= row_reg1[15:8]; row_reg1[15:8] <= row_reg1[23:16]; row_reg1[23:16] <= row_reg1[31:24]; row_reg1[31:24] <= row_reg1[39:32];
                row_reg1[39:32] <= row_reg1[47:40]; row_reg1[47:40] <= row_reg1[55:48]; row_reg1[55:48] <= row_reg1[63:56]; row_reg1[63:56] <= row_reg1[71:64];
                row_reg1[71:64] <= row_reg1[79:72]; row_reg1[79:72] <= row_reg1[87:80]; row_reg1[87:80] <= row_reg1[95:88]; row_reg1[95:88] <= row_reg1[103:96];
                row_reg1[103:96] <= row_reg1[111:104]; row_reg1[111:104] <= row_reg1[119:112]; row_reg1[119:112] <= row_reg1[127:120]; row_reg1[127:120] <= img_reg1 / 3;
                row_reg2[7:0] <= row_reg2[15:8]; row_reg2[15:8] <= row_reg2[23:16]; row_reg2[23:16] <= row_reg2[31:24]; row_reg2[31:24] <= row_reg2[39:32];
                row_reg2[39:32] <= row_reg2[47:40]; row_reg2[47:40] <= row_reg2[55:48]; row_reg2[55:48] <= row_reg2[63:56]; row_reg2[63:56] <= row_reg2[71:64];
                row_reg2[71:64] <= row_reg2[79:72]; row_reg2[79:72] <= row_reg2[87:80]; row_reg2[87:80] <= row_reg2[95:88]; row_reg2[95:88] <= row_reg2[103:96];
                row_reg2[103:96] <= row_reg2[111:104]; row_reg2[111:104] <= row_reg2[119:112]; row_reg2[119:112] <= row_reg2[127:120]; row_reg2[127:120] <= img_reg2;
            end
        end else begin
            case(state0)
            MAX_POOL: begin
                case (action_counter)
                0, 4, 8, 12, 16, 20, 24, 28: row_reg0 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                1, 5, 9, 13, 17, 21, 25, 29: row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                endcase
            end
            NEGATIVE: begin
                case (action_counter)
                0, 10, 20, 30, 40, 50, 60, 70: row_reg0 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                1, 11, 21, 31, 41, 51, 61, 71: row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                endcase
            end
            H_FLIP: begin
                case (action_counter)
                0, 4, 8, 12, 16, 20, 24, 28: row_reg0 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                1, 5, 9, 13, 17, 21, 25, 29: row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                endcase
            end
            MEDIAN: begin
                if(image_size_reg < 2) begin
                    case (action_counter)
                    0: row_reg0 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                    1: row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                    8, 14: begin
                        row_reg0 <= row_reg1;
                        row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                    end
                    endcase
                end else begin
                    case (action_counter)
                    0: row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                    1: row_reg2 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                    7, 13, 19, 25, 31, 37, 43, 49, 55, 61, 67, 73, 79, 85, 89: begin
                        row_reg0 <= row_reg1;
                        row_reg1 <= row_reg2;
                        row_reg2 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                    end
                    endcase
                end
            end
            CONV: begin
                if(image_size_reg < 2) begin
                    case (action_counter)
                        0: begin
                            if(conv_counter == 0) begin
                                row_reg0 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end else if(conv_counter == 1) begin
                                row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end
                        end
                        24, 40: begin
                            if(conv_counter == 1) begin
                                row_reg0 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end else if(conv_counter == 2) begin
                                row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end
                        end
                    endcase
                end else begin
                    case (action_counter)
                        0: begin
                            if(conv_counter == 0) begin
                                row_reg0 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end else if(conv_counter == 1) begin
                                row_reg1 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end else if(conv_counter == 2) begin
                                row_reg2 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end
                        end
                        32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224: begin
                            if(conv_counter == 1) begin
                                row_reg0 <= row_reg1;
                                row_reg1 <= row_reg2;
                                row_reg2 <= {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                            end
                        end
                    endcase
                end
            end
            endcase
        end
    end
end
// ----------------- memory control -----------------
always @(*) begin
    mem_web = 1'd1;
    mem_addr = 6'd0;
    mem_di[0] = 8'd0; mem_di[1] = 8'd0; mem_di[2] = 8'd0; mem_di[3] = 8'd0; mem_di[4] = 8'd0; mem_di[5] = 8'd0; mem_di[6] = 8'd0; mem_di[7] = 8'd0;
    mem_di[8] = 8'd0; mem_di[9] = 8'd0; mem_di[10] = 8'd0; mem_di[11] = 8'd0; mem_di[12] = 8'd0; mem_di[13] = 8'd0; mem_di[14] = 8'd0; mem_di[15] = 8'd0;
    if(in_valid_reg2) begin
        if(rgb_counter == 0) begin
            mem_addr = action_counter / 16 - 1;
        end else if(rgb_counter == 1) begin
            mem_addr = action_counter / 16 + 15;
        end else if(rgb_counter == 2) begin
            mem_addr = action_counter / 16 + 31;
        end
        if((action_counter == 16 | action_counter == 32 | action_counter == 48 | action_counter == 64 |
            action_counter == 80 | action_counter == 96 | action_counter == 112 | action_counter == 128 |
            action_counter == 144 | action_counter == 160 | action_counter == 176 | action_counter == 192 |
            action_counter == 208 | action_counter == 224 | action_counter == 240 | action_counter == 256)) begin
            mem_web = 1'd0;
            if(rgb_counter == 0) begin
                mem_di[0] = row_reg0[15:8]; mem_di[1] = row_reg0[23:16]; mem_di[2] = row_reg0[31:24]; mem_di[3] = row_reg0[39:32];
                mem_di[4] = row_reg0[47:40]; mem_di[5] = row_reg0[55:48]; mem_di[6] = row_reg0[63:56]; mem_di[7] = row_reg0[71:64];
                mem_di[8] = row_reg0[79:72]; mem_di[9] = row_reg0[87:80]; mem_di[10] = row_reg0[95:88]; mem_di[11] = row_reg0[103:96];
                mem_di[12] = row_reg0[111:104]; mem_di[13] = row_reg0[119:112]; mem_di[14] = row_reg0[127:120]; mem_di[15] = img_reg0;
            end else if(rgb_counter == 1) begin
                mem_di[0] = row_reg1[7:0]; mem_di[1] = row_reg1[15:8]; mem_di[2] = row_reg1[23:16]; mem_di[3] = row_reg1[31:24];
                mem_di[4] = row_reg1[39:32]; mem_di[5] = row_reg1[47:40]; mem_di[6] = row_reg1[55:48]; mem_di[7] = row_reg1[63:56];
                mem_di[8] = row_reg1[71:64]; mem_di[9] = row_reg1[79:72]; mem_di[10] = row_reg1[87:80]; mem_di[11] = row_reg1[95:88];
                mem_di[12] = row_reg1[103:96]; mem_di[13] = row_reg1[111:104]; mem_di[14] = row_reg1[119:112]; mem_di[15] = row_reg1[127:120];
            end else if(rgb_counter == 2) begin
                mem_di[0] = row_reg2[7:0]; mem_di[1] = row_reg2[15:8]; mem_di[2] = row_reg2[23:16]; mem_di[3] = row_reg2[31:24];
                mem_di[4] = row_reg2[39:32]; mem_di[5] = row_reg2[47:40]; mem_di[6] = row_reg2[55:48]; mem_di[7] = row_reg2[63:56];
                mem_di[8] = row_reg2[71:64]; mem_di[9] = row_reg2[79:72]; mem_di[10] = row_reg2[87:80]; mem_di[11] = row_reg2[95:88];
                mem_di[12] = row_reg2[103:96]; mem_di[13] = row_reg2[111:104]; mem_di[14] = row_reg2[119:112]; mem_di[15] = row_reg2[127:120];
            end
        end
    end else begin
        case(state0)
        SELECT: begin
            if(target_map == 0) begin           mem_addr = 6'd0;
            end else if(target_map == 1) begin  mem_addr = 6'd16;
            end else begin                      mem_addr = 6'd32;
            end
        end
        MAX_POOL: begin
            mem_addr = 6'd48; 
            if(image_size_reg == 0) begin
                mem_web = 1'd0;
                mem_di = {mem_do[15], mem_do[14], mem_do[13], mem_do[12], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
            end else if(image_size_reg == 1) begin
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end
                2: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00};
                end
                3: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                4: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                6: begin
                    mem_web = 1'd0;
                    mem_di = {maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                endcase
            end else if(image_size_reg == 2) begin
                if(action_counter > 9 && action_counter < 15) begin
                    mem_addr = 6'd49;
                end else if(action_counter > 17 && action_counter < 23) begin
                    mem_addr = 6'd50;
                end else if(action_counter > 25 && action_counter < 31) begin
                    mem_addr = 6'd51;
                end
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end
                2: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00};
                end
                3: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                4: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                6: begin
                    mem_web = 1'd0;
                    mem_di = {maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                7: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 4;
                    end else begin
                        mem_addr = 6'd52;
                    end
                end
                8: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 5;
                    end else begin
                        mem_addr = 6'd53;
                    end
                end
                10: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00};
                end
                11: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 6;
                    end else begin
                        mem_addr = 6'd54;
                    end
                end
                12: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 7;
                    end else begin
                        mem_addr = 6'd55;
                    end
                end
                14: begin
                    mem_web = 1'd0;
                    mem_di = {maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                15: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 8;
                    end else begin
                        mem_addr = 6'd56;
                    end
                end
                16: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 9;
                    end else begin
                        mem_addr = 6'd57;
                    end
                end
                18: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00};
                end
                19: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 10;
                    end else begin
                        mem_addr = 6'd58;
                    end
                end
                20: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 11;
                    end else begin
                        mem_addr = 6'd59;
                    end
                end
                22: begin
                    mem_web = 1'd0;
                    mem_di = {maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                23: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 12;
                    end else begin
                        mem_addr = 6'd60;
                    end
                end
                24: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 13;
                    end else begin
                        mem_addr = 6'd61;
                    end
                end
                26: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00};
                end
                27: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 14;
                    end else begin
                        mem_addr = 6'd62;
                    end
                end
                28: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 15;
                    end else begin
                        mem_addr = 6'd63;
                    end
                end
                30: begin
                    mem_web = 1'd0;
                    mem_di = {maxima31, maxima30, maxima21, maxima20, maxima11, maxima10, maxima01, maxima00, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                endcase
            end
        end
        NEGATIVE: begin
            mem_addr = 6'd48; 
            if(image_size_reg == 0) begin
                case(action_counter)
                1: begin
                    mem_web = 1'd0;
                    {mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {neout[3], neout[2], neout[1], neout[0]};
                end
                2: begin
                    mem_web = 1'd0;
                    {mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {neout[3], neout[2], neout[1], neout[0], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                3: begin
                    mem_web = 1'd0;
                    {mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {neout[3], neout[2], neout[1], neout[0], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                4: begin
                    mem_web = 1'd0;
                    {mem_di[15], mem_di[14], mem_di[13], mem_di[12], mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {neout[3], neout[2], neout[1], neout[0], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                endcase
            end else if(image_size_reg == 1) begin
                if(action_counter > 4 && action_counter < 9) begin
                    mem_addr = 6'd49;
                end else if(action_counter > 10 && action_counter < 15) begin
                    mem_addr = 6'd50;
                end else if(action_counter > 14 && action_counter < 19) begin
                    mem_addr = 6'd51;
                end
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end 
                1, 5, 11, 15: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, neout[3], neout[2], neout[1], neout[0]};
                end
                2, 6, 12, 16: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, neout[3], neout[2], neout[1], neout[0], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                3, 7, 13, 17: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, neout[3], neout[2], neout[1], neout[0], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                4, 8, 14, 18: begin
                    mem_web = 1'd0;
                    mem_di = {neout[3], neout[2], neout[1], neout[0], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                9: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                10: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                endcase
            end else if(image_size_reg == 2) begin
                if(action_counter > 4 && action_counter < 9) begin
                    mem_addr = 6'd49;
                end else if(action_counter > 10 && action_counter < 15) begin
                    mem_addr = 6'd50;
                end else if(action_counter > 14 && action_counter < 19) begin
                    mem_addr = 6'd51;
                end else if(action_counter > 20 && action_counter < 25) begin
                    mem_addr = 6'd52;
                end else if(action_counter > 24 && action_counter < 29) begin
                    mem_addr = 6'd53;
                end else if(action_counter > 30 && action_counter < 35) begin
                    mem_addr = 6'd54;
                end else if(action_counter > 34 && action_counter < 39) begin
                    mem_addr = 6'd55;
                end else if(action_counter > 40 && action_counter < 45) begin
                    mem_addr = 6'd56;
                end else if(action_counter > 44 && action_counter < 49) begin
                    mem_addr = 6'd57;
                end else if(action_counter > 50 && action_counter < 55) begin
                    mem_addr = 6'd58;
                end else if(action_counter > 54 && action_counter < 59) begin
                    mem_addr = 6'd59;
                end else if(action_counter > 60 && action_counter < 65) begin
                    mem_addr = 6'd60;
                end else if(action_counter > 64 && action_counter < 69) begin
                    mem_addr = 6'd61;
                end else if(action_counter > 70 && action_counter < 75) begin
                    mem_addr = 6'd62;
                end else if(action_counter > 74 && action_counter < 79) begin
                    mem_addr = 6'd63;
                end
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end 
                1, 5, 11, 15, 21, 25, 31, 35, 41, 45, 51, 55, 61, 65, 71, 75: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, neout[3], neout[2], neout[1], neout[0]};
                end
                2, 6, 12, 16, 22, 26, 32, 36, 42, 46, 52, 56, 62, 66, 72, 76: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, neout[3], neout[2], neout[1], neout[0], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                3, 7, 13, 17, 23, 27, 33, 37, 43, 47, 53, 57, 63, 67, 73, 77: begin
                    mem_web = 1'd0;
                    mem_di = {8'd0, 8'd0, 8'd0, 8'd0, neout[3], neout[2], neout[1], neout[0], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                4, 8, 14, 18, 24, 28, 34, 38, 44, 48, 54, 58, 64, 68, 74, 78: begin
                    mem_web = 1'd0;
                    mem_di = {neout[3], neout[2], neout[1], neout[0], mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]};
                end
                9: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                10: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                19: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 4;
                    end else begin
                        mem_addr = 6'd52;
                    end
                end
                20: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 5;
                    end else begin
                        mem_addr = 6'd53;
                    end
                end
                29: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 6;
                    end else begin
                        mem_addr = 6'd54;
                    end
                end
                30: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 7;
                    end else begin
                        mem_addr = 6'd55;
                    end
                end
                39: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 8;
                    end else begin
                        mem_addr = 6'd56;
                    end
                end
                40: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 9;
                    end else begin
                        mem_addr = 6'd57;
                    end
                end
                49: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 10;
                    end else begin
                        mem_addr = 6'd58;
                    end
                end
                50: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 11;
                    end else begin
                        mem_addr = 6'd59;
                    end
                end
                59: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 12;
                    end else begin
                        mem_addr = 6'd60;
                    end
                end
                60: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 13;
                    end else begin
                        mem_addr = 6'd61;
                    end
                end
                69: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 14;
                    end else begin
                        mem_addr = 6'd62;
                    end
                end
                70: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 15;
                    end else begin
                        mem_addr = 6'd63;
                    end
                end
                endcase
            end 
        end
        H_FLIP: begin
            mem_addr = 6'd48; 
            if(image_size_reg == 0) begin
                case(action_counter)
                1: begin
                    mem_web = 1'd0;
                    mem_di = {row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], row_reg0[127:120], row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg0[95:88],
                                row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg0[63:56], row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg0[31:24]};
                end
                endcase
            end else if(image_size_reg == 1) begin
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end 
                1, 5: begin
                    mem_web = 1'd0;
                    mem_addr = (action_counter > 2) ? 6'd50 : 6'd48;
                    mem_di = {row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], row_reg0[127:120],
                                row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg0[63:56]};
                end
                2, 6: begin
                    mem_web = 1'd0;
                    mem_addr = (action_counter > 2) ? 6'd51 : 6'd49;
                    mem_di = {row_reg1[71:64], row_reg1[79:72], row_reg1[87:80], row_reg1[95:88], row_reg1[103:96], row_reg1[111:104], row_reg1[119:112], row_reg1[127:120],
                                row_reg1[7:0], row_reg1[15:8], row_reg1[23:16], row_reg1[31:24], row_reg1[39:32], row_reg1[47:40], row_reg1[55:48], row_reg1[63:56]};
                end
                3: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                4: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                endcase
            end else if(image_size_reg == 2) begin
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end 
                1, 5, 9, 13, 17, 21, 25, 29: begin
                    if(action_counter == 5) begin
                        mem_addr = 6'd50;
                    end else if(action_counter == 9) begin
                        mem_addr = 6'd52;
                    end else if(action_counter == 13) begin
                        mem_addr = 6'd54;
                    end else if(action_counter == 17) begin
                        mem_addr = 6'd56;
                    end else if(action_counter == 21) begin
                        mem_addr = 6'd58;
                    end else if(action_counter == 25) begin
                        mem_addr = 6'd60;
                    end else if(action_counter == 29) begin
                        mem_addr = 6'd62;
                    end
                    mem_web = 1'd0;
                    mem_di = {row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg0[63:56],
                                row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], row_reg0[127:120]};
                end
                2, 6, 10, 14, 18, 22, 26, 30: begin
                    mem_addr = 6'd49;
                    if(action_counter == 6) begin
                        mem_addr = 6'd51;
                    end else if(action_counter == 10) begin
                        mem_addr = 6'd53;
                    end else if(action_counter == 14) begin
                        mem_addr = 6'd55;
                    end else if(action_counter == 18) begin
                        mem_addr = 6'd57;
                    end else if(action_counter == 22) begin
                        mem_addr = 6'd59;
                    end else if(action_counter == 26) begin
                        mem_addr = 6'd61;
                    end else if(action_counter == 30) begin
                        mem_addr = 6'd63;
                    end
                    mem_web = 1'd0;
                    mem_di = {row_reg1[7:0], row_reg1[15:8], row_reg1[23:16], row_reg1[31:24], row_reg1[39:32], row_reg1[47:40], row_reg1[55:48], row_reg1[63:56],
                                row_reg1[71:64], row_reg1[79:72], row_reg1[87:80], row_reg1[95:88], row_reg1[103:96], row_reg1[111:104], row_reg1[119:112], row_reg1[127:120]};
                end
                3: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                4: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                7: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 4;
                    end else begin
                        mem_addr = 6'd52;
                    end
                end
                8: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 5;
                    end else begin
                        mem_addr = 6'd53;
                    end
                end
                11: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 6;
                    end else begin
                        mem_addr = 6'd54;
                    end
                end
                12: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 7;
                    end else begin
                        mem_addr = 6'd55;
                    end
                end
                15: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 8;
                    end else begin
                        mem_addr = 6'd56;
                    end
                end
                16: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 9;
                    end else begin
                        mem_addr = 6'd57;
                    end
                end
                19: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 10;
                    end else begin
                        mem_addr = 6'd58;
                    end
                end
                20: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 11;
                    end else begin
                        mem_addr = 6'd59;
                    end
                end
                23: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 12;
                    end else begin
                        mem_addr = 6'd60;
                    end
                end
                24: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 13;
                    end else begin
                        mem_addr = 6'd61;
                    end
                end
                27: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 14;
                    end else begin
                        mem_addr = 6'd62;
                    end
                end
                28: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 15;
                    end else begin
                        mem_addr = 6'd63;
                    end
                end
                endcase
            end
        end
        MEDIAN: begin
            mem_addr = 6'd48; 
            if(image_size_reg == 0) begin
                case(action_counter)
                1: begin
                    mem_web = 1'd0;
                    {mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {meout3, meout2, meout1, meout0};
                end
                2: begin
                    mem_web = 1'd0;
                    {mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {meout3, meout2, meout1, meout0, mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                3: begin
                    mem_web = 1'd0;
                    {mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {meout3, meout2, meout1, meout0, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                4: begin
                    mem_web = 1'd0;
                    {mem_di[15], mem_di[14], mem_di[13], mem_di[12], mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {meout3, meout2, meout1, meout0, mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                endcase
            end else if(image_size_reg == 1) begin
                if(action_counter > 4 && action_counter < 11) begin
                    mem_addr = 6'd49;
                end else if(action_counter > 10 && action_counter < 17) begin
                    mem_addr = 6'd50;
                end else if(action_counter > 16 && action_counter < 21) begin
                    mem_addr = 6'd51;
                end
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end
                1, 5, 11, 17: begin
                    mem_web = 1'd0;
                    {mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {meout3, meout2, meout1, meout0};
                end
                2, 6, 12, 18: begin
                    mem_web = 1'd0;
                    {mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {meout3, meout2, meout1, meout0, mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                3, 9, 15, 19: begin
                    mem_web = 1'd0;
                    {mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {meout3, meout2, meout1, meout0, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                4, 10, 16, 20: begin
                    mem_web = 1'd0;
                    {mem_di[15], mem_di[14], mem_di[13], mem_di[12], mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {meout3, meout2, meout1, meout0, mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                7: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                13: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                endcase
            end else if(image_size_reg == 2) begin
                if(action_counter > 7 && action_counter < 12) begin
                    mem_addr = 6'd49;
                end else if(action_counter > 13 && action_counter < 18) begin
                    mem_addr = 6'd50;
                end else if(action_counter > 19 && action_counter < 24) begin
                    mem_addr = 6'd51;
                end else if(action_counter > 25 && action_counter < 30) begin
                    mem_addr = 6'd52;
                end else if(action_counter > 31 && action_counter < 36) begin
                    mem_addr = 6'd53;
                end else if(action_counter > 37 && action_counter < 42) begin
                    mem_addr = 6'd54;
                end else if(action_counter > 43 && action_counter < 48) begin
                    mem_addr = 6'd55;
                end else if(action_counter > 49 && action_counter < 54) begin
                    mem_addr = 6'd56;
                end else if(action_counter > 55 && action_counter < 60) begin
                    mem_addr = 6'd57;
                end else if(action_counter > 61 && action_counter < 66) begin
                    mem_addr = 6'd58;
                end else if(action_counter > 67 && action_counter < 72) begin
                    mem_addr = 6'd59;
                end else if(action_counter > 73 && action_counter < 78) begin
                    mem_addr = 6'd60;
                end else if(action_counter > 79 && action_counter < 84) begin
                    mem_addr = 6'd61;
                end else if(action_counter > 85 && action_counter < 90) begin
                    mem_addr = 6'd62;
                end else if(action_counter > 89 && action_counter < 94) begin
                    mem_addr = 6'd63;
                end
                case(action_counter)
                0: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end
                2, 8, 14, 20, 26, 32, 38, 44, 50, 56, 62, 68, 74, 80, 86, 90: begin
                    mem_web = 1'd0;
                    {mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {meout3, meout2, meout1, meout0};
                end
                3, 9, 15, 21, 27, 33, 39, 45, 51, 57, 63, 69, 75, 81, 87, 91: begin
                    mem_web = 1'd0;
                    {mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]} = {meout3, meout2, meout1, meout0, mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                4, 10, 16, 22, 28, 34, 40, 46, 52, 58, 64, 70, 76, 82, 88, 92: begin
                    mem_web = 1'd0;
                    {mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {meout3, meout2, meout1, meout0, mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                5, 11, 17, 23, 29, 35, 41, 47, 53, 59, 65, 71, 77, 83, 89, 93: begin
                    mem_web = 1'd0;
                    {mem_di[15], mem_di[14], mem_di[13], mem_di[12], mem_di[11], mem_di[10], mem_di[9], mem_di[8], mem_di[7], mem_di[6], mem_di[5], mem_di[4], mem_di[3], mem_di[2], mem_di[1], mem_di[0]}
                    = {meout3, meout2, meout1, meout0, mem_do[11], mem_do[10], mem_do[9], mem_do[8], mem_do[7], mem_do[6], mem_do[5], mem_do[4], mem_do[3], mem_do[2], mem_do[1], mem_do[0]}; 
                end
                6: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 2;
                    end else begin
                        mem_addr = 6'd50;
                    end
                end
                12: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 3;
                    end else begin
                        mem_addr = 6'd51;
                    end
                end
                18: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 4;
                    end else begin
                        mem_addr = 6'd52;
                    end
                end
                24: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 5;
                    end else begin
                        mem_addr = 6'd53;
                    end
                end
                30: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 6;
                    end else begin
                        mem_addr = 6'd54;
                    end
                end
                36: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 7;
                    end else begin
                        mem_addr = 6'd55;
                    end
                end
                42: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 8;
                    end else begin
                        mem_addr = 6'd56;
                    end
                end
                48: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 9;
                    end else begin
                        mem_addr = 6'd57;
                    end
                end
                54: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 10;
                    end else begin
                        mem_addr = 6'd58;
                    end
                end
                60: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 11;
                    end else begin
                        mem_addr = 6'd59;
                    end
                end
                66: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 12;
                    end else begin
                        mem_addr = 6'd60;
                    end
                end
                72: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 13;
                    end else begin
                        mem_addr = 6'd61;
                    end
                end
                78: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 14;
                    end else begin
                        mem_addr = 6'd62;
                    end
                end
                84: begin
                    if(state1 == FIRST_ACTION) begin
                        mem_addr = target_map * 16 + 15;
                    end else begin
                        mem_addr = 6'd63;
                    end
                end
                endcase
            end 
        end
        CONV: begin
            if(image_size_reg == 1) begin
                case(action_counter)
                0: begin
                    if(state1 == SINGLE_ACTION) begin
                        mem_addr = target_map * 16 + 1;
                    end else begin
                        mem_addr = 6'd49;
                    end
                end 
                24: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 1;
                        end else begin
                            mem_addr = 6'd49;
                        end
                    end else if(conv_counter == 1) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 2;
                        end else begin
                            mem_addr = 6'd50;
                        end
                    end 
                end
                40: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 2;
                        end else begin
                            mem_addr = 6'd50;
                        end
                    end else if(conv_counter == 1) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 3;
                        end else begin
                            mem_addr = 6'd51;
                        end
                    end 
                end
                endcase
            end else if(image_size_reg == 2) begin
                case(action_counter)
                0: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 1;
                        end else begin
                            mem_addr = 6'd49;
                        end
                    end else if(conv_counter == 1) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 2;
                        end else begin
                            mem_addr = 6'd50;
                        end
                    end 
                end 
                32: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 3;
                        end else begin
                            mem_addr = 6'd51;
                        end
                    end
                end
                48: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 4;
                        end else begin
                            mem_addr = 6'd52;
                        end
                    end
                end
                64: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 5;
                        end else begin
                            mem_addr = 6'd53;
                        end
                    end
                end
                80: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 6;
                        end else begin
                            mem_addr = 6'd54;
                        end
                    end
                end
                96: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 7;
                        end else begin
                            mem_addr = 6'd55;
                        end
                    end
                end
                112: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 8;
                        end else begin
                            mem_addr = 6'd56;
                        end
                    end
                end
                128: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 9;
                        end else begin
                            mem_addr = 6'd57;
                        end
                    end
                end
                144: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 10;
                        end else begin
                            mem_addr = 6'd58;
                        end
                    end
                end
                160: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 11;
                        end else begin
                            mem_addr = 6'd59;
                        end
                    end
                end
                176: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 12;
                        end else begin
                            mem_addr = 6'd60;
                        end
                    end
                end
                192: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 13;
                        end else begin
                            mem_addr = 6'd61;
                        end
                    end
                end
                208: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 14;
                        end else begin
                            mem_addr = 6'd62;
                        end
                    end
                end
                224: begin
                    if(conv_counter == 0) begin
                        if(state1 == SINGLE_ACTION) begin
                            mem_addr = target_map * 16 + 15;
                        end else begin
                            mem_addr = 6'd63;
                        end
                    end
                end
                endcase
            end
        end
        endcase
    end
end
// ----------------- median & max_pool -----------------
always @(*) begin
    mein0 = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    mein1 = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    mein2 = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    mein3 = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    if(state0 == MAX_POOL) begin
        if(image_size_reg == 1) begin
            case(action_counter) 
            2, 6: begin
                {mein0[0], mein0[1], mein0[3], mein0[7]} = {row_reg0[7:0], row_reg0[15:8], row_reg0[71: 64], row_reg0[79:72]};
                {mein0[2], mein0[4], mein0[5], mein0[8]} = {row_reg0[23:16], row_reg0[31:24], row_reg0[87: 80], row_reg0[95:88]};
                {mein1[0], mein1[1], mein1[3], mein1[7]} = {row_reg0[39:32], row_reg0[47:40], row_reg0[103: 96], row_reg0[111:104]};
                {mein1[2], mein1[4], mein1[5], mein1[8]} = {row_reg0[55:48], row_reg0[63:56], row_reg0[119: 112], row_reg0[127:120]};
                {mein2[0], mein2[1], mein2[3], mein2[7]} = {row_reg1[7:0], row_reg1[15:8], row_reg1[71: 64], row_reg1[79:72]};
                {mein2[2], mein2[4], mein2[5], mein2[8]} = {row_reg1[23:16], row_reg1[31:24], row_reg1[87: 80], row_reg1[95:88]};
                {mein3[0], mein3[1], mein3[3], mein3[7]} = {row_reg1[39:32], row_reg1[47:40], row_reg1[103: 96], row_reg1[111:104]};
                {mein3[2], mein3[4], mein3[5], mein3[8]} = {row_reg1[55:48], row_reg1[63:56], row_reg1[119: 112], row_reg1[127:120]};
            end
            endcase
        end else if(image_size_reg == 2) begin
            case(action_counter) 
            2, 6, 10, 14, 18, 22, 26, 30: begin
                {mein0[0], mein0[1], mein0[3], mein0[7]} = {row_reg0[7:0], row_reg0[15:8], row_reg1[7:0], row_reg1[15:8]};
                {mein0[2], mein0[4], mein0[5], mein0[8]} = {row_reg0[23:16], row_reg0[31:24], row_reg1[23:16], row_reg1[31:24]};
                {mein1[0], mein1[1], mein1[3], mein1[7]} = {row_reg0[39:32], row_reg0[47:40], row_reg1[39:32], row_reg1[47:40]};
                {mein1[2], mein1[4], mein1[5], mein1[8]} = {row_reg0[55:48], row_reg0[63:56], row_reg1[55:48], row_reg1[63:56]};
                {mein2[0], mein2[1], mein2[3], mein2[7]} = {row_reg0[71:64], row_reg0[79:72], row_reg1[71:64], row_reg1[79:72]};
                {mein2[2], mein2[4], mein2[5], mein2[8]} = {row_reg0[87:80], row_reg0[95:88], row_reg1[87:80], row_reg1[95:88]};
                {mein3[0], mein3[1], mein3[3], mein3[7]} = {row_reg0[103:96], row_reg0[111:104], row_reg1[103:96], row_reg1[111:104]};
                {mein3[2], mein3[4], mein3[5], mein3[8]} = {row_reg0[119:112], row_reg0[127:120], row_reg1[119:112], row_reg1[127:120]};
            end
            endcase
        end
    end else if(state0 == MEDIAN) begin
        if(image_size_reg == 0) begin
            case (action_counter)
            1: begin
                mein0 = {row_reg0[47:40], row_reg0[39:32], row_reg0[39:32], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0]};
                mein1 = {row_reg0[55:48], row_reg0[47:40], row_reg0[39:32], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0]};
                mein2 = {row_reg0[63:56], row_reg0[55:48], row_reg0[47:40], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8]};
                mein3 = {row_reg0[63:56], row_reg0[63:56], row_reg0[55:48], row_reg0[31:24], row_reg0[31:24], row_reg0[23:16], row_reg0[31:24], row_reg0[31:24], row_reg0[23:16]};
            end
            2: begin
                mein0 = {row_reg0[79:72], row_reg0[71:64], row_reg0[71:64], row_reg0[47:40], row_reg0[39:32], row_reg0[39:32], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0]};
                mein1 = {row_reg0[87:80], row_reg0[79:72], row_reg0[71:64], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0]};
                mein2 = {row_reg0[95:88], row_reg0[87:80], row_reg0[79:72], row_reg0[63:56], row_reg0[55:48], row_reg0[47:40], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8]};
                mein3 = {row_reg0[95:88], row_reg0[95:88], row_reg0[87:80], row_reg0[63:56], row_reg0[63:56], row_reg0[55:48], row_reg0[31:24], row_reg0[31:24], row_reg0[23:16]};
            end
            3: begin
                mein0 = {row_reg0[111:104], row_reg0[103:96], row_reg0[103:96], row_reg0[79:72], row_reg0[71:64], row_reg0[71:64], row_reg0[47:40], row_reg0[39:32], row_reg0[39:32]};
                mein1 = {row_reg0[119:112], row_reg0[111:104], row_reg0[103:96], row_reg0[87:80], row_reg0[79:72], row_reg0[71:64], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32]};
                mein2 = {row_reg0[127:120], row_reg0[119:112], row_reg0[111:104], row_reg0[95:88], row_reg0[87:80], row_reg0[79:72], row_reg0[63:56], row_reg0[55:48], row_reg0[47:40]};
                mein3 = {row_reg0[127:120], row_reg0[127:120], row_reg0[119:112], row_reg0[95:88], row_reg0[95:88], row_reg0[87:80], row_reg0[63:56], row_reg0[63:56], row_reg0[55:48]};
            end
            4: begin
                mein0 = {row_reg0[111:104], row_reg0[103:96], row_reg0[103:96], row_reg0[111:104], row_reg0[103:96], row_reg0[103:96], row_reg0[79:72], row_reg0[71:64], row_reg0[71:64]};
                mein1 = {row_reg0[119:112], row_reg0[111:104], row_reg0[103:96], row_reg0[119:112], row_reg0[111:104], row_reg0[103:96], row_reg0[87:80], row_reg0[79:72], row_reg0[71:64]};
                mein2 = {row_reg0[127:120], row_reg0[119:112], row_reg0[111:104], row_reg0[127:120], row_reg0[119:112], row_reg0[111:104], row_reg0[95:88], row_reg0[87:80], row_reg0[79:72]};
                mein3 = {row_reg0[127:120], row_reg0[127:120], row_reg0[119:112], row_reg0[127:120], row_reg0[127:120], row_reg0[119:112], row_reg0[95:88], row_reg0[95:88], row_reg0[87:80]};
            end
            endcase
        end else if(image_size_reg == 1) begin
            case (action_counter)
            1: begin
                mein0 = {row_reg0[79:72], row_reg0[71:64], row_reg0[71:64], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0]};
                mein1 = {row_reg0[87:80], row_reg0[79:72], row_reg0[71:64], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0]};
                mein2 = {row_reg0[95:88], row_reg0[87:80], row_reg0[79:72], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8]};
                mein3 = {row_reg0[103:96], row_reg0[95:88], row_reg0[87:80], row_reg0[39:32], row_reg0[31:24], row_reg0[23:16], row_reg0[39:32], row_reg0[31:24], row_reg0[23:16]};
            end
            2: begin
                mein0 = {row_reg0[111:104], row_reg0[103:96], row_reg0[95:88], row_reg0[47:40], row_reg0[39:32], row_reg0[31:24], row_reg0[47:40], row_reg0[39:32], row_reg0[31:24]};
                mein1 = {row_reg0[119:112], row_reg0[111:104], row_reg0[103:96], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32]};
                mein2 = {row_reg0[127:120], row_reg0[119:112], row_reg0[111:104], row_reg0[63:56], row_reg0[55:48], row_reg0[47:40], row_reg0[63:56], row_reg0[55:48], row_reg0[47:40]};
                mein3 = {row_reg0[127:120], row_reg0[127:120], row_reg0[119:112], row_reg0[63:56], row_reg0[63:56], row_reg0[55:48], row_reg0[63:56], row_reg0[63:56], row_reg0[55:48]};
            end
            3, 9, 15: begin
                mein0 = {row_reg1[15:8], row_reg1[7:0], row_reg1[7:0], row_reg0[79:72], row_reg0[71:64], row_reg0[71:64], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0]};
                mein1 = {row_reg1[23:16], row_reg1[15:8], row_reg1[7:0], row_reg0[87:80], row_reg0[79:72], row_reg0[71:64], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0]};
                mein2 = {row_reg1[31:24], row_reg1[23:16], row_reg1[15:8], row_reg0[95:88], row_reg0[87:80], row_reg0[79:72], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8]};
                mein3 = {row_reg1[39:32], row_reg1[31:24], row_reg1[23:16], row_reg0[103:96], row_reg0[95:88], row_reg0[87:80], row_reg0[39:32], row_reg0[31:24], row_reg0[23:16]};
            end
            4, 10, 16: begin
                mein0 = {row_reg1[47:40], row_reg1[39:32], row_reg1[31:24], row_reg0[111:104], row_reg0[103:96], row_reg0[95:88], row_reg0[47:40], row_reg0[39:32], row_reg0[31:24]};
                mein1 = {row_reg1[55:48], row_reg1[47:40], row_reg1[39:32], row_reg0[119:112], row_reg0[111:104], row_reg0[103:96], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32]};
                mein2 = {row_reg1[63:56], row_reg1[55:48], row_reg1[47:40], row_reg0[127:120], row_reg0[119:112], row_reg0[111:104], row_reg0[63:56], row_reg0[55:48], row_reg0[47:40]};
                mein3 = {row_reg1[63:56], row_reg1[63:56], row_reg1[55:48], row_reg0[127:120], row_reg0[127:120], row_reg0[119:112], row_reg0[63:56], row_reg0[63:56], row_reg0[55:48]};
            end
            5, 11, 17: begin
                mein0 = {row_reg1[79:72], row_reg1[71:64], row_reg1[71:64], row_reg1[15:8], row_reg1[7:0], row_reg1[7:0], row_reg0[79:72], row_reg0[71:64], row_reg0[71:64]};
                mein1 = {row_reg1[87:80], row_reg1[79:72], row_reg1[71:64], row_reg1[23:16], row_reg1[15:8], row_reg1[7:0], row_reg0[87:80], row_reg0[79:72], row_reg0[71:64]};
                mein2 = {row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg1[31:24], row_reg1[23:16], row_reg1[15:8], row_reg0[95:88], row_reg0[87:80], row_reg0[79:72]};
                mein3 = {row_reg1[103:96], row_reg1[95:88], row_reg1[87:80], row_reg1[39:32], row_reg1[31:24], row_reg1[23:16], row_reg0[103:96], row_reg0[95:88], row_reg0[87:80]};
            end
            6, 12, 18: begin
                mein0 = {row_reg1[111:104], row_reg1[103:96], row_reg1[95:88], row_reg1[47:40], row_reg1[39:32], row_reg1[31:24], row_reg0[111:104], row_reg0[103:96], row_reg0[95:88]};
                mein1 = {row_reg1[119:112], row_reg1[111:104], row_reg1[103:96], row_reg1[55:48], row_reg1[47:40], row_reg1[39:32], row_reg0[119:112], row_reg0[111:104], row_reg0[103:96]};
                mein2 = {row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg1[63:56], row_reg1[55:48], row_reg1[47:40], row_reg0[127:120], row_reg0[119:112], row_reg0[111:104]};
                mein3 = {row_reg1[127:120], row_reg1[127:120], row_reg1[119:112], row_reg1[63:56], row_reg1[63:56], row_reg1[55:48], row_reg0[127:120], row_reg0[127:120], row_reg0[119:112]};
            end
            19: begin
                mein0 = {row_reg1[79:72], row_reg1[71:64], row_reg1[71:64], row_reg1[79:72], row_reg1[71:64], row_reg1[71:64], row_reg1[15:8], row_reg1[7:0], row_reg1[7:0]};
                mein1 = {row_reg1[87:80], row_reg1[79:72], row_reg1[71:64], row_reg1[87:80], row_reg1[79:72], row_reg1[71:64], row_reg1[23:16], row_reg1[15:8], row_reg1[7:0]};
                mein2 = {row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg1[31:24], row_reg1[23:16], row_reg1[15:8]};
                mein3 = {row_reg1[103:96], row_reg1[95:88], row_reg1[87:80], row_reg1[103:96], row_reg1[95:88], row_reg1[87:80], row_reg1[39:32], row_reg1[31:24], row_reg1[23:16]};
            end
            20: begin
                mein0 = {row_reg1[111:104], row_reg1[103:96], row_reg1[95:88], row_reg1[111:104], row_reg1[103:96], row_reg1[95:88], row_reg1[47:40], row_reg1[39:32], row_reg1[31:24]};
                mein1 = {row_reg1[119:112], row_reg1[111:104], row_reg1[103:96], row_reg1[119:112], row_reg1[111:104], row_reg1[103:96], row_reg1[55:48], row_reg1[47:40], row_reg1[39:32]};
                mein2 = {row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg1[63:56], row_reg1[55:48], row_reg1[47:40]};
                mein3 = {row_reg1[127:120], row_reg1[127:120], row_reg1[119:112], row_reg1[127:120], row_reg1[127:120], row_reg1[119:112], row_reg1[63:56], row_reg1[63:56], row_reg1[55:48]};
            end
            endcase
        end else if(image_size_reg == 2) begin
            case (action_counter)
            2: begin
                mein0 = {row_reg2[15:8], row_reg2[7:0], row_reg2[7:0], row_reg1[15:8], row_reg1[7:0], row_reg1[7:0], row_reg1[15:8], row_reg1[7:0], row_reg1[7:0]};
                mein1 = {row_reg2[23:16], row_reg2[15:8], row_reg2[7:0], row_reg1[23:16], row_reg1[15:8], row_reg1[7:0], row_reg1[23:16], row_reg1[15:8], row_reg1[7:0]};
                mein2 = {row_reg2[31:24], row_reg2[23:16], row_reg2[15:8], row_reg1[31:24], row_reg1[23:16], row_reg1[15:8], row_reg1[31:24], row_reg1[23:16], row_reg1[15:8]};
                mein3 = {row_reg2[39:32], row_reg2[31:24], row_reg2[23:16], row_reg1[39:32], row_reg1[31:24], row_reg1[23:16], row_reg1[39:32], row_reg1[31:24], row_reg1[23:16]};
            end
            3: begin
                mein0 = {row_reg2[47:40], row_reg2[39:32], row_reg2[31:24], row_reg1[47:40], row_reg1[39:32], row_reg1[31:24], row_reg1[47:40], row_reg1[39:32], row_reg1[31:24]};
                mein1 = {row_reg2[55:48], row_reg2[47:40], row_reg2[39:32], row_reg1[55:48], row_reg1[47:40], row_reg1[39:32], row_reg1[55:48], row_reg1[47:40], row_reg1[39:32]};
                mein2 = {row_reg2[63:56], row_reg2[55:48], row_reg2[47:40], row_reg1[63:56], row_reg1[55:48], row_reg1[47:40], row_reg1[63:56], row_reg1[55:48], row_reg1[47:40]};
                mein3 = {row_reg2[71:64], row_reg2[63:56], row_reg2[55:48], row_reg1[71:64], row_reg1[63:56], row_reg1[55:48], row_reg1[71:64], row_reg1[63:56], row_reg1[55:48]};
            end
            4: begin
                mein0 = {row_reg2[79:72], row_reg2[71:64], row_reg2[63:56], row_reg1[79:72], row_reg1[71:64], row_reg1[63:56], row_reg1[79:72], row_reg1[71:64], row_reg1[63:56]};
                mein1 = {row_reg2[87:80], row_reg2[79:72], row_reg2[71:64], row_reg1[87:80], row_reg1[79:72], row_reg1[71:64], row_reg1[87:80], row_reg1[79:72], row_reg1[71:64]};
                mein2 = {row_reg2[95:88], row_reg2[87:80], row_reg2[79:72], row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg1[95:88], row_reg1[87:80], row_reg1[79:72]};
                mein3 = {row_reg2[103:96], row_reg2[95:88], row_reg2[87:80], row_reg1[103:96], row_reg1[95:88], row_reg1[87:80], row_reg1[103:96], row_reg1[95:88], row_reg1[87:80]};
            end
            5: begin
                mein0 = {row_reg2[111:104], row_reg2[103:96], row_reg2[95:88], row_reg1[111:104], row_reg1[103:96], row_reg1[95:88], row_reg1[111:104], row_reg1[103:96], row_reg1[95:88]};
                mein1 = {row_reg2[119:112], row_reg2[111:104], row_reg2[103:96], row_reg1[119:112], row_reg1[111:104], row_reg1[103:96], row_reg1[119:112], row_reg1[111:104], row_reg1[103:96]};
                mein2 = {row_reg2[127:120], row_reg2[119:112], row_reg2[111:104], row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg1[127:120], row_reg1[119:112], row_reg1[111:104]};
                mein3 = {row_reg2[127:120], row_reg2[127:120], row_reg2[119:112], row_reg1[127:120], row_reg1[127:120], row_reg1[119:112], row_reg1[127:120], row_reg1[127:120], row_reg1[119:112]};
            end
            8, 14, 20, 26, 32, 38, 44, 50, 56, 62, 68, 74, 80, 86: begin
                mein0 = {row_reg2[15:8], row_reg2[7:0], row_reg2[7:0], row_reg1[15:8], row_reg1[7:0], row_reg1[7:0], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0]};
                mein1 = {row_reg2[23:16], row_reg2[15:8], row_reg2[7:0], row_reg1[23:16], row_reg1[15:8], row_reg1[7:0], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0]};
                mein2 = {row_reg2[31:24], row_reg2[23:16], row_reg2[15:8], row_reg1[31:24], row_reg1[23:16], row_reg1[15:8], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8]};
                mein3 = {row_reg2[39:32], row_reg2[31:24], row_reg2[23:16], row_reg1[39:32], row_reg1[31:24], row_reg1[23:16], row_reg0[39:32], row_reg0[31:24], row_reg0[23:16]};
            end 
            9, 15, 21, 27, 33, 39, 45, 51, 57, 63, 69, 75, 81, 87: begin
                mein0 = {row_reg2[47:40], row_reg2[39:32], row_reg2[31:24], row_reg1[47:40], row_reg1[39:32], row_reg1[31:24], row_reg0[47:40], row_reg0[39:32], row_reg0[31:24]};
                mein1 = {row_reg2[55:48], row_reg2[47:40], row_reg2[39:32], row_reg1[55:48], row_reg1[47:40], row_reg1[39:32], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32]};
                mein2 = {row_reg2[63:56], row_reg2[55:48], row_reg2[47:40], row_reg1[63:56], row_reg1[55:48], row_reg1[47:40], row_reg0[63:56], row_reg0[55:48], row_reg0[47:40]};
                mein3 = {row_reg2[71:64], row_reg2[63:56], row_reg2[55:48], row_reg1[71:64], row_reg1[63:56], row_reg1[55:48], row_reg0[71:64], row_reg0[63:56], row_reg0[55:48]};
            end
            10, 16, 22, 28, 34, 40, 46, 52, 58, 64, 70, 76, 82, 88: begin
                mein0 = {row_reg2[79:72], row_reg2[71:64], row_reg2[63:56], row_reg1[79:72], row_reg1[71:64], row_reg1[63:56], row_reg0[79:72], row_reg0[71:64], row_reg0[63:56]};
                mein1 = {row_reg2[87:80], row_reg2[79:72], row_reg2[71:64], row_reg1[87:80], row_reg1[79:72], row_reg1[71:64], row_reg0[87:80], row_reg0[79:72], row_reg0[71:64]};
                mein2 = {row_reg2[95:88], row_reg2[87:80], row_reg2[79:72], row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg0[95:88], row_reg0[87:80], row_reg0[79:72]};
                mein3 = {row_reg2[103:96], row_reg2[95:88], row_reg2[87:80], row_reg1[103:96], row_reg1[95:88], row_reg1[87:80], row_reg0[103:96], row_reg0[95:88], row_reg0[87:80]};
            end
            11, 17, 23, 29, 35, 41, 47, 53, 59, 65, 71, 77, 83, 89: begin
                mein0 = {row_reg2[111:104], row_reg2[103:96], row_reg2[95:88], row_reg1[111:104], row_reg1[103:96], row_reg1[95:88], row_reg0[111:104], row_reg0[103:96], row_reg0[95:88]};
                mein1 = {row_reg2[119:112], row_reg2[111:104], row_reg2[103:96], row_reg1[119:112], row_reg1[111:104], row_reg1[103:96], row_reg0[119:112], row_reg0[111:104], row_reg0[103:96]};
                mein2 = {row_reg2[127:120], row_reg2[119:112], row_reg2[111:104], row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg0[127:120], row_reg0[119:112], row_reg0[111:104]};
                mein3 = {row_reg2[127:120], row_reg2[127:120], row_reg2[119:112], row_reg1[127:120], row_reg1[127:120], row_reg1[119:112], row_reg0[127:120], row_reg0[127:120], row_reg0[119:112]};
            end
            90: begin
                mein0 = {row_reg1[15:8], row_reg1[7:0], row_reg1[7:0], row_reg1[15:8], row_reg1[7:0], row_reg1[7:0], row_reg0[15:8], row_reg0[7:0], row_reg0[7:0]};
                mein1 = {row_reg1[23:16], row_reg1[15:8], row_reg1[7:0], row_reg1[23:16], row_reg1[15:8], row_reg1[7:0], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0]};
                mein2 = {row_reg1[31:24], row_reg1[23:16], row_reg1[15:8], row_reg1[31:24], row_reg1[23:16], row_reg1[15:8], row_reg0[31:24], row_reg0[23:16], row_reg0[15:8]};
                mein3 = {row_reg1[39:32], row_reg1[31:24], row_reg1[23:16], row_reg1[39:32], row_reg1[31:24], row_reg1[23:16], row_reg0[39:32], row_reg0[31:24], row_reg0[23:16]};
            end 
            91: begin
                mein0 = {row_reg1[47:40], row_reg1[39:32], row_reg1[31:24], row_reg1[47:40], row_reg1[39:32], row_reg1[31:24], row_reg0[47:40], row_reg0[39:32], row_reg0[31:24]};
                mein1 = {row_reg1[55:48], row_reg1[47:40], row_reg1[39:32], row_reg1[55:48], row_reg1[47:40], row_reg1[39:32], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32]};
                mein2 = {row_reg1[63:56], row_reg1[55:48], row_reg1[47:40], row_reg1[63:56], row_reg1[55:48], row_reg1[47:40], row_reg0[63:56], row_reg0[55:48], row_reg0[47:40]};
                mein3 = {row_reg1[71:64], row_reg1[63:56], row_reg1[55:48], row_reg1[71:64], row_reg1[63:56], row_reg1[55:48], row_reg0[71:64], row_reg0[63:56], row_reg0[55:48]};
            end
            92: begin
                mein0 = {row_reg1[79:72], row_reg1[71:64], row_reg1[63:56], row_reg1[79:72], row_reg1[71:64], row_reg1[63:56], row_reg0[79:72], row_reg0[71:64], row_reg0[63:56]};
                mein1 = {row_reg1[87:80], row_reg1[79:72], row_reg1[71:64], row_reg1[87:80], row_reg1[79:72], row_reg1[71:64], row_reg0[87:80], row_reg0[79:72], row_reg0[71:64]};
                mein2 = {row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg0[95:88], row_reg0[87:80], row_reg0[79:72]};
                mein3 = {row_reg1[103:96], row_reg1[95:88], row_reg1[87:80], row_reg1[103:96], row_reg1[95:88], row_reg1[87:80], row_reg0[103:96], row_reg0[95:88], row_reg0[87:80]};
            end
            93: begin
                mein0 = {row_reg1[111:104], row_reg1[103:96], row_reg1[95:88], row_reg1[111:104], row_reg1[103:96], row_reg1[95:88], row_reg0[111:104], row_reg0[103:96], row_reg0[95:88]};
                mein1 = {row_reg1[119:112], row_reg1[111:104], row_reg1[103:96], row_reg1[119:112], row_reg1[111:104], row_reg1[103:96], row_reg0[119:112], row_reg0[111:104], row_reg0[103:96]};
                mein2 = {row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg0[127:120], row_reg0[119:112], row_reg0[111:104]};
                mein3 = {row_reg1[127:120], row_reg1[127:120], row_reg1[119:112], row_reg1[127:120], row_reg1[127:120], row_reg1[119:112], row_reg0[127:120], row_reg0[127:120], row_reg0[119:112]};
            end
            endcase
        end
    end
end
// ----------------- negative -----------------
always @(*) begin
    nein = {7'd0, 7'd0, 7'd0, 7'd0};
    case (action_counter)
    1, 11, 21, 31, 41, 51, 61, 71: nein = {row_reg0[31:24], row_reg0[23:16], row_reg0[15:8], row_reg0[7:0]};
    2, 12, 22, 32, 42, 52, 62, 72: nein = {row_reg0[63:56], row_reg0[55:48], row_reg0[47:40], row_reg0[39:32]};
    3, 13, 23, 33, 43, 53, 63, 73: nein = {row_reg0[95:88], row_reg0[87:80], row_reg0[79:72], row_reg0[71:64]};
    4, 14, 24, 34, 44, 54, 64, 74: nein = {row_reg0[127:120], row_reg0[119:112], row_reg0[111:104], row_reg0[103:96]};
    5, 15, 25, 35, 45, 55, 65, 75: nein = {row_reg1[31:24], row_reg1[23:16], row_reg1[15:8], row_reg1[7:0]};
    6, 16, 26, 36, 46, 56, 66, 76: nein = {row_reg1[63:56], row_reg1[55:48], row_reg1[47:40], row_reg1[39:32]};
    7, 17, 27, 37, 47, 57, 67, 77: nein = {row_reg1[95:88], row_reg1[87:80], row_reg1[79:72], row_reg1[71:64]};
    8, 18, 28, 38, 48, 58, 68, 78: nein = {row_reg1[127:120], row_reg1[119:112], row_reg1[111:104], row_reg1[103:96]};
    endcase
end
// ----------------- convolution -----------------
reg [7:0] target_kernel[0:8];
reg [7:0] target_pixel;
reg [15:0] product;
reg [19:0] conv_result;
always @(*) begin
    target_kernel = {0, 0, 0, 0, 0, 0, 0, 0, 0};
    if(image_size_reg == 0) begin
        case(action_counter)
            0: target_kernel = {0, 0, 0, 0, row_reg0[7:0], row_reg0[15:8], 0, row_reg0[39:32], row_reg0[47:40]};
            1: target_kernel = {0, 0, 0, row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg0[39:32], row_reg0[47:40], row_reg0[55:48]};
            2: target_kernel = {0, 0, 0, row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg0[47:40], row_reg0[55:48], row_reg0[63:56]};
            3: target_kernel = {0, 0, 0, row_reg0[23:16], row_reg0[31:24], 0, row_reg0[55:48], row_reg0[63:56], 0};
            4: target_kernel = {0, row_reg0[7:0], row_reg0[15:8], 0, row_reg0[39:32], row_reg0[47:40], 0, row_reg0[71:64], row_reg0[79:72]};
            5: target_kernel = {row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg0[71:64], row_reg0[79:72], row_reg0[87:80]};
            6: target_kernel = {row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg0[47:40], row_reg0[55:48], row_reg0[63:56], row_reg0[79:72], row_reg0[87:80], row_reg0[95:88]};
            7: target_kernel = {row_reg0[23:16], row_reg0[31:24], 0, row_reg0[55:48], row_reg0[63:56], 0, row_reg0[87:80], row_reg0[95:88], 0};
            8: target_kernel = {0, row_reg0[39:32], row_reg0[47:40], 0, row_reg0[71:64], row_reg0[79:72], 0, row_reg0[103:96], row_reg0[111:104]};
            9: target_kernel = {row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg0[103:96], row_reg0[111:104], row_reg0[119:112]};
            10: target_kernel = {row_reg0[47:40], row_reg0[55:48], row_reg0[63:56], row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg0[111:104], row_reg0[119:112], row_reg0[127:120]};
            11: target_kernel = {row_reg0[55:48], row_reg0[63:56], 0, row_reg0[87:80], row_reg0[95:88], 0, row_reg0[119:112], row_reg0[127:120], 0};
            12: target_kernel = {0, row_reg0[71:64], row_reg0[79:72], 0, row_reg0[103:96], row_reg0[111:104], 0, 0, 0};
            13: target_kernel = {row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], 0, 0, 0};
            14: target_kernel = {row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg0[111:104], row_reg0[119:112], row_reg0[127:120], 0, 0, 0};
            15: target_kernel = {row_reg0[87:80], row_reg0[95:88], 0, row_reg0[119:112], row_reg0[127:120], 0, 0, 0, 0};
        endcase
    end else if(image_size_reg == 1) begin
        case(action_counter)
            0: target_kernel = {0, 0, 0, 0, row_reg0[7:0], row_reg0[15:8], 0, row_reg0[71:64], row_reg0[79:72]};
            1: target_kernel = {0, 0, 0, row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg0[71:64], row_reg0[79:72], row_reg0[87:80]};
            2: target_kernel = {0, 0, 0, row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg0[79:72], row_reg0[87:80], row_reg0[95:88]};
            3: target_kernel = {0, 0, 0, row_reg0[23:16], row_reg0[31:24], row_reg0[39:32], row_reg0[87:80], row_reg0[95:88], row_reg0[103:96]};
            4: target_kernel = {0, 0, 0, row_reg0[31:24], row_reg0[39:32], row_reg0[47:40], row_reg0[95:88], row_reg0[103:96], row_reg0[111:104]};
            5: target_kernel = {0, 0, 0, row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg0[103:96], row_reg0[111:104], row_reg0[119:112]};
            6: target_kernel = {0, 0, 0, row_reg0[47:40], row_reg0[55:48], row_reg0[63:56], row_reg0[111:104], row_reg0[119:112], row_reg0[127:120]};
            7: target_kernel = {0, 0, 0, row_reg0[55:48], row_reg0[63:56], 0, row_reg0[119:112], row_reg0[127:120], 0};
            8, 24, 40: target_kernel = {0, row_reg0[7:0], row_reg0[15:8], 0, row_reg0[71:64], row_reg0[79:72], 0, row_reg1[7:0], row_reg1[15:8]};
            9, 25, 41: target_kernel = {row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg1[7:0], row_reg1[15:8], row_reg1[23:16]};
            10, 26, 42: target_kernel = {row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg1[15:8], row_reg1[23:16], row_reg1[31:24]};
            11, 27, 43: target_kernel = {row_reg0[23:16], row_reg0[31:24], row_reg0[39:32], row_reg0[87:80], row_reg0[95:88], row_reg0[103:96], row_reg1[23:16], row_reg1[31:24], row_reg1[39:32]};
            12, 28, 44: target_kernel = {row_reg0[31:24], row_reg0[39:32], row_reg0[47:40], row_reg0[95:88], row_reg0[103:96], row_reg0[111:104], row_reg1[31:24], row_reg1[39:32], row_reg1[47:40]};
            13, 29, 45: target_kernel = {row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], row_reg1[39:32], row_reg1[47:40], row_reg1[55:48]};
            14, 30, 46: target_kernel = {row_reg0[47:40], row_reg0[55:48], row_reg0[63:56], row_reg0[111:104], row_reg0[119:112], row_reg0[127:120], row_reg1[47:40], row_reg1[55:48], row_reg1[63:56]};
            15, 31, 47: target_kernel = {row_reg0[55:48], row_reg0[63:56], 0, row_reg0[119:112], row_reg0[127:120], 0, row_reg1[55:48], row_reg1[63:56], 0};
            16, 32, 48: target_kernel = {0, row_reg0[71:64], row_reg0[79:72], 0, row_reg1[7:0], row_reg1[15:8], 0, row_reg1[71:64], row_reg1[79:72]};
            17, 33, 49: target_kernel = {row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg1[7:0], row_reg1[15:8], row_reg1[23:16], row_reg1[71:64], row_reg1[79:72], row_reg1[87:80]};
            18, 34, 50: target_kernel = {row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg1[15:8], row_reg1[23:16], row_reg1[31:24], row_reg1[79:72], row_reg1[87:80], row_reg1[95:88]};
            19, 35, 51: target_kernel = {row_reg0[87:80], row_reg0[95:88], row_reg0[103:96], row_reg1[23:16], row_reg1[31:24], row_reg1[39:32], row_reg1[87:80], row_reg1[95:88], row_reg1[103:96]};
            20, 36, 52: target_kernel = {row_reg0[95:88], row_reg0[103:96], row_reg0[111:104], row_reg1[31:24], row_reg1[39:32], row_reg1[47:40], row_reg1[95:88], row_reg1[103:96], row_reg1[111:104]};
            21, 37, 53: target_kernel = {row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], row_reg1[39:32], row_reg1[47:40], row_reg1[55:48], row_reg1[103:96], row_reg1[111:104], row_reg1[119:112]};
            22, 38, 54: target_kernel = {row_reg0[111:104], row_reg0[119:112], row_reg0[127:120], row_reg1[47:40], row_reg1[55:48], row_reg1[63:56], row_reg1[111:104], row_reg1[119:112], row_reg1[127:120]};
            23, 39, 55: target_kernel = {row_reg0[119:112], row_reg0[127:120], 0, row_reg1[55:48], row_reg1[63:56], 0, row_reg1[119:112], row_reg1[127:120], 0};
            56: target_kernel = {0, row_reg1[7:0], row_reg1[15:8], 0, row_reg1[71:64], row_reg1[79:72], 0, 0, 0};
            57: target_kernel = {row_reg1[7:0], row_reg1[15:8], row_reg1[23:16], row_reg1[71:64], row_reg1[79:72], row_reg1[87:80], 0, 0, 0};
            58: target_kernel = {row_reg1[15:8], row_reg1[23:16], row_reg1[31:24], row_reg1[79:72], row_reg1[87:80], row_reg1[95:88], 0, 0, 0};
            59: target_kernel = {row_reg1[23:16], row_reg1[31:24], row_reg1[39:32], row_reg1[87:80], row_reg1[95:88], row_reg1[103:96], 0, 0, 0};
            60: target_kernel = {row_reg1[31:24], row_reg1[39:32], row_reg1[47:40], row_reg1[95:88], row_reg1[103:96], row_reg1[111:104], 0, 0, 0};
            61: target_kernel = {row_reg1[39:32], row_reg1[47:40], row_reg1[55:48], row_reg1[103:96], row_reg1[111:104], row_reg1[119:112], 0, 0, 0};
            62: target_kernel = {row_reg1[47:40], row_reg1[55:48], row_reg1[63:56], row_reg1[111:104], row_reg1[119:112], row_reg1[127:120], 0, 0, 0};
            63: target_kernel = {row_reg1[55:48], row_reg1[63:56], 0, row_reg1[119:112], row_reg1[127:120], 0, 0, 0, 0};
        endcase
    end else if(image_size_reg == 2) begin
        case(action_counter)
            0: target_kernel = {0, 0, 0, 0, row_reg0[7:0], row_reg0[15:8], 0, row_reg1[7:0], row_reg1[15:8]};
            1: target_kernel = {0, 0, 0, row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg1[7:0], row_reg1[15:8], row_reg1[23:16]};
            2: target_kernel = {0, 0, 0, row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg1[15:8], row_reg1[23:16], row_reg1[31:24]};
            3: target_kernel = {0, 0, 0, row_reg0[23:16], row_reg0[31:24], row_reg0[39:32], row_reg1[23:16], row_reg1[31:24], row_reg1[39:32]};
            4: target_kernel = {0, 0, 0, row_reg0[31:24], row_reg0[39:32], row_reg0[47:40], row_reg1[31:24], row_reg1[39:32], row_reg1[47:40]};
            5: target_kernel = {0, 0, 0, row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg1[39:32], row_reg1[47:40], row_reg1[55:48]};
            6: target_kernel = {0, 0, 0, row_reg0[47:40], row_reg0[55:48], row_reg0[63:56], row_reg1[47:40], row_reg1[55:48], row_reg1[63:56]};
            7: target_kernel = {0, 0, 0, row_reg0[55:48], row_reg0[63:56], row_reg0[71:64], row_reg1[55:48], row_reg1[63:56], row_reg1[71:64]};
            8: target_kernel = {0, 0, 0, row_reg0[63:56], row_reg0[71:64], row_reg0[79:72], row_reg1[63:56], row_reg1[71:64], row_reg1[79:72]};
            9: target_kernel = {0, 0, 0, row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg1[71:64], row_reg1[79:72], row_reg1[87:80]};
            10: target_kernel = {0, 0, 0, row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg1[79:72], row_reg1[87:80], row_reg1[95:88]};
            11: target_kernel = {0, 0, 0, row_reg0[87:80], row_reg0[95:88], row_reg0[103:96], row_reg1[87:80], row_reg1[95:88], row_reg1[103:96]};
            12: target_kernel = {0, 0, 0, row_reg0[95:88], row_reg0[103:96], row_reg0[111:104], row_reg1[95:88], row_reg1[103:96], row_reg1[111:104]};
            13: target_kernel = {0, 0, 0, row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], row_reg1[103:96], row_reg1[111:104], row_reg1[119:112]};
            14: target_kernel = {0, 0, 0, row_reg0[111:104], row_reg0[119:112], row_reg0[127:120], row_reg1[111:104], row_reg1[119:112], row_reg1[127:120]};
            15: target_kernel = {0, 0, 0, row_reg0[119:112], row_reg0[127:120], 0, row_reg1[119:112], row_reg1[127:120], 0};
            16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224: target_kernel = {0, row_reg0[7:0], row_reg0[15:8], 0, row_reg1[7:0], row_reg1[15:8], 0, row_reg2[7:0], row_reg2[15:8]};
            17, 33, 49, 65, 81, 97, 113, 129, 145,  161, 177, 193, 209, 225: target_kernel = {row_reg0[7:0], row_reg0[15:8], row_reg0[23:16], row_reg1[7:0], row_reg1[15:8], row_reg1[23:16], row_reg2[7:0], row_reg2[15:8], row_reg2[23:16]};
            18, 34, 50, 66, 82, 98, 114, 130, 146, 162, 178, 194, 210, 226: target_kernel = {row_reg0[15:8], row_reg0[23:16], row_reg0[31:24], row_reg1[15:8], row_reg1[23:16], row_reg1[31:24], row_reg2[15:8], row_reg2[23:16], row_reg2[31:24]};
            19, 35, 51, 67, 83, 99, 115, 131, 147, 163, 179, 195, 211, 227: target_kernel = {row_reg0[23:16], row_reg0[31:24], row_reg0[39:32], row_reg1[23:16], row_reg1[31:24], row_reg1[39:32], row_reg2[23:16], row_reg2[31:24], row_reg2[39:32]};
            20, 36, 52, 68, 84, 100, 116, 132, 148, 164, 180, 196, 212, 228: target_kernel = {row_reg0[31:24], row_reg0[39:32], row_reg0[47:40], row_reg1[31:24], row_reg1[39:32], row_reg1[47:40], row_reg2[31:24], row_reg2[39:32], row_reg2[47:40]};
            21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229: target_kernel = {row_reg0[39:32], row_reg0[47:40], row_reg0[55:48], row_reg1[39:32], row_reg1[47:40], row_reg1[55:48], row_reg2[39:32], row_reg2[47:40], row_reg2[55:48]};
            22, 38, 54, 70, 86, 102, 118, 134, 150, 166, 182, 198, 214, 230: target_kernel = {row_reg0[47:40], row_reg0[55:48], row_reg0[63:56], row_reg1[47:40], row_reg1[55:48], row_reg1[63:56], row_reg2[47:40], row_reg2[55:48], row_reg2[63:56]};
            23, 39, 55, 71, 87, 103, 119, 135, 151, 167, 183, 199, 215, 231: target_kernel = {row_reg0[55:48], row_reg0[63:56], row_reg0[71:64], row_reg1[55:48], row_reg1[63:56], row_reg1[71:64], row_reg2[55:48], row_reg2[63:56], row_reg2[71:64]};
            24, 40, 56, 72, 88, 104, 120, 136, 152, 168, 184, 200, 216, 232: target_kernel = {row_reg0[63:56], row_reg0[71:64], row_reg0[79:72], row_reg1[63:56], row_reg1[71:64], row_reg1[79:72], row_reg2[63:56], row_reg2[71:64], row_reg2[79:72]};
            25, 41, 57, 73, 89, 105, 121, 137, 153, 169, 185, 201, 217, 233: target_kernel = {row_reg0[71:64], row_reg0[79:72], row_reg0[87:80], row_reg1[71:64], row_reg1[79:72], row_reg1[87:80], row_reg2[71:64], row_reg2[79:72], row_reg2[87:80]};
            26, 42, 58, 74, 90, 106, 122, 138, 154, 170, 186, 202, 218, 234: target_kernel = {row_reg0[79:72], row_reg0[87:80], row_reg0[95:88], row_reg1[79:72], row_reg1[87:80], row_reg1[95:88], row_reg2[79:72], row_reg2[87:80], row_reg2[95:88]};
            27, 43, 59, 75, 91, 107, 123, 139, 155, 171, 187, 203, 219, 235: target_kernel = {row_reg0[87:80], row_reg0[95:88], row_reg0[103:96], row_reg1[87:80], row_reg1[95:88], row_reg1[103:96], row_reg2[87:80], row_reg2[95:88], row_reg2[103:96]};
            28, 44, 60, 76, 92, 108, 124, 140, 156, 172, 188, 204, 220, 236: target_kernel = {row_reg0[95:88], row_reg0[103:96], row_reg0[111:104], row_reg1[95:88], row_reg1[103:96], row_reg1[111:104], row_reg2[95:88], row_reg2[103:96], row_reg2[111:104]};
            29, 45, 61, 77, 93, 109, 125, 141, 157, 173, 189, 205, 221, 237: target_kernel = {row_reg0[103:96], row_reg0[111:104], row_reg0[119:112], row_reg1[103:96], row_reg1[111:104], row_reg1[119:112], row_reg2[103:96], row_reg2[111:104], row_reg2[119:112]};
            30, 46, 62, 78, 94, 110, 126, 142, 158, 174, 190, 206, 222, 238: target_kernel = {row_reg0[111:104], row_reg0[119:112], row_reg0[127:120], row_reg1[111:104], row_reg1[119:112], row_reg1[127:120], row_reg2[111:104], row_reg2[119:112], row_reg2[127:120]};
            31, 47, 63, 79, 95, 111, 127, 143, 159, 175, 191, 207, 223, 239: target_kernel = {row_reg0[119:112], row_reg0[127:120], 0, row_reg1[119:112], row_reg1[127:120], 0, row_reg2[119:112], row_reg2[127:120], 0};
            240: target_kernel = {0, row_reg1[7:0], row_reg1[15:8], 0, row_reg2[7:0], row_reg2[15:8], 0, 0, 0};
            241: target_kernel = {row_reg1[7:0], row_reg1[15:8], row_reg1[23:16], row_reg2[7:0], row_reg2[15:8], row_reg2[23:16], 0, 0, 0};
            242: target_kernel = {row_reg1[15:8], row_reg1[23:16], row_reg1[31:24], row_reg2[15:8], row_reg2[23:16], row_reg2[31:24], 0, 0, 0};
            243: target_kernel = {row_reg1[23:16], row_reg1[31:24], row_reg1[39:32], row_reg2[23:16], row_reg2[31:24], row_reg2[39:32], 0, 0, 0};
            244: target_kernel = {row_reg1[31:24], row_reg1[39:32], row_reg1[47:40], row_reg2[31:24], row_reg2[39:32], row_reg2[47:40], 0, 0, 0};
            245: target_kernel = {row_reg1[39:32], row_reg1[47:40], row_reg1[55:48], row_reg2[39:32], row_reg2[47:40], row_reg2[55:48], 0, 0, 0};
            246: target_kernel = {row_reg1[47:40], row_reg1[55:48], row_reg1[63:56], row_reg2[47:40], row_reg2[55:48], row_reg2[63:56], 0, 0, 0};
            247: target_kernel = {row_reg1[55:48], row_reg1[63:56], row_reg1[71:64], row_reg2[55:48], row_reg2[63:56], row_reg2[71:64], 0, 0, 0};
            248: target_kernel = {row_reg1[63:56], row_reg1[71:64], row_reg1[79:72], row_reg2[63:56], row_reg2[71:64], row_reg2[79:72], 0, 0, 0};
            249: target_kernel = {row_reg1[71:64], row_reg1[79:72], row_reg1[87:80], row_reg2[71:64], row_reg2[79:72], row_reg2[87:80], 0, 0, 0};
            250: target_kernel = {row_reg1[79:72], row_reg1[87:80], row_reg1[95:88], row_reg2[79:72], row_reg2[87:80], row_reg2[95:88], 0, 0, 0};
            251: target_kernel = {row_reg1[87:80], row_reg1[95:88], row_reg1[103:96], row_reg2[87:80], row_reg2[95:88], row_reg2[103:96], 0, 0, 0};
            252: target_kernel = {row_reg1[95:88], row_reg1[103:96], row_reg1[111:104], row_reg2[95:88], row_reg2[103:96], row_reg2[111:104], 0, 0, 0};
            253: target_kernel = {row_reg1[103:96], row_reg1[111:104], row_reg1[119:112], row_reg2[103:96], row_reg2[111:104], row_reg2[119:112], 0, 0, 0};
            254: target_kernel = {row_reg1[111:104], row_reg1[119:112], row_reg1[127:120], row_reg2[111:104], row_reg2[119:112], row_reg2[127:120], 0, 0, 0};
            255: target_kernel = {row_reg1[119:112], row_reg1[127:120], 0, row_reg2[119:112], row_reg2[127:120], 0, 0, 0, 0};
        endcase
    end
end
assign target_pixel = target_kernel[conv_counter - 10];
assign product = target_pixel * template_reg[0];
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        conv_result <= 0;
    end else begin
        if(conv_counter == 7) begin
            conv_result <= 0;
        end else if(conv_counter > 9) begin
            conv_result <= conv_result + product;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        template_reg[0] <= 0; template_reg[1] <= 0; template_reg[2] <= 0; template_reg[3] <= 0; template_reg[4] <= 0; 
        template_reg[5] <= 0; template_reg[6] <= 0; template_reg[7] <= 0; template_reg[8] <= 0;
    end else begin
        if(in_valid & (action_counter < 3)) begin
            template_reg[0] <= template_reg[1]; template_reg[1] <= template_reg[2]; template_reg[2] <= template_reg[3]; template_reg[3] <= template_reg[4]; 
            template_reg[4] <= template_reg[5]; template_reg[5] <= template_reg[6]; template_reg[6] <= template_reg[7]; template_reg[7] <= template_reg[8];
            template_reg[8] <= template;
        end else if(conv_counter > 9 & 19 > conv_counter) begin
            template_reg[0] <= template_reg[1]; template_reg[1] <= template_reg[2]; template_reg[2] <= template_reg[3]; template_reg[3] <= template_reg[4]; 
            template_reg[4] <= template_reg[5]; template_reg[5] <= template_reg[6]; template_reg[6] <= template_reg[7]; template_reg[7] <= template_reg[8];
            template_reg[8] <= template_reg[0];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        action_num <= 0;
    end else begin
        if(in_valid2) begin
            action_num <= action_num + 1;
        end else begin
            action_num <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        action_reg[0] <= 0; action_reg[1] <= 0; action_reg[2] <= 0; action_reg[3] <= 0; action_reg[4] <= 0; action_reg[5] <= 0; action_reg[6] <= 0;
    end else begin
        if(in_valid2) begin
            case(action_num)
                1: action_reg[0] <= action;
                2: action_reg[1] <= action;
                3: action_reg[2] <= action;
                4: action_reg[3] <= action;
                5: action_reg[4] <= action;
                6: action_reg[5] <= action;
                7: action_reg[6] <= action;
            endcase
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        output_reg <= 0;
    end else begin
        if(conv_counter == 19) begin
            output_reg <= conv_result;
        end
    end
end
always @(*) begin
    if(state0 == CONV) begin
        if(action_counter > 0) begin
            out_valid = 1;
            out_value = output_reg[19 - conv_counter];
        end else begin
            out_valid = 0;
            out_value = 0;
        end
    end else begin
        out_valid = 0;
        out_value = 0;
    end
end
  
endmodule

module median (
    input [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8,
    output reg [7:0] median_out, max_pool_out0, max_pool_out1
);
reg [7:0] sort00, sort01, sort02, sort03, sort04, sort05, sort06, sort07, sort08;
reg [7:0] sort10, sort11, sort12, sort13, sort14, sort15, sort16, sort17, sort18;
reg [7:0] sort21, sort22, sort23, sort24, sort25, sort26, sort27, sort28;
reg [7:0] sort32, sort33, sort34, sort35;
reg [7:0] sort42, sort43, sort44, sort45;
reg [7:0] sort53, sort54;

assign sort00 = (in0 > in3) ? in0 : in3;
assign sort01 = (in1 > in7) ? in1 : in7;
assign sort02 = (in2 > in5) ? in2 : in5;
assign sort03 = (in0 > in3) ? in3 : in0;
assign sort04 = (in4 > in8) ? in4 : in8;
assign sort05 = (in2 > in5) ? in5 : in2;
assign sort06 = in6;
assign sort07 = (in1 > in7) ? in7 : in1;
assign sort08 = (in4 > in8) ? in8 : in4;

assign sort10 = sort00 > sort07 ? sort00 : sort07;
assign sort11 = sort01;
assign sort12 = sort02 > sort04 ? sort02 : sort04;
assign sort13 = sort03 > sort08 ? sort03 : sort08;
assign sort14 = sort02 > sort04 ? sort04 : sort02;
assign sort15 = sort05 > sort06 ? sort05 : sort06;
assign sort16 = sort05 > sort06 ? sort06 : sort05;
assign sort17 = sort00 > sort07 ? sort07 : sort00;
assign sort18 = sort03 > sort08 ? sort08 : sort03;

assign sort21 = sort11 > sort13 ? sort11 : sort13;
assign sort22 = sort10 > sort12 ? sort12 : sort10;
assign sort23 = sort11 > sort13 ? sort13 : sort11;
assign sort24 = sort14 > sort15 ? sort14 : sort15;
assign sort25 = sort14 > sort15 ? sort15 : sort14;
assign sort26 = sort16;
assign sort27 = sort17 > sort18 ? sort17 : sort18;
assign sort28 = sort17 > sort18 ? sort18 : sort17;

assign sort32 = sort22;
assign sort33 = sort23 > sort26 ? sort23 : sort26;
assign sort34 = sort21 > sort24 ? sort24 : sort21;
assign sort35 = sort25 > sort27 ? sort25 : sort27;

assign sort42 = sort32 > sort34 ? sort32 : sort34;
assign sort43 = sort33 > sort35 ? sort33 : sort35;
assign sort44 = sort32 > sort34 ? sort34 : sort32;
assign sort45 = sort33 > sort35 ? sort35 : sort33;

assign sort53 = sort42 > sort43 ? sort43 : sort42;
assign sort54 = sort44 > sort45 ? sort44 : sort45;

assign median_out = sort53 > sort54 ? sort54 : sort53;
assign max_pool_out0 = sort00 > sort01 ? sort00 : sort01;
assign max_pool_out1 = sort12;
endmodule

module negative4 (
    input [7:0] in0, in1, in2, in3,
    output reg [7:0] out0, out1, out2, out3
);
assign out0 = 255 - in0;
assign out1 = 255 - in1;
assign out2 = 255 - in2;
assign out3 = 255 - in3;
endmodule
