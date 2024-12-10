/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

// integer fp_w;

// initial begin
// fp_w = $fopen("out_valid.txt", "w");
// end

/**
 * This section contains the definition of the class and the instantiation of the object.
 *  * 
 * The always_ff blocks update the object based on the values of valid signals.
 * When valid signal is true, the corresponding property is updated with the value of inf.D
 */

class Formula_and_mode;
    Formula_Type f_type;
    Mode f_mode;
endclass
Formula_and_mode fm_info = new();

always_ff @(posedge clk) begin
    if(inf.formula_valid) begin
        fm_info.f_type = inf.D.d_formula[0];
    end
    if(inf.mode_valid) begin
        fm_info.f_mode = inf.D.d_mode[0];
    end
end

Action input_action;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin
        input_action = Index_Check;
    end else if(inf.sel_action_valid) begin
        input_action = inf.D.d_act[0];
    end
end

covergroup spec1 @(posedge clk iff(inf.formula_valid));
    option.per_instance = 1;
    option.at_least = 150;
    formula_hits: coverpoint inf.D.d_formula[0] {
        bins b_formula [] = {[Formula_A:Formula_H]};
    }
endgroup
spec1 spec1_inst = new();

covergroup spec2 @(posedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 150;
    mode_hits: coverpoint inf.D.d_mode[0] {
        bins b_mode [] = {[Insensitive:Sensitive]};
    }
endgroup
spec2 spec2_inst = new();

covergroup spec3 @(negedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 150;
	fm_cross_hits: cross fm_info.f_type, fm_info.f_mode;
endgroup
spec3 spec3_inst = new();

covergroup spec4 @(negedge clk iff(inf.out_valid));
    option.per_instance = 1;
    option.at_least = 50;
	warn_hits: coverpoint inf.warn_msg {
		bins b_warn [] = {[No_Warn:Data_Warn]};
	}
endgroup
spec4 spec4_inst = new();

covergroup spec5 @(posedge clk iff(inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = 300 ;
	action_trans: coverpoint inf.D.d_act[0] {
		bins b_act [] = ([Index_Check:Check_Valid_Date]=>[Index_Check:Check_Valid_Date]);
	}
endgroup
spec5 spec5_inst = new();

covergroup spec6 @(posedge clk iff(inf.index_valid && input_action === Update));
    option.per_instance = 1;
    option.at_least = 1;
	index_var_hits: coverpoint inf.D.d_index[0] {
		option.auto_bin_max = 32 ;
	}
endgroup
spec6 spec6_inst = new();

logic[2:0] index_cnt;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin
        index_cnt = 0;
    end else begin
        if(inf.index_valid) begin
            index_cnt = index_cnt + 1;
        end else if(inf.sel_action_valid) begin
            index_cnt = 0;
        end
    end
end

logic in_valid;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin
        in_valid = 0;
    end else begin
        case(input_action)
            Index_Check, Update: in_valid = (index_cnt === 4) ? 1 : 0;
            Check_Valid_Date: in_valid = inf.data_no_valid;
        endcase     
    end
end

always @(negedge inf.rst_n) begin 
	#(5);
	reset_check: assert(inf.out_valid === 0 && inf.warn_msg === 0 && inf.complete === 0 && 
                        inf.AR_VALID === 0 && inf.AR_ADDR === 0 && inf.R_READY === 0 && 
                        inf.AW_VALID === 0 && inf.AW_ADDR === 0 && inf.W_VALID === 0 && 
                        inf.W_DATA === 0 && inf.B_READY === 0)
    else begin 
        $display("======================================================================");
        $display("                     Assertion 1 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
end

always @(posedge clk) begin
    latency_limit: assert property(lat_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 2 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end 
end
property lat_check;
    @(posedge clk) in_valid |-> ##[1:1000] inf.out_valid;
endproperty

always @(negedge clk) begin
    complete_no_warn: assert property(warn_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 3 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
end
property warn_check;
    @(negedge clk) inf.complete |-> inf.warn_msg === No_Warn;
endproperty

always @(posedge clk) begin
	if(inf.sel_action_valid) begin 
		first_input_lat: assert property(first_check)
        else begin
            $display("======================================================================");
            $display("                     Assertion 4 is violated                          ");			
            $display("======================================================================");
            $fatal;
        end
    end else if(input_action === Index_Check) begin
        IC_input_lat: assert property(IC_check)
        else begin
            $display("======================================================================");
            $display("                     Assertion 4 is violated                          ");			
            $display("======================================================================");
            $fatal;
        end
    end else if(input_action === Update) begin
        U_input_lat: assert property(U_check)
        else begin
            $display("======================================================================");
            $display("                     Assertion 4 is violated                          ");			
            $display("======================================================================");
            $fatal;
        end
    end else if(input_action === Check_Valid_Date) begin
        CVD_input_lat: assert property(CVD_check)
        else begin
            $display("======================================================================");
            $display("                     Assertion 4 is violated                          ");			
            $display("======================================================================");
            $fatal;
        end
    end
end
property first_check;
	@(posedge clk) inf.sel_action_valid |-> ##[1:4] (inf.formula_valid | inf.date_valid);
endproperty
property IC_check;
	@(posedge clk) inf.formula_valid |-> ##[1:4] inf.mode_valid ##[1:4] inf.date_valid ##[1:4] inf.data_no_valid
                ##[1:4] inf.index_valid ##[1:4] inf.index_valid ##[1:4] inf.index_valid ##[1:4] inf.index_valid;
endproperty
property U_check;
	@(posedge clk) inf.date_valid |-> ##[1:4] inf.data_no_valid 
                ##[1:4] inf.index_valid ##[1:4] inf.index_valid ##[1:4] inf.index_valid ##[1:4] inf.index_valid;
endproperty
property CVD_check;
	@(posedge clk) inf.date_valid |-> ##[1:4] inf.data_no_valid;
endproperty 

always @(posedge clk) begin
    action_valid_overlap: assert property(action_valid_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 5 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
    formula_valid_overlap: assert property(formula_valid_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 5 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
    mode_valid_overlap: assert property(mode_valid_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 5 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
    date_valid_overlap: assert property(date_valid_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 5 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
    data_no_valid_overlap: assert property(data_no_valid_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 5 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
    index_valid_overlap: assert property(index_valid_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 5 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
end
property action_valid_check;
    @(posedge clk) inf.sel_action_valid |-> (inf.formula_valid | inf.mode_valid | inf.date_valid | inf.data_no_valid | inf.index_valid) === 0;
endproperty
property formula_valid_check;
    @(posedge clk) inf.formula_valid |-> (inf.sel_action_valid | inf.mode_valid | inf.date_valid | inf.data_no_valid | inf.index_valid) === 0;
endproperty
property mode_valid_check;
    @(posedge clk) inf.mode_valid |-> (inf.sel_action_valid | inf.formula_valid | inf.date_valid | inf.data_no_valid | inf.index_valid) === 0;
endproperty
property date_valid_check;
    @(posedge clk) inf.date_valid |-> (inf.sel_action_valid | inf.formula_valid | inf.mode_valid | inf.data_no_valid | inf.index_valid) === 0;
endproperty
property data_no_valid_check;
    @(posedge clk) inf.data_no_valid |-> (inf.sel_action_valid | inf.formula_valid | inf.mode_valid | inf.date_valid | inf.index_valid) === 0;
endproperty
property index_valid_check;
    @(posedge clk) inf.index_valid |-> (inf.sel_action_valid | inf.formula_valid | inf.mode_valid | inf.date_valid | inf.data_no_valid) === 0;
endproperty

always @(posedge clk) begin
    out_valid_one_cycle: assert property(out_valid_cycle_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 6 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
end
property out_valid_cycle_check;
    @(posedge clk) inf.out_valid |-> ##1 inf.out_valid === 0;
endproperty

always @(posedge clk) begin
	input_gap: assert property(input_gap_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 7 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
end
property input_gap_check;
	@(posedge clk) inf.out_valid |-> ##[1:4] inf.sel_action_valid;
endproperty

always @(posedge clk) begin
    vaild_date: assert property(valid_date_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 8 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
end
property valid_date_check;
    @(posedge clk) inf.date_valid |-> (((inf.D.d_date[0].M === 1 || inf.D.d_date[0].M === 3 || inf.D.d_date[0].M === 5 || inf.D.d_date[0].M === 7 || 
                                      inf.D.d_date[0].M === 8 || inf.D.d_date[0].M === 10 || inf.D.d_date[0].M === 12) && 
                                      (inf.D.d_date[0].D <= 31)) || 
                                      ((inf.D.d_date[0].M === 4 || inf.D.d_date[0].M === 6 || inf.D.d_date[0].M === 9 || inf.D.d_date[0].M === 11) && 
                                      (inf.D.d_date[0].D <= 30)) ||
                                      ((inf.D.d_date[0].M === 2) && 
                                      (inf.D.d_date[0].D <= 28))) && (inf.D.d_date[0].M <= 12 && inf.D.d_date[0].M >= 1) && (inf.D.d_date[0].D <= 31 && inf.D.d_date[0].D >= 1);
endproperty

always @(posedge clk) begin
    ar_overlap: assert property(ar_overlap_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 9 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
    aw_overlap: assert property(aw_overlap_check)
    else begin
        $display("======================================================================");
        $display("                     Assertion 9 is violated                          ");			
        $display("======================================================================");
        $fatal;
    end
end
property ar_overlap_check;
    @(posedge clk) inf.AR_VALID |-> inf.AW_VALID === 0;
endproperty
property aw_overlap_check;
    @(posedge clk) inf.AW_VALID |-> inf.AR_VALID === 0;
endproperty

endmodule