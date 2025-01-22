module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input [1:0] in_mode,
    input [1:0] in_ratio_mode,

    // Output Signals
    output out_valid,
    output [7:0] out_data,
    
    // DRAM Signals
    // axi write address channel
    // src master
    output [3:0]  awid_s_inf,
    output [31:0] awaddr_s_inf,
    output [2:0]  awsize_s_inf,
    output [1:0]  awburst_s_inf,
    output [7:0]  awlen_s_inf,
    output        awvalid_s_inf,
    // src slave
    input         awready_s_inf,
    // -----------------------------
  
    // axi write data channel 
    // src master
    output [127:0] wdata_s_inf,
    output         wlast_s_inf,
    output         wvalid_s_inf,
    // src slave
    input          wready_s_inf,
  
    // axi write response channel 
    // src slave
    input [3:0]    bid_s_inf,
    input [1:0]    bresp_s_inf,
    input          bvalid_s_inf,
    // src master 
    output         bready_s_inf,
    // -----------------------------
  
    // axi read address channel 
    // src master
    output [3:0]   arid_s_inf,
    output [31:0]  araddr_s_inf,
    output [7:0]   arlen_s_inf,
    output [2:0]   arsize_s_inf,
    output [1:0]   arburst_s_inf,
    output         arvalid_s_inf,
    // src slave
    input          arready_s_inf,
    // -----------------------------
  
    // axi read data channel 
    // slave
    input [3:0]    rid_s_inf,
    input [127:0]  rdata_s_inf,
    input [1:0]    rresp_s_inf,
    input          rlast_s_inf,
    input          rvalid_s_inf,
    // master
    output         rready_s_inf
    
);

// Your Design
enum reg [3:0]{
    IDLE_R,
    R_BUF, R_HS, R_REC_head, R_WAIT, R_REC, R_CALC,
    R_SKIP
} state_r, state_r_nxt;

enum reg [2:0] {
    IDLE_W,
    W_BUF,
    W_HS,
    W_WAIT_head,
    W_OUT_head,
    W_WAIT,
    W_OUT,
    W_RESP
} state_w, state_w_nxt;

reg [7:0] gp_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        gp_cnt <= 8'b0;
    end else begin
        case(state_r)
            R_REC_head, R_REC: begin
                gp_cnt <= (rready_s_inf && rvalid_s_inf) ? gp_cnt + 1 : gp_cnt;
            end
            R_CALC: begin
                gp_cnt <= (gp_cnt == 203) ? 0 : gp_cnt + 1;
            end
        endcase
    end
end

reg [4:0] af_cnt;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        af_cnt <= 0;
    end else begin
        if(state_r == R_REC && gp_cnt == 158) begin
            af_cnt <= 1;
        end else begin
            if(af_cnt > 0) begin
                af_cnt <= af_cnt + 1;
            end
        end
    end
end

reg [1:0] arg_max;
reg [17:0] avg;

reg [7:0] data_in [15:0];
reg [127:0] data_out;

reg [1:0] mode_reg;
reg [3:0] pic_no_reg;
reg [1:0] ratio_reg;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mode_reg <= 2'b0;
        pic_no_reg <= 4'b0;
        ratio_reg <= 2'b0;
    end else begin
        if (in_valid) begin
            mode_reg <= in_mode;
            pic_no_reg <= in_pic_no;
            ratio_reg <= in_mode == 1 ? in_ratio_mode : 2;
        end
    end
end

reg [7:0] max_temp;
reg [7:0] R_max, G_max, B_max;
reg [7:0] min_temp;
reg [7:0] R_min, G_min, B_min;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        R_max <= 0; R_min <= 0;
        G_max <= 0; G_min <= 0;
        B_max <= 0; B_min <= 0;
    end else begin
        if(gp_cnt == 0) begin
            R_max <= 0; R_min <= 255;
            G_max <= 0; G_min <= 255;
            B_max <= 0; B_min <= 255;
        end else if(gp_cnt <= 64) begin
            R_max <= max_temp > R_max ? max_temp : R_max;
            R_min <= (state_r == R_REC) ? min_temp < R_min ? min_temp : R_min : 255;
        end else if(gp_cnt <= 128) begin
            G_max <= max_temp > G_max ? max_temp : G_max;
            G_min <= min_temp < G_min ? min_temp : G_min;
        end else if(gp_cnt <= 192) begin
            B_max <= max_temp > B_max ? max_temp : B_max;
            B_min <= min_temp < B_min ? min_temp : B_min;
        end
    end
end

reg [9:0] RGB_max, RGB_min;
reg [8:0] max, min, max_tmp, min_tmp;
reg [7:0] max_min_avg;
reg [9:0] RGB_max_reg, RGB_min_reg, RGB_max_tmp, RGB_min_tmp;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        RGB_max <= 0; RGB_min <= 0;
    end else begin
        RGB_max <= R_max + G_max + B_max;
        RGB_min <= R_min + G_min + B_min;
    end
end

assign max_min_avg = (max + min) / 2;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        RGB_max_reg <= 0;
        RGB_min_reg <= 0;
    end else begin
        RGB_max_reg <= gp_cnt == 193 ? RGB_max : RGB_max_tmp;
        RGB_min_reg <= gp_cnt == 193 ? RGB_min : RGB_min_tmp;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        max <= 0;
        min <= 0;
    end else begin
        max <= state_r == R_REC ? 0 : max_tmp;
        min <= state_r == R_REC ? 0 : min_tmp;
    end
end

always @* begin
    RGB_max_tmp = RGB_max_reg;
    RGB_min_tmp = RGB_min_reg;
    if(RGB_max_reg >= 384) begin
        RGB_max_tmp = RGB_max_reg - 384;
        max_tmp = max + 128;
    end else if(RGB_max_reg >= 192) begin
        RGB_max_tmp = RGB_max_reg - 192;
        max_tmp = max + 64;
    end else if(RGB_max_reg >= 96) begin
        RGB_max_tmp = RGB_max_reg - 96;
        max_tmp = max + 32;
    end else if(RGB_max_reg >= 48) begin
        RGB_max_tmp = RGB_max_reg - 48;
        max_tmp = max + 16;
    end else if(RGB_max_reg >= 24) begin
        RGB_max_tmp = RGB_max_reg - 24;
        max_tmp = max + 8;
    end else if(RGB_max_reg >= 12) begin
        RGB_max_tmp = RGB_max_reg - 12;
        max_tmp = max + 4;
    end else if(RGB_max_reg >= 6) begin
        RGB_max_tmp = RGB_max_reg - 6;
        max_tmp = max + 2;
    end else if(RGB_max_reg >= 3) begin
        RGB_max_tmp = RGB_max_reg - 3;
        max_tmp = max + 1;
    end else begin
        RGB_max_tmp = RGB_max_reg;
        max_tmp = max;
    end
    if(RGB_min_reg >= 384) begin
        RGB_min_tmp = RGB_min_reg - 384;
        min_tmp = min + 128;
    end else if(RGB_min_reg >= 192) begin
        RGB_min_tmp = RGB_min_reg - 192;
        min_tmp = min + 64;
    end else if(RGB_min_reg >= 96) begin
        RGB_min_tmp = RGB_min_reg - 96;
        min_tmp = min + 32;
    end else if(RGB_min_reg >= 48) begin
        RGB_min_tmp = RGB_min_reg - 48;
        min_tmp = min + 16;
    end else if(RGB_min_reg >= 24) begin
        RGB_min_tmp = RGB_min_reg - 24;
        min_tmp = min + 8;
    end else if(RGB_min_reg >= 12) begin
        RGB_min_tmp = RGB_min_reg - 12;
        min_tmp = min + 4;
    end else if(RGB_min_reg >= 6) begin
        RGB_min_tmp = RGB_min_reg - 6;
        min_tmp = min + 2;
    end else if(RGB_min_reg >= 3) begin
        RGB_min_tmp = RGB_min_reg - 3;
        min_tmp = min + 1;
    end else begin
        RGB_min_tmp = RGB_min_reg;
        min_tmp = min;
    end
end

reg [7:0] sort000, sort001, sort002, sort003, sort004, sort005, sort006, sort007;
reg [7:0] sort010, sort011, sort016, sort017;
reg [7:0] sort020, sort021;
always @(posedge clk) begin
    sort000 <= data_out[23:16] > data_out[7:0] ? data_out[23:16] : data_out[7:0];
    sort001 <= data_out[31:24] > data_out[15:8] ? data_out[31:24] : data_out[15:8];
    sort002 <= data_out[23:16] > data_out[7:0] ? data_out[7:0] : data_out[23:16];
    sort003 <= data_out[31:24] > data_out[15:8] ? data_out[15:8] : data_out[31:24];
    sort004 <= data_out[55:48] > data_out[39:32] ? data_out[55:48] : data_out[39:32];
    sort005 <= data_out[63:56] > data_out[47:40] ? data_out[63:56] : data_out[47:40];
    sort006 <= data_out[55:48] > data_out[39:32] ? data_out[39:32] : data_out[55:48];
    sort007 <= data_out[63:56] > data_out[47:40] ? data_out[47:40] : data_out[63:56];

    sort010 <= sort004 > sort000 ? sort004 : sort000;
    sort011 <= sort005 > sort001 ? sort005 : sort001;
    sort016 <= sort006 > sort002 ? sort002 : sort006;
    sort017 <= sort007 > sort003 ? sort003 : sort007;

    sort020 <= sort010 > sort011 ? sort010 : sort011;
    sort021 <= sort016 > sort017 ? sort017 : sort016;
end

reg [7:0] sort100, sort101, sort102, sort103, sort104, sort105, sort106, sort107;
reg [7:0] sort110, sort111, sort116, sort117;
reg [7:0] sort120, sort121;
always @(posedge clk) begin
    sort100 <= data_out[87:80] > data_out[71:64] ? data_out[87:80] : data_out[71:64];
    sort101 <= data_out[95:88] > data_out[79:72] ? data_out[95:88] : data_out[79:72];
    sort102 <= data_out[87:80] > data_out[71:64] ? data_out[71:64] : data_out[87:80];
    sort103 <= data_out[95:88] > data_out[79:72] ? data_out[79:72] : data_out[95:88];
    sort104 <= data_out[119:112] > data_out[103:96] ? data_out[119:112] : data_out[103:96];
    sort105 <= data_out[127:120] > data_out[111:104] ? data_out[127:120] : data_out[111:104];
    sort106 <= data_out[119:112] > data_out[103:96] ? data_out[103:96] : data_out[119:112];
    sort107 <= data_out[127:120] > data_out[111:104] ? data_out[111:104] : data_out[127:120];

    sort110 <= sort104 > sort100 ? sort104 : sort100;
    sort111 <= sort105 > sort101 ? sort105 : sort101;
    sort116 <= sort106 > sort102 ? sort102 : sort106;
    sort117 <= sort107 > sort103 ? sort103 : sort107;

    sort120 <= sort110 > sort111 ? sort110 : sort111;
    sort121 <= sort116 > sort117 ? sort117 : sort116;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        max_temp <= 0;
        min_temp <= 0;
    end else begin
        max_temp <= sort020 > sort120 ? sort020 : sort120;
        min_temp <= sort021 < sort121 ? sort021 : sort121;
    end
end

reg record_table [15:0];
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < 16; i = i + 1) begin
            record_table[i] <= 0;
        end
    end else begin
        if(state_r == R_CALC) begin
            record_table[pic_no_reg] <= 1;
        end
    end
end

reg [1:0] focus_record [15:0];
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < 16; i = i + 1) begin
            focus_record[i] <= 0;
        end
    end else begin
        if(state_r == R_CALC) begin
            focus_record[pic_no_reg] <= arg_max;
        end
    end
end

reg [7:0] expo_record [15:0];
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < 16; i = i + 1) begin
            expo_record[i] <= 0;
        end
    end else begin
        if(state_r == R_CALC) begin
            expo_record[pic_no_reg] <= avg[17:10];
        end
    end
end

reg [7:0] avg_record [15:0];
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < 16; i = i + 1) begin
            avg_record[i] <= 0;
        end
    end else begin
        if(state_r == R_CALC) begin
            avg_record[pic_no_reg] <= max_min_avg;
        end
    end
end

reg [2:0] pic_max [15:0];
reg [2:0] global_max_checker; // {(3or2), (1), (0)}
reg expo_skip;
assign expo_skip = (record_table[pic_no_reg] && pic_max[pic_no_reg][2] && (ratio_reg == 0)) || (record_table[pic_no_reg] && pic_max[pic_no_reg][1] && ~(ratio_reg[1]));
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        global_max_checker <= 3'b111;
    end else begin
        if(state_w == W_OUT) begin
            if(data_out[127:120] > 3 | data_out[119:112] > 3 | data_out[111:104] > 3 | data_out[103:96] > 3 | data_out[95:88] > 3 | data_out[87:80] > 3 | data_out[79:72] > 3 | data_out[71:64] > 3 | data_out[63:56] > 3 | data_out[55:48] > 3 | data_out[47:40] > 3 | data_out[39:32] > 3 | data_out[31:24] > 3 | data_out[23:16] > 3 | data_out[15:8] > 3 | data_out[7:0] > 3) begin
                global_max_checker[2] <= 0;
            end
            if(data_out[127:120] > 1 | data_out[119:112] > 1 | data_out[111:104] > 1 | data_out[103:96] > 1 | data_out[95:88] > 1 | data_out[87:80] > 1 | data_out[79:72] > 1 | data_out[71:64] > 1 | data_out[63:56] > 1 | data_out[55:48] > 1 | data_out[47:40] > 1 | data_out[39:32] > 1 | data_out[31:24] > 1 | data_out[23:16] > 1 | data_out[15:8] > 1 | data_out[7:0] > 1) begin
                global_max_checker[1] <= 0;
            end
            if(data_out[127:120] > 0 | data_out[119:112] > 0 | data_out[111:104] > 0 | data_out[103:96] > 0 | data_out[95:88] > 0 | data_out[87:80] > 0 | data_out[79:72] > 0 | data_out[71:64] > 0 | data_out[63:56] > 0 | data_out[55:48] > 0 | data_out[47:40] > 0 | data_out[39:32] > 0 | data_out[31:24] > 0 | data_out[23:16] > 0 | data_out[15:8] > 0 | data_out[7:0] > 0) begin
                global_max_checker[0] <= 0;
            end
        end else if(state_w == W_BUF) begin
            global_max_checker <= 3'b111;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < 16; i = i + 1) begin
            pic_max[i] <= 0;
        end
    end else begin
        if(expo_skip) begin
            if(state_r == R_BUF) begin
                pic_max[pic_no_reg] <= 3'b111;
            end
        end else if(state_w == W_RESP) begin
            case(1'b1)
                global_max_checker[0]: pic_max[pic_no_reg] <= 3'b111;
                global_max_checker[1]: pic_max[pic_no_reg] <= 3'b110;
                global_max_checker[2]: pic_max[pic_no_reg] <= 3'b100;
                default: pic_max[pic_no_reg] <= 3'b000;
            endcase
        end
    end
end

always @* begin
    state_r_nxt = state_r;
    case(state_r)
        IDLE_R: begin
            if(in_valid) begin
                state_r_nxt = R_BUF;
            end
        end
        R_BUF: begin
                if(mode_reg == 1) begin
                    if(expo_skip) begin
                        state_r_nxt = R_SKIP;
                    end else if(pic_max[pic_no_reg][0] | ratio_reg == 2 & record_table[pic_no_reg]) begin
                        state_r_nxt = R_SKIP;
                    end else begin
                        state_r_nxt = R_HS;
                    end
                end else begin
                    if(record_table[pic_no_reg]) begin
                        state_r_nxt = R_SKIP;
                    end else begin
                        state_r_nxt = R_HS;
                    end
                end
        end
        R_HS: begin
            state_r_nxt = arready_s_inf ? R_REC_head : R_HS;
        end
        R_REC_head: begin
            state_r_nxt = rvalid_s_inf ? R_WAIT : R_REC_head;
        end
        R_WAIT: begin
            state_r_nxt = wready_s_inf ? R_REC : R_WAIT;
        end
        R_REC: begin
            state_r_nxt = rlast_s_inf ? R_CALC : R_REC;
        end
        R_CALC: begin
            state_r_nxt = gp_cnt == 203 ? IDLE_R : R_CALC;
        end
        R_SKIP: begin
            state_r_nxt = IDLE_R;
        end
    endcase
end

always @* begin
    state_w_nxt = state_w;
    case(state_w)
        IDLE_W: begin
            if(in_valid) begin
                state_w_nxt = W_BUF;
            end
        end
        W_BUF: begin
                if(mode_reg == 1) begin
                    if(expo_skip) begin
                        state_w_nxt = IDLE_W;
                    end else if(pic_max[pic_no_reg][0] | (ratio_reg == 2 & record_table[pic_no_reg])) begin
                        state_w_nxt = IDLE_W;
                    end else begin
                        state_w_nxt = W_HS;
                    end
                end else begin
                    if(record_table[pic_no_reg]) begin
                        state_w_nxt = IDLE_W;
                    end else begin
                        state_w_nxt = W_HS;
                    end
                end
        end
        W_HS: begin
            state_w_nxt = awready_s_inf ? W_WAIT_head : W_HS;
        end
        W_WAIT_head: begin
            state_w_nxt = rvalid_s_inf ? W_OUT_head : W_WAIT_head;
        end
        W_OUT_head: begin
            state_w_nxt = wready_s_inf ? W_WAIT : W_OUT_head;
        end
        W_WAIT: begin
            state_w_nxt = rready_s_inf ? W_OUT : W_WAIT;
        end
        W_OUT: begin
            state_w_nxt = (gp_cnt == 192) ? W_RESP : W_OUT;
        end
        W_RESP: begin
            state_w_nxt = bvalid_s_inf ? IDLE_W : W_RESP;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state_r <= IDLE_R;
        state_w <= IDLE_W;
    end else begin
        state_r <= state_r_nxt;
        state_w <= state_w_nxt;
    end
end

reg arvalid_s_inf_reg;
reg [31:0] araddr_s_inf_reg;
reg rready_s_inf_reg;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        arvalid_s_inf_reg <= 0;
        araddr_s_inf_reg <= 0;
        rready_s_inf_reg <= 0;
    end else begin
        arvalid_s_inf_reg <= state_r_nxt == R_HS;
        araddr_s_inf_reg <= 32'h10000 + 3*32*32*pic_no_reg;
        rready_s_inf_reg <= (state_r_nxt == R_REC_head) | (state_r_nxt == R_REC);
    end
end
assign arvalid_s_inf = arvalid_s_inf_reg;
assign araddr_s_inf = araddr_s_inf_reg;
assign arlen_s_inf = 191;
assign arsize_s_inf = 3'd4;
assign arburst_s_inf = 2'd1;
assign arid_s_inf = 4'd0;

assign rready_s_inf = rready_s_inf_reg;

reg [31:0] awaddr_s_inf_reg;
reg awvalid_s_inf_reg;
reg wvalid_s_inf_reg;
reg wlast_s_inf_reg;
reg bready_s_inf_reg;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        awvalid_s_inf_reg <= 0;
        awaddr_s_inf_reg <= 0;
        wvalid_s_inf_reg <= 0;
        wlast_s_inf_reg <= 0;
        bready_s_inf_reg <= 0;
    end else begin
        awvalid_s_inf_reg <= state_w_nxt == W_HS;
        awaddr_s_inf_reg <= 32'h10000 + 3*32*32*pic_no_reg;
        wvalid_s_inf_reg <= (state_w_nxt == W_OUT) | (state_w_nxt == W_OUT_head);
        wlast_s_inf_reg <= gp_cnt == 191;
        bready_s_inf_reg <= state_w_nxt != W_HS && state_w_nxt != IDLE_W;
    end
end
assign awvalid_s_inf = awvalid_s_inf_reg;
assign awaddr_s_inf = awaddr_s_inf_reg;
assign awlen_s_inf = 8'd191;
assign awsize_s_inf = 3'd4;
assign awburst_s_inf = 2'd1;
assign awid_s_inf = 4'd0;

assign wvalid_s_inf = wvalid_s_inf_reg;
assign wdata_s_inf = data_out;
assign wlast_s_inf = wlast_s_inf_reg;

assign bready_s_inf = bready_s_inf_reg;

reg [7:0] focus_matrix [5:0][5:0];
always @(posedge clk) begin
    case(state_r)
        IDLE_R: begin
            for (int i = 0; i < 6; i = i + 1) begin
                for (int j = 0; j < 6; j = j + 1) begin
                    focus_matrix[i][j] <= 0;
                end
            end
        end
        R_REC:begin
            case(gp_cnt[5:0])
                27, 29, 31, 33, 35, 37: begin
                    if(gp_cnt[7:6] == 1) begin
                        focus_matrix[5][0] <= focus_matrix[0][0] + data_out[111:105];
                        focus_matrix[5][1] <= focus_matrix[0][1] + data_out[119:113];
                        focus_matrix[5][2] <= focus_matrix[0][2] + data_out[127:121];
                    end else begin
                        focus_matrix[5][0] <= focus_matrix[0][0] + data_out[111:106];
                        focus_matrix[5][1] <= focus_matrix[0][1] + data_out[119:114];
                        focus_matrix[5][2] <= focus_matrix[0][2] + data_out[127:122];
                    end
                    focus_matrix[4][2:0] <= focus_matrix[5][2:0];
                    focus_matrix[3][2:0] <= focus_matrix[4][2:0];
                    focus_matrix[2][2:0] <= focus_matrix[3][2:0];
                    focus_matrix[1][2:0] <= focus_matrix[2][2:0];
                    focus_matrix[0][2:0] <= focus_matrix[1][2:0];
                end
                28, 30, 32, 34, 36, 38: begin
                    if(gp_cnt[7:6] == 1) begin
                        focus_matrix[5][3] <= focus_matrix[0][3] + data_out[7:1];;
                        focus_matrix[5][4] <= focus_matrix[0][4] + data_out[15:9];;
                        focus_matrix[5][5] <= focus_matrix[0][5] + data_out[23:17];
                    end else begin
                        focus_matrix[5][3] <= focus_matrix[0][3] + data_out[7:2];
                        focus_matrix[5][4] <= focus_matrix[0][4] + data_out[15:10];
                        focus_matrix[5][5] <= focus_matrix[0][5] + data_out[23:18];
                    end
                    focus_matrix[4][5:3] <= focus_matrix[5][5:3];
                    focus_matrix[3][5:3] <= focus_matrix[4][5:3];
                    focus_matrix[2][5:3] <= focus_matrix[3][5:3];
                    focus_matrix[1][5:3] <= focus_matrix[2][5:3];
                    focus_matrix[0][5:3] <= focus_matrix[1][5:3];
                end
            endcase
        end
    endcase
end

always @* begin
    case(ratio_reg)
        2'b00: begin 
            data_in[0] = rdata_s_inf[7:2];
            data_in[1] = rdata_s_inf[15:10];
            data_in[2] = rdata_s_inf[23:18];
            data_in[3] = rdata_s_inf[31:26];
            data_in[4] = rdata_s_inf[39:34];
            data_in[5] = rdata_s_inf[47:42];
            data_in[6] = rdata_s_inf[55:50];
            data_in[7] = rdata_s_inf[63:58];
            data_in[8] = rdata_s_inf[71:66];
            data_in[9] = rdata_s_inf[79:74];
            data_in[10] = rdata_s_inf[87:82];
            data_in[11] = rdata_s_inf[95:90];
            data_in[12] = rdata_s_inf[103:98];
            data_in[13] = rdata_s_inf[111:106];
            data_in[14] = rdata_s_inf[119:114];
            data_in[15] = rdata_s_inf[127:122];
        end
        2'b01: begin 
            data_in[0] = rdata_s_inf[7:1];
            data_in[1] = rdata_s_inf[15:9];
            data_in[2] = rdata_s_inf[23:17];
            data_in[3] = rdata_s_inf[31:25];
            data_in[4] = rdata_s_inf[39:33];
            data_in[5] = rdata_s_inf[47:41];
            data_in[6] = rdata_s_inf[55:49];
            data_in[7] = rdata_s_inf[63:57];
            data_in[8] = rdata_s_inf[71:65];
            data_in[9] = rdata_s_inf[79:73];
            data_in[10] = rdata_s_inf[87:81];
            data_in[11] = rdata_s_inf[95:89];
            data_in[12] = rdata_s_inf[103:97];
            data_in[13] = rdata_s_inf[111:105];
            data_in[14] = rdata_s_inf[119:113];
            data_in[15] = rdata_s_inf[127:121];
        end
        2'b10: begin 
            data_in[0] = rdata_s_inf[7:0];
            data_in[1] = rdata_s_inf[15:8];
            data_in[2] = rdata_s_inf[23:16];
            data_in[3] = rdata_s_inf[31:24];
            data_in[4] = rdata_s_inf[39:32];
            data_in[5] = rdata_s_inf[47:40];
            data_in[6] = rdata_s_inf[55:48];
            data_in[7] = rdata_s_inf[63:56];
            data_in[8] = rdata_s_inf[71:64];
            data_in[9] = rdata_s_inf[79:72];
            data_in[10] = rdata_s_inf[87:80];
            data_in[11] = rdata_s_inf[95:88];
            data_in[12] = rdata_s_inf[103:96];
            data_in[13] = rdata_s_inf[111:104];
            data_in[14] = rdata_s_inf[119:112];
            data_in[15] = rdata_s_inf[127:120];
        end
        2'b11: begin 
            data_in[0] = rdata_s_inf[7] ? 8'd255 : rdata_s_inf[7:0] * 2;
            data_in[1] = rdata_s_inf[15] ? 8'd255 : rdata_s_inf[15:8] * 2;
            data_in[2] = rdata_s_inf[23] ? 8'd255 : rdata_s_inf[23:16] * 2;
            data_in[3] = rdata_s_inf[31] ? 8'd255 : rdata_s_inf[31:24] * 2;
            data_in[4] = rdata_s_inf[39] ? 8'd255 : rdata_s_inf[39:32] * 2;
            data_in[5] = rdata_s_inf[47] ? 8'd255 : rdata_s_inf[47:40] * 2;
            data_in[6] = rdata_s_inf[55] ? 8'd255 : rdata_s_inf[55:48] * 2;
            data_in[7] = rdata_s_inf[63] ? 8'd255 : rdata_s_inf[63:56] * 2;
            data_in[8] = rdata_s_inf[71] ? 8'd255 : rdata_s_inf[71:64] * 2;
            data_in[9] = rdata_s_inf[79] ? 8'd255 : rdata_s_inf[79:72] * 2;
            data_in[10] = rdata_s_inf[87] ? 8'd255 : rdata_s_inf[87:80] * 2;
            data_in[11] = rdata_s_inf[95] ? 8'd255 : rdata_s_inf[95:88] * 2;
            data_in[12] = rdata_s_inf[103] ? 8'd255 : rdata_s_inf[103:96] * 2;
            data_in[13] = rdata_s_inf[111] ? 8'd255 : rdata_s_inf[111:104] * 2;
            data_in[14] = rdata_s_inf[119] ? 8'd255 : rdata_s_inf[119:112] * 2;
            data_in[15] = rdata_s_inf[127] ? 8'd255 : rdata_s_inf[127:120] * 2;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out <= 0;
    end else begin
        if(state_w != W_OUT_head) begin
            data_out <= {data_in[15], data_in[14], data_in[13], data_in[12], data_in[11], data_in[10], data_in[9], data_in[8], data_in[7], data_in[6], data_in[5], data_in[4], data_in[3], data_in[2], data_in[1], data_in[0]};
        end
    end
end

reg [7:0] expo_sum00, expo_sum01, expo_sum02, expo_sum03, expo_sum04, expo_sum05, expo_sum06, expo_sum07;
reg [8:0] expo_sum10, expo_sum11, expo_sum12, expo_sum13;
reg [9:0] expo_sum20, expo_sum21;
reg [10:0] expo_sum;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        expo_sum00 <= 0; expo_sum01 <= 0; expo_sum02 <= 0; expo_sum03 <= 0; expo_sum04 <= 0; expo_sum05 <= 0; expo_sum06 <= 0; expo_sum07 <= 0;
        expo_sum10 <= 0; expo_sum11 <= 0; expo_sum12 <= 0; expo_sum13 <= 0;
        expo_sum20 <= 0; expo_sum21 <= 0;
        expo_sum <= 0;
    end else begin
        if(gp_cnt < 65) begin
            expo_sum00 <= data_out[7:2] + data_out[15:10];
            expo_sum01 <= data_out[23:18] + data_out[31:26];
            expo_sum02 <= data_out[39:34] + data_out[47:42];
            expo_sum03 <= data_out[55:50] + data_out[63:58];
            expo_sum04 <= data_out[71:66] + data_out[79:74];
            expo_sum05 <= data_out[87:82] + data_out[95:90];
            expo_sum06 <= data_out[103:98] + data_out[111:106];
            expo_sum07 <= data_out[119:114] + data_out[127:122];
        end else if(gp_cnt < 129) begin
            expo_sum00 <= data_out[7:1] + data_out[15:9]; 
            expo_sum01 <= data_out[23:17] + data_out[31:25];
            expo_sum02 <= data_out[39:33] + data_out[47:41];
            expo_sum03 <= data_out[55:49] + data_out[63:57];
            expo_sum04 <= data_out[71:65] + data_out[79:73];
            expo_sum05 <= data_out[87:81] + data_out[95:89];
            expo_sum06 <= data_out[103:97] + data_out[111:105];
            expo_sum07 <= data_out[119:113] + data_out[127:121];
        end else begin
            expo_sum00 <= data_out[7:2] + data_out[15:10];
            expo_sum01 <= data_out[23:18] + data_out[31:26];
            expo_sum02 <= data_out[39:34] + data_out[47:42];
            expo_sum03 <= data_out[55:50] + data_out[63:58];
            expo_sum04 <= data_out[71:66] + data_out[79:74];
            expo_sum05 <= data_out[87:82] + data_out[95:90];
            expo_sum06 <= data_out[103:98] + data_out[111:106];
            expo_sum07 <= data_out[119:114] + data_out[127:122];
        end
        
        expo_sum10 <= expo_sum00 + expo_sum01;
        expo_sum11 <= expo_sum02 + expo_sum03;
        expo_sum12 <= expo_sum04 + expo_sum05;
        expo_sum13 <= expo_sum06 + expo_sum07;

        expo_sum20 <= expo_sum10 + expo_sum11;
        expo_sum21 <= expo_sum12 + expo_sum13;

        expo_sum <= expo_sum20 + expo_sum21;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        avg <= 0;
    end else begin
        if(gp_cnt < 5) begin
            avg <= 0;
        end else begin
            avg <= avg + expo_sum;
        end
    end
end

reg [7:0] sub0, sub1, sub2, sub3, sub4 ,sub5, sub6, sub7, sub8, sub9, sub10;
reg [7:0] rsub0, rsub1, rsub2, rsub3, rsub4, rsub5;
reg [7:0] csub0, csub1, csub2, csub3, csub4, csub5;

reg [9:0] rsub_sum0;
reg [10:0] rsub_sum1;

reg [8:0] csub_sum00, csub_sum01, csub_sum02, csub_sum03;
reg [9:0] csub_sum1;
reg [10:0] csub_sum2;

abs_sub abs_sub_row0( .a(focus_matrix[5][1]), .b(focus_matrix[5][0]), .c(sub0) );
abs_sub abs_sub_row1( .a(focus_matrix[5][2]), .b(focus_matrix[5][1]), .c(sub1) );
abs_sub abs_sub_row2( .a(focus_matrix[5][3]), .b(focus_matrix[5][2]), .c(sub2) );
abs_sub abs_sub_row3( .a(focus_matrix[5][4]), .b(focus_matrix[5][3]), .c(sub3) );
abs_sub abs_sub_row4( .a(focus_matrix[5][5]), .b(focus_matrix[5][4]), .c(sub4) );

abs_sub abs_sub_col0( .a(focus_matrix[5][0]), .b(focus_matrix[4][0]), .c(sub5) );
abs_sub abs_sub_col1( .a(focus_matrix[5][1]), .b(focus_matrix[4][1]), .c(sub6) );
abs_sub abs_sub_col2( .a(focus_matrix[5][2]), .b(focus_matrix[4][2]), .c(sub7) );
abs_sub abs_sub_col3( .a(focus_matrix[5][3]), .b(focus_matrix[4][3]), .c(sub8) );
abs_sub abs_sub_col4( .a(focus_matrix[5][4]), .b(focus_matrix[4][4]), .c(sub9) );
abs_sub abs_sub_col5( .a(focus_matrix[5][5]), .b(focus_matrix[4][5]), .c(sub10) );

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        rsub0 <= 0; rsub1 <= 0; rsub2 <= 0; rsub3 <= 0; rsub4 <= 0; rsub5 <= 0;
        csub0 <= 0; csub1 <= 0; csub2 <= 0; csub3 <= 0; csub4 <= 0; csub5 <= 0;
    end else begin
        rsub0 <= sub0; rsub1 <= sub1; rsub2 <= sub2; rsub3 <= sub3; rsub4 <= sub4; rsub5 <= rsub0;
        csub0 <= sub5; csub1 <= sub6; csub2 <= sub7; csub3 <= sub8; csub4 <= sub9; csub5 <= sub10;
    end
end

always @(posedge clk) begin
    rsub_sum0 <= rsub1 + rsub2 + rsub3; 
    rsub_sum1 <= rsub_sum0 + rsub5 + rsub4;

    csub_sum00 <= csub0 + csub5; csub_sum01 <= csub1 + csub4; csub_sum02 <= csub2 + csub3;
    csub_sum03 <= csub_sum00;
    csub_sum1 <= csub_sum01 + csub_sum02;
    csub_sum2 <= csub_sum03 + csub_sum1;
end

reg [13:0] D6;
reg [12:0] D4;
reg [9:0] D2;

reg [11:0] D6_reg, D6_tmp;
reg [8:0] D6_result, D6_result_tmp;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        D6_reg <= 0;
        D6_result <= 0;
    end else begin
        D6_reg <= (af_cnt == 14) ? D6 : D6_tmp;
        D6_result <= (af_cnt == 14) ? 0 : D6_result_tmp;
    end
end

always @* begin
    D6_tmp = D6_reg;
    D6_result_tmp = D6_result;
    if(D6_reg >= 576) begin
        D6_tmp = D6_reg - 576;
        D6_result_tmp = D6_result + 64;
    end else if(D6_reg >= 288) begin
        D6_tmp = D6_reg - 288;
        D6_result_tmp = D6_result + 32;
    end else if(D6_reg >= 144) begin
        D6_tmp = D6_reg - 144;
        D6_result_tmp = D6_result + 16;
    end else if(D6_reg >= 72) begin
        D6_tmp = D6_reg - 72;
        D6_result_tmp = D6_result + 8;
    end else if(D6_reg >= 36) begin
        D6_tmp = D6_reg - 36;
        D6_result_tmp = D6_result + 4;
    end else if(D6_reg >= 18) begin
        D6_tmp = D6_reg - 18;
        D6_result_tmp = D6_result + 2;
    end else if(D6_reg >= 9) begin
        D6_tmp = D6_reg - 9; 
        D6_result_tmp = D6_result + 1;
    end else begin
        D6_tmp = D6_reg;
        D6_result_tmp = D6_result;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        D6 <= 0;
    end else begin
        case(af_cnt)
            2: D6 <= rsub_sum1;
            4, 6, 8, 10, 12: D6 <= D6 + rsub_sum1;
            5, 7, 9, 11: D6 <= D6 + csub_sum2;
            13: D6 <= (D6 + csub_sum2) / 4;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        D4 <= 0;
    end else begin
        case(af_cnt)
            3: D4 <= rsub_sum0;
            5, 7, 9: D4 <= D4 + rsub_sum0;
            6, 8, 10: D4 <= D4 + csub_sum1;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        D2 <= 0;
    end else begin
        case(af_cnt)
            4: D2 <= rsub2;
            6: D2 <= D2 + rsub2;
            7: D2 <= D2 + csub_sum02;
        endcase
    end
end

always @* begin
    if(D2[9:2] >= D4[12:4] && D2[9:2] >= D6_result) begin
        arg_max = 0;
    end else if(D4[12:4] > D2[9:2] && D4[12:4] >= D6_result) begin
        arg_max = 1;
    end else begin
        arg_max = 2;
    end
end

reg out_valid_reg;
reg [7:0] out_data_reg;

assign out_valid = out_valid_reg;
assign out_data = out_data_reg;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_data_reg <= 0;
        out_valid_reg <= 0;
    end else begin
        case(state_r)
            R_CALC: begin
                case(mode_reg)
                    0: begin
                        if(gp_cnt == 202) begin
                            out_data_reg <= arg_max;
                            out_valid_reg <= 1;
                        end else begin
                            out_data_reg <= 0;
                            out_valid_reg <= 0;
                        end
                    end
                    1: begin
                        if(gp_cnt == 202) begin
                            out_data_reg <= avg[17:10];
                            out_valid_reg <= 1;
                        end else begin
                            out_data_reg <= 0;
                            out_valid_reg <= 0;
                        end
                    end
                    2: begin
                        if(gp_cnt == 202) begin
                            out_data_reg <= max_min_avg;
                            out_valid_reg <= 1;
                        end else begin
                            out_data_reg <= 0;
                            out_valid_reg <= 0;
                        end
                    end
                endcase
            end
            R_BUF: begin
                if((record_table[pic_no_reg] && pic_max[pic_no_reg][0]) | expo_skip) begin
                    out_data_reg <= 0;
                    out_valid_reg <= 1;
                end else begin
                    case(mode_reg)
                        0: begin
                            if(record_table[pic_no_reg]) begin
                                out_data_reg <= focus_record[pic_no_reg][1:0];
                                out_valid_reg <= 1;
                            end
                        end
                        1: begin
                            if(ratio_reg == 2 & record_table[pic_no_reg]) begin
                                out_data_reg <= expo_record[pic_no_reg];
                                out_valid_reg <= 1;
                            end
                        end
                        2: begin
                            if(record_table[pic_no_reg]) begin
                                out_data_reg <= avg_record[pic_no_reg][7:0];
                                out_valid_reg <= 1;
                            end
                        end
                    endcase
                end
            end
            default: begin
                out_data_reg <= 0;
                out_valid_reg <= 0;
            end
        endcase
    end
end

endmodule

module abs_sub(
    input [7:0] a,
    input [7:0] b,
    output [7:0] c
);
assign c = (a > b) ? a - b : b - a;
endmodule
