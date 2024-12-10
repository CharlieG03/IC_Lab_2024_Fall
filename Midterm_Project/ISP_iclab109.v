module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input       in_mode,
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
reg [3:0] pic_no_reg;
reg [1:0] ratio_reg;

reg check0all;

reg zero_table [15:0];

reg [2:0] dirty_table [15:0];

reg [1:0] arg_max;

enum reg [3:0] {
    IDLE_R,
    AF_R_req,
    AF_R_rec,
    AF_calc,
    AF_calc_out,
    AE_R_req,
    AE_R_rec_1st, 
    AE_R_wait,
    AE_R_rec
} state_r, state_r_nxt;

enum reg [2:0] {
    IDLE_W,
    AE_W_req,
    AE_W_rec,
    AE_W_out_1st,
    AE_W_wait,
    AE_W_out,
    AE_W_end
} state_w, state_w_nxt;

reg [7:0] cnt16;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt16 <= 0;
    end else begin
        if(in_valid & zero_table[in_pic_no]) begin
            cnt16 <= 196;
        end else if(cnt16 >= 193) begin
            cnt16 <= (cnt16 == 196) ? 0 : cnt16 + 1;
        end else if (state_r == AE_R_rec) begin
            cnt16 <= cnt16 + 1;
        end else if(state_r == AE_R_wait) begin
            cnt16 <= (wready_s_inf) ? 2 : 1;
        end else if(state_r == AE_R_rec_1st) begin
            cnt16 <= (rvalid_s_inf) ? 1 : 0;
        end else if(state_r == AF_R_rec) begin
            cnt16 <= (cnt16 == 140) ? 0 : (rready_s_inf && rvalid_s_inf) ? cnt16 + 1 : 0;
        end else if(state_r == AF_calc) begin
            cnt16 <= (cnt16 == 13) ? 0 : cnt16 + 1;
        end else if(state_r == AF_calc_out) begin
            cnt16 <= (cnt16 == 1) ? 0 : cnt16 + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        dirty_table <= {7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7};
    end else begin
        if(state_r == AF_calc_out && dirty_table[pic_no_reg][2] && cnt16 == 1 || state_r == AE_R_rec && cnt16 == 183) begin
            dirty_table[pic_no_reg] <= {1'b0, arg_max};
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        zero_table <= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    end else begin
        if(cnt16 == 194 & state_w == AE_W_out) begin
            zero_table[pic_no_reg] <= check0all;
        end
    end
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
always @* begin
    state_r_nxt = state_r; 
    case (state_r)
        IDLE_R: begin
            if (in_valid) begin
                if(in_mode) begin
                    state_r_nxt = AE_R_req;
                end else begin
                    if(dirty_table[in_pic_no][2]) begin
                        state_r_nxt = AF_R_req;
                    end else begin
                        state_r_nxt = AF_calc_out;
                    end
                end
                if(zero_table[in_pic_no]) begin
                    state_r_nxt = IDLE_R;
                end
            end
        end
        AF_R_req: begin
            if(arready_s_inf) begin
                state_r_nxt = AF_R_rec;
            end
        end
        AF_R_rec: begin
            if(cnt16 == 140) begin
                state_r_nxt = AF_calc;
            end
        end
        AF_calc: begin
            if(cnt16 == 13) begin
                state_r_nxt = AF_calc_out;
            end
        end
        AF_calc_out: begin
            if(cnt16 == 1) begin
                state_r_nxt = IDLE_R;
            end
        end
        AE_R_req: begin
            if(arready_s_inf) begin
                state_r_nxt = AE_R_rec_1st;
            end
        end
        AE_R_rec_1st: begin
            if(rvalid_s_inf) begin
                state_r_nxt = AE_R_wait;
            end
        end
        AE_R_wait: begin
            if(wready_s_inf) begin
                state_r_nxt = AE_R_rec;
            end
        end
        AE_R_rec: begin
            if(cnt16 == 192) begin
                state_r_nxt = IDLE_R;
            end
        end
    endcase
end

always @* begin
    state_w_nxt = state_w;
    case (state_w)
        IDLE_W: begin
            if (in_valid) begin
                state_w_nxt = in_mode ? AE_W_req : IDLE_W;
            end
            if(zero_table[in_pic_no]) begin
                state_w_nxt = IDLE_W;
            end
        end
        AE_W_req: begin
            if(awready_s_inf) begin
                state_w_nxt = AE_W_rec;
            end
        end
        AE_W_rec: begin
            if(state_r == AE_R_rec_1st && rvalid_s_inf) begin
                state_w_nxt = AE_W_out_1st;
            end
        end
        AE_W_out_1st: begin
            state_w_nxt = (wready_s_inf) ? AE_W_wait : AE_W_out_1st;
        end
        AE_W_wait: begin
            state_w_nxt = cnt16 == 3 ? AE_W_out : AE_W_wait;
        end
        AE_W_out: begin
            state_w_nxt = cnt16 == 194 ? AE_W_end : AE_W_out;
        end
        AE_W_end: begin
            state_w_nxt = (bready_s_inf && bvalid_s_inf) ? IDLE_W : AE_W_end;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pic_no_reg <= 0;
        ratio_reg <= 0;
    end else begin
        if(in_valid) begin
            pic_no_reg <= in_pic_no;
            ratio_reg <= in_ratio_mode;
        end
    end
end

reg [31:0] araddr_s_inf_reg;
reg [7:0]  arlen_s_inf_reg;
always @* begin
    araddr_s_inf_reg = 0; arlen_s_inf_reg = 0;
    case(state_r)
        AF_R_req: begin
            araddr_s_inf_reg = 32'h10000 + (3*32*32)*pic_no_reg + 32'd416;
            arlen_s_inf_reg = 139;
        end
        AE_R_req: begin
            araddr_s_inf_reg = 32'h10000 + (3*32*32)*pic_no_reg;
            arlen_s_inf_reg = 191;
        end
    endcase
end

reg [6:0] in_data_reg[2:0];
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_data_reg <= {0, 0, 0};
    end else begin
        if(rvalid_s_inf) begin
            if(cnt16[0]) begin
                in_data_reg[0] <= rdata_s_inf[23:17];
                in_data_reg[1] <= rdata_s_inf[15:9];
                in_data_reg[2] <= rdata_s_inf[7:1];
            end else begin
                in_data_reg[0] <= rdata_s_inf[127:121];
                in_data_reg[1] <= rdata_s_inf[119:113];
                in_data_reg[2] <= rdata_s_inf[111:105];
            end
        end
    end
end

assign arid_s_inf = 4'd0;
assign araddr_s_inf = araddr_s_inf_reg;
assign arlen_s_inf = arlen_s_inf_reg;
assign arsize_s_inf = state_r == AE_R_req | state_r == AF_R_req ? 3'd4 : 3'd0;
assign arburst_s_inf = state_r == AE_R_req | state_r == AF_R_req ? 2'd1 : 2'd0;
assign arvalid_s_inf = state_r == AE_R_req | state_r == AF_R_req;

assign rready_s_inf = state_r == AE_R_rec_1st | state_r == AE_R_rec | state_r == AF_R_rec;

reg [7:0] data_reg [51:0];
reg [7:0] expo_data0, expo_data1, expo_data2, expo_data3, expo_data4, expo_data5, expo_data6, expo_data7;
reg [7:0] expo_data8, expo_data9, expo_data10, expo_data11, expo_data12, expo_data13, expo_data14, expo_data15;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_reg <= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    end else begin
        case(state_r)
        IDLE_R: begin
            data_reg <= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        end
        AF_R_rec: begin
            if (cnt16 > 0 & cnt16 <=12 | cnt16 > 64 & cnt16 <= 76 | cnt16 > 128 & cnt16 <= 140) begin
                if(cnt16 > 64 & cnt16 <= 76) begin
                    data_reg[16] <= data_reg[49] + in_data_reg[0];
                    data_reg[17] <= data_reg[50] + in_data_reg[1];
                    data_reg[18] <= data_reg[51] + in_data_reg[2];
                end else begin
                    data_reg[16] <= data_reg[49] + in_data_reg[0][6:1];
                    data_reg[17] <= data_reg[50] + in_data_reg[1][6:1];
                    data_reg[18] <= data_reg[51] + in_data_reg[2][6:1];
                end
                    data_reg[19] <= data_reg[16]; data_reg[20] <= data_reg[17]; data_reg[21] <= data_reg[18];
                    data_reg[22] <= data_reg[19]; data_reg[23] <= data_reg[20]; data_reg[24] <= data_reg[21];
                    data_reg[25] <= data_reg[22]; data_reg[26] <= data_reg[23]; data_reg[27] <= data_reg[24];
                    data_reg[28] <= data_reg[25]; data_reg[29] <= data_reg[26]; data_reg[30] <= data_reg[27];
                    data_reg[31] <= data_reg[28]; data_reg[32] <= data_reg[29]; data_reg[33] <= data_reg[30];
                    data_reg[34] <= data_reg[31]; data_reg[35] <= data_reg[32]; data_reg[36] <= data_reg[33];
                    data_reg[37] <= data_reg[34]; data_reg[38] <= data_reg[35]; data_reg[39] <= data_reg[36];
                    data_reg[40] <= data_reg[37]; data_reg[41] <= data_reg[38]; data_reg[42] <= data_reg[39];
                    data_reg[43] <= data_reg[40]; data_reg[44] <= data_reg[41]; data_reg[45] <= data_reg[42];
                    data_reg[46] <= data_reg[43]; data_reg[47] <= data_reg[44]; data_reg[48] <= data_reg[45];
                    data_reg[49] <= data_reg[46]; data_reg[50] <= data_reg[47]; data_reg[51] <= data_reg[48];
            end
        end
        AF_calc: begin
            if(cnt16 == 5) begin
                data_reg[51:46] <= {data_reg[45], data_reg[39], data_reg[33], data_reg[27], data_reg[21], data_reg[51]};
                data_reg[45:40] <= {data_reg[44], data_reg[38], data_reg[32], data_reg[26], data_reg[20], data_reg[50]};
                data_reg[39:34] <= {data_reg[43], data_reg[37], data_reg[31], data_reg[25], data_reg[19], data_reg[49]};
                data_reg[33:28] <= {data_reg[42], data_reg[36], data_reg[30], data_reg[24], data_reg[18], data_reg[48]};
                data_reg[27:22] <= {data_reg[41], data_reg[35], data_reg[29], data_reg[23], data_reg[17], data_reg[47]};
                data_reg[21:16] <= {data_reg[40], data_reg[34], data_reg[28], data_reg[22], data_reg[16], data_reg[46]};
            end else begin
                data_reg[51:46] <= data_reg[45:40]; data_reg[45:40] <= data_reg[39:34]; data_reg[39:34] <= data_reg[33:28];
                data_reg[33:28] <= data_reg[27:22]; data_reg[27:22] <= data_reg[21:16]; data_reg[21:16] <= data_reg[51:46];
            end
        end
        AE_R_rec_1st: begin
            if (rvalid_s_inf) begin
                data_reg[0] <= rdata_s_inf[7:0];
                data_reg[1] <= rdata_s_inf[15:8];
                data_reg[2] <= rdata_s_inf[23:16];
                data_reg[3] <= rdata_s_inf[31:24];
                data_reg[4] <= rdata_s_inf[39:32];
                data_reg[5] <= rdata_s_inf[47:40];
                data_reg[6] <= rdata_s_inf[55:48];
                data_reg[7] <= rdata_s_inf[63:56];
                data_reg[8] <= rdata_s_inf[71:64];
                data_reg[9] <= rdata_s_inf[79:72];
                data_reg[10] <= rdata_s_inf[87:80];
                data_reg[11] <= rdata_s_inf[95:88];
                data_reg[12] <= rdata_s_inf[103:96];
                data_reg[13] <= rdata_s_inf[111:104];
                data_reg[14] <= rdata_s_inf[119:112];
                data_reg[15] <= rdata_s_inf[127:120];
            end
        end
        AE_R_wait: begin
            if (wready_s_inf) begin
                data_reg[0] <= rdata_s_inf[7:0];
                data_reg[1] <= rdata_s_inf[15:8];
                data_reg[2] <= rdata_s_inf[23:16];
                data_reg[3] <= rdata_s_inf[31:24];
                data_reg[4] <= rdata_s_inf[39:32];
                data_reg[5] <= rdata_s_inf[47:40];
                data_reg[6] <= rdata_s_inf[55:48];
                data_reg[7] <= rdata_s_inf[63:56];
                data_reg[8] <= rdata_s_inf[71:64];
                data_reg[9] <= rdata_s_inf[79:72];
                data_reg[10] <= rdata_s_inf[87:80];
                data_reg[11] <= rdata_s_inf[95:88];
                data_reg[12] <= rdata_s_inf[103:96];
                data_reg[13] <= rdata_s_inf[111:104];
                data_reg[14] <= rdata_s_inf[119:112];
                data_reg[15] <= rdata_s_inf[127:120];
            end
        end
        AE_R_rec: begin
            if (rvalid_s_inf && rready_s_inf) begin
                data_reg[0] <= rdata_s_inf[7:0];
                data_reg[1] <= rdata_s_inf[15:8];
                data_reg[2] <= rdata_s_inf[23:16];
                data_reg[3] <= rdata_s_inf[31:24];
                data_reg[4] <= rdata_s_inf[39:32];
                data_reg[5] <= rdata_s_inf[47:40];
                data_reg[6] <= rdata_s_inf[55:48];
                data_reg[7] <= rdata_s_inf[63:56];
                data_reg[8] <= rdata_s_inf[71:64];
                data_reg[9] <= rdata_s_inf[79:72];
                data_reg[10] <= rdata_s_inf[87:80];
                data_reg[11] <= rdata_s_inf[95:88];
                data_reg[12] <= rdata_s_inf[103:96];
                data_reg[13] <= rdata_s_inf[111:104];
                data_reg[14] <= rdata_s_inf[119:112];
                data_reg[15] <= rdata_s_inf[127:120];
            end
            if(cnt16 > 27 & cnt16 <= 39 | cnt16 > 155 & cnt16 <= 167) begin
                if(cnt16[0]) begin
                    data_reg[16] <= data_reg[49] + expo_data2[7:2];
                    data_reg[17] <= data_reg[50] + expo_data1[7:2];
                    data_reg[18] <= data_reg[51] + expo_data0[7:2];
                end else begin
                    data_reg[16] <= data_reg[49] + expo_data15[7:2];
                    data_reg[17] <= data_reg[50] + expo_data14[7:2];
                    data_reg[18] <= data_reg[51] + expo_data13[7:2];
                end
                data_reg[19] <= data_reg[16]; data_reg[20] <= data_reg[17]; data_reg[21] <= data_reg[18];
                data_reg[22] <= data_reg[19]; data_reg[23] <= data_reg[20]; data_reg[24] <= data_reg[21];
                data_reg[25] <= data_reg[22]; data_reg[26] <= data_reg[23]; data_reg[27] <= data_reg[24];
                data_reg[28] <= data_reg[25]; data_reg[29] <= data_reg[26]; data_reg[30] <= data_reg[27];
                data_reg[31] <= data_reg[28]; data_reg[32] <= data_reg[29]; data_reg[33] <= data_reg[30];
                data_reg[34] <= data_reg[31]; data_reg[35] <= data_reg[32]; data_reg[36] <= data_reg[33];
                data_reg[37] <= data_reg[34]; data_reg[38] <= data_reg[35]; data_reg[39] <= data_reg[36];
                data_reg[40] <= data_reg[37]; data_reg[41] <= data_reg[38]; data_reg[42] <= data_reg[39];
                data_reg[43] <= data_reg[40]; data_reg[44] <= data_reg[41]; data_reg[45] <= data_reg[42];
                data_reg[46] <= data_reg[43]; data_reg[47] <= data_reg[44]; data_reg[48] <= data_reg[45];
                data_reg[49] <= data_reg[46]; data_reg[50] <= data_reg[47]; data_reg[51] <= data_reg[48];
            end else if(cnt16 > 91 & cnt16 <= 103) begin
                if(cnt16[0]) begin
                    data_reg[16] <= data_reg[49] + expo_data2[7:1];
                    data_reg[17] <= data_reg[50] + expo_data1[7:1];
                    data_reg[18] <= data_reg[51] + expo_data0[7:1];
                end else begin
                    data_reg[16] <= data_reg[49] +  expo_data15[7:1];
                    data_reg[17] <= data_reg[50] +  expo_data14[7:1];
                    data_reg[18] <= data_reg[51] +  expo_data13[7:1];
                end
                data_reg[19] <= data_reg[16]; data_reg[20] <= data_reg[17]; data_reg[21] <= data_reg[18];
                data_reg[22] <= data_reg[19]; data_reg[23] <= data_reg[20]; data_reg[24] <= data_reg[21];
                data_reg[25] <= data_reg[22]; data_reg[26] <= data_reg[23]; data_reg[27] <= data_reg[24];
                data_reg[28] <= data_reg[25]; data_reg[29] <= data_reg[26]; data_reg[30] <= data_reg[27];
                data_reg[31] <= data_reg[28]; data_reg[32] <= data_reg[29]; data_reg[33] <= data_reg[30];
                data_reg[34] <= data_reg[31]; data_reg[35] <= data_reg[32]; data_reg[36] <= data_reg[33];
                data_reg[37] <= data_reg[34]; data_reg[38] <= data_reg[35]; data_reg[39] <= data_reg[36];
                data_reg[40] <= data_reg[37]; data_reg[41] <= data_reg[38]; data_reg[42] <= data_reg[39];
                data_reg[43] <= data_reg[40]; data_reg[44] <= data_reg[41]; data_reg[45] <= data_reg[42];
                data_reg[46] <= data_reg[43]; data_reg[47] <= data_reg[44]; data_reg[48] <= data_reg[45];
                data_reg[49] <= data_reg[46]; data_reg[50] <= data_reg[47]; data_reg[51] <= data_reg[48];
            end
            if(cnt16 > 167 & cnt16 <= 179) begin
                if(cnt16 == 173) begin
                    data_reg[51:46] <= {data_reg[45], data_reg[39], data_reg[33], data_reg[27], data_reg[21], data_reg[51]};
                    data_reg[45:40] <= {data_reg[44], data_reg[38], data_reg[32], data_reg[26], data_reg[20], data_reg[50]};
                    data_reg[39:34] <= {data_reg[43], data_reg[37], data_reg[31], data_reg[25], data_reg[19], data_reg[49]};
                    data_reg[33:28] <= {data_reg[42], data_reg[36], data_reg[30], data_reg[24], data_reg[18], data_reg[48]};
                    data_reg[27:22] <= {data_reg[41], data_reg[35], data_reg[29], data_reg[23], data_reg[17], data_reg[47]};
                    data_reg[21:16] <= {data_reg[40], data_reg[34], data_reg[28], data_reg[22], data_reg[16], data_reg[46]};
                end else begin
                    data_reg[51:46] <= data_reg[45:40]; data_reg[45:40] <= data_reg[39:34]; data_reg[39:34] <= data_reg[33:28];
                    data_reg[33:28] <= data_reg[27:22]; data_reg[27:22] <= data_reg[21:16]; data_reg[21:16] <= data_reg[51:46];
                end
            end
        end
        
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        check0all <= 0;
    end else begin
        if(state_r == AE_R_req) begin
            check0all <= 1;
        end else if(state_w == AE_W_out_1st | state_w == AE_W_wait | state_w == AE_W_out & cnt16 < 194) begin
            check0all <= (expo_data0 != 0 || expo_data1 != 0 || expo_data2 != 0 || expo_data3 != 0 || 
                          expo_data4 != 0 || expo_data5 != 0 || expo_data6 != 0 || expo_data7 != 0 || 
                          expo_data8 != 0 || expo_data9 != 0 || expo_data10 != 0 || expo_data11 != 0 || 
                          expo_data12 != 0 || expo_data13 != 0 || expo_data14 != 0 || expo_data15 != 0) ? 0 : check0all;
        end
    end
end

reg [7:0] sub0, sub1, sub2, sub3, sub4;
reg [7:0] sub0_reg, sub1_reg, sub2_reg, sub3_reg, sub4_reg;
abs_sub abs_sub_inst0( .a(data_reg[17]), .b(data_reg[16]), .c(sub0) );
abs_sub abs_sub_inst1( .a(data_reg[18]), .b(data_reg[17]), .c(sub1) );
abs_sub abs_sub_inst2( .a(data_reg[19]), .b(data_reg[18]), .c(sub2) );
abs_sub abs_sub_inst3( .a(data_reg[20]), .b(data_reg[19]), .c(sub3) );
abs_sub abs_sub_inst4( .a(data_reg[21]), .b(data_reg[20]), .c(sub4) );
always @(posedge clk) begin
    sub0_reg <= sub0;
    sub1_reg <= sub1;
    sub2_reg <= sub2;
    sub3_reg <= sub3;
    sub4_reg <= sub4;
end

reg [8:0] sub_sum0;
reg [9:0] sub_sum1;
always @(posedge clk) begin
    sub_sum0 <= sub0_reg + sub1_reg;
    sub_sum1 <= sub2_reg + sub3_reg + sub4_reg;
end

reg [13:0] D6;
reg [12:0] D4;
reg [9:0] D2;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        D6 <= 0;
    end else begin
        if(state_r == AF_calc) begin
            if(cnt16 > 1) begin
                D6 <= D6 + sub_sum0 + sub_sum1;
            end
        end else if(state_r == AE_R_rec) begin
            if(cnt16 > 169 & cnt16 <= 181) begin
                D6 <= D6 + sub_sum0 + sub_sum1;
            end else if(cnt16 == 182) begin
                D6 <= D6 / 36;
            end
        end else if(state_r == IDLE_R) begin
            D6 <= 0;
        end else if(state_r == AF_calc_out && cnt16 == 0) begin
            D6 <= D6 / 36;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        D4 <= 0;
    end else begin
        if(state_r == AF_calc) begin
            case(cnt16)
                3, 4, 5, 6, 9, 10, 11, 12: D4 <= D4 + sub1_reg + sub2_reg + sub3_reg;
            endcase
        end else if(state_r == AE_R_rec) begin
            case(cnt16)
                171, 172, 173, 174, 177, 178, 179, 180: D4 <= D4 + sub1_reg + sub2_reg + sub3_reg;
                181: D4 <= D4 / 16;
            endcase
        end else if(state_r == IDLE_R) begin
            D4 <= 0;
        end else if(state_r == AF_calc_out && cnt16 == 0) begin
            D4 <= D4 / 16;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        D2 <= 0;
    end else begin
        if(state_r == AF_calc) begin
            case(cnt16)
                4, 5, 10, 11: begin D2 <= D2 + sub2_reg; end
            endcase
        end else if(state_r == AE_R_rec) begin
            case(cnt16)
                172, 173, 178, 179: begin D2 <= D2 + sub2_reg; end
                180: begin D2 <= D2 / 4; end
            endcase
        end else if(state_r == IDLE_R) begin
            D2 <= 0;
        end else if(state_r == AF_calc_out && cnt16 == 0) begin
            D2 <= D2 / 4;
        end
    end
end

always @* begin
    if(D2 >= D4 && D2 >= D6) begin
        arg_max = 0;
    end else if(D4 > D2 && D4 >= D6) begin
        arg_max = 1;
    end else begin
        arg_max = 2;
    end
end

always @* begin
    case(ratio_reg)
        2'b00: begin 
            expo_data0 = data_reg[0] / 4;
            expo_data1 = data_reg[1] / 4;
            expo_data2 = data_reg[2] / 4;
            expo_data3 = data_reg[3] / 4;
            expo_data4 = data_reg[4] / 4;
            expo_data5 = data_reg[5] / 4;
            expo_data6 = data_reg[6] / 4;
            expo_data7 = data_reg[7] / 4;
            expo_data8 = data_reg[8] / 4;
            expo_data9 = data_reg[9] / 4;
            expo_data10 = data_reg[10] / 4;
            expo_data11 = data_reg[11] / 4;
            expo_data12 = data_reg[12] / 4;
            expo_data13 = data_reg[13] / 4;
            expo_data14 = data_reg[14] / 4;
            expo_data15 = data_reg[15] / 4;
        end
        2'b01: begin 
            expo_data0 = data_reg[0] / 2;
            expo_data1 = data_reg[1] / 2;
            expo_data2 = data_reg[2] / 2;
            expo_data3 = data_reg[3] / 2;
            expo_data4 = data_reg[4] / 2;
            expo_data5 = data_reg[5] / 2;
            expo_data6 = data_reg[6] / 2;
            expo_data7 = data_reg[7] / 2;
            expo_data8 = data_reg[8] / 2;
            expo_data9 = data_reg[9] / 2;
            expo_data10 = data_reg[10] / 2;
            expo_data11 = data_reg[11] / 2;
            expo_data12 = data_reg[12] / 2;
            expo_data13 = data_reg[13] / 2;
            expo_data14 = data_reg[14] / 2;
            expo_data15 = data_reg[15] / 2;
        end
        2'b10: begin 
            expo_data0 = data_reg[0];
            expo_data1 = data_reg[1];
            expo_data2 = data_reg[2];
            expo_data3 = data_reg[3];
            expo_data4 = data_reg[4];
            expo_data5 = data_reg[5];
            expo_data6 = data_reg[6];
            expo_data7 = data_reg[7];
            expo_data8 = data_reg[8];
            expo_data9 = data_reg[9];
            expo_data10 = data_reg[10];
            expo_data11 = data_reg[11];
            expo_data12 = data_reg[12];
            expo_data13 = data_reg[13];
            expo_data14 = data_reg[14];
            expo_data15 = data_reg[15];
        end
        2'b11: begin 
            expo_data0 = data_reg[0][7] ? 8'd255 : data_reg[0] * 2;
            expo_data1 = data_reg[1][7] ? 8'd255 : data_reg[1] * 2;
            expo_data2 = data_reg[2][7] ? 8'd255 : data_reg[2] * 2;
            expo_data3 = data_reg[3][7] ? 8'd255 : data_reg[3] * 2;
            expo_data4 = data_reg[4][7] ? 8'd255 : data_reg[4] * 2;
            expo_data5 = data_reg[5][7] ? 8'd255 : data_reg[5] * 2;
            expo_data6 = data_reg[6][7] ? 8'd255 : data_reg[6] * 2;
            expo_data7 = data_reg[7][7] ? 8'd255 : data_reg[7] * 2;
            expo_data8 = data_reg[8][7] ? 8'd255 : data_reg[8] * 2;
            expo_data9 = data_reg[9][7] ? 8'd255 : data_reg[9] * 2;
            expo_data10 = data_reg[10][7] ? 8'd255 : data_reg[10] * 2;
            expo_data11 = data_reg[11][7] ? 8'd255 : data_reg[11] * 2;
            expo_data12 = data_reg[12][7] ? 8'd255 : data_reg[12] * 2;
            expo_data13 = data_reg[13][7] ? 8'd255 : data_reg[13] * 2;
            expo_data14 = data_reg[14][7] ? 8'd255 : data_reg[14] * 2;
            expo_data15 = data_reg[15][7] ? 8'd255 : data_reg[15] * 2;
        end
    endcase
end
reg [127:0] data_out;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out <= 0;
    end else begin
        data_out <= {expo_data15, expo_data14, expo_data13, expo_data12, expo_data11, expo_data10, expo_data9, expo_data8, 
                     expo_data7, expo_data6, expo_data5, expo_data4, expo_data3, expo_data2, expo_data1, expo_data0};
    end
end

reg [7:0] expo_sum0, expo_sum1, expo_sum2, expo_sum3, expo_sum4, expo_sum5, expo_sum6, expo_sum7;
always @(posedge clk) begin
    if(cnt16 < 66) begin
        expo_sum0 <= expo_data0[7:2] + expo_data1[7:2];
        expo_sum1 <= expo_data2[7:2] + expo_data3[7:2];
        expo_sum2 <= expo_data4[7:2] + expo_data5[7:2];
        expo_sum3 <= expo_data6[7:2] + expo_data7[7:2];
        expo_sum4 <= expo_data8[7:2] + expo_data9[7:2];
        expo_sum5 <= expo_data10[7:2] + expo_data11[7:2];
        expo_sum6 <= expo_data12[7:2] + expo_data13[7:2];
        expo_sum7 <= expo_data14[7:2] + expo_data15[7:2];
    end else if(cnt16 < 130) begin
        expo_sum0 <= expo_data0[7:1] + expo_data1[7:1];
        expo_sum1 <= expo_data2[7:1] + expo_data3[7:1];
        expo_sum2 <= expo_data4[7:1] + expo_data5[7:1];
        expo_sum3 <= expo_data6[7:1] + expo_data7[7:1];
        expo_sum4 <= expo_data8[7:1] + expo_data9[7:1];
        expo_sum5 <= expo_data10[7:1] + expo_data11[7:1];
        expo_sum6 <= expo_data12[7:1] + expo_data13[7:1];
        expo_sum7 <= expo_data14[7:1] + expo_data15[7:1];
    end else if(cnt16 < 194) begin
        expo_sum0 <= expo_data0[7:2] + expo_data1[7:2];
        expo_sum1 <= expo_data2[7:2] + expo_data3[7:2];
        expo_sum2 <= expo_data4[7:2] + expo_data5[7:2];
        expo_sum3 <= expo_data6[7:2] + expo_data7[7:2];
        expo_sum4 <= expo_data8[7:2] + expo_data9[7:2];
        expo_sum5 <= expo_data10[7:2] + expo_data11[7:2];
        expo_sum6 <= expo_data12[7:2] + expo_data13[7:2];
        expo_sum7 <= expo_data14[7:2] + expo_data15[7:2];
    end
end
reg [9:0] expo_sum8, expo_sum9;
always @(posedge clk) begin
    expo_sum8 <= expo_sum0 + expo_sum1 + expo_sum2 + expo_sum3;
    expo_sum9 <= expo_sum4 + expo_sum5 + expo_sum6 + expo_sum7;
end

assign awid_s_inf = 4'd0;
assign awaddr_s_inf = state_w == AE_W_req ? 32'h10000 + (3*32*32)*pic_no_reg : 32'd0;
assign awsize_s_inf = state_w == AE_W_req ? 3'd4 : 3'd0;
assign awburst_s_inf = state_w == AE_W_req ? 2'd1 : 2'd0;
assign awlen_s_inf = state_w == AE_W_req ? 8'd191 : 8'd0;
assign awvalid_s_inf = state_w == AE_W_req;

assign wdata_s_inf = state_w == AE_W_out | state_w == AE_W_out_1st ? data_out : 128'd0;
assign wlast_s_inf = state_w == AE_W_out && cnt16 == 194;
assign wvalid_s_inf = state_w == AE_W_out | state_w == AE_W_out_1st;

assign bready_s_inf = state_w == AE_W_rec || state_w == AE_W_out || state_w == AE_W_end;

reg [17:0] avg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        avg <= 0;
    end else begin
        if(cnt16 < 4) begin
            avg <= expo_sum8 + expo_sum9;
        end else if(cnt16 < 196) begin
            avg <= avg + expo_sum8 + expo_sum9;
        end else begin
            avg <= 0;
        end
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
        if(cnt16 == 196) begin
            out_valid_reg <= 1;
            out_data_reg <= (zero_table[pic_no_reg]) ? 0 : avg[17:10];
        end else begin
            if(dirty_table[pic_no_reg][2]) begin
                if(state_r == AF_calc_out && cnt16 == 1) begin
                    out_valid_reg <= 1;
                    out_data_reg <= arg_max;
                end else begin
                    out_valid_reg <= 0;
                    out_data_reg <= 0;
                end
            end else begin
                if(state_r == AF_calc_out && cnt16 == 0) begin
                    out_valid_reg <= 1;
                    out_data_reg <= dirty_table[pic_no_reg][1:0];
                end else begin
                    out_valid_reg <= 0;
                    out_data_reg <= 0;
                end
            end
        end
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
