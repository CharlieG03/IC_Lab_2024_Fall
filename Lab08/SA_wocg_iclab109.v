/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: SA.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Fall IC Lab / Exersise Lab08 / SA
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

module SA(
    //Input signals
    clk,
    rst_n,
    in_valid,
    T,
    in_data,
    w_Q,
    w_K,
    w_V,

    //Output signals
    out_valid,
    out_data
    );

input clk;
input rst_n;
input in_valid;
input [3:0] T;
input signed [7:0] in_data;
input signed [7:0] w_Q;
input signed [7:0] w_K;
input signed [7:0] w_V;

output reg out_valid;
output reg signed [63:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//

//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [7:0] i_cnt;
reg [3:0] T_reg;
reg [6:0] in_data_num;
reg in_valid_reg;
reg signed [7:0] in_data_reg [63:0];
reg signed [7:0] w_Q_reg [63:0];
reg signed [7:0] w_reg;
reg signed [18:0] Q [63:0];
reg signed [18:0] K [63:0];
reg signed [18:0] V [63:0];
reg signed [38:0] A [63:0];
reg signed [57:0] P;
reg signed [15:0] p0, p1, p2, p3, p4, p5, p6, p7;
reg signed [55:0] p8, p9, p10, p11, p12, p13, p14, p15;
reg signed [7:0] mc0, mc1, mc2, mc3, mc4, mc5, mc6, mc7;
reg signed [36:0] mc8, mc9, mc10, mc11, mc12, mc13, mc14, mc15;
reg signed [7:0] mp0, mp1, mp2, mp3, mp4, mp5, mp6, mp7;
reg signed [18:0] mp8, mp9, mp10, mp11, mp12, mp13, mp14, mp15;
reg cnt_prop;

//==============================================//
//                  design                      //
//==============================================//
assign p0  = mc0  * mp0;
assign p1  = mc1  * mp1;
assign p2  = mc2  * mp2;
assign p3  = mc3  * mp3;
assign p4  = mc4  * mp4;
assign p5  = mc5  * mp5;
assign p6  = mc6  * mp6;
assign p7  = mc7  * mp7;
assign p8  = mc8  * mp8;
assign p9  = mc9  * mp9;
assign p10 = mc10 * mp10;
assign p11 = mc11 * mp11;
assign p12 = mc12 * mp12;
assign p13 = mc13 * mp13;
assign p14 = mc14 * mp14;
assign p15 = mc15 * mp15;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		in_valid_reg <= 0;
	end else begin
		in_valid_reg <= in_valid;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		i_cnt <= 0;
	end else begin
		if(i_cnt == 0) begin
			i_cnt <= in_valid ? 1 : 0;
		end else begin
			case(T_reg)
				1: i_cnt <= i_cnt < 200 ? i_cnt + 1 : 0;
				4: i_cnt <= i_cnt < 224 ? i_cnt + 1 : 0;
				8: i_cnt <= i_cnt + 1;
			endcase
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cnt_prop <= 0;
	end else begin
		if(i_cnt == 255) begin
			cnt_prop <= 1;
		end else begin
			cnt_prop <= 0;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		T_reg <= 0;
	end else begin
		T_reg <= (i_cnt == 0 & in_valid) ? T : T_reg;
	end
end
assign in_data_num = T_reg * 8;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		for(int i = 0; i < 64; i = i + 1) begin
			in_data_reg[i] <= 0;
		end
	end else begin
		if ((i_cnt < in_data_num | i_cnt == 0) & in_valid) begin
			in_data_reg[i_cnt] <= in_data;
		end else if(out_valid) begin
			for(int i = 0; i < 64; i = i + 1) begin
				in_data_reg[i] <= 0;
			end
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		for(int i = 0; i < 64; i = i + 1) begin
			w_Q_reg[i] <= 0;
		end
	end else begin
		if (i_cnt < 64 & in_valid) begin
			w_Q_reg[i_cnt] <= w_Q;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		w_reg <= 0;
	end else begin
        if(i_cnt <= 127) begin
            w_reg <= w_K;
        end else begin
            w_reg <= w_V;
        end
	end
end
reg [7:0] row_p0, row_p1;
reg [2:0] temp_ptr;
reg [2:0] row_ptr;
reg [5:0] Q_ptr;
reg [2:0] Q_ptr_A0;
assign row_p0 = i_cnt - 1;
assign row_p1 = i_cnt - 2;
assign temp_ptr = row_p0[2:0];
assign row_ptr = row_p0[5:3];
assign Q_ptr = (row_ptr + 2) * 8;
assign Q_ptr_A0 = row_p1[5:3] + 1;	
always @(*) begin
	mc0 = 0; mc1 = 0; mc2 = 0; mc3 = 0; mc4 = 0; mc5 = 0; mc6 = 0; mc7 = 0;
	mc8 = 0; mc9 = 0; mc10 = 0; mc11 = 0; mc12 = 0; mc13 = 0; mc14 = 0; mc15 = 0;
	mp0 = 0; mp1 = 0; mp2 = 0; mp3 = 0; mp4 = 0; mp5 = 0; mp6 = 0; mp7 = 0;
	mp8 = 0; mp9 = 0; mp10 = 0; mp11 = 0; mp12 = 0; mp13 = 0; mp14 = 0; mp15 = 0;
	if(i_cnt <= 64) begin
		mc0 = in_data_reg[0]; mp0 = w_Q_reg[temp_ptr + 0];
		mc1 = in_data_reg[1]; mp1 = w_Q_reg[temp_ptr + 8];
		mc2 = in_data_reg[2]; mp2 = w_Q_reg[temp_ptr + 16];
		mc3 = in_data_reg[3]; mp3 = w_Q_reg[temp_ptr + 24];
		mc4 = in_data_reg[4]; mp4 = w_Q_reg[temp_ptr + 32];
		mc5 = in_data_reg[5]; mp5 = w_Q_reg[temp_ptr + 40];
		mc6 = in_data_reg[6]; mp6 = w_Q_reg[temp_ptr + 48];
		mc7 = in_data_reg[7]; mp7 = w_Q_reg[temp_ptr + 56];
		
		mc8  = in_data_reg[8];   mp8  = w_Q_reg[temp_ptr + 0];
		mc9  = in_data_reg[9];   mp9  = w_Q_reg[temp_ptr + 8];
		mc10 = in_data_reg[10];  mp10 = w_Q_reg[temp_ptr + 16];
		mc11 = in_data_reg[11];  mp11 = w_Q_reg[temp_ptr + 24];
		mc12 = in_data_reg[12];  mp12 = w_Q_reg[temp_ptr + 32];
		mc13 = in_data_reg[13];  mp13 = w_Q_reg[temp_ptr + 40];
		mc14 = in_data_reg[14];  mp14 = w_Q_reg[temp_ptr + 48];
		mc15 = in_data_reg[15];  mp15 = w_Q_reg[temp_ptr + 56];
	end else if(i_cnt <= 128) begin
		mc0 = in_data_reg[row_ptr + 0]; mp0 = w_reg;
		mc1 = in_data_reg[row_ptr + 8]; mp1 = w_reg;
		mc2 = in_data_reg[row_ptr + 16]; mp2 = w_reg;
		mc3 = in_data_reg[row_ptr + 24]; mp3 = w_reg;
		mc4 = in_data_reg[row_ptr + 32]; mp4 = w_reg;
		mc5 = in_data_reg[row_ptr + 40]; mp5 = w_reg;
		mc6 = in_data_reg[row_ptr + 48]; mp6 = w_reg;
		mc7 = in_data_reg[row_ptr + 56]; mp7 = w_reg;
		if(i_cnt <= 112) begin
			mc8  = in_data_reg[Q_ptr + 0];  mp8  = w_Q_reg[temp_ptr + 0];
			mc9  = in_data_reg[Q_ptr + 1];  mp9  = w_Q_reg[temp_ptr + 8];
			mc10 = in_data_reg[Q_ptr + 2];  mp10 = w_Q_reg[temp_ptr + 16];
			mc11 = in_data_reg[Q_ptr + 3];  mp11 = w_Q_reg[temp_ptr + 24];
			mc12 = in_data_reg[Q_ptr + 4];  mp12 = w_Q_reg[temp_ptr + 32];
			mc13 = in_data_reg[Q_ptr + 5];  mp13 = w_Q_reg[temp_ptr + 40];
			mc14 = in_data_reg[Q_ptr + 6];  mp14 = w_Q_reg[temp_ptr + 48];
			mc15 = in_data_reg[Q_ptr + 7];  mp15 = w_Q_reg[temp_ptr + 56];
		end else begin
			mc8  = Q[row_p1[2:0]];  mp8  = K[row_p1[2:0] + 0]; 
			mc9  = Q[row_p1[2:0]];  mp9  = K[row_p1[2:0] + 8]; 
			mc10 = Q[row_p1[2:0]];  mp10 = K[row_p1[2:0] + 16];
			mc11 = Q[row_p1[2:0]];  mp11 = K[row_p1[2:0] + 24];
			mc12 = Q[row_p1[2:0]];  mp12 = K[row_p1[2:0] + 32];
			mc13 = Q[row_p1[2:0]];  mp13 = K[row_p1[2:0] + 40];
			mc14 = Q[row_p1[2:0]];  mp14 = K[row_p1[2:0] + 48];
			mc15 = Q[row_p1[2:0]];  mp15 = K[row_p1[2:0] + 56];
		end
	end else if(i_cnt <= 191) begin
		mc0 = in_data_reg[row_ptr + 0]; mp0 = w_reg;
		mc1 = in_data_reg[row_ptr + 8]; mp1 = w_reg;
		mc2 = in_data_reg[row_ptr + 16]; mp2 = w_reg;
		mc3 = in_data_reg[row_ptr + 24]; mp3 = w_reg;
		mc4 = in_data_reg[row_ptr + 32]; mp4 = w_reg;
		mc5 = in_data_reg[row_ptr + 40]; mp5 = w_reg;
		mc6 = in_data_reg[row_ptr + 48]; mp6 = w_reg;
		mc7 = in_data_reg[row_ptr + 56]; mp7 = w_reg;
		
		mc8  = Q[{Q_ptr_A0, row_p1[2:0]}]; mp8  = K[row_p1[2:0] + 0]; 
		mc9  = Q[{Q_ptr_A0, row_p1[2:0]}]; mp9  = K[row_p1[2:0] + 8]; 
		mc10 = Q[{Q_ptr_A0, row_p1[2:0]}]; mp10 = K[row_p1[2:0] + 16];
		mc11 = Q[{Q_ptr_A0, row_p1[2:0]}]; mp11 = K[row_p1[2:0] + 24];
		mc12 = Q[{Q_ptr_A0, row_p1[2:0]}]; mp12 = K[row_p1[2:0] + 32];
		mc13 = Q[{Q_ptr_A0, row_p1[2:0]}]; mp13 = K[row_p1[2:0] + 40];
		mc14 = Q[{Q_ptr_A0, row_p1[2:0]}]; mp14 = K[row_p1[2:0] + 48];
		mc15 = Q[{Q_ptr_A0, row_p1[2:0]}]; mp15 = K[row_p1[2:0] + 56];
	end else begin
		mc0 = in_data_reg[row_ptr + 0]; mp0 = w_reg;
		mc1 = in_data_reg[row_ptr + 8]; mp1 = w_reg;
		mc2 = in_data_reg[row_ptr + 16]; mp2 = w_reg;
		mc3 = in_data_reg[row_ptr + 24]; mp3 = w_reg;
		mc4 = in_data_reg[row_ptr + 32]; mp4 = w_reg;
		mc5 = in_data_reg[row_ptr + 40]; mp5 = w_reg;
		mc6 = in_data_reg[row_ptr + 48]; mp6 = w_reg;
		mc7 = in_data_reg[row_ptr + 56]; mp7 = w_reg;

		mc8  = A[{i_cnt[5:3], 3'd0}]; mp8  = V[i_cnt[2:0] + 0];
		mc9  = A[{i_cnt[5:3], 3'd1}]; mp9  = V[i_cnt[2:0] + 8];
		mc10 = A[{i_cnt[5:3], 3'd2}]; mp10 = V[i_cnt[2:0] + 16];
		mc11 = A[{i_cnt[5:3], 3'd3}]; mp11 = V[i_cnt[2:0] + 24];
		mc12 = A[{i_cnt[5:3], 3'd4}]; mp12 = V[i_cnt[2:0] + 32];
		mc13 = A[{i_cnt[5:3], 3'd5}]; mp13 = V[i_cnt[2:0] + 40];
		mc14 = A[{i_cnt[5:3], 3'd6}]; mp14 = V[i_cnt[2:0] + 48];
		mc15 = A[{i_cnt[5:3], 3'd7}]; mp15 = V[i_cnt[2:0] + 56];
	end
end
reg [36:0] temp_sum0;
reg [58:0] temp_sum1;
assign temp_sum0 = p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7;
assign temp_sum1 = p8 + p9 + p10 + p11 + p12 + p13 + p14 + p15;
//==============================================//
//                    Q 					    //
//==============================================//
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[0] <= 0; Q[1] <= 0; Q[2] <= 0; Q[3] <= 0; Q[4] <= 0; Q[5] <= 0; Q[6] <= 0; Q[7] <= 0;
	end else begin
		Q[0] <= (i_cnt == 57 & in_valid_reg) ? temp_sum0 : Q[0];
		Q[1] <= (i_cnt == 58 & in_valid_reg) ? temp_sum0 : Q[1];
		Q[2] <= (i_cnt == 59 & in_valid_reg) ? temp_sum0 : Q[2];
		Q[3] <= (i_cnt == 60 & in_valid_reg) ? temp_sum0 : Q[3];
		Q[4] <= (i_cnt == 61 & in_valid_reg) ? temp_sum0 : Q[4];
		Q[5] <= (i_cnt == 62 & in_valid_reg) ? temp_sum0 : Q[5];
		Q[6] <= (i_cnt == 63 & in_valid_reg) ? temp_sum0 : Q[6];
		Q[7] <= (i_cnt == 64 & in_valid_reg) ? temp_sum0 : Q[7];
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[8] <= 0; Q[9] <= 0; Q[10] <= 0; Q[11] <= 0; Q[12] <= 0; Q[13] <= 0; Q[14] <= 0; Q[15] <= 0;
	end else begin
		Q[8] <= (i_cnt == 57 & in_valid_reg) ? temp_sum1 : Q[8];
		Q[9] <= (i_cnt == 58 & in_valid_reg) ? temp_sum1 : Q[9];
		Q[10] <= (i_cnt == 59 & in_valid_reg) ? temp_sum1 : Q[10];
		Q[11] <= (i_cnt == 60 & in_valid_reg) ? temp_sum1 : Q[11];
		Q[12] <= (i_cnt == 61 & in_valid_reg) ? temp_sum1 : Q[12];
		Q[13] <= (i_cnt == 62 & in_valid_reg) ? temp_sum1 : Q[13];
		Q[14] <= (i_cnt == 63 & in_valid_reg) ? temp_sum1 : Q[14];
		Q[15] <= (i_cnt == 64 & in_valid_reg) ? temp_sum1 : Q[15];
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[16] <= 0; Q[17] <= 0; Q[18] <= 0; Q[19] <= 0; Q[20] <= 0; Q[21] <= 0; Q[22] <= 0; Q[23] <= 0;
	end else begin
		Q[16] <= (i_cnt == 65 & in_valid_reg) ? temp_sum1 : Q[16];
		Q[17] <= (i_cnt == 66 & in_valid_reg) ? temp_sum1 : Q[17];
		Q[18] <= (i_cnt == 67 & in_valid_reg) ? temp_sum1 : Q[18];
		Q[19] <= (i_cnt == 68 & in_valid_reg) ? temp_sum1 : Q[19];
		Q[20] <= (i_cnt == 69 & in_valid_reg) ? temp_sum1 : Q[20];
		Q[21] <= (i_cnt == 70 & in_valid_reg) ? temp_sum1 : Q[21];
		Q[22] <= (i_cnt == 71 & in_valid_reg) ? temp_sum1 : Q[22];
		Q[23] <= (i_cnt == 72 & in_valid_reg) ? temp_sum1 : Q[23];
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[24] <= 0; Q[25] <= 0; Q[26] <= 0; Q[27] <= 0; Q[28] <= 0; Q[29] <= 0; Q[30] <= 0; Q[31] <= 0;
	end else begin
		Q[24] <= (i_cnt == 73 & in_valid_reg) ? temp_sum1 : Q[24];
		Q[25] <= (i_cnt == 74 & in_valid_reg) ? temp_sum1 : Q[25];
		Q[26] <= (i_cnt == 75 & in_valid_reg) ? temp_sum1 : Q[26];
		Q[27] <= (i_cnt == 76 & in_valid_reg) ? temp_sum1 : Q[27];
		Q[28] <= (i_cnt == 77 & in_valid_reg) ? temp_sum1 : Q[28];
		Q[29] <= (i_cnt == 78 & in_valid_reg) ? temp_sum1 : Q[29];
		Q[30] <= (i_cnt == 79 & in_valid_reg) ? temp_sum1 : Q[30];
		Q[31] <= (i_cnt == 80 & in_valid_reg) ? temp_sum1 : Q[31];
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[32] <= 0; Q[33] <= 0; Q[34] <= 0; Q[35] <= 0; Q[36] <= 0; Q[37] <= 0; Q[38] <= 0; Q[39] <= 0;
	end else begin
		Q[32] <= (i_cnt == 81 & in_valid_reg) ? temp_sum1 : Q[32];
		Q[33] <= (i_cnt == 82 & in_valid_reg) ? temp_sum1 : Q[33];
		Q[34] <= (i_cnt == 83 & in_valid_reg) ? temp_sum1 : Q[34];
		Q[35] <= (i_cnt == 84 & in_valid_reg) ? temp_sum1 : Q[35];
		Q[36] <= (i_cnt == 85 & in_valid_reg) ? temp_sum1 : Q[36];
		Q[37] <= (i_cnt == 86 & in_valid_reg) ? temp_sum1 : Q[37];
		Q[38] <= (i_cnt == 87 & in_valid_reg) ? temp_sum1 : Q[38];
		Q[39] <= (i_cnt == 88 & in_valid_reg) ? temp_sum1 : Q[39];
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[40] <= 0; Q[41] <= 0; Q[42] <= 0; Q[43] <= 0; Q[44] <= 0; Q[45] <= 0; Q[46] <= 0; Q[47] <= 0;
	end else begin
		Q[40] <= (i_cnt == 89 & in_valid_reg) ? temp_sum1 : Q[40];
		Q[41] <= (i_cnt == 90 & in_valid_reg) ? temp_sum1 : Q[41];
		Q[42] <= (i_cnt == 91 & in_valid_reg) ? temp_sum1 : Q[42];
		Q[43] <= (i_cnt == 92 & in_valid_reg) ? temp_sum1 : Q[43];
		Q[44] <= (i_cnt == 93 & in_valid_reg) ? temp_sum1 : Q[44];
		Q[45] <= (i_cnt == 94 & in_valid_reg) ? temp_sum1 : Q[45];
		Q[46] <= (i_cnt == 95 & in_valid_reg) ? temp_sum1 : Q[46];
		Q[47] <= (i_cnt == 96 & in_valid_reg) ? temp_sum1 : Q[47];
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[48] <= 0; Q[49] <= 0; Q[50] <= 0; Q[51] <= 0; Q[52] <= 0; Q[53] <= 0; Q[54] <= 0; Q[55] <= 0;
	end else begin
		Q[48] <= (i_cnt == 97 & in_valid_reg) ? temp_sum1 : Q[48];
		Q[49] <= (i_cnt == 98 & in_valid_reg) ? temp_sum1 : Q[49];
		Q[50] <= (i_cnt == 99 & in_valid_reg) ? temp_sum1 : Q[50];
		Q[51] <= (i_cnt == 100 & in_valid_reg) ? temp_sum1 : Q[51];
		Q[52] <= (i_cnt == 101 & in_valid_reg) ? temp_sum1 : Q[52];
		Q[53] <= (i_cnt == 102 & in_valid_reg) ? temp_sum1 : Q[53];
		Q[54] <= (i_cnt == 103 & in_valid_reg) ? temp_sum1 : Q[54];
		Q[55] <= (i_cnt == 104 & in_valid_reg) ? temp_sum1 : Q[55];
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Q[56] <= 0; Q[57] <= 0; Q[58] <= 0; Q[59] <= 0; Q[60] <= 0; Q[61] <= 0; Q[62] <= 0; Q[63] <= 0;
	end else begin
		Q[56] <= (i_cnt == 105 & in_valid_reg) ? temp_sum1 : Q[56];
		Q[57] <= (i_cnt == 106 & in_valid_reg) ? temp_sum1 : Q[57];
		Q[58] <= (i_cnt == 107 & in_valid_reg) ? temp_sum1 : Q[58];
		Q[59] <= (i_cnt == 108 & in_valid_reg) ? temp_sum1 : Q[59];
		Q[60] <= (i_cnt == 109 & in_valid_reg) ? temp_sum1 : Q[60];
		Q[61] <= (i_cnt == 110 & in_valid_reg) ? temp_sum1 : Q[61];
		Q[62] <= (i_cnt == 111 & in_valid_reg) ? temp_sum1 : Q[62];
		Q[63] <= (i_cnt == 112 & in_valid_reg) ? temp_sum1 : Q[63];
	end
end
//==============================================//
//                    K 					    //
//==============================================//
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[0] <= 0; K[1] <= 0; K[2] <= 0; K[3] <= 0; K[4] <= 0; K[5] <= 0; K[6] <= 0; K[7] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[0] <= 0; K[1] <= 0; K[2] <= 0; K[3] <= 0; K[4] <= 0; K[5] <= 0; K[6] <= 0; K[7] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[0] <= (i_cnt[2:0] == 3'b001) ? K[0] + p0 : K[0];
			K[1] <= (i_cnt[2:0] == 3'b010) ? K[1] + p0 : K[1];
			K[2] <= (i_cnt[2:0] == 3'b011) ? K[2] + p0 : K[2];
			K[3] <= (i_cnt[2:0] == 3'b100) ? K[3] + p0 : K[3];
			K[4] <= (i_cnt[2:0] == 3'b101) ? K[4] + p0 : K[4];
			K[5] <= (i_cnt[2:0] == 3'b110) ? K[5] + p0 : K[5];
			K[6] <= (i_cnt[2:0] == 3'b111) ? K[6] + p0 : K[6];
			K[7] <= (i_cnt[2:0] == 3'b000) ? K[7] + p0 : K[7];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[8] <= 0; K[9] <= 0; K[10] <= 0; K[11] <= 0; K[12] <= 0; K[13] <= 0; K[14] <= 0; K[15] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[8] <= 0; K[9] <= 0; K[10] <= 0; K[11] <= 0; K[12] <= 0; K[13] <= 0; K[14] <= 0; K[15] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[8] <=  (i_cnt[2:0] == 3'b001) ? K[8] + p1 : K[8];
			K[9] <=  (i_cnt[2:0] == 3'b010) ? K[9] + p1 : K[9];
			K[10] <= (i_cnt[2:0] == 3'b011) ? K[10] + p1 : K[10];
			K[11] <= (i_cnt[2:0] == 3'b100) ? K[11] + p1 : K[11];
			K[12] <= (i_cnt[2:0] == 3'b101) ? K[12] + p1 : K[12];
			K[13] <= (i_cnt[2:0] == 3'b110) ? K[13] + p1 : K[13];
			K[14] <= (i_cnt[2:0] == 3'b111) ? K[14] + p1 : K[14];
			K[15] <= (i_cnt[2:0] == 3'b000) ? K[15] + p1 : K[15];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[16] <= 0; K[17] <= 0; K[18] <= 0; K[19] <= 0; K[20] <= 0; K[21] <= 0; K[22] <= 0; K[23] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[16] <= 0; K[17] <= 0; K[18] <= 0; K[19] <= 0; K[20] <= 0; K[21] <= 0; K[22] <= 0; K[23] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[16] <= (i_cnt[2:0] == 3'b001) ? K[16] + p2 : K[16];
			K[17] <= (i_cnt[2:0] == 3'b010) ? K[17] + p2 : K[17];
			K[18] <= (i_cnt[2:0] == 3'b011) ? K[18] + p2 : K[18];
			K[19] <= (i_cnt[2:0] == 3'b100) ? K[19] + p2 : K[19];
			K[20] <= (i_cnt[2:0] == 3'b101) ? K[20] + p2 : K[20];
			K[21] <= (i_cnt[2:0] == 3'b110) ? K[21] + p2 : K[21];
			K[22] <= (i_cnt[2:0] == 3'b111) ? K[22] + p2 : K[22];
			K[23] <= (i_cnt[2:0] == 3'b000) ? K[23] + p2 : K[23];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[24] <= 0; K[25] <= 0; K[26] <= 0; K[27] <= 0; K[28] <= 0; K[29] <= 0; K[30] <= 0; K[31] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[24] <= 0; K[25] <= 0; K[26] <= 0; K[27] <= 0; K[28] <= 0; K[29] <= 0; K[30] <= 0; K[31] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[24] <= (i_cnt[2:0] == 3'b001) ? K[24] + p3 : K[24];
			K[25] <= (i_cnt[2:0] == 3'b010) ? K[25] + p3 : K[25];
			K[26] <= (i_cnt[2:0] == 3'b011) ? K[26] + p3 : K[26];
			K[27] <= (i_cnt[2:0] == 3'b100) ? K[27] + p3 : K[27];
			K[28] <= (i_cnt[2:0] == 3'b101) ? K[28] + p3 : K[28];
			K[29] <= (i_cnt[2:0] == 3'b110) ? K[29] + p3 : K[29];
			K[30] <= (i_cnt[2:0] == 3'b111) ? K[30] + p3 : K[30];
			K[31] <= (i_cnt[2:0] == 3'b000) ? K[31] + p3 : K[31];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[32] <= 0; K[33] <= 0; K[34] <= 0; K[35] <= 0; K[36] <= 0; K[37] <= 0; K[38] <= 0; K[39] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[32] <= 0; K[33] <= 0; K[34] <= 0; K[35] <= 0; K[36] <= 0; K[37] <= 0; K[38] <= 0; K[39] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[32] <= (i_cnt[2:0] == 3'b001) ? K[32] + p4 : K[32];
			K[33] <= (i_cnt[2:0] == 3'b010) ? K[33] + p4 : K[33];
			K[34] <= (i_cnt[2:0] == 3'b011) ? K[34] + p4 : K[34];
			K[35] <= (i_cnt[2:0] == 3'b100) ? K[35] + p4 : K[35];
			K[36] <= (i_cnt[2:0] == 3'b101) ? K[36] + p4 : K[36];
			K[37] <= (i_cnt[2:0] == 3'b110) ? K[37] + p4 : K[37];
			K[38] <= (i_cnt[2:0] == 3'b111) ? K[38] + p4 : K[38];
			K[39] <= (i_cnt[2:0] == 3'b000) ? K[39] + p4 : K[39];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[40] <= 0; K[41] <= 0; K[42] <= 0; K[43] <= 0; K[44] <= 0; K[45] <= 0; K[46] <= 0; K[47] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[40] <= 0; K[41] <= 0; K[42] <= 0; K[43] <= 0; K[44] <= 0; K[45] <= 0; K[46] <= 0; K[47] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[40] <= (i_cnt[2:0] == 3'b001) ? K[40] + p5 : K[40];
			K[41] <= (i_cnt[2:0] == 3'b010) ? K[41] + p5 : K[41];
			K[42] <= (i_cnt[2:0] == 3'b011) ? K[42] + p5 : K[42];
			K[43] <= (i_cnt[2:0] == 3'b100) ? K[43] + p5 : K[43];
			K[44] <= (i_cnt[2:0] == 3'b101) ? K[44] + p5 : K[44];
			K[45] <= (i_cnt[2:0] == 3'b110) ? K[45] + p5 : K[45];
			K[46] <= (i_cnt[2:0] == 3'b111) ? K[46] + p5 : K[46];
			K[47] <= (i_cnt[2:0] == 3'b000) ? K[47] + p5 : K[47];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[48] <= 0; K[49] <= 0; K[50] <= 0; K[51] <= 0; K[52] <= 0; K[53] <= 0; K[54] <= 0; K[55] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[48] <= 0; K[49] <= 0; K[50] <= 0; K[51] <= 0; K[52] <= 0; K[53] <= 0; K[54] <= 0; K[55] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[48] <= (i_cnt[2:0] == 3'b001) ? K[48] + p6 : K[48];
			K[49] <= (i_cnt[2:0] == 3'b010) ? K[49] + p6 : K[49];
			K[50] <= (i_cnt[2:0] == 3'b011) ? K[50] + p6 : K[50];
			K[51] <= (i_cnt[2:0] == 3'b100) ? K[51] + p6 : K[51];
			K[52] <= (i_cnt[2:0] == 3'b101) ? K[52] + p6 : K[52];
			K[53] <= (i_cnt[2:0] == 3'b110) ? K[53] + p6 : K[53];
			K[54] <= (i_cnt[2:0] == 3'b111) ? K[54] + p6 : K[54];
			K[55] <= (i_cnt[2:0] == 3'b000) ? K[55] + p6 : K[55];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		K[56] <= 0; K[57] <= 0; K[58] <= 0; K[59] <= 0; K[60] <= 0; K[61] <= 0; K[62] <= 0; K[63] <= 0;
	end else begin
		if(i_cnt == 64) begin
			K[56] <= 0; K[57] <= 0; K[58] <= 0; K[59] <= 0; K[60] <= 0; K[61] <= 0; K[62] <= 0; K[63] <= 0;
		end else if(i_cnt <= 128 & i_cnt > 64) begin
			K[56] <= (i_cnt[2:0] == 3'b001) ? K[56] + p7 : K[56];
			K[57] <= (i_cnt[2:0] == 3'b010) ? K[57] + p7 : K[57];
			K[58] <= (i_cnt[2:0] == 3'b011) ? K[58] + p7 : K[58];
			K[59] <= (i_cnt[2:0] == 3'b100) ? K[59] + p7 : K[59];
			K[60] <= (i_cnt[2:0] == 3'b101) ? K[60] + p7 : K[60];
			K[61] <= (i_cnt[2:0] == 3'b110) ? K[61] + p7 : K[61];
			K[62] <= (i_cnt[2:0] == 3'b111) ? K[62] + p7 : K[62];
			K[63] <= (i_cnt[2:0] == 3'b000) ? K[63] + p7 : K[63];
		end
	end
end
//==============================================//
//                    V 					    //
//==============================================//
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[0] <= 0; V[1] <= 0; V[2] <= 0; V[3] <= 0; V[4] <= 0; V[5] <= 0; V[6] <= 0; V[7] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[0] <= 0; V[1] <= 0; V[2] <= 0; V[3] <= 0; V[4] <= 0; V[5] <= 0; V[6] <= 0; V[7] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[0] <= (i_cnt[2:0] == 3'b001) ? V[0] + p0 : V[0];
			V[1] <= (i_cnt[2:0] == 3'b010) ? V[1] + p0 : V[1];
			V[2] <= (i_cnt[2:0] == 3'b011) ? V[2] + p0 : V[2];
			V[3] <= (i_cnt[2:0] == 3'b100) ? V[3] + p0 : V[3];
			V[4] <= (i_cnt[2:0] == 3'b101) ? V[4] + p0 : V[4];
			V[5] <= (i_cnt[2:0] == 3'b110) ? V[5] + p0 : V[5];
			V[6] <= (i_cnt[2:0] == 3'b111) ? V[6] + p0 : V[6];
			V[7] <= (i_cnt[2:0] == 3'b000) ? V[7] + p0 : V[7];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[8] <= 0; V[9] <= 0; V[10] <= 0; V[11] <= 0; V[12] <= 0; V[13] <= 0; V[14] <= 0; V[15] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[8] <= 0; V[9] <= 0; V[10] <= 0; V[11] <= 0; V[12] <= 0; V[13] <= 0; V[14] <= 0; V[15] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[8] <=  (i_cnt[2:0] == 3'b001) ? V[8] + p1 : V[8];
			V[9] <=  (i_cnt[2:0] == 3'b010) ? V[9] + p1 : V[9];
			V[10] <= (i_cnt[2:0] == 3'b011) ? V[10] + p1 : V[10];
			V[11] <= (i_cnt[2:0] == 3'b100) ? V[11] + p1 : V[11];
			V[12] <= (i_cnt[2:0] == 3'b101) ? V[12] + p1 : V[12];
			V[13] <= (i_cnt[2:0] == 3'b110) ? V[13] + p1 : V[13];
			V[14] <= (i_cnt[2:0] == 3'b111) ? V[14] + p1 : V[14];
			V[15] <= (i_cnt[2:0] == 3'b000) ? V[15] + p1 : V[15];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[16] <= 0; V[17] <= 0; V[18] <= 0; V[19] <= 0; V[20] <= 0; V[21] <= 0; V[22] <= 0; V[23] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[16] <= 0; V[17] <= 0; V[18] <= 0; V[19] <= 0; V[20] <= 0; V[21] <= 0; V[22] <= 0; V[23] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[16] <= (i_cnt[2:0] == 3'b001) ? V[16] + p2 : V[16];
			V[17] <= (i_cnt[2:0] == 3'b010) ? V[17] + p2 : V[17];
			V[18] <= (i_cnt[2:0] == 3'b011) ? V[18] + p2 : V[18];
			V[19] <= (i_cnt[2:0] == 3'b100) ? V[19] + p2 : V[19];
			V[20] <= (i_cnt[2:0] == 3'b101) ? V[20] + p2 : V[20];
			V[21] <= (i_cnt[2:0] == 3'b110) ? V[21] + p2 : V[21];
			V[22] <= (i_cnt[2:0] == 3'b111) ? V[22] + p2 : V[22];
			V[23] <= (i_cnt[2:0] == 3'b000) ? V[23] + p2 : V[23];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[24] <= 0; V[25] <= 0; V[26] <= 0; V[27] <= 0; V[28] <= 0; V[29] <= 0; V[30] <= 0; V[31] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[24] <= 0; V[25] <= 0; V[26] <= 0; V[27] <= 0; V[28] <= 0; V[29] <= 0; V[30] <= 0; V[31] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[24] <= (i_cnt[2:0] == 3'b001) ? V[24] + p3 : V[24];
			V[25] <= (i_cnt[2:0] == 3'b010) ? V[25] + p3 : V[25];
			V[26] <= (i_cnt[2:0] == 3'b011) ? V[26] + p3 : V[26];
			V[27] <= (i_cnt[2:0] == 3'b100) ? V[27] + p3 : V[27];
			V[28] <= (i_cnt[2:0] == 3'b101) ? V[28] + p3 : V[28];
			V[29] <= (i_cnt[2:0] == 3'b110) ? V[29] + p3 : V[29];
			V[30] <= (i_cnt[2:0] == 3'b111) ? V[30] + p3 : V[30];
			V[31] <= (i_cnt[2:0] == 3'b000) ? V[31] + p3 : V[31];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[32] <= 0; V[33] <= 0; V[34] <= 0; V[35] <= 0; V[36] <= 0; V[37] <= 0; V[38] <= 0; V[39] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[32] <= 0; V[33] <= 0; V[34] <= 0; V[35] <= 0; V[36] <= 0; V[37] <= 0; V[38] <= 0; V[39] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[32] <= (i_cnt[2:0] == 3'b001) ? V[32] + p4 : V[32];
			V[33] <= (i_cnt[2:0] == 3'b010) ? V[33] + p4 : V[33];
			V[34] <= (i_cnt[2:0] == 3'b011) ? V[34] + p4 : V[34];
			V[35] <= (i_cnt[2:0] == 3'b100) ? V[35] + p4 : V[35];
			V[36] <= (i_cnt[2:0] == 3'b101) ? V[36] + p4 : V[36];
			V[37] <= (i_cnt[2:0] == 3'b110) ? V[37] + p4 : V[37];
			V[38] <= (i_cnt[2:0] == 3'b111) ? V[38] + p4 : V[38];
			V[39] <= (i_cnt[2:0] == 3'b000) ? V[39] + p4 : V[39];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[40] <= 0; V[41] <= 0; V[42] <= 0; V[43] <= 0; V[44] <= 0; V[45] <= 0; V[46] <= 0; V[47] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[40] <= 0; V[41] <= 0; V[42] <= 0; V[43] <= 0; V[44] <= 0; V[45] <= 0; V[46] <= 0; V[47] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[40] <= (i_cnt[2:0] == 3'b001) ? V[40] + p5 : V[40];
			V[41] <= (i_cnt[2:0] == 3'b010) ? V[41] + p5 : V[41];
			V[42] <= (i_cnt[2:0] == 3'b011) ? V[42] + p5 : V[42];
			V[43] <= (i_cnt[2:0] == 3'b100) ? V[43] + p5 : V[43];
			V[44] <= (i_cnt[2:0] == 3'b101) ? V[44] + p5 : V[44];
			V[45] <= (i_cnt[2:0] == 3'b110) ? V[45] + p5 : V[45];
			V[46] <= (i_cnt[2:0] == 3'b111) ? V[46] + p5 : V[46];
			V[47] <= (i_cnt[2:0] == 3'b000) ? V[47] + p5 : V[47];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[48] <= 0; V[49] <= 0; V[50] <= 0; V[51] <= 0; V[52] <= 0; V[53] <= 0; V[54] <= 0; V[55] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[48] <= 0; V[49] <= 0; V[50] <= 0; V[51] <= 0; V[52] <= 0; V[53] <= 0; V[54] <= 0; V[55] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[48] <= (i_cnt[2:0] == 3'b001) ? V[48] + p6 : V[48];
			V[49] <= (i_cnt[2:0] == 3'b010) ? V[49] + p6 : V[49];
			V[50] <= (i_cnt[2:0] == 3'b011) ? V[50] + p6 : V[50];
			V[51] <= (i_cnt[2:0] == 3'b100) ? V[51] + p6 : V[51];
			V[52] <= (i_cnt[2:0] == 3'b101) ? V[52] + p6 : V[52];
			V[53] <= (i_cnt[2:0] == 3'b110) ? V[53] + p6 : V[53];
			V[54] <= (i_cnt[2:0] == 3'b111) ? V[54] + p6 : V[54];
			V[55] <= (i_cnt[2:0] == 3'b000) ? V[55] + p6 : V[55];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		V[56] <= 0; V[57] <= 0; V[58] <= 0; V[59] <= 0; V[60] <= 0; V[61] <= 0; V[62] <= 0; V[63] <= 0;
	end else begin
		if(i_cnt == 128) begin
			V[56] <= 0; V[57] <= 0; V[58] <= 0; V[59] <= 0; V[60] <= 0; V[61] <= 0; V[62] <= 0; V[63] <= 0;
		end else if(i_cnt <= 192 & i_cnt > 128) begin
			V[56] <= (i_cnt[2:0] == 3'b001) ? V[56] + p7 : V[56];
			V[57] <= (i_cnt[2:0] == 3'b010) ? V[57] + p7 : V[57];
			V[58] <= (i_cnt[2:0] == 3'b011) ? V[58] + p7 : V[58];
			V[59] <= (i_cnt[2:0] == 3'b100) ? V[59] + p7 : V[59];
			V[60] <= (i_cnt[2:0] == 3'b101) ? V[60] + p7 : V[60];
			V[61] <= (i_cnt[2:0] == 3'b110) ? V[61] + p7 : V[61];
			V[62] <= (i_cnt[2:0] == 3'b111) ? V[62] + p7 : V[62];
			V[63] <= (i_cnt[2:0] == 3'b000) ? V[63] + p7 : V[63];
		end
	end
end
//==============================================//
//                    A 					    //
//==============================================//
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		for(int i = 0; i < 64; i = i + 1) begin
			A[i] <= 0;
		end
	end else begin
		if(i_cnt > 121 & i_cnt <= 185) begin
			A[{Q_ptr_A0, 3'd0}] <= A[{Q_ptr_A0, 3'd0}] + p8 ;
			A[{Q_ptr_A0, 3'd1}] <= A[{Q_ptr_A0, 3'd1}] + p9 ;
			A[{Q_ptr_A0, 3'd2}] <= A[{Q_ptr_A0, 3'd2}] + p10;
			A[{Q_ptr_A0, 3'd3}] <= A[{Q_ptr_A0, 3'd3}] + p11;
			A[{Q_ptr_A0, 3'd4}] <= A[{Q_ptr_A0, 3'd4}] + p12;
			A[{Q_ptr_A0, 3'd5}] <= A[{Q_ptr_A0, 3'd5}] + p13;
			A[{Q_ptr_A0, 3'd6}] <= A[{Q_ptr_A0, 3'd6}] + p14;
			A[{Q_ptr_A0, 3'd7}] <= A[{Q_ptr_A0, 3'd7}] + p15;
		end else if(i_cnt == 0) begin
			for(int i = 0; i < 64; i = i + 1) begin
				A[i] <= 0;
			end
		end
        if(i_cnt > 129 & i_cnt <= 193) begin
            A[i_cnt-130] <= A[i_cnt-130] > 0 ? A[i_cnt-130] / 3 : 0;
        end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		P <= 0;
	end else begin
		P <= temp_sum1;
	end
end
assign out_valid = i_cnt > 192 | cnt_prop;
assign out_data = out_valid ? P : 0;
endmodule
