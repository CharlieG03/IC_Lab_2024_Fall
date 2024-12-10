/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: PATTERN
// FILE NAME: PATTERN.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / PATTERN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

`define CYCLE_TIME 8.9

module PATTERN(
	//OUTPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//INPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output reg			rst_n, clk, in_valid;
output reg	[2:0]	tetrominoes;
output reg  [2:0]	position;
input 				tetris_valid, score_valid, fail;
input 		[3:0]	score;
input		[71:0]	tetris;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer lat, total_lat;
real CYCLE = `CYCLE_TIME;
integer PATNUM, patcount, patnum;	
integer in_f;
integer pn, pc, tpt, tpp;
integer input_gap;
integer col, col_score;
integer i, j, k;
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [71:0] golden_tetris;
reg [89:0] extra_tetris;
reg [3:0] golden_score;
reg [3:0] floor [0:5], floor_temp;
reg golden_fail;
reg done;
reg [2:0] in_tetrominoes[0:15];
reg [2:0] in_position[0:15];
//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
always	#(CYCLE / 2.0) clk = ~clk;

//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------
assign golden_tetris = extra_tetris[71:0];

initial begin
	reset_task;
	total_lat = 0;
	in_f = $fopen("../00_TESTBED/input.txt","r");
	pn = $fscanf(in_f, "%d", PATNUM);

	for(patcount = 0; patcount < PATNUM; patcount++) begin
     	input_task;
		$display("pass pattern %d", patcount);
 	end

  	PASS;
	$fclose(in_f);
	$finish;
end

task reset_task; begin
	rst_n = 1;
	done = 0;
	in_valid = 1'b0;
	tetrominoes = 'x;
	position = 'x;
	golden_fail = 0;
	golden_score = 0;
	extra_tetris = 0;
	
	force clk = 1'b0;
		#(CYCLE / 2.0);
	rst_n = 0;
		#(100);
	if(tetris_valid !== '0 || score_valid !== '0 || fail !== '0 || score !== '0 || tetris !== '0) begin
    release clk;
	rst_n = 1;
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    SPEC-4 FAIL                   ");
		$display("           The output signals must be 0 when the reset signal is low.           ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
		#(CYCLE * 9.0 / 10.0) rst_n = 1;
		#(CYCLE) release clk; 
		repeat(2) @(negedge clk);
end endtask

always @(*) begin
	if(golden_tetris[71])
		floor[5] = 12;
	else if(golden_tetris[65])
		floor[5] = 11;
	else if(golden_tetris[59])
		floor[5] = 10;
	else if(golden_tetris[53])
		floor[5] = 9;
	else if(golden_tetris[47])
		floor[5] = 8;
	else if(golden_tetris[41])
		floor[5] = 7;
	else if(golden_tetris[35])
		floor[5] = 6;
	else if(golden_tetris[29])
		floor[5] = 5;
	else if(golden_tetris[23])
		floor[5] = 4;
	else if(golden_tetris[17])
		floor[5] = 3;
	else if(golden_tetris[11])
		floor[5] = 2;
	else if(golden_tetris[5])
		floor[5] = 1;
	else
		floor[5] = 0;

	if(golden_tetris[70])
		floor[4] = 12;
	else if(golden_tetris[64])
		floor[4] = 11;
	else if(golden_tetris[58])
		floor[4] = 10;
	else if(golden_tetris[52])
		floor[4] = 9;
	else if(golden_tetris[46])
		floor[4] = 8;
	else if(golden_tetris[40])
		floor[4] = 7;
	else if(golden_tetris[34])
		floor[4] = 6;
	else if(golden_tetris[28])
		floor[4] = 5;
	else if(golden_tetris[22])
		floor[4] = 4;
	else if(golden_tetris[16])
		floor[4] = 3;
	else if(golden_tetris[10])
		floor[4] = 2;
	else if(golden_tetris[4])
		floor[4] = 1;
	else
		floor[4] = 0;

	if(golden_tetris[69])
		floor[3] = 12;
	else if(golden_tetris[63])
		floor[3] = 11;
	else if(golden_tetris[57])
		floor[3] = 10;
	else if(golden_tetris[51])
		floor[3] = 9;
	else if(golden_tetris[45])
		floor[3] = 8;
	else if(golden_tetris[39])
		floor[3] = 7;
	else if(golden_tetris[33])
		floor[3] = 6;
	else if(golden_tetris[27])
		floor[3] = 5;
	else if(golden_tetris[21])
		floor[3] = 4;
	else if(golden_tetris[15])
		floor[3] = 3;
	else if(golden_tetris[9])
		floor[3] = 2;
	else if(golden_tetris[3])
		floor[3] = 1;
	else
		floor[3] = 0;
	
	if(golden_tetris[68])
		floor[2] = 12;
	else if(golden_tetris[62])
		floor[2] = 11;
	else if(golden_tetris[56])
		floor[2] = 10;
	else if(golden_tetris[50])
		floor[2] = 9;
	else if(golden_tetris[44])
		floor[2] = 8;
	else if(golden_tetris[38])
		floor[2] = 7;
	else if(golden_tetris[32])
		floor[2] = 6;
	else if(golden_tetris[26])
		floor[2] = 5;
	else if(golden_tetris[20])
		floor[2] = 4;
	else if(golden_tetris[14])
		floor[2] = 3;
	else if(golden_tetris[8])
		floor[2] = 2;
	else if(golden_tetris[2])
		floor[2] = 1;
	else
		floor[2] = 0;
	
	if(golden_tetris[67])
		floor[1] = 12;
	else if(golden_tetris[61])
		floor[1] = 11;
	else if(golden_tetris[55])
		floor[1] = 10;
	else if(golden_tetris[49])
		floor[1] = 9;
	else if(golden_tetris[43])
		floor[1] = 8;
	else if(golden_tetris[37])
		floor[1] = 7;
	else if(golden_tetris[31])
		floor[1] = 6;
	else if(golden_tetris[25])
		floor[1] = 5;
	else if(golden_tetris[19])
		floor[1] = 4;
	else if(golden_tetris[13])
		floor[1] = 3;
	else if(golden_tetris[7])
		floor[1] = 2;
	else if(golden_tetris[1])
		floor[1] = 1;
	else
		floor[1] = 0;
	
	if(golden_tetris[66])
		floor[0] = 12;
	else if(golden_tetris[60])
		floor[0] = 11;
	else if(golden_tetris[54])
		floor[0] = 10;
	else if(golden_tetris[48])
		floor[0] = 9;
	else if(golden_tetris[42])
		floor[0] = 8;
	else if(golden_tetris[36])
		floor[0] = 7;
	else if(golden_tetris[30])
		floor[0] = 6;
	else if(golden_tetris[24])
		floor[0] = 5;
	else if(golden_tetris[18])
		floor[0] = 4;
	else if(golden_tetris[12])
		floor[0] = 3;
	else if(golden_tetris[6])
		floor[0] = 2;
	else if(golden_tetris[0])
		floor[0] = 1;
	else
		floor[0] = 0;
end

task input_task; begin
	golden_fail = 0;
	golden_score = 0;
	extra_tetris = 0;
	pc = $fscanf(in_f, "%d", patnum);
	for(k = 0; k < 16; k++) begin
		tpt = $fscanf(in_f, "%d %d", in_tetrominoes[k], in_position[k]);
	end
	for(i = 0; i < 16; i++) begin
		// $display("enter input %d", i);
		if(done) begin
			done = 0;
			i = 0;
			break;
		end
		// $display("finish terminate detect %d", i);
		input_gap = $urandom_range(4,1);
		repeat(input_gap) @(negedge clk);
		// $display("finish input_gap %d", i);
		in_valid = 1;
		tetrominoes = in_tetrominoes[i];
		position = in_position[i];
		golden_fail = 1;
		// $display("finish input %d", i);
		case(tetrominoes)
		0: begin
			floor_temp = floor[position] > floor[position + 1] ? floor[position] : floor[position + 1];
			for(col = floor_temp; col < 14; col = col + 1) begin
				if( extra_tetris[6 * col + position] === 0 & extra_tetris[6 * col + position + 1] === 0 & extra_tetris[6 * (col + 1) + position] === 0 & extra_tetris[6 * (col + 1) + position + 1] === 0) begin
					extra_tetris[6 * col + position] = 1;
					extra_tetris[6 * col + position + 1] = 1;
					extra_tetris[6 * (col + 1) + position] = 1;
					extra_tetris[6 * (col + 1) + position + 1] = 1;
					golden_fail = 0;
					break;
				end
			end
		end
		1: begin
			for(col = floor[position]; col < 12; col = col + 1) begin
				if( extra_tetris[6 * col + position] === 0 & extra_tetris[6 * (col + 1) + position] === 0 & extra_tetris[6 * (col + 2) + position] === 0 & extra_tetris[6 * (col + 3) + position] === 0) begin
					extra_tetris[6 * col + position] = 1;
					extra_tetris[6 * (col + 1) + position] = 1;
					extra_tetris[6 * (col + 2) + position] = 1;
					extra_tetris[6 * (col + 3) + position] = 1;
					golden_fail = 0;
					break;
				end
			end
		end
		2: begin
			if(floor[position] >= floor[position + 1] && floor[position] >= floor[position + 2] && floor[position] >= floor[position + 3]) begin
				floor_temp = floor[position];
			end else if(floor[position + 1] >= floor[position] && floor[position + 1] >= floor[position + 2] && floor[position + 1] >= floor[position + 3]) begin
				floor_temp = floor[position + 1];
			end else if(floor[position + 2] >= floor[position] && floor[position + 2] >= floor[position + 1] && floor[position + 2] >= floor[position + 3]) begin
				floor_temp = floor[position + 2];
			end else begin
				floor_temp = floor[position + 3];
			end
			for(col = floor_temp; col < 15; col = col + 1) begin
				if( extra_tetris[6 * col + position] === 0 & extra_tetris[6 * col + position + 1] === 0 & extra_tetris[6 * col + position + 2] === 0 & extra_tetris[6 * col + position + 3] === 0) begin
					extra_tetris[6 * col + position] = 1;
					extra_tetris[6 * col + position + 1] = 1;
					extra_tetris[6 * col + position + 2] = 1;
					extra_tetris[6 * col + position + 3] = 1;
					golden_fail = 0;
					break;
				end
			end
		end
		3: begin
			floor_temp = floor[position] > floor[position + 1] ? floor[position] >= 2 ? floor[position] - 2 : 0 : floor[position + 1];
			for(col = floor_temp; col < 13; col = col + 1) begin
				if(col >= 0) begin
					if( extra_tetris[6 * col + position + 1] === 0 & extra_tetris[6 * (col + 1) + position + 1] === 0 & extra_tetris[6 * (col + 2) + position + 1] === 0 & extra_tetris[6 * (col + 2) + position] === 0) begin
						extra_tetris[6 * col + position + 1] = 1;
						extra_tetris[6 * (col + 1) + position + 1] = 1;
						extra_tetris[6 * (col + 2) + position + 1] = 1;
						extra_tetris[6 * (col + 2) + position] = 1;
						golden_fail = 0;
						break;
					end
				end
			end
		end
		4: begin
			if(floor[position] >= floor[position + 1] && floor[position] >= floor[position + 2]) begin
				floor_temp = floor[position];
			end else if(floor[position + 1] >= floor[position] && floor[position + 1] >= floor[position + 2]) begin
				floor_temp = floor[position + 1] >= 1 ? floor[position + 1] - 1 : 0;
			end else begin
				floor_temp = floor[position + 2] >= 1 ? floor[position + 2] - 1 : 0;
			end
			for(col = floor_temp; col < 14; col = col + 1) begin
				if( extra_tetris[6 * col + position] === 0 & extra_tetris[6 * (col + 1) + position] === 0 & extra_tetris[6 * (col + 1) + position + 1] === 0 & extra_tetris[6 * (col + 1) + position + 2] === 0) begin
					extra_tetris[6 * col + position] = 1;
					extra_tetris[6 * (col + 1) + position] = 1;
					extra_tetris[6 * (col + 1) + position + 1] = 1;
					extra_tetris[6 * (col + 1) + position + 2] = 1;
					golden_fail = 0;
					break;
				end
			end
		end
		5: begin
			floor_temp = floor[position] > floor[position + 1] ? floor[position] : floor[position + 1];
			for(col = floor_temp; col < 13; col = col + 1) begin
				if( extra_tetris[6 * col + position] === 0 & extra_tetris[6 * col + position + 1] === 0 & extra_tetris[6 * (col + 1) + position] === 0 & extra_tetris[6 * (col + 2) + position] === 0) begin
					extra_tetris[6 * col + position] = 1;
					extra_tetris[6 * col + position + 1] = 1;
					extra_tetris[6 * (col + 1) + position] = 1;
					extra_tetris[6 * (col + 2) + position] = 1;
					golden_fail = 0;
					break;
				end
			end
		end
		6: begin
			floor_temp = floor[position] > floor[position + 1] ? floor[position] >= 1 ? floor[position] - 1 : 0 : floor[position + 1];
			for(col = floor_temp - 1; col < 13; col = col + 1) begin
				if(col >= 0) begin
					if( extra_tetris[6 * col + position + 1] === 0 & extra_tetris[6 * (col + 1) + position] === 0 & extra_tetris[6 * (col + 1) + position + 1] === 0 & extra_tetris[6 * (col + 2) + position] === 0) begin
						extra_tetris[6 * col + position + 1] = 1;
						extra_tetris[6 * (col + 1) + position] = 1;
						extra_tetris[6 * (col + 1) + position + 1] = 1;
						extra_tetris[6 * (col + 2) + position] = 1;
						golden_fail = 0;
						break;
					end
				end
			end
		end
		7: begin
			if(floor[position] >= floor[position + 1] && floor[position] >= floor[position + 2]) begin
				floor_temp = floor[position];
			end else if(floor[position + 1] >= floor[position] && floor[position + 1] >= floor[position + 2]) begin
				floor_temp = floor[position + 1];
			end else begin
				floor_temp = floor[position + 2] >= 1 ? floor[position + 2] - 1 : 0;
			end
			for(col = floor_temp; col < 14; col = col + 1) begin
				if( extra_tetris[6 * col + position] === 0 & extra_tetris[6 * col + position + 1] === 0 & extra_tetris[6 * (col + 1) + position + 1] === 0 & extra_tetris[6 * (col + 1) + position + 2] === 0) begin
					extra_tetris[6 * col + position] = 1;
					extra_tetris[6 * col + position + 1] = 1;
					extra_tetris[6 * (col + 1) + position + 1] = 1;
					extra_tetris[6 * (col + 1) + position + 2] = 1;
					golden_fail = 0;
					break;
				end
			end
		end
		endcase
		for(col = 0; col < 12; col = col + 1) begin
			if(extra_tetris[(col * 6 + 5)] === 1 & extra_tetris[(col * 6 + 4)] === 1 & extra_tetris[(col * 6 + 3)] === 1 & extra_tetris[(col * 6 + 2)] === 1 & extra_tetris[(col * 6 + 1)] === 1 & extra_tetris[(col * 6)] === 1) begin
				col_score = col;
				golden_score = golden_score + 1;
				update_after_score;
				col = col - 1;
			end
		end
		// $display("finish update_golden %d", i);
		@(negedge clk);
		// $display("new negedge %d", i);
		in_valid = 0;
		tetrominoes = 'x;
		position = 'x;
		// $display("pass input %d", i);
		
		check_tetris;
		// $display("pass check_tetris %d", i);

		wait_score_valid;
		// $display("pass wait_score_valid %d", i);
		check_ans;
		// $display("pass check_ans %d", i);
		check_out_zero;
		// $display("pass check_out_zero %d", i);
	end
end endtask

task update_after_score; begin
	for(j = col_score; j < 13; j = j + 1) begin
		extra_tetris[(j * 6 + 5)] = extra_tetris[((j + 1) * 6 + 5)];
		extra_tetris[(j * 6 + 4)] = extra_tetris[((j + 1) * 6 + 4)];
		extra_tetris[(j * 6 + 3)] = extra_tetris[((j + 1) * 6 + 3)];
		extra_tetris[(j * 6 + 2)] = extra_tetris[((j + 1) * 6 + 2)];
		extra_tetris[(j * 6 + 1)] = extra_tetris[((j + 1) * 6 + 1)];
		extra_tetris[(j * 6)] = extra_tetris[((j + 1) * 6)];
	end
end endtask

always @(negedge clk) begin
	if(score_valid === 0)begin
		if(score !== 0) begin
			FAIL;
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display("                    SPEC-5 FAIL                   ");
			$display("           Score, fail, and tetris_valid must be 0 when the score_valid is low.           ");
			$display ("			score = %d, fail = %d, tetris_valid = %d", score, fail, tetris_valid);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2) @(negedge clk);
			$finish;
		end
		if(tetris_valid !== 0) begin
			FAIL;
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display("                    SPEC-5 FAIL                   ");
			$display("           Score, fail, and tetris_valid must be 0 when the score_valid is low.           ");
			$display ("			score = %d, fail = %d, tetris_valid = %d", score, fail, tetris_valid);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2) @(negedge clk);
			$finish;
		end
		if(fail !== 0) begin
			FAIL;
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display("                    SPEC-5 FAIL                   ");
			$display("           Score, fail, and tetris_valid must be 0 when the score_valid is low.           ");
			$display ("			score = %d, fail = %d, tetris_valid = %d", score, fail, tetris_valid);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2) @(negedge clk);
			$finish;
		end
	end
end

task wait_score_valid; begin
    lat = 1;
    while(score_valid !== 1) begin
        lat = lat + 1;
        if(lat == 1000) begin
            FAIL;
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display("                    SPEC-6 FAIL                   ");
			$display("           The score_valid signal should be high after 1000 cycles.           ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(2)@(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_lat = total_lat + lat;
end endtask

task check_tetris; begin
	if(extra_tetris[89:72] !== 0) begin
		golden_fail = 1;
	end
end endtask

task check_ans; begin
	if(golden_fail == 1 && i !== 15) done = 1;
	if(golden_fail !== fail) begin
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    SPEC-7 FAIL                   ");
		$display("           golden_fail = %d, your output = %d", golden_fail, fail);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("               current piece : (%1d,%1d)", in_tetrominoes[i], in_position[i]);
		$display("        your score = %2d, golden score = %2d", score, golden_score);
		$display("        your fail  =  %1b, golden fail  =  %1b", fail, golden_fail);
		$display("==================================================");
		$display("           your tetris  |  golden tetris          ");
		$display("                        |                         ");
		for(i = 11; i >= 0; i = i - 1) begin
		$write("          ");
		for(j = 0; j < 6; j = j + 1) begin
			if(tetris[i * 6 + j] === 1'b1) begin
			$write("■ ");
			end else begin
			$write("□ ");
			end
		end
		$write("  |   ");
		for(j = 0; j < 6; j = j + 1) begin
			if(golden_tetris[6*i+j] === 1'b1) begin
			$write("■ ");
			end else begin
			$write("□ ");
			end
		end
		$display("");
		end
		$display("                        |                         ");
		$display("--------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
	if(golden_score !== score) begin
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    SPEC-7 FAIL                   ");
		$display("           golden_score = %d, your output = %d", golden_score, score);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("               current piece : (%1d,%1d)", in_tetrominoes[i], in_position[i]);
		$display("        your score = %2d, golden score = %2d", score, golden_score);
		$display("        your fail  =  %1b, golden fail  =  %1b", fail, golden_fail);
		$display("==================================================");
		$display("           your tetris  |  golden tetris          ");
		$display("                        |                         ");
		for(i = 11; i >= 0; i = i - 1) begin
		$write("          ");
		for(j = 0; j < 6; j = j + 1) begin
			if(tetris[i * 6 + j] === 1'b1) begin
			$write("■ ");
			end else begin
			$write("□ ");
			end
		end
		$write("  |   ");
		for(j = 0; j < 6; j = j + 1) begin
			if(golden_tetris[6*i+j] === 1'b1) begin
			$write("■ ");
			end else begin
			$write("□ ");
			end
		end
		$display("");
		end
		$display("                        |                         ");
		$display("--------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
	if(tetris !== 0 & tetris_valid === 0) begin
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    SPEC-5 FAIL                   ");
		$display("           Tetris must be reset when tetris_valid is low.           ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
	if(golden_tetris !== tetris & tetris_valid) begin
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    SPEC-7 FAIL                   ");
		$display("           golden_tetris = %d, your output = %d", golden_tetris, tetris);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("               current piece : (%1d,%1d)", in_tetrominoes[i], in_position[i]);
		$display("        your score = %2d, golden score = %2d", score, golden_score);
		$display("        your fail  =  %1b, golden fail  =  %1b", fail, golden_fail);
		$display("==================================================");
		$display("           your tetris  |  golden tetris          ");
		$display("                        |                         ");
		for(i = 11; i >= 0; i = i - 1) begin
		$write("          ");
		for(j = 0; j < 6; j = j + 1) begin
			if(tetris[i * 6 + j] === 1'b1) begin
			$write("■ ");
			end else begin
			$write("□ ");
			end
		end
		$write("  |   ");
		for(j = 0; j < 6; j = j + 1) begin
			if(golden_tetris[6*i+j] === 1'b1) begin
			$write("■ ");
			end else begin
			$write("□ ");
			end
		end
		$display("");
		end
		$display("                        |                         ");
		$display("--------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
	if(i == 15 & tetris_valid !== 1) begin
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    FAIL                   ");
		$display("       You should output tetris_valid = 1 when the last tetromino is inputted.           ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
	if(golden_fail === 1 & tetris_valid !== 1) begin
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    FAIL                   ");
		$display("       You should output tetris_valid = 1 when the game is over early.           ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
	@(negedge clk);
end endtask

task check_out_zero; begin
	if(tetris_valid !== 0 | score_valid !== 0) begin
		FAIL;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display("                    SPEC-8 FAIL                   ");
		$display("           The score_valid and the tetris_valid cannot be high for more than 1 cycle.           ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2) @(negedge clk);
		$finish;
	end
end endtask

task FAIL; begin
$display("\033[38;2;252;238;238m                                                                                                                                           ");      
$display("\033[38;2;252;238;238m                                                                                                :L777777v7.                                ");
$display("\033[31m  i:..::::::i.      :::::         ::::    .:::.       \033[38;2;252;238;238m                                       .vYr::::::::i7Lvi                             ");
$display("\033[31m  BBBBBBBBBBBi     iBBBBBL       .BBBB    7BBB7       \033[38;2;252;238;238m                                      JL..\033[38;2;252;172;172m:r777v777i::\033[38;2;252;238;238m.ijL                           ");
$display("\033[31m  BBBB.::::ir.     BBB:BBB.      .BBBv    iBBB:       \033[38;2;252;238;238m                                    :K: \033[38;2;252;172;172miv777rrrrr777v7:.\033[38;2;252;238;238m:J7                         ");
$display("\033[31m  BBBQ            :BBY iBB7       BBB7    :BBB:       \033[38;2;252;238;238m                                   :d \033[38;2;252;172;172m.L7rrrrrrrrrrrrr77v: \033[38;2;252;238;238miI.                       ");
$display("\033[31m  BBBB            BBB. .BBB.      BBB7    :BBB:       \033[38;2;252;238;238m                                  .B \033[38;2;252;172;172m.L7rrrrrrrrrrrrrrrrr7v..\033[38;2;252;238;238mBr                      ");
$display("\033[31m  BBBB:r7vvj:    :BBB   gBBs      BBB7    :BBB:       \033[38;2;252;238;238m                                  S:\033[38;2;252;172;172m v7rrrrrrrrrrrrrrrrrrr7v. \033[38;2;252;238;238mB:                     ");
$display("\033[31m  BBBBBBBBBB7    BBB:   .BBB.     BBB7    :BBB:       \033[38;2;252;238;238m                                 .D \033[38;2;252;172;172mi7rrrrrrr777rrrrrrrrrrr7v. \033[38;2;252;238;238mB.                    ");
$display("\033[31m  BBBB    ..    iBBBBBBBBBBBP     BBB7    :BBB:       \033[38;2;252;238;238m                                 rv\033[38;2;252;172;172m v7rrrrrr7rirv7rrrrrrrrrr7v \033[38;2;252;238;238m:I                    ");
$display("\033[31m  BBBB          BBBBi7vviQBBB.    BBB7    :BBB.       \033[38;2;252;238;238m                                 2i\033[38;2;252;172;172m.v7rrrrrr7i  :v7rrrrrrrrrrvi \033[38;2;252;238;238mB:                   ");
$display("\033[31m  BBBB         rBBB.      BBBQ   .BBBv    iBBB2ir777L7\033[38;2;252;238;238m                                 2i.\033[38;2;252;172;172mv7rrrrrr7v \033[38;2;252;238;238m:..\033[38;2;252;172;172mv7rrrrrrrrr77 \033[38;2;252;238;238mrX                   ");
$display("\033[31m .BBBB        :BBBB       BBBB7  .BBBB    7BBBBBBBBBBB\033[38;2;252;238;238m                                 Yv \033[38;2;252;172;172mv7rrrrrrrv.\033[38;2;252;238;238m.B \033[38;2;252;172;172m.vrrrrrrrrrrL.\033[38;2;252;238;238m:5                   ");
$display("\033[31m  . ..        ....         ...:   ....    ..   .......\033[38;2;252;238;238m                                 .q \033[38;2;252;172;172mr7rrrrrrr7i \033[38;2;252;238;238mPv \033[38;2;252;172;172mi7rrrrrrrrrv.\033[38;2;252;238;238m:S                   ");
$display("\033[38;2;252;238;238m                                                                                        Lr \033[38;2;252;172;172m77rrrrrr77 \033[38;2;252;238;238m:B. \033[38;2;252;172;172mv7rrrrrrrrv.\033[38;2;252;238;238m:S                   ");
$display("\033[38;2;252;238;238m                                                                                         B: \033[38;2;252;172;172m7v7rrrrrv. \033[38;2;252;238;238mBY \033[38;2;252;172;172mi7rrrrrrr7v \033[38;2;252;238;238miK                   ");
$display("\033[38;2;252;238;238m                                                                              .::rriii7rir7. \033[38;2;252;172;172m.r77777vi \033[38;2;252;238;238m7B  \033[38;2;252;172;172mvrrrrrrr7r \033[38;2;252;238;238m2r                   ");
$display("\033[38;2;252;238;238m                                                                       .:rr7rri::......    .     \033[38;2;252;172;172m.:i7s \033[38;2;252;238;238m.B. \033[38;2;252;172;172mv7rrrrr7L..\033[38;2;252;238;238mB                    ");
$display("\033[38;2;252;238;238m                                                        .::7L7rriiiirr77rrrrrrrr72BBBBBBBBBBBBvi:..  \033[38;2;252;172;172m.  \033[38;2;252;238;238mBr \033[38;2;252;172;172m77rrrrrvi \033[38;2;252;238;238mKi                    ");
$display("\033[38;2;252;238;238m                                                    :rv7i::...........    .:i7BBBBQbPPPqPPPdEZQBBBBBr:.\033[38;2;252;238;238m ii \033[38;2;252;172;172mvvrrrrvr \033[38;2;252;238;238mvs                     ");
$display("\033[38;2;252;238;238m                    .S77L.                      .rvi:. ..:r7QBBBBBBBBBBBgri.    .:BBBPqqKKqqqqPPPPPEQBBBZi  \033[38;2;252;172;172m:777vi \033[38;2;252;238;238mvI                      ");
$display("\033[38;2;252;238;238m                    B: ..Jv                   isi. .:rBBBBBQZPPPPqqqPPdERBBBBBi.    :BBRKqqqqqqqqqqqqPKDDBB:  \033[38;2;252;172;172m:7. \033[38;2;252;238;238mJr                       ");
$display("\033[38;2;252;238;238m                   vv SB: iu                rL: .iBBBQEPqqPPqqqqqqqqqqqqqPPPPbQBBB:   .EBQKqqqqqqPPPqqKqPPgBB:  .B:                        ");
$display("\033[38;2;252;238;238m                  :R  BgBL..s7            rU: .qBBEKPqqqqqqqqqqqqqqqqqqqqqqqqqPPPEBBB:   EBEPPPEgQBBQEPqqqqKEBB: .s                        ");
$display("\033[38;2;252;238;238m               .U7.  iBZBBBi :ji         5r .MBQqPqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPKgBB:  .BBBBBdJrrSBBQKqqqqKZB7  I:                      ");
$display("\033[38;2;252;238;238m              v2. :rBBBB: .BB:.ru7:    :5. rBQqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPPBB:  :.        .5BKqqqqqqBB. Kr                     ");
$display("\033[38;2;252;238;238m             .B .BBQBB.   .RBBr  :L77ri2  BBqPqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPbBB   \033[38;2;252;172;172m.irrrrri  \033[38;2;252;238;238mQQqqqqqqKRB. 2i                    ");
$display("\033[38;2;252;238;238m              27 :BBU  rBBBdB \033[38;2;252;172;172m iri::::: \033[38;2;252;238;238m.BQKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqKRBs\033[38;2;252;172;172mirrr7777L: \033[38;2;252;238;238m7BqqqqqqqXZB. BLv772i              ");
$display("\033[38;2;252;238;238m               rY  PK  .:dPMB \033[38;2;252;172;172m.Y77777r.\033[38;2;252;238;238m:BEqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPPBqi\033[38;2;252;172;172mirrrrrv: \033[38;2;252;238;238muBqqqqqqqqqgB  :.:. B:             ");
$display("\033[38;2;252;238;238m                iu 7BBi  rMgB \033[38;2;252;172;172m.vrrrrri\033[38;2;252;238;238mrBEqKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPQgi\033[38;2;252;172;172mirrrrv. \033[38;2;252;238;238mQQqqqqqqqqqXBb .BBB .s:.           ");
$display("\033[38;2;252;238;238m                i7 BBdBBBPqbB \033[38;2;252;172;172m.vrrrri\033[38;2;252;238;238miDgPPbPqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPQDi\033[38;2;252;172;172mirr77 \033[38;2;252;238;238m:BdqqqqqqqqqqPB. rBB. .:iu7         ");
$display("\033[38;2;252;238;238m                iX.:iBRKPqKXB.\033[38;2;252;172;172m 77rrr\033[38;2;252;238;238mi7QPBBBBPqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPB7i\033[38;2;252;172;172mrr7r \033[38;2;252;238;238m.vBBPPqqqqqqKqBZ  BPBgri: 1B        ");
$display("\033[38;2;252;238;238m                 ivr .BBqqKXBi \033[38;2;252;172;172mr7rri\033[38;2;252;238;238miQgQi   QZKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPEQi\033[38;2;252;172;172mirr7r.  \033[38;2;252;238;238miBBqPqqqqqqPB:.QPPRBBB LK        ");
$display("\033[38;2;252;238;238m                   :I. iBgqgBZ \033[38;2;252;172;172m:7rr\033[38;2;252;238;238miJQPB.   gRqqqqqqqqPPPPPPPPqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqPQ7\033[38;2;252;172;172mirrr7vr.  \033[38;2;252;238;238mUBqqPPgBBQPBBKqqqKB  B         ");
$display("\033[38;2;252;238;238m                     v7 .BBR: \033[38;2;252;172;172m.r7ri\033[38;2;252;238;238miggqPBrrBBBBBBBBBBBBBBBBBBQEPPqqPPPqqqqqqqqqqqqqqqqqqqqqqqqqPgPi\033[38;2;252;172;172mirrrr7v7  \033[38;2;252;238;238mrBPBBP:.LBbPqqqqqB. u.        ");
$display("\033[38;2;252;238;238m                      .j. . \033[38;2;252;172;172m :77rr\033[38;2;252;238;238miiBPqPbBB::::::.....:::iirrSBBBBBBBQZPPPPPqqqqqqqqqqqqqqqqqqqqEQi\033[38;2;252;172;172mirrrrrr7v \033[38;2;252;238;238m.BB:     :BPqqqqqDB .B        ");
$display("\033[38;2;252;238;238m                       YL \033[38;2;252;172;172m.i77rrrr\033[38;2;252;238;238miLQPqqKQJ. \033[38;2;252;172;172m ............       \033[38;2;252;238;238m..:irBBBBBBZPPPqqqqqqqPPBBEPqqqdRr\033[38;2;252;172;172mirrrrrr7v \033[38;2;252;238;238m.B  .iBB  dQPqqqqPBi Y:       ");
$display("\033[38;2;252;238;238m                     :U:.\033[38;2;252;172;172mrv7rrrrri\033[38;2;252;238;238miPgqqqqKZB.\033[38;2;252;172;172m.v77777777777777ri::..   \033[38;2;252;238;238m  ..:rBBBBQPPqqqqPBUvBEqqqPRr\033[38;2;252;172;172mirrrrrrvi\033[38;2;252;238;238m iB:RBBbB7 :BQqPqKqBR r7       ");
$display("\033[38;2;252;238;238m                    iI.\033[38;2;252;172;172m.v7rrrrrrri\033[38;2;252;238;238midgqqqqqKB:\033[38;2;252;172;172m 77rrrrrrrrrrrrr77777777ri:..   \033[38;2;252;238;238m .:1BBBEPPB:   BbqqPQr\033[38;2;252;172;172mirrrr7vr\033[38;2;252;238;238m .BBBZPqqDB  .JBbqKPBi vi       ");
$display("\033[38;2;252;238;238m                   :B \033[38;2;252;172;172miL7rrrrrrrri\033[38;2;252;238;238mibgqqqqqqBr\033[38;2;252;172;172m r7rrrrrrrrrrrrrrrrrrrrr777777ri:.  \033[38;2;252;238;238m .iBBBBi  .BbqqdRr\033[38;2;252;172;172mirr7v7: \033[38;2;252;238;238m.Bi.dBBPqqgB:  :BPqgB  B        ");
$display("\033[38;2;252;238;238m                   .K.i\033[38;2;252;172;172mv7rrrrrrrri\033[38;2;252;238;238miZgqqqqqqEB \033[38;2;252;172;172m.vrrrrrrrrrrrrrrrrrrrrrrrrrrr777vv7i.  \033[38;2;252;238;238m :PBBBBPqqqEQ\033[38;2;252;172;172miir77:  \033[38;2;252;238;238m:BB:  .rBPqqEBB. iBZB. Rr        ");
$display("\033[38;2;252;238;238m                    iM.:\033[38;2;252;172;172mv7rrrrrrrri\033[38;2;252;238;238mUQPqqqqqPBi\033[38;2;252;172;172m i7rrrrrrrrrrrrrrrrrrrrrrrrr77777i.   \033[38;2;252;238;238m.  :BddPqqqqEg\033[38;2;252;172;172miir7. \033[38;2;252;238;238mrBBPqBBP. :BXKqgB  BBB. 2r         ");
$display("\033[38;2;252;238;238m                     :U:.\033[38;2;252;172;172miv77rrrrri\033[38;2;252;238;238mrBPqqqqqqPB: \033[38;2;252;172;172m:7777rrrrrrrrrrrrrrr777777ri.   \033[38;2;252;238;238m.:uBBBBZPqqqqqqPQL\033[38;2;252;172;172mirr77 \033[38;2;252;238;238m.BZqqPB:  qMqqPB. Yv:  Ur          ");
$display("\033[38;2;252;238;238m                       1L:.\033[38;2;252;172;172m:77v77rii\033[38;2;252;238;238mqQPqqqqqPbBi \033[38;2;252;172;172m .ir777777777777777ri:..   \033[38;2;252;238;238m.:rBBBRPPPPPqqqqqqqgQ\033[38;2;252;172;172miirr7vr \033[38;2;252;238;238m:BqXQ: .BQPZBBq ...:vv.           ");
$display("\033[38;2;252;238;238m                         LJi..\033[38;2;252;172;172m::r7rii\033[38;2;252;238;238mRgKPPPPqPqBB:.  \033[38;2;252;172;172m ............     \033[38;2;252;238;238m..:rBBBBPPqqKKKKqqqPPqPbB1\033[38;2;252;172;172mrvvvvvr  \033[38;2;252;238;238mBEEDQBBBBBRri. 7JLi              ");
$display("\033[38;2;252;238;238m                           .jL\033[38;2;252;172;172m  777rrr\033[38;2;252;238;238mBBBBBBgEPPEBBBvri:::::::::irrrbBBBBBBDPPPPqqqqqqXPPZQBBBBr\033[38;2;252;172;172m.......\033[38;2;252;238;238m.:BBBBg1ri:....:rIr                 ");
$display("\033[38;2;252;238;238m                            vI \033[38;2;252;172;172m:irrr:....\033[38;2;252;238;238m:rrEBBBBBBBBBBBBBBBBBBBBBBBBBBBBBQQBBBBBBBBBBBBBQr\033[38;2;252;172;172mi:...:.   \033[38;2;252;238;238m.:ii:.. .:.:irri::                    ");
$display("\033[38;2;252;238;238m                             71vi\033[38;2;252;172;172m:::irrr::....\033[38;2;252;238;238m    ...:..::::irrr7777777777777rrii::....  ..::irvrr7sUJYv7777v7ii..                         ");
$display("\033[38;2;252;238;238m                               .i777i. ..:rrri77rriiiiiii:::::::...............:::iiirr7vrrr:.                                             ");
$display("\033[38;2;252;238;238m                                                      .::::::::::::::::::::::::::::::                                                      \033[m");

end endtask

task PASS; begin
$display ("                                                                                        \n");
$display ("                         ...-+=.              ...                       \033[32m      :BBQvi.                                             \033[0m");
$display ("                        .+/*-=-.           .-+##=.                      \033[32m     BBBBBBBBQi                                           \033[0m");
$display ("                      -#*-:..+.       .-**+=-::+:                       \033[32m    :BBBP :7BBBB.                                         \033[0m");
$display ("                   .:**-.....+     .=++-:......+.                       \033[32m    BBBB     BBBB                                         \033[0m");
$display ("                  .=#-......:+  .:++-.........:=     .:--====+++===-:.  \033[32m   iBBBv     BBBB       vBr                               \033[0m");
$display ("                 .+#........:+ .**:...........-- .:-**=:...........-#:  \033[32m   BBBBBKrirBBBB.     :BBBBBB:                            \033[0m");
$display ("                 +*..........#+#:.............=-+/-................*.   \033[32m  rBBBBBBBBBBBR.    .BBBM:BBB                             \033[0m");
$display ("               .-*...........*+...............-*:.................*.    \033[32m  BBBB   .::.      EBBBi :BBU                             \033[0m");
$display ("          .*+. .*:...........+...............::..................+.     \033[32m MBBBr           vBBBu   BBB.                             \033[0m");
$display ("          -++=.:+...........=:..................................-=      \033[32m i7PB          iBBBBB.  iBBB                              \033[0m");
$display ("  .::.   .*:.=*/-...............................................+.             \033[32m      vBBBBPBBBBPBBB7       .7QBB5i                \033[0m");
$display ("  :##=.. :*....+=:.............................................:#*+=:...       \033[32m     :RBBB.  .rBBBBB.      rBBBBBBBB7              \033[0m");
$display ("  =+.-#=.-+......:-............................................:....:-*#:      \033[32m                BBBB       BBBB  :BBBB             \033[0m");
$display ("  *=...-+#+.............................................................-+=.   \033[32m               rBBBr       BBBB    BBBU            \033[0m");
$display ("  *-......+...............................................................-*-. \033[32m               vBBB        .BBBB   :7i.            \033[0m");
$display ("  +=......--........................................:::.....................+=.\033[32m                     BBB7   iBBBg                  \033[0m");
$display ("  :*..............................:.......................................::-#.\033[32m                     dBBB.   5BBBr                 \033[0m");
$display ("   *:............................:.....................................-*+:.   \033[32m                      ZBBBr  EBBBv     YBBBBQi     \033[0m");
$display ("   .*:..............:............-............:....................:-**:..     \033[32m                       iBBBBBBBBD     BBBBBBBBB.   \033[0m");
$display ("    .==.............=..:.........=..........::........................-+=.     \033[32m                         :LBBBr      vBBBi  5BBB   \033[0m");
$display ("    :=#+==-.........=-:+=--------*:........-:...........................:=.    \033[32m                               ...   :BBB:   BBBu  \033[0m");
$display (" .:**-.........:-=*#/\033[30;30m@@@@@@@@@@@@@@@@\033[0m/#*+=--:.............................=:  \033[32m                                ...   :BBB:   BBBu  \033[0m");
$display (" .##++++*+=:=#\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m/*=::.........................+. \033[32m                               .BBBi   BBBB   iMBu  \033[0m");
$display ("  ..    .../\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m/*:......................:* \033[32m                                BBBX   :BBBr        \033[0m");
$display ("          .\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m/*-..........:*:::::::-- \033[32m                                .BBBv  :BBBQ        \033[0m");
$display ("          -\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m/+:........*.         \033[32m                                 .BBBBBBBBB:        \033[0m");
$display ("          -\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m*==-....*.         \033[32m                                   rBBBBB1.         \033[0m");
$display ("          :\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m:  -*-.:+                      ");
$display ("          ./\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m*.    =##.                      ");
$display ("         .+/\033[30;30m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m#-     ..                       ");
$display ("         =*=*=+*#/\033[30;30m@@@@\033[0m//##*+++++*/\033[30;30m@@@@@@@@@@@@@@@@@@\033[0m/*+=--=+*.                            ");
$display ("         =*++::::-------:::-----:--=+##/\033[30;30m@@@@@\033[0m//#*+=-:::-==-:=*.                           ");
$display ("         .#*+:::::::::::::-#++***+-::::-------::::::::-*=++:-#.                           ");
$display ("          .#+-::::::::::::=+\033[30;31m::::\033[0m-*-:::::::::::::::::::-*-=*--#.                           ");
$display ("           .*=::::::::::::-*\033[30;31m::::\033[0m#-:::::::::::::::::::=###+--*-.                           ");
$display ("            .-*+-::::::::::+=\033[30;31m::\033[0m*=:::::::::::::::::-=-::::-=*-.                            ");
$display ("              .-=++--::::::-+++=:::::::::::::--=+=---=====-.                              ");
$display ("                  .=++====-----:::::----===+++=:..                                        ");
$display ("                        .:=++********++=:..                                               ");
$display ("                                                                                          \n");
$display("                  Congratulations!               ");
$display("              execution cycles = %7d", total_lat);
$display("              clock period = %4fns", CYCLE);
$finish;	
end endtask

endmodule
// for spec check
// $display("                    SPEC-4 FAIL                   ");
// $display("                    SPEC-5 FAIL                   ");
// $display("                    SPEC-6 FAIL                   ");
// $display("                    SPEC-7 FAIL                   ");
// $display("                    SPEC-8 FAIL                   ");
// for successful design
// $display("                  Congratulations!               ");
// $display("              execution cycles = %7d", total_latency);
// $display("              clock period = %4fns", CYCLE);