// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"
`define PATNUM 100
`define SEED 8721
`define CYCLE_TIME 9
`define DEBUG 0

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE=1000;

integer temp;

integer exe_latency;
integer total_latency;

integer i_pat;

integer input_gap;

integer f;
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 32 box

Action input_action;
Formula_Type input_formula;
Mode input_mode;
Date input_date;
Data_No input_data_no;
Index input_index;

logic in_valid;

logic [10:0] threshold;
Index index_reg [3:0];
logic signed [12:0] IA, IB, IC, ID;
logic [11:0] sortedIA, sortedIB, sortedIC, sortedID;
logic [11:0] IVA, IVB, IVC, IVD;
logic [7:0] month, day;
logic exceed;
logic [11:0] result;
logic [11:0] GA, GB, GC, GD;
logic [13:0] sortedGA, sortedGB, sortedGC, sortedGD;
logic [11:0] s00, s01, s02, s03; logic [11:0] s11, s12;
logic [13:0] s20, s21, s22, s23; logic [13:0] s31, s32;

Warn_Msg golden_warn_msg;
logic golden_complete;
 
real CYCLE = `CYCLE_TIME;
//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_act;
    randc Action act_id;
	function new (int seed);
		this.srandom(seed);
	endfunction
    constraint range{
        act_id inside{Index_Check, Update, Check_Valid_Date};
    }
endclass
random_act random_act_inst = new(`SEED);
/**
 * Class representing a random formula.
 */
class random_formula;
    randc Formula_Type formula_id;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint range{
        formula_id inside{Formula_A, Formula_B, Formula_C, Formula_D, Formula_E, Formula_F, Formula_G, Formula_H};
    }
endclass
random_formula random_formula_inst = new(`SEED);
/**
 * Class representing a random mode.
 */
class random_mode;
    randc Mode mode_id;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint range{
        mode_id inside{Insensitive, Normal, Sensitive};
    }
endclass
random_mode random_mode_inst = new(`SEED);
/**
 * Class representing a random date.
 */
class random_date;
    randc Date date_id;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint range{
		date_id.M inside {[1:12]};
		date_id.D inside {[1:31]};
		if (date_id.M == 2) {
			date_id.D inside {[1:28]};
		} else if (date_id.M == 4 || date_id.M == 6 || date_id.M == 9 || date_id.M == 11) { 
			date_id.D inside {[1:30]};
		}
    }
endclass
random_date random_date_inst = new(`SEED);
/**
 * Class representing a random data_no.
 */
class random_data_no;
    randc Data_No data_no_id;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint range{
        data_no_id inside {[0:255]};
    }
endclass
random_data_no random_data_no_inst = new(`SEED);
/**
 * Class representing a random index.
 */
class random_index;
    randc Index index_id;
    function new (int seed);
        this.srandom(seed);
    endfunction
    constraint range{
        index_id inside {[0:4095]};
    }
endclass
random_index random_index_inst = new(`SEED);

//================================================================
// initial
//================================================================
initial begin 
	$readmemh (DRAM_p_r, golden_DRAM);
	reset_task;
    for(i_pat=0; i_pat<`PATNUM; i_pat=i_pat+1) begin
        input_task;
        ans_gen_task;
        wait_task;
        check_task;
    end
    pass_task;
	$finish;
end
//================================================================
// task
//================================================================
task reset_task; begin
    inf.rst_n = 1'b1;
    inf.sel_action_valid = 1'b0;
    inf.formula_valid = 1'b0;
    inf.mode_valid = 1'b0;
    inf.date_valid = 1'b0;
    inf.data_no_valid = 1'b0;
    inf.index_valid = 1'b0;

    inf.D = 'dx;

    in_valid = 1'b0;

    exe_latency = 0;
    total_latency = 0;

    temp = random_act_inst.randomize();
    temp = random_formula_inst.randomize();
    temp = random_mode_inst.randomize();
    temp = random_date_inst.randomize();
    temp = random_data_no_inst.randomize();
    temp = random_index_inst.randomize();

    force clk = 'b0;
    #(1); inf.rst_n = 1'b0;
    #(100); inf.rst_n = 1'b1;

    if(inf.out_valid !== 1'b0 || inf.warn_msg !== 2'b0 || inf.complete !== 1'b0) begin : RESET_CHECK
        // fail_task;
        $display("--------------------------------------------------");
        $display("                      FAIL!!                      ");
        $display("           Output must be 0 after reset           ");
        $display("--------------------------------------------------");
        #(CYCLE * 5);
        $finish;
    end
    #(CYCLE); release clk;
    repeat(3) @(negedge clk);
end endtask

task input_task; begin
    in_valid = 1'b1;

	temp = random_act_inst.randomize();
	input_action = random_act_inst.act_id;

	inf.sel_action_valid = 1'b1;
	inf.D.d_act[0] = input_action;
	@(negedge clk);

	inf.sel_action_valid = 1'b0;
	inf.D = 'dx;
    input_gap = $urandom_range(3);
    repeat(input_gap) @(negedge clk)
    
    if(input_action == Index_Check) begin
        temp = random_formula_inst.randomize();
        input_formula = random_formula_inst.formula_id;
        
        inf.formula_valid = 1'b1;
        inf.D.d_formula[0] = input_formula;
        @(negedge clk);
        
        inf.formula_valid = 1'b0;
        inf.D = 'dx;
        input_gap = $urandom_range(3);
        repeat(input_gap) @(negedge clk);
        
        temp = random_mode_inst.randomize();
        input_mode = random_mode_inst.mode_id;

        inf.mode_valid = 1'b1;
        inf.D.d_mode[0] = input_mode;
        @(negedge clk) ;
            
        inf.mode_valid = 1'b0;
        inf.D = 'dx ;
        input_gap = $urandom_range(3);
        repeat(input_gap) @(negedge clk);
    end

    temp = random_date_inst.randomize();
    input_date = random_date_inst.date_id;

    inf.date_valid = 1'b1;
    inf.D.d_date[0] = {input_date.M, input_date.D};
    @(negedge clk);

    inf.date_valid = 1'b0;
    inf.D = 'dx;
    input_gap = $urandom_range(3);
    repeat(input_gap) @(negedge clk)

    temp = random_data_no_inst.randomize();
    input_data_no = random_data_no_inst.data_no_id;

    inf.data_no_valid = 1'b1;
    inf.D.d_data_no[0] = input_data_no;
    @(negedge clk);

    inf.data_no_valid = 1'b0;
    inf.D = 'dx;

    if(input_action == Update || input_action == Index_Check) begin
        for(int i=0; i<4; i=i+1) begin
            input_gap = $urandom_range(3);
            repeat(input_gap) @(negedge clk);

            temp = random_index_inst.randomize();
            input_index = random_index_inst.index_id;
            index_reg[i] = input_index;

            inf.index_valid = 1'b1;
            inf.D.d_index[0] = input_index;
            @(negedge clk);

            inf.index_valid = 1'b0;
            inf.D = 'dx;
        end
        in_valid = 1'b0;
    end else begin
        in_valid = 1'b0;
    end
end endtask 

task ans_gen_task; begin
    golden_complete = 1'b1;
    golden_warn_msg = No_Warn;

    day = golden_DRAM[65536+(input_data_no*8)];
    ID = {1'b0, golden_DRAM[65536+(input_data_no*8)+2][3:0], golden_DRAM[65536+(input_data_no*8)+1]};
    IC = {1'b0, golden_DRAM[65536+(input_data_no*8)+3], golden_DRAM[65536+(input_data_no*8)+2][7:4]};
    month = golden_DRAM[65536+(input_data_no*8)+4];
    IB = {1'b0, golden_DRAM[65536+(input_data_no*8)+6][3:0], golden_DRAM[65536+(input_data_no*8)+5]};
    IA = {1'b0, golden_DRAM[65536+(input_data_no*8)+7], golden_DRAM[65536+(input_data_no*8)+6][7:4]};

    threshold = 0;
    result = 0;
    s00 = (IA[11:0] > IC[11:0]) ? IA : IC;
    s01 = (IB[11:0] > ID[11:0]) ? IB : ID;
    s02 = (IA[11:0] > IC[11:0]) ? IC : IA;
    s03 = (IB[11:0] > ID[11:0]) ? ID : IB;
    sortedIA = (s00 > s01) ? s00 : s01;
    s11 = (s00 > s01) ? s01 : s00;
    s12 = (s02 > s03) ? s02 : s03;
    sortedID = (s02 > s03) ? s03 : s02;
    sortedIB = (s11 > s12) ? s11 : s12;
    sortedIC = (s11 > s12) ? s12 : s11;
    
    GA = (IA > index_reg[0]) ? IA - index_reg[0] : index_reg[0] - IA;
    GB = (IB > index_reg[1]) ? IB - index_reg[1] : index_reg[1] - IB;
    GC = (IC > index_reg[2]) ? IC - index_reg[2] : index_reg[2] - IC;
    GD = (ID > index_reg[3]) ? ID - index_reg[3] : index_reg[3] - ID;
    s20 = (GA[11:0] > GC[11:0]) ? {2'b00,GA} : {2'b10,GC};
    s21 = (GB[11:0] > GD[11:0]) ? {2'b01,GB} : {2'b11,GD};
    s22 = (GA[11:0] > GC[11:0]) ? {2'b10,GC} : {2'b00,GA};
    s23 = (GB[11:0] > GD[11:0]) ? {2'b11,GD} : {2'b01,GB};
    sortedGA = (s20[11:0] > s21[11:0]) ? s20 : s21;
    s31 = (s20[11:0] > s21[11:0]) ? s21 : s20;
    s32 = (s22[11:0] > s23[11:0]) ? s22 : s23;
    sortedGD = (s22[11:0] > s23[11:0]) ? s23 : s22;
    sortedGB = (s31[11:0] > s32[11:0]) ? s31 : s32;
    sortedGC = (s31[11:0] > s32[11:0]) ? s32 : s31;
    case(input_formula)
    Formula_A: begin
        case(input_mode)
        Insensitive: threshold = 2047;
        Normal: threshold = 1023;
        Sensitive: threshold = 511;
        endcase
        result = (IA + IB + IC + ID) / 4;
    end
    Formula_B: begin
        case(input_mode)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
        result = sortedIA[11:0] - sortedID[11:0];
    end
    Formula_C: begin
        case(input_mode)
        Insensitive: threshold = 2047;
        Normal: threshold = 1023;
        Sensitive: threshold = 511;
        endcase
        result = sortedID[11:0];
    end
    Formula_D: begin
        case(input_mode)
        Insensitive: threshold = 3;
        Normal: threshold = 2;
        Sensitive: threshold = 1;
        endcase
        result = (IA >= 2047) + (IB >= 2047) + (IC >= 2047) + (ID >= 2047);
    end
    Formula_E: begin
        case(input_mode)
        Insensitive: threshold = 3;
        Normal: threshold = 2;
        Sensitive: threshold = 1;
        endcase
        result = (IA >= index_reg[0]) + (IB >= index_reg[1]) + (IC >= index_reg[2]) + (ID >= index_reg[3]);
    end
    Formula_F: begin
        case(input_mode)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
        case(sortedGA[13:12])
            2'b00: result = (GB + GC + GD) / 3;
            2'b01: result = (GA + GC + GD) / 3;
            2'b10: result = (GA + GB + GD) / 3;
            2'b11: result = (GA + GB + GC) / 3;
        endcase 
    end
    Formula_G: begin
        case(input_mode)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
        result = (sortedGD[11:0] / 2) + (sortedGC[11:0] / 4) + (sortedGB[11:0] / 4);
    end
    Formula_H: begin
        case(input_mode)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
        result = (GA + GB + GC + GD) / 4;
    end
    endcase
    IVA = 0; IVB = 0; IVC = 0; IVD = 0;
    exceed = 1'b0;
    // Index A Variation
    if(IA + $signed(index_reg[0]) < 0) begin
        IVA = 0;
        exceed = 1'b1;
    end else if(IA + $signed(index_reg[0]) > 4095) begin
        IVA = 4095;
        exceed = 1'b1;
    end else begin
        IVA = IA + $signed(index_reg[0]);
    end
    // Index B Variation
    if(IB + $signed(index_reg[1]) < 0) begin
        IVB = 0;
        exceed = 1'b1;
    end else if(IB + $signed(index_reg[1]) > 4095) begin
        IVB = 4095;
        exceed = 1'b1;
    end else begin
        IVB = IB + $signed(index_reg[1]);
    end
    // Index C Variation
    if(IC + $signed(index_reg[2]) < 0) begin
        IVC = 0;
        exceed = 1'b1;
    end else if(IC + $signed(index_reg[2]) > 4095) begin
        IVC = 4095;
        exceed = 1'b1;
    end else begin
        IVC = IC + $signed(index_reg[2]);
    end
    // Index D Variation
    if(ID + $signed(index_reg[3]) < 0) begin
        IVD = 0;
        exceed = 1'b1;
    end else if(ID + $signed(index_reg[3]) > 4095) begin
        IVD = 4095;
        exceed = 1'b1;
    end else begin
        IVD = ID + $signed(index_reg[3]);
    end
    case(input_action)
        Index_Check: begin
            if(month > input_date.M || month == input_date.M && day > input_date.D) begin
                golden_warn_msg = Date_Warn;
                golden_complete = 1'b0;
            end else if(result >= threshold) begin
                golden_warn_msg = Risk_Warn;
                golden_complete = 1'b0;
            end
        end 
        Update: begin
            if(exceed) begin
                golden_warn_msg = Data_Warn;
                golden_complete = 1'b0;
            end
            golden_DRAM[65536+(input_data_no*8)] = {3'b0,input_date.D};
            {golden_DRAM[65536+(input_data_no*8)+2][3:0], golden_DRAM[65536+(input_data_no*8)+1]} = IVD;
            {golden_DRAM[65536+(input_data_no*8)+3], golden_DRAM[65536+(input_data_no*8)+2][7:4]} = IVC;
            golden_DRAM[65536+(input_data_no*8)+4] = {4'b0,input_date.M};
            {golden_DRAM[65536+(input_data_no*8)+6][3:0], golden_DRAM[65536+(input_data_no*8)+5]} = IVB;
            {golden_DRAM[65536+(input_data_no*8)+7], golden_DRAM[65536+(input_data_no*8)+6][7:4]} = IVA;
        end
        Check_Valid_Date: begin
            if(month > input_date.M || month == input_date.M && day > input_date.D) begin
                golden_warn_msg = Date_Warn;
                golden_complete = 1'b0;
            end
        end
    endcase
    if(`DEBUG) begin
        f = $fopen("golden_process.txt", "w");
        $fdisplay(f, "------------- Pattern No.%4d -------------", i_pat);
        case(input_action)
            Index_Check: begin
                $fdisplay(f, "Action: Index_Check");
                $fdisplay(f, "Formula: %d", input_formula);
                $fdisplay(f, "Mode: %d", input_mode);
                $fdisplay(f, "Date: %d/%d", input_date.M, input_date.D);
                $fdisplay(f, "Data No: %d", input_data_no);
                $fdisplay(f, "Index A: %d", index_reg[0]);
                $fdisplay(f, "Index B: %d", index_reg[1]);
                $fdisplay(f, "Index C: %d", index_reg[2]);
                $fdisplay(f, "Index D: %d", index_reg[3]);
                $fdisplay(f, "--------------------------------------------------");
                $fdisplay(f, "G: %d %d %d %d", GA, GB, GC, GD);
                $fdisplay(f, "N: %d %d %d %d", sortedGA[11:0], sortedGB[11:0], sortedGC[11:0], sortedGD[11:0]);
                $fdisplay(f, "Threshold: %d", threshold);
                $fdisplay(f, "Risk: %d", result);
            end
            Update: begin
                $fdisplay(f, "Action: Update");
                $fdisplay(f, "Date: %d/%d", input_date.M, input_date.D);
                $fdisplay(f, "Data No: %d", input_data_no);
                $fdisplay(f, "Index A variation: %d", $signed(index_reg[0]));
                $fdisplay(f, "Index B variation: %d", $signed(index_reg[1]));
                $fdisplay(f, "Index C variation: %d", $signed(index_reg[2]));
                $fdisplay(f, "Index D variation: %d", $signed(index_reg[3]));
                $fdisplay(f, "--------------------------------------------------");
                $fdisplay(f, "Update Index A: %d", IVA);
                $fdisplay(f, "Update Index B: %d", IVB);
                $fdisplay(f, "Update Index C: %d", IVC);
                $fdisplay(f, "Update Index D: %d", IVD);
            end
            Check_Valid_Date: begin
                $fdisplay(f, "Action: Check_Valid_Date");
                $fdisplay(f, "Date: %d/%d", input_date.M, input_date.D);
                $fdisplay(f, "Data No: %d", input_data_no);
            end
        endcase
        $fdisplay(f, "------------- Dram Data -------------");
        $fdisplay(f, "Date: %d/%d", month, day);
        $fdisplay(f, "Index A: %d", IA);
        $fdisplay(f, "Index B: %d", IB);
        $fdisplay(f, "Index C: %d", IC);
        $fdisplay(f, "Index D: %d", ID);
        $fdisplay(f, "--------------------------------------------------");
        $fdisplay(f, "golden_warn_msg: %d", golden_warn_msg);
        $fdisplay(f, "golden_complete: %d", golden_complete);
        $fdisplay(f, "--------------------------------------------------");
        $fclose(f);
    end
end endtask
task wait_task; begin
    exe_latency = 0;
    while(inf.out_valid !== 1'b1) begin
        exe_latency = exe_latency + 1;
        if(exe_latency == 2000) begin : TIMEOUT_CHECK
            // fail_task;
            $display("--------------------------------------------------");
            $display("                      FAIL!!                      ");
            $display("       Execution timeout (over 2000 cycles)       ");
            $display("--------------------------------------------------");
            repeat(5) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
end endtask

task check_task; begin
    if(inf.warn_msg !== golden_warn_msg || inf.complete !== golden_complete) begin
        // fail_task;
        $display("--------------------------------------------------");
        $display("                      FAIL!!                      ");
        $display("         Output does not match with golden        ");
        $display("==================================================");
        $display("  Golden Warn Msg: %d", golden_warn_msg);
        $display("  Yours Warn Msg: %d", inf.warn_msg);
        $display("  Golden Complete: %d", golden_complete);
        $display("  Yours Complete: %d", inf.complete);
        $display("");
        repeat(5) @(negedge clk);
        $finish;
    end
    $display("\033[38;5;123mPATTERN NO.%4d PASS!!\033[0;32m EXECUTION CYCLE :%4d\033[m", i_pat, exe_latency);
    total_latency = total_latency + exe_latency;
    @(negedge clk);
    input_gap = $urandom_range(3);
    repeat(input_gap) @(negedge clk);
end endtask

task pass_task ; begin 
    $display("==========================================================================") ;
	$display("                            Congratulations                               ") ;
    $display("==========================================================================") ;
end endtask 

endprogram
