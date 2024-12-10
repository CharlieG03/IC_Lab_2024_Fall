module Ramen(
    // Input Registers
    input clk, 
    input rst_n, 
    input in_valid,
    input selling,
    input portion, 
    input [1:0] ramen_type,

    // Output Signals
    output reg out_valid_order,
    output reg success,

    output reg out_valid_tot,
    output reg [27:0] sold_num,
    output reg [14:0] total_gain
);


//==============================================//
//             Parameter and Integer            //
//==============================================//

// ramen_type
parameter TONKOTSU = 0;
parameter TONKOTSU_SOY = 1;
parameter MISO = 2;
parameter MISO_SOY = 3;

// initial ingredient
parameter NOODLE_INIT = 12000;
parameter BROTH_INIT = 41000;
parameter TONKOTSU_SOUP_INIT =  9000;
parameter MISO_INIT = 1000;
parameter SOY_SAUSE_INIT = 1500;


//==============================================//
//                 reg declaration              //
//==============================================// 
reg selling_reg;
reg in_valid_reg0, in_valid_reg1;
reg portion_reg;
reg [1:0] type_reg;

reg [13:0] noodle_stack, ns_nxt;
reg [15:0] broth_stack, bs_nxt;
reg [13:0] tonkotsu_stack, ts_nxt;
reg [9:0] miso_stack, ms_nxt;
reg [10:0] soy_stack, ss_nxt;

reg [7:0] noodle_need;
reg [9:0] broth_need;
reg [7:0] tonkotsu_need;
reg [5:0] miso_need;
reg [5:0] soy_need;

reg success_nxt;

reg [6:0] t_sn, ts_sn, m_sn, ms_sn;
reg [14:0] gain_nxt;

//==============================================//
//                    Design                    //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        noodle_stack <= 'd12000;
        broth_stack <= 'd41000;
        tonkotsu_stack <= 'd9000;
        miso_stack <= 'd1000;
        soy_stack <= 'd1500;
    end else begin
        if(out_valid_tot) begin
            noodle_stack <= 'd12000;
            broth_stack <= 'd41000;
            tonkotsu_stack <= 'd9000;
            miso_stack <= 'd1000;
            soy_stack <= 'd1500;
        end else begin
            noodle_stack <= in_valid_reg1 ? ns_nxt : noodle_stack;
            broth_stack <= in_valid_reg1 ? bs_nxt : broth_stack;
            tonkotsu_stack <= in_valid_reg1 ? ts_nxt : tonkotsu_stack;
            miso_stack <= in_valid_reg1 ? ms_nxt: miso_stack;
            soy_stack <= in_valid_reg1 ? ss_nxt : soy_stack;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        selling_reg <= 0;
    end else begin
        selling_reg <= selling;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        in_valid_reg0 <= 0;
        in_valid_reg1 <= 0;
    end else begin
        in_valid_reg0 <= in_valid_reg0 == 0 ? in_valid : 0;
        in_valid_reg1 <= in_valid_reg1 == 0 ? in_valid_reg0 : 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        sold_num <= 0;
        total_gain <= 0;
    end else begin
        sold_num <= {t_sn, ts_sn, m_sn, ms_sn};
        total_gain <= gain_nxt;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        portion_reg <= 0;
        type_reg <= 0;
    end else begin
        if(in_valid_reg0) begin
            portion_reg <= portion;
        end
        if(in_valid & ~in_valid_reg0) begin
            type_reg <= ramen_type;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_valid_order <= 0;
        success <= 0;
    end else begin
        out_valid_order <= (in_valid_reg1);
        success <= (in_valid_reg1) ? success_nxt : 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_valid_tot <= 0;
    end else begin
        out_valid_tot <= (!selling & out_valid_order);
    end
end

always @(*) begin
    success_nxt = 1;
    if(noodle_stack < noodle_need) begin
        success_nxt = 0;
    end
    if(broth_stack < broth_need) begin
        success_nxt = 0;
    end
    if(tonkotsu_stack < tonkotsu_need) begin
        success_nxt = 0;
    end
    if(miso_stack < miso_need) begin
        success_nxt = 0;
    end
    if(soy_stack < soy_need) begin
        success_nxt = 0;
    end

    if(noodle_stack >= noodle_need) begin
        if(success_nxt) begin
            ns_nxt = noodle_stack - noodle_need;
        end else begin
            ns_nxt = noodle_stack;
        end
    end else begin
        ns_nxt = noodle_stack;
    end
    if(broth_stack >= broth_need) begin
        if(success_nxt) begin
            bs_nxt = broth_stack - broth_need;
        end else begin
            bs_nxt = broth_stack;
        end
    end else begin
        bs_nxt = broth_stack;
    end
    if(tonkotsu_stack >= tonkotsu_need) begin
        if(success_nxt) begin
            ts_nxt = tonkotsu_stack - tonkotsu_need;
        end else begin
            ts_nxt = tonkotsu_stack;
        end
    end else begin
        ts_nxt = tonkotsu_stack;
    end
    if(miso_stack >= miso_need ) begin
        if(success_nxt) begin
            ms_nxt = miso_stack - miso_need;
        end else begin
            ms_nxt = miso_stack;
        end
    end else begin
        ms_nxt = miso_stack;
    end
    if(soy_stack >= soy_need) begin
        if(success_nxt) begin
            ss_nxt = soy_stack - soy_need;
        end else begin
            ss_nxt = soy_stack;
        end
    end else begin
        ss_nxt = soy_stack;
    end
end

always @(*) begin
    noodle_need = portion_reg ? 150 : 100;
    broth_need = 0;
    tonkotsu_need = 0;
    miso_need = 0;
    soy_need = 0;
    case(type_reg)
    TONKOTSU: begin
        broth_need = portion_reg ? 500 : 300;
        tonkotsu_need = portion_reg ? 200 : 150;
    end
    TONKOTSU_SOY: begin
        broth_need = portion_reg ? 500 : 300;
        tonkotsu_need = portion_reg ? 150 : 100;
        soy_need = portion_reg ? 50 : 30;
    end
    MISO: begin
        broth_need = portion_reg ? 650 : 400;
        miso_need = portion_reg ? 50 : 30;
    end
    MISO_SOY: begin
        broth_need = portion_reg ? 500 : 300;
        tonkotsu_need = portion_reg ? 100 : 70;
        miso_need = portion_reg ? 25 : 15;
        soy_need = portion_reg ? 25 : 15;
    end
    endcase
end

always @(*) begin
    t_sn = sold_num[27:21]; ts_sn = sold_num[20:14]; m_sn = sold_num[13:7]; ms_sn = sold_num[6:0]; 
    gain_nxt = total_gain;
    if(in_valid_reg1) begin
        case(type_reg)
        TONKOTSU: begin
            if(success_nxt) begin
                t_sn = t_sn + 1;
                gain_nxt = gain_nxt + 200;
            end
        end
        TONKOTSU_SOY: begin
            if(success_nxt) begin
                ts_sn = ts_sn + 1;
                gain_nxt = gain_nxt + 250;
            end
        end
        MISO: begin
            if(success_nxt) begin
                m_sn = m_sn + 1;
                gain_nxt = gain_nxt + 200;
            end
        end
        MISO_SOY: begin
            if(success_nxt) begin
                ms_sn = ms_sn + 1;
                gain_nxt = gain_nxt + 250;
            end
        end
        endcase
    end else if(out_valid_tot) begin
        t_sn = 0; ts_sn = 0; m_sn = 0; ms_sn = 0;
        gain_nxt = 0;
    end
end

endmodule
