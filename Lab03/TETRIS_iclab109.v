/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: TETRIS
// FILE NAME: TETRIS.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / TETRIS
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
module TETRIS (
	//INPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//OUTPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[2:0]	tetrominoes;
input		[2:0]	position;
output reg			tetris_valid, score_valid, fail;
output reg	[3:0]	score;
output reg 	[71:0]	tetris;


//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg in_valid_reg0;
reg [5:0] tetris_map [0:11];
reg [5:0] tetris_map_nxt [0:13];
reg [3:0] floor[0:5];
reg [3:0] floor_ref, floor_tmp0, floor_tmp1;
reg [3:0] turn_count;
reg [3:0] score_reg;
reg current_score;
reg fail_nxt;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
//---------------------------------------------------------------------
// ROW CHECK & FIND FLOOR
//---------------------------------------------------------------------
genvar i, j; 
generate
	for(j=0;j<6;j=j+1) begin : GEN_FIND_FLOOR
		FIND_FLOOR FF(
			.column({tetris_map[11][j], tetris_map[10][j], tetris_map[9][j], tetris_map[8][j], tetris_map[7][j], tetris_map[6][j], tetris_map[5][j], tetris_map[4][j], tetris_map[3][j], tetris_map[2][j], tetris_map[1][j], tetris_map[0][j]}),
			.floor(floor[j])
		);
	end
endgenerate

//---------------------------------------------------------------------
// TURN COUNT
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		turn_count <= 15;
	end else begin
		if(in_valid) begin
			turn_count <= turn_count + 1;
		end
		if(fail | turn_count == 15 & score_valid) begin
			turn_count <= 15;
		end
	end
end

//---------------------------------------------------------------------
// OUTPUT
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		score_valid <= 0;
	end else begin
		if(in_valid) begin
			if(~(&(tetris_map_nxt[10]) | &(tetris_map_nxt[9]) | &(tetris_map_nxt[8]) | &(tetris_map_nxt[7]) | &(tetris_map_nxt[6]) | &(tetris_map_nxt[5]) | &(tetris_map_nxt[4]) | &(tetris_map_nxt[3]) | &(tetris_map_nxt[2]) | &(tetris_map_nxt[1]) | &(tetris_map_nxt[0]))) begin
				score_valid <= 1;
			end
		end else if(in_valid_reg0) begin
			if(~(&tetris_map_nxt[9] | &tetris_map_nxt[8] | &tetris_map_nxt[7] | &tetris_map_nxt[6] | &tetris_map_nxt[5] | &tetris_map_nxt[4] | &tetris_map_nxt[3] | &tetris_map_nxt[2] | &tetris_map_nxt[1] | &tetris_map_nxt[0])) begin
				score_valid <= 1;
			end else begin
				score_valid <= 0;
			end
		end else begin
			score_valid <= 0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		score_reg <= 0;
	end else begin
		if(turn_count == 15 & score_valid | fail) begin
			score_reg <= 0;
		end else begin
			score_reg <= score_reg + current_score;
		end
	end
end

assign tetris = (score_valid) ? {tetris_map[11],tetris_map[10],tetris_map[9],tetris_map[8],tetris_map[7],tetris_map[6],tetris_map[5],tetris_map[4],tetris_map[3],tetris_map[2],tetris_map[1],tetris_map[0]} : 0;
assign score = (score_valid) ? score_reg : 0;
assign tetris_valid = score_valid;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fail <= 0;
	end else begin
		fail <= fail_nxt;
	end
end

always @(*) begin
	fail_nxt = 0;
	if(tetris_map_nxt[13] != 0 | tetris_map_nxt[12] != 0) begin
		fail_nxt = 1;
	end
end
//---------------------------------------------------------------------
// IN_VALID REG
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		in_valid_reg0 <= 0;
	end else begin
		if(in_valid) begin
			in_valid_reg0 <= 1;
		end
		if(~(&tetris_map_nxt[10] | &tetris_map_nxt[9] | &tetris_map_nxt[8] | &tetris_map_nxt[7] | &tetris_map_nxt[6] | &tetris_map_nxt[5] | &tetris_map_nxt[4] | &tetris_map_nxt[3] | &tetris_map_nxt[2] | &tetris_map_nxt[1] | &tetris_map_nxt[0])) begin
			in_valid_reg0 <= 0;
		end
	end
end
//---------------------------------------------------------------------
// TETRIS MAP
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		tetris_map[0] <= 0; tetris_map[1] <= 0; tetris_map[2] <= 0; tetris_map[3] <= 0; tetris_map[4] <= 0; tetris_map[5] <= 0; 
		tetris_map[6] <= 0; tetris_map[7] <= 0; tetris_map[8] <= 0; tetris_map[9] <= 0; tetris_map[10] <= 0; tetris_map[11] <= 0;
	end else begin
		tetris_map[0] <= tetris_map_nxt[0]; tetris_map[1] <= tetris_map_nxt[1]; tetris_map[2] <= tetris_map_nxt[2]; 
		tetris_map[3] <= tetris_map_nxt[3]; tetris_map[4] <= tetris_map_nxt[4]; tetris_map[5] <= tetris_map_nxt[5];
		tetris_map[6] <= tetris_map_nxt[6]; tetris_map[7] <= tetris_map_nxt[7]; tetris_map[8] <= tetris_map_nxt[8]; 
		tetris_map[9] <= tetris_map_nxt[9]; tetris_map[10] <= tetris_map_nxt[10]; tetris_map[11] <= tetris_map_nxt[11];
	end
end

always @(*) begin
	tetris_map_nxt[13] = 0; tetris_map_nxt[12] = 0;
	tetris_map_nxt[11] = tetris_map[11]; tetris_map_nxt[10] = tetris_map[10]; tetris_map_nxt[9] = tetris_map[9]; tetris_map_nxt[8] = tetris_map[8];
	tetris_map_nxt[7] = tetris_map[7]; tetris_map_nxt[6] = tetris_map[6]; tetris_map_nxt[5] = tetris_map[5]; tetris_map_nxt[4] = tetris_map[4];
	tetris_map_nxt[3] = tetris_map[3]; tetris_map_nxt[2] = tetris_map[2]; tetris_map_nxt[1] = tetris_map[1]; tetris_map_nxt[0] = tetris_map[0];
	floor_ref = 0;
	floor_tmp0 = 0;
	floor_tmp1 = 0;
	current_score = 0;
	if(in_valid) begin
		case (tetrominoes)
		0: begin
			floor_ref = floor[position] > floor[position+1] ? floor[position] : floor[position+1];
			tetris_map_nxt[floor_ref][position] = 1;
			tetris_map_nxt[floor_ref][position+1] = 1;
			tetris_map_nxt[floor_ref+1][position] = 1;
			tetris_map_nxt[floor_ref+1][position+1] = 1;
		end
		1: begin
			floor_ref = floor[position];
			tetris_map_nxt[floor_ref][position] = 1;
			tetris_map_nxt[floor_ref+1][position] = 1;
			tetris_map_nxt[floor_ref+2][position] = 1;
			if(floor[position] < 11)
				tetris_map_nxt[floor_ref+3][position] = 1;
		end
		2: begin
			floor_tmp0 = floor[position] > floor[position+3] ? floor[position] : floor[position+3];
			floor_tmp1 = floor[position+1] > floor[position+2] ? floor[position+1] : floor[position+2];
			floor_ref = floor_tmp0 > floor_tmp1 ? floor_tmp0 : floor_tmp1;
			tetris_map_nxt[floor_ref][position] = 1;
			tetris_map_nxt[floor_ref][position+1] = 1;
			tetris_map_nxt[floor_ref][position+2] = 1;
			tetris_map_nxt[floor_ref][position+3] = 1;
		end
		3: begin
			floor_ref = floor[position] >= floor[position+1] + 2 ? floor[position] - 2 : floor[position+1];
			tetris_map_nxt[floor_ref][position+1] = 1;
			tetris_map_nxt[floor_ref+1][position+1] = 1;
			tetris_map_nxt[floor_ref+2][position] = 1;
			tetris_map_nxt[floor_ref+2][position+1] = 1;
		end
		4: begin
			floor_tmp1 = floor[position+1] > floor[position+2] ? floor[position+1] : floor[position+2];
			floor_ref =  floor[position] >= floor_tmp1 ? floor[position] : floor_tmp1 - 1;
			tetris_map_nxt[floor_ref][position] = 1;
			tetris_map_nxt[floor_ref+1][position] = 1;
			tetris_map_nxt[floor_ref+1][position+1] = 1;
			tetris_map_nxt[floor_ref+1][position+2] = 1;
		end
		5: begin
			floor_ref = floor[position] > floor[position+1] ? floor[position] : floor[position+1];
			tetris_map_nxt[floor_ref][position] = 1;
			tetris_map_nxt[floor_ref][position+1] = 1;
			tetris_map_nxt[floor_ref+1][position] = 1;
			tetris_map_nxt[floor_ref+2][position] = 1;
		end
		6: begin
			floor_ref = floor[position+1] >= floor[position] ? floor[position+1] : floor[position] - 1;
			tetris_map_nxt[floor_ref][position+1] = 1;
			tetris_map_nxt[floor_ref+1][position] = 1;
			tetris_map_nxt[floor_ref+1][position+1] = 1;
			tetris_map_nxt[floor_ref+2][position] = 1;
		end
		7: begin
			floor_tmp0 = floor[position] > floor[position+1] ? floor[position] : floor[position+1];
			floor_ref = floor_tmp0 >= floor[position+2] ? floor_tmp0 : floor[position+2] - 1;
			tetris_map_nxt[floor_ref][position] = 1;
			tetris_map_nxt[floor_ref][position+1] = 1;
			tetris_map_nxt[floor_ref+1][position+1] = 1;
			tetris_map_nxt[floor_ref+1][position+2] = 1;
		end
		endcase
		if(&(tetris_map_nxt[11])) begin
			current_score = 1;
			tetris_map_nxt [11] = tetris_map_nxt [12];
			tetris_map_nxt[12] = tetris_map_nxt [13];
		end else if(&(tetris_map_nxt[10])) begin
			current_score = 1;
			tetris_map_nxt[10] = tetris_map_nxt[11];
			tetris_map_nxt[11] = tetris_map_nxt[12];
			tetris_map_nxt [12] = 0;
		end
	end else if(in_valid_reg0) begin
		if(&(tetris_map[10])) begin
			current_score = 1;
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[9])) begin
			current_score = 1;
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[8])) begin
			current_score = 1;
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[7])) begin
			current_score = 1;
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[6])) begin
			current_score = 1;
			tetris_map_nxt[6] = tetris_map[7];
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[5])) begin
			current_score = 1;
			tetris_map_nxt[5] = tetris_map[6];
			tetris_map_nxt[6] = tetris_map[7];
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[4])) begin
			current_score = 1;
			tetris_map_nxt[4] = tetris_map[5];
			tetris_map_nxt[5] = tetris_map[6];
			tetris_map_nxt[6] = tetris_map[7];
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[3])) begin
			current_score = 1;
			tetris_map_nxt[3] = tetris_map[4];
			tetris_map_nxt[4] = tetris_map[5];
			tetris_map_nxt[5] = tetris_map[6];
			tetris_map_nxt[6] = tetris_map[7];
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[2])) begin
			current_score = 1;
			tetris_map_nxt[2] = tetris_map[3];
			tetris_map_nxt[3] = tetris_map[4];
			tetris_map_nxt[4] = tetris_map[5];
			tetris_map_nxt[5] = tetris_map[6];
			tetris_map_nxt[6] = tetris_map[7];
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[1])) begin
			current_score = 1;
			tetris_map_nxt[1] = tetris_map[2];
			tetris_map_nxt[2] = tetris_map[3];
			tetris_map_nxt[3] = tetris_map[4];
			tetris_map_nxt[4] = tetris_map[5];
			tetris_map_nxt[5] = tetris_map[6];
			tetris_map_nxt[6] = tetris_map[7];
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end else if(&(tetris_map[0])) begin
			current_score = 1;
			tetris_map_nxt[0] = tetris_map[1];
			tetris_map_nxt[1] = tetris_map[2];
			tetris_map_nxt[2] = tetris_map[3];
			tetris_map_nxt[3] = tetris_map[4];
			tetris_map_nxt[4] = tetris_map[5];
			tetris_map_nxt[5] = tetris_map[6];
			tetris_map_nxt[6] = tetris_map[7];
			tetris_map_nxt[7] = tetris_map[8];
			tetris_map_nxt[8] = tetris_map[9];
			tetris_map_nxt[9] = tetris_map[10];
			tetris_map_nxt[10] = tetris_map[11];
			tetris_map_nxt[11] = 0;
		end
	end
	if(turn_count == 15 & score_valid | fail) begin
		tetris_map_nxt[13] = 0; tetris_map_nxt[12] = 0; 
		tetris_map_nxt[11] = 0; tetris_map_nxt[10] = 0; tetris_map_nxt[9] = 0; tetris_map_nxt[8] = 0; tetris_map_nxt[7] = 0; tetris_map_nxt[6] = 0; 
		tetris_map_nxt[5] = 0; tetris_map_nxt[4] = 0; tetris_map_nxt[3] = 0; tetris_map_nxt[2] = 0; tetris_map_nxt[1] = 0; tetris_map_nxt[0] = 0;
	end
end

endmodule

module FIND_FLOOR(
	input [11:0] column,
	output reg [3:0] floor
);
always @(*) begin
	casez(column)
	12'b1???_????_????: floor = 12;
	12'b01??_????_????: floor = 11;
	12'b001?_????_????: floor = 10;
	12'b0001_????_????: floor = 9;
	12'b0000_1???_????: floor = 8;
	12'b0000_01??_????: floor = 7;
	12'b0000_001?_????: floor = 6;
	12'b0000_0001_????: floor = 5;
	12'b0000_0000_1???: floor = 4;
	12'b0000_0000_01??: floor = 3;
	12'b0000_0000_001?: floor = 2;
	12'b0000_0000_0001: floor = 1;
	default: 			floor = 0;		
	endcase
end
endmodule