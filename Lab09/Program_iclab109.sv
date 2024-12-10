module Program(input clk, INF.Program_inf inf);
import usertype::*;

Action action_reg;
Formula_Type formula_reg;
Mode mode_reg;
Date date_reg;
Data_No data_no_reg;
Index index_reg [3:0];
logic signed [11:0] index_var [3:0];
logic index_valid_reg0;

logic [2:0] index_cnt;

FSM state, state_nxt;
FSM_DRAM dram_state, dram_state_nxt;
logic signed [12:0] IA, IB, IC, ID;
logic [11:0] GA, GB, GC, GD;
logic [11:0] GA_nxt, GB_nxt, GC_nxt, GD_nxt;
logic [11:0] IVA, IVB, IVC, IVD;
logic [7:0] month, day;

logic [10:0] threshold;
logic [11:0] result, result_nxt;

logic exceed;

always_comb begin
    threshold = 0;
    case(formula_reg)
    Formula_A: begin
        case(mode_reg)
        Insensitive: threshold = 2047;
        Normal: threshold = 1023;
        Sensitive: threshold = 511;
        endcase
    end
    Formula_B: begin
        case(mode_reg)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
    end
    Formula_C: begin
        case(mode_reg)
        Insensitive: threshold = 2047;
        Normal: threshold = 1023;
        Sensitive: threshold = 511;
        endcase
    end
    Formula_D: begin
        case(mode_reg)
        Insensitive: threshold = 3;
        Normal: threshold = 2;
        Sensitive: threshold = 1;
        endcase
    end
    Formula_E: begin
        case(mode_reg)
        Insensitive: threshold = 3;
        Normal: threshold = 2;
        Sensitive: threshold = 1;
        endcase
    end
    Formula_F: begin
        case(mode_reg)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
    end
    Formula_G: begin
        case(mode_reg)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
    end
    Formula_H: begin
        case(mode_reg)
        Insensitive: threshold = 800;
        Normal: threshold = 400;
        Sensitive: threshold = 200;
        endcase
    end
    endcase
end

// -----------------  Input Register  ----------------- //

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin action_reg <= Index_Check; end
    else begin action_reg <= (inf.sel_action_valid) ? inf.D.d_act[0] : action_reg; end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin formula_reg <= Formula_A; end
    else begin formula_reg <= (inf.formula_valid) ? inf.D.d_formula[0] : formula_reg; end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin mode_reg <= Insensitive; end
    else begin mode_reg <= (inf.mode_valid) ? inf.D.d_mode[0] : mode_reg; end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin date_reg <= 0; end
    else begin date_reg <= (inf.date_valid) ? inf.D.d_date[0] : date_reg; end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin data_no_reg <= 0; end
    else begin data_no_reg <= (inf.data_no_valid) ? inf.D.d_data_no[0] : data_no_reg; end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        index_reg <= {0, 0, 0, 0}; 
    end else begin 
        if(inf.index_valid) begin
            index_reg <= {inf.D.d_index[0], index_reg[3:1]}; 
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        index_valid_reg0 <= 0;
    end else begin
        index_valid_reg0 <= inf.index_valid;
    end
end

// -----------------  FSM  ----------------- //

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        state <= IDLE;
    end else begin
        state <= state_nxt;
    end
end

always_comb begin
    state_nxt = state;
    case(state)
    IDLE: begin
        if(inf.sel_action_valid) begin
            case(inf.D.d_act[0])
            Index_Check: begin
                state_nxt = INDEX_CHECK;
            end
            Update: begin
                state_nxt = UPDATE;
            end
            Check_Valid_Date: begin
                state_nxt = CHECK_VALID_DATE;
            end
            endcase
        end
    end
    INDEX_CHECK: begin
        if(dram_state == DRAM_REQ && inf.R_VALID) begin
            if(inf.R_DATA[35:32] > date_reg.M) begin
                state_nxt = (index_cnt == 4) ? DATE_WARN : WAIT_INPUT;
            end else if(inf.R_DATA[35:32] == date_reg.M) begin
                if(inf.R_DATA[4:0] > date_reg.D) begin
                    state_nxt = (index_cnt == 4) ? DATE_WARN : WAIT_INPUT;
                end else begin
                    state_nxt = IC_CALC;
                end
            end else begin
                state_nxt = IC_CALC;
            end
        end
    end
    UPDATE: begin
        if(dram_state == DRAM_REQ && inf.R_VALID) begin
            state_nxt = UP_CALC;
        end
    end
    CHECK_VALID_DATE: begin
        if(dram_state == DRAM_REQ && inf.R_VALID) begin
            if(inf.R_DATA[35:32] > date_reg.M) begin
                state_nxt = DATE_WARN;
            end else if(inf.R_DATA[35:32] == date_reg.M) begin
                if(inf.R_DATA[4:0] > date_reg.D) begin
                    state_nxt = DATE_WARN;
                end else begin
                    state_nxt = NO_WARN;
                end
            end else begin
                state_nxt = NO_WARN;
            end
        end
    end
    WAIT_INPUT: begin
        if(index_cnt == 4) begin
            state_nxt = DATE_WARN;
        end
    end
    IC_CALC: begin
        if(index_cnt == 4) begin
            state_nxt = IC_WAIT0;
        end
    end
    IC_WAIT0: begin
        state_nxt = IC_WAIT1;
    end
    IC_WAIT1: begin
        state_nxt = (result >= threshold) ? RISK_WARN : NO_WARN;
    end
    UP_CALC: begin
        if(inf.B_VALID) begin
            state_nxt = (exceed) ? DATA_WARN : NO_WARN;
        end
    end
    DATE_WARN: begin
        state_nxt = IDLE;
    end
    RISK_WARN: begin
        state_nxt = IDLE;
    end
    DATA_WARN: begin
        state_nxt = IDLE;
    end
    NO_WARN: begin
        state_nxt = IDLE;
    end
    endcase
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        dram_state <= IDLE_DRAM;
    end else begin
        dram_state <= dram_state_nxt;
    end
end

always_comb begin
    dram_state_nxt = dram_state;
    case(dram_state)
    IDLE_DRAM: begin
        if(inf.data_no_valid) begin
            dram_state_nxt = DRAM_HS;
        end
    end
    DRAM_HS: begin
        if(inf.AR_READY) begin
            dram_state_nxt = DRAM_REQ;
        end
    end
    DRAM_REQ: begin
        if(inf.R_VALID) begin
            dram_state_nxt = (action_reg == Update) ? DRAM_WAIT : IDLE_DRAM;
        end
    end
    DRAM_WAIT: begin
        if(index_cnt == 4) begin
            dram_state_nxt = DRAM_WREQ;
        end
    end
    DRAM_WREQ: begin
        if(inf.W_READY) begin
            dram_state_nxt = DRAM_RESP;
        end
    end
    DRAM_RESP: begin
        if(inf.B_VALID) begin
            dram_state_nxt = IDLE_DRAM;
        end
    end
    endcase
end

assign inf.AR_VALID = dram_state == DRAM_HS;
assign inf.AR_ADDR = dram_state == DRAM_HS ? 17'h10000 + 8 * data_no_reg : 0;
assign inf.R_READY = dram_state == DRAM_REQ;

assign inf.AW_VALID = dram_state == DRAM_HS && state == UPDATE;
assign inf.AW_ADDR = dram_state == DRAM_HS && state == UPDATE ? 17'h10000 + 8 * data_no_reg : 0;
assign inf.W_VALID = dram_state == DRAM_WREQ;
assign inf.W_DATA = inf.W_VALID ? {IVA, IVB, {4'b0, date_reg.M}, IVC, IVD, {3'b0, date_reg.D}} : 0;
assign inf.B_READY = dram_state == DRAM_RESP;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        IA <= 0; IB <= 0; IC <= 0; ID <= 0;
        month <= 0; day <= 0;
    end else begin
        if(inf.R_VALID) begin
            IA <= {1'b0 , inf.R_DATA[63:52]};
            IB <= {1'b0 , inf.R_DATA[51:40]};
            month <= inf.R_DATA[39:32];
            IC <= {1'b0 , inf.R_DATA[31:20]};
            ID <= {1'b0 , inf.R_DATA[19:8]};
            day <= inf.R_DATA[7:0];
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        index_cnt <= 0;
    end else begin
        if(inf.out_valid) begin
            index_cnt <= 0;
        end else begin
            index_cnt <= (inf.index_valid) ? index_cnt + 1 : index_cnt;
        end
    end
end
// -----------------  Index Variation  ----------------- //
assign index_var[0] = index_reg[0];
assign index_var[1] = index_reg[1];
assign index_var[2] = index_reg[2];
assign index_var[3] = index_reg[3];
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        IVA <= 0; IVB <= 0; IVC <= 0; IVD <= 0;
    end else begin
        // Index A Variation
        if(IA + index_var[0] < 0) begin
            IVA <= 0;
        end else if(IA + index_var[0] > 4095) begin
            IVA <= 4095;
        end else begin
            IVA <= IA + index_var[0];
        end
        // Index B Variation
        if(IB + index_var[1] < 0) begin
            IVB <= 0;
        end else if(IB + index_var[1] > 4095) begin
            IVB <= 4095;
        end else begin
            IVB <= IB + index_var[1];
        end
        // Index C Variation
        if(IC + index_var[2] < 0) begin
            IVC <= 0;
        end else if(IC + index_var[2] > 4095) begin
            IVC <= 4095;
        end else begin
            IVC <= IC + index_var[2];
        end
        // Index D Variation
        if(ID + index_var[3] < 0) begin
            IVD <= 0;
        end else if(ID + index_var[3] > 4095) begin
            IVD <= 4095;
        end else begin
            IVD <= ID + index_var[3];
        end
    end
end
// -----------------  Exceed  ----------------- //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        exceed <= 0;
    end else begin
        if(index_cnt == 4 && dram_state != DRAM_REQ) begin
            if(IA + index_var[0] < 0 || IA + index_var[0] > 4095) begin
                exceed <= 1;
            end
            if(IB + index_var[1] < 0 || IB + index_var[1] > 4095) begin
                exceed <= 1;
            end
            if(IC + index_var[2] < 0 || IC + index_var[2] > 4095) begin
                exceed <= 1;
            end
            if(ID + index_var[3] < 0 || ID + index_var[3] > 4095) begin
                exceed <= 1;
            end
        end else begin
            exceed <= 0;
        end
    end
end
// -----------------  G ----------------- //
abs_calc abs_calc0(.in0(IA[11:0]), .in1(index_reg[0]), .out(GA_nxt));
abs_calc abs_calc1(.in0(IB[11:0]), .in1(index_reg[1]), .out(GB_nxt));
abs_calc abs_calc2(.in0(IC[11:0]), .in1(index_reg[2]), .out(GC_nxt));
abs_calc abs_calc3(.in0(ID[11:0]), .in1(index_reg[3]), .out(GD_nxt));
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        GA <= 0; GB <= 0; GC <= 0; GD <= 0;
    end else begin
        GA <= GA_nxt;
        GB <= GB_nxt;
        GC <= GC_nxt;
        GD <= GD_nxt;
    end
end
// -----------------  Sorting 4  ----------------- //
logic [13:0] sortin0, sortin1, sortin2, sortin3;
logic [13:0] sortout0, sortout1, sortout2, sortout3;
sort4 sort4_inst (.in0(sortin0), .in1(sortin1), .in2(sortin2), .in3(sortin3), 
                  .out0(sortout0), .out1(sortout1), .out2(sortout2), .out3(sortout3));  
always_comb begin
    sortin0 = 0; sortin1 = 0; sortin2 = 0; sortin3 = 0;
    case(formula_reg)
        Formula_B, Formula_C: begin sortin0 = {2'b00, IA[11:0]}; sortin1 = {2'b00, IB[11:0]}; sortin2 = {2'b00, IC[11:0]}; sortin3 = {2'b00, ID[11:0]}; end
        Formula_F, Formula_G: begin sortin0 = {2'b00, GA}; sortin1 = {2'b01, GB}; sortin2 = {2'b10, GC}; sortin3 = {2'b11, GD}; end
    endcase
end
// -----------------  Result ----------------- //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n) begin 
        result <= 0;
    end else begin
        result <= result_nxt;
    end
end
always_comb begin
    result_nxt = 0;
    case(formula_reg)
        Formula_A:begin 
            result_nxt = (IA + IB + IC + ID) / 4;
        end
        Formula_B:begin 
            result_nxt = sortout0[11:0] - sortout3[11:0];
        end
        Formula_C:begin 
            result_nxt = sortout3[11:0];
        end
        Formula_D:begin
            result_nxt = (IA >= 2047) + (IB >= 2047) + (IC >= 2047) + (ID >= 2047); 
        end
        Formula_E:begin
            result_nxt = (IA >= index_reg[0]) + (IB >= index_reg[1]) + (IC >= index_reg[2]) + (ID >= index_reg[3]); 
        end
        Formula_F:begin
            case(sortout0[13:12])
                2'b00: result_nxt = (GB + GC + GD) / 3;
                2'b01: result_nxt = (GA + GC + GD) / 3;
                2'b10: result_nxt = (GA + GB + GD) / 3;
                2'b11: result_nxt = (GA + GB + GC) / 3;
            endcase 
        end
        Formula_G:begin
            result_nxt = (sortout3[11:0] / 2) + (sortout2[11:0] / 4) + (sortout1[11:0] / 4); 
        end
        Formula_H:begin 
            result_nxt = (GA + GB + GC + GD) / 4;
        end
    endcase
end
// -----------------  output  ----------------- //
    assign inf.out_valid = (state == DATE_WARN | state == RISK_WARN | state == DATA_WARN | state == NO_WARN) ? 1 : 0;
    always_comb begin
        if(inf.out_valid) begin
            case(state)
                DATE_WARN: inf.warn_msg = Date_Warn;
                RISK_WARN: inf.warn_msg = Risk_Warn;
                DATA_WARN: inf.warn_msg = Data_Warn;
                NO_WARN: inf.warn_msg = No_Warn;
                default: inf.warn_msg = No_Warn;
            endcase
        end else begin
            inf.warn_msg = No_Warn;
        end
    end
    assign inf.complete = state == NO_WARN ? 1 : 0;

endmodule

module abs_calc(input logic [11:0] in0, input logic [11:0] in1, output logic [11:0] out);
    assign out = (in0 > in1) ? in0 - in1 : in1 - in0;
endmodule

module sort4(input logic [13:0] in0, in1, in2, in3, output logic [13:0] out0, out1, out2, out3);
    logic [13:0] s00, s01, s02, s03; logic [13:0] s11, s12;
    assign s00 = (in0[11:0] > in2[11:0]) ? in0 : in2;
    assign s01 = (in1[11:0] > in3[11:0]) ? in1 : in3;
    assign s02 = (in0[11:0] > in2[11:0]) ? in2 : in0;
    assign s03 = (in1[11:0] > in3[11:0]) ? in3 : in1;
    assign out0 = (s00[11:0] > s01[11:0]) ? s00 : s01;
    assign s11 = (s00[11:0] > s01[11:0]) ? s01 : s00;
    assign s12 = (s02[11:0] > s03[11:0]) ? s02 : s03;
    assign out3 = (s02[11:0] > s03[11:0]) ? s03 : s02;
    assign out1 = (s11[11:0] > s12[11:0]) ? s11 : s12;
    assign out2 = (s11[11:0] > s12[11:0]) ? s12 : s11;
endmodule
