//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Convolution Neural Network 
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CNN.v
//   Module Name : CNN
//   Release version : V1.0 (Release Date: 2024-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel_ch1,
    Kernel_ch2,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
parameter inst_rnd = 3'd0;

parameter IDLE = 3'd0;
parameter IN = 3'd1;
parameter CAL = 3'd2;
parameter OUT = 3'd3;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel_ch1, Kernel_ch2, Weight;
input Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [6:0]   in_count;
reg opt_reg;
reg [31:0]  feature_map_0, feature_map_1, feature_map_2, feature_map_3, feature_map_4, feature_map_5, feature_map_6;

reg [31:0]  kernel1_00, kernel1_01, kernel1_02, kernel1_03, kernel1_10, kernel1_11, kernel1_12, kernel1_13, kernel1_20, kernel1_21, kernel1_22, kernel1_23;
reg [31:0]  kernel2_00, kernel2_01, kernel2_02, kernel2_03, kernel2_10, kernel2_11, kernel2_12, kernel2_13, kernel2_20, kernel2_21, kernel2_22, kernel2_23;

reg [31:0]  conv_map0_0, conv_map0_1, conv_map0_2, conv_map0_3, conv_map0_4, conv_map0_5, conv_map0_6, conv_map0_7, conv_map0_8, conv_map0_9, 
            conv_map0_10, conv_map0_11, conv_map0_12, conv_map0_13, conv_map0_14, conv_map0_15, conv_map0_16, conv_map0_17, conv_map0_18, conv_map0_19, 
            conv_map0_20, conv_map0_21, conv_map0_22, conv_map0_23, conv_map0_24, conv_map0_25, conv_map0_26, conv_map0_27, conv_map0_28, conv_map0_29,
            conv_map0_30, conv_map0_31, conv_map0_32, conv_map0_33, conv_map0_34, conv_map0_35;

reg [31:0]  conv_map1_0, conv_map1_1, conv_map1_2, conv_map1_3, conv_map1_4, conv_map1_5, conv_map1_6, conv_map1_7, conv_map1_8, conv_map1_9,
            conv_map1_10, conv_map1_11, conv_map1_12, conv_map1_13, conv_map1_14, conv_map1_15, conv_map1_16, conv_map1_17, conv_map1_18, conv_map1_19,
            conv_map1_20, conv_map1_21, conv_map1_22, conv_map1_23, conv_map1_24, conv_map1_25, conv_map1_26, conv_map1_27, conv_map1_28, conv_map1_29,
            conv_map1_30, conv_map1_31, conv_map1_32, conv_map1_33, conv_map1_34, conv_map1_35;

reg [31:0] conv0_dot0_a, conv0_dot0_c, conv0_dot0_e, conv0_dot0_g;
reg [31:0] conv1_dot0_a, conv1_dot0_c, conv1_dot0_e, conv1_dot0_g;
reg [31:0] conv0_dot0_b, conv0_dot0_d, conv0_dot0_f, conv0_dot0_h; 
reg [31:0] conv1_dot0_b, conv1_dot0_d, conv1_dot0_f, conv1_dot0_h;

reg [31:0] conv0_dot1_a, conv0_dot1_c, conv0_dot1_e, conv0_dot1_g;
reg [31:0] conv1_dot1_a, conv1_dot1_c, conv1_dot1_e, conv1_dot1_g;
reg [31:0] conv0_dot1_b, conv0_dot1_d, conv0_dot1_f, conv0_dot1_h;
reg [31:0] conv1_dot1_b, conv1_dot1_d, conv1_dot1_f, conv1_dot1_h;

reg [31:0] conv0_dot2_a, conv0_dot2_c, conv0_dot2_e, conv0_dot2_g;
reg [31:0] conv1_dot2_a, conv1_dot2_c, conv1_dot2_e, conv1_dot2_g;
reg [31:0] conv0_dot2_b, conv0_dot2_d, conv0_dot2_f, conv0_dot2_h;
reg [31:0] conv1_dot2_b, conv1_dot2_d, conv1_dot2_f, conv1_dot2_h;

reg [31:0] conv0_add0_b;
reg [31:0] conv0_add1_b;
reg [31:0] conv0_add2_b;
reg [31:0] conv1_add0_b;
reg [31:0] conv1_add1_b;
reg [31:0] conv1_add2_b;

reg [31:0] conv0_dot0, conv0_sum0, conv0_dot1, conv0_sum1, conv0_dot2, conv0_sum2;
reg [31:0] conv1_dot0, conv1_sum0, conv1_dot1, conv1_sum1, conv1_dot2, conv1_sum2;

reg [31:0] merged_to_act0, merged_to_act1, merged_to_act2, merged_to_act3;

reg [31:0] merged_to_fc0, merged_to_fc1, merged_to_fc2, merged_to_fc3, merged_to_fc4, merged_to_fc5, merged_to_fc6, merged_to_fc7;
reg [31:0] merged_to_fc8, merged_to_fc9, merged_to_fc10, merged_to_fc11, merged_to_fc12, merged_to_fc13, merged_to_fc14, merged_to_fc15;
reg [31:0] merged_to_fc16, merged_to_fc17, merged_to_fc18, merged_to_fc19, merged_to_fc20, merged_to_fc21, merged_to_fc22, merged_to_fc23;
reg [31:0] merged_to_fc24, merged_to_fc25, merged_to_fc26;
reg [31:0] merged_to_fc27;

reg [31:0] merged_to_SM0, merged_to_SM1;

reg [31:0] act0, act1, act2, act3;

reg [31:0] fc0_0, fc0_1, fc1_0, fc1_1, fc2_0, fc2_1;

//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------
DW_fp_dp4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) FP0_DOT0 ( .a(merged_to_fc0), .b(merged_to_fc1), .c(merged_to_fc2), .d(merged_to_fc3), .e(merged_to_fc4), .f(merged_to_fc5), .g(merged_to_fc6), .h(merged_to_fc7), .rnd(inst_rnd), .z(conv0_dot0) );
DW_fp_dp4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) FP0_DOT1 ( .a(merged_to_fc8), .b(merged_to_fc9), .c(merged_to_fc10), .d(merged_to_fc11), .e(merged_to_fc12), .f(merged_to_fc13), .g(merged_to_fc14), .h(merged_to_fc15), .rnd(inst_rnd), .z(conv0_dot1) );
DW_fp_dp4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) FP0_DOT2 ( .a(merged_to_fc16), .b(merged_to_fc17), .c(merged_to_fc18), .d(merged_to_fc19), .e(merged_to_fc20), .f(merged_to_fc21), .g(merged_to_fc22), .h(merged_to_fc23), .rnd(inst_rnd), .z(conv0_dot2) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP0_ADD0 ( .a(conv0_dot0), .b(merged_to_fc25), .rnd(inst_rnd), .z(conv0_sum0));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP0_ADD1 ( .a(conv0_dot1), .b(merged_to_fc26), .rnd(inst_rnd), .z(conv0_sum1));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP0_ADD2 ( .a(merged_to_act2), .b(merged_to_act3), .rnd(inst_rnd), .z(conv0_sum2));

//---------------------------------------------------------------------

DW_fp_dp4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) FP1_DOT0 ( .a(conv1_dot0_a), .b(conv1_dot0_b), .c(conv1_dot0_c), .d(conv1_dot0_d), .e(conv1_dot0_e), .f(conv1_dot0_f), .g(conv1_dot0_g), .h(conv1_dot0_h), .rnd(inst_rnd), .z(conv1_dot0) );
DW_fp_dp4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) FP1_DOT1 ( .a(conv1_dot1_a), .b(conv1_dot1_b), .c(conv1_dot1_c), .d(conv1_dot1_d), .e(conv1_dot1_e), .f(conv1_dot1_f), .g(conv1_dot1_g), .h(conv1_dot1_h), .rnd(inst_rnd), .z(conv1_dot1) );
DW_fp_dp4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) FP1_DOT2 ( .a(conv1_dot2_a), .b(conv1_dot2_b), .c(conv1_dot2_c), .d(conv1_dot2_d), .e(conv1_dot2_e), .f(conv1_dot2_f), .g(conv1_dot2_g), .h(conv1_dot2_h), .rnd(inst_rnd), .z(conv1_dot2) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP1_ADD0 ( .a(merged_to_fc24), .b(merged_to_fc27), .rnd(inst_rnd), .z(conv1_sum0));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP1_ADD1 ( .a(merged_to_SM0), .b(merged_to_SM1), .rnd(inst_rnd), .z(conv1_sum1));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP1_ADD2 ( .a(merged_to_act0), .b(merged_to_act1), .rnd(inst_rnd), .z(conv1_sum2));

//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------
// Input Counter
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        in_count <= 0;
    end else begin
        if(in_valid) begin
            in_count <= 1;
        end
        if(in_count > 0) begin
            in_count <= in_count + 1;
        end
        if(in_count > 92) begin
            in_count <= 0;
        end
    end
end

// Opt
always @(posedge clk) begin
    if(in_count < 1) begin
        opt_reg <= Opt;
    end
end
// Kernel
always @(posedge clk) begin
    case(in_count)
    0: begin kernel1_00 <= Kernel_ch1; kernel2_00 <= Kernel_ch2; end    1: begin kernel1_01 <= Kernel_ch1; kernel2_01 <= Kernel_ch2; end
    2: begin kernel1_02 <= Kernel_ch1; kernel2_02 <= Kernel_ch2; end    3: begin kernel1_03 <= Kernel_ch1; kernel2_03 <= Kernel_ch2; end
    4: begin kernel1_10 <= Kernel_ch1; kernel2_10 <= Kernel_ch2; end    5: begin kernel1_11 <= Kernel_ch1; kernel2_11 <= Kernel_ch2; end
    6: begin kernel1_12 <= Kernel_ch1; kernel2_12 <= Kernel_ch2; end    7: begin kernel1_13 <= Kernel_ch1; kernel2_13 <= Kernel_ch2; end
    8: begin kernel1_20 <= Kernel_ch1; kernel2_20 <= Kernel_ch2; end    9: begin kernel1_21 <= Kernel_ch1; kernel2_21 <= Kernel_ch2; end
    10: begin kernel1_22 <= Kernel_ch1; kernel2_22 <= Kernel_ch2; end   11: begin kernel1_23 <= Kernel_ch1; kernel2_23 <= Kernel_ch2; end
    // 31, 56: begin kernel1_00 <= kernel1_10; kernel1_01 <= kernel1_11; kernel1_02 <= kernel1_12; kernel1_03 <= kernel1_13;
    //               kernel2_00 <= kernel2_10; kernel2_01 <= kernel2_11; kernel2_02 <= kernel2_12; kernel2_03 <= kernel2_13; 
    //               kernel1_10 <= kernel1_20; kernel1_11 <= kernel1_21; kernel1_12 <= kernel1_22; kernel1_13 <= kernel1_23;
    //               kernel2_10 <= kernel2_20; kernel2_11 <= kernel2_21; kernel2_12 <= kernel2_22; kernel2_13 <= kernel2_23; end
    endcase
end

// Weight
reg [31:0]  weight00, weight01, weight02, weight03, weight04, weight05, weight06, weight07;
reg [31:0]  weight10, weight11, weight12, weight13, weight14, weight15, weight16, weight17;
reg [31:0]  weight20, weight21, weight22, weight23, weight24, weight25, weight26, weight27;
always @(posedge clk) begin
    if(in_count < 24) begin
        weight00 <= weight01; weight01 <= weight02; weight02 <= weight03; weight03 <= weight04; weight04 <= weight05; weight05 <= weight06; weight06 <= weight07; weight07 <= weight10;
        weight10 <= weight11; weight11 <= weight12; weight12 <= weight13; weight13 <= weight14; weight14 <= weight15; weight15 <= weight16; weight16 <= weight17; weight17 <= weight20;
        weight20 <= weight21; weight21 <= weight22; weight22 <= weight23; weight23 <= weight24; weight24 <= weight25; weight25 <= weight26; weight26 <= weight27; weight27 <= Weight;
    end
end

// Feature Map Buffer
always @(posedge clk) begin
    feature_map_6 <= feature_map_5; feature_map_5 <= feature_map_4; feature_map_4 <= feature_map_3;
    feature_map_3 <= feature_map_2; feature_map_2 <= feature_map_1; feature_map_1 <= feature_map_0; feature_map_0 <= Img;
end

// Feature Map0
always @(posedge clk) begin
    if(in_count >= 6 && in_count < 26) begin 
        conv_map0_6 <= conv_map0_7; conv_map0_7 <= conv_map0_8; conv_map0_8 <= conv_map0_9; conv_map0_9 <= conv_map0_10; conv_map0_10 <= conv_map0_12;
        conv_map0_12 <= conv_map0_13; conv_map0_13 <= conv_map0_14; conv_map0_14 <= conv_map0_15; conv_map0_15 <= conv_map0_16; conv_map0_16 <= conv_map0_18;
        conv_map0_18 <= conv_map0_19; conv_map0_19 <= conv_map0_20; conv_map0_20 <= conv_map0_21; conv_map0_21 <= conv_map0_22; conv_map0_22 <= conv_map0_24;
        conv_map0_24 <= conv_map0_25; conv_map0_25 <= conv_map0_26; conv_map0_26 <= conv_map0_27; conv_map0_27 <= conv_map0_28; conv_map0_28 <= conv0_dot0; 
    end else if(in_count >= 31 && in_count < 51 || in_count >= 56 && in_count < 76) begin
        conv_map0_6 <= conv_map0_7; conv_map0_7 <= conv_map0_8; conv_map0_8 <= conv_map0_9; conv_map0_9 <= conv_map0_10; conv_map0_10 <= conv_map0_12;
        conv_map0_12 <= conv_map0_13; conv_map0_13 <= conv_map0_14; conv_map0_14 <= conv_map0_15; conv_map0_15 <= conv_map0_16; conv_map0_16 <= conv_map0_18;
        conv_map0_18 <= conv_map0_19; conv_map0_19 <= conv_map0_20; conv_map0_20 <= conv_map0_21; conv_map0_21 <= conv_map0_22; conv_map0_22 <= conv_map0_24;
        conv_map0_24 <= conv_map0_25; conv_map0_25 <= conv_map0_26; conv_map0_26 <= conv_map0_27; conv_map0_27 <= conv_map0_28; conv_map0_28 <= conv0_sum0;
    end
    if(in_count == 4) begin
        conv_map0_0 <= conv0_dot0;
    end else if(in_count == 26 || in_count == 51) begin
        conv_map0_0 <= conv0_sum0;
    end
end
always @(*) begin
    conv0_dot0_a  = 0; conv0_dot0_c  = 0; conv0_dot0_e  = 0; conv0_dot0_g  = 0;
    conv0_dot0_b  = 0; conv0_dot0_d  = 0; conv0_dot0_f  = 0; conv0_dot0_h  = 0;
    conv0_add0_b = 0;
    if(in_count == 4) begin
        if(opt_reg) begin
            conv0_dot0_a = feature_map_3; conv0_dot0_c = feature_map_3; conv0_dot0_e = feature_map_3; conv0_dot0_g = feature_map_3;
            conv0_dot0_b = kernel1_00; conv0_dot0_d = kernel1_01; conv0_dot0_f = kernel1_02; conv0_dot0_h = kernel1_03;
        end else begin
            conv0_dot0_a = feature_map_3;
            conv0_dot0_b = kernel1_03;
        end
    end else if (in_count == 26) begin
        conv0_add0_b = conv_map0_0;
        if(opt_reg) begin
            conv0_dot0_a = feature_map_0; conv0_dot0_c = feature_map_0; conv0_dot0_e = feature_map_0; conv0_dot0_g = feature_map_0;
            conv0_dot0_b = kernel1_10; conv0_dot0_d = kernel1_11; conv0_dot0_f = kernel1_12; conv0_dot0_h = kernel1_13;
        end else begin
            conv0_dot0_a = feature_map_0;
            conv0_dot0_b = kernel1_13;
        end
    end else if (in_count == 51) begin
        conv0_add0_b = conv_map0_0;
        if(opt_reg) begin
            conv0_dot0_a = feature_map_0; conv0_dot0_c = feature_map_0; conv0_dot0_e = feature_map_0; conv0_dot0_g = feature_map_0;
            conv0_dot0_b = kernel1_20; conv0_dot0_d = kernel1_21; conv0_dot0_f = kernel1_22; conv0_dot0_h = kernel1_23;
        end else begin
            conv0_dot0_a = feature_map_0;
            conv0_dot0_b = kernel1_23;
        end
    end else if(in_count == 6 || in_count == 11 || in_count == 16 || in_count == 21) begin
        if(opt_reg) begin
            conv0_dot0_a = feature_map_5; conv0_dot0_c = feature_map_0; conv0_dot0_e = feature_map_5; conv0_dot0_g = feature_map_0;
            conv0_dot0_b = kernel1_01; conv0_dot0_d = kernel1_03; conv0_dot0_f = kernel1_00; conv0_dot0_h = kernel1_02;
        end else begin
            conv0_dot0_a = feature_map_5; conv0_dot0_c = feature_map_0;
            conv0_dot0_b = kernel1_01; conv0_dot0_d = kernel1_03;
        end
    end else if(in_count == 31 || in_count == 36 || in_count == 41 || in_count == 46) begin
        conv0_add0_b = conv_map0_6;
        if(opt_reg) begin
            conv0_dot0_a = feature_map_5; conv0_dot0_c = feature_map_0; conv0_dot0_e = feature_map_5; conv0_dot0_g = feature_map_0;
            conv0_dot0_b = kernel1_11; conv0_dot0_d = kernel1_13; conv0_dot0_f = kernel1_10; conv0_dot0_h = kernel1_12;
        end else begin
            conv0_dot0_a = feature_map_5; conv0_dot0_c = feature_map_0;
            conv0_dot0_b = kernel1_11; conv0_dot0_d = kernel1_13;
        end
    end else if(in_count == 56 || in_count == 61 || in_count == 66 || in_count == 71) begin
        conv0_add0_b = conv_map0_6;
        if(opt_reg) begin
            conv0_dot0_a = feature_map_5; conv0_dot0_c = feature_map_0; conv0_dot0_e = feature_map_5; conv0_dot0_g = feature_map_0;
            conv0_dot0_b = kernel1_21; conv0_dot0_d = kernel1_23; conv0_dot0_f = kernel1_20; conv0_dot0_h = kernel1_22;
        end else begin
            conv0_dot0_a = feature_map_5; conv0_dot0_c = feature_map_0;
            conv0_dot0_b = kernel1_21; conv0_dot0_d = kernel1_23;
        end
    end else if( in_count > 6 && in_count < 26 ) begin
        conv0_dot0_a = feature_map_6; conv0_dot0_c = feature_map_5; conv0_dot0_e = feature_map_1; conv0_dot0_g = feature_map_0;
        conv0_dot0_b = kernel1_00; conv0_dot0_d = kernel1_01; conv0_dot0_f = kernel1_02; conv0_dot0_h = kernel1_03;
    end else if( in_count > 31 && in_count < 51 ) begin  
        conv0_dot0_a = feature_map_6; conv0_dot0_c = feature_map_5; conv0_dot0_e = feature_map_1; conv0_dot0_g = feature_map_0;  
        conv0_dot0_b = kernel1_10; conv0_dot0_d = kernel1_11; conv0_dot0_f = kernel1_12; conv0_dot0_h = kernel1_13;
        conv0_add0_b = conv_map0_6;
    end else if( in_count > 56 && in_count < 76 ) begin 
        conv0_dot0_a = feature_map_6; conv0_dot0_c = feature_map_5; conv0_dot0_e = feature_map_1; conv0_dot0_g = feature_map_0;
        conv0_dot0_b = kernel1_20; conv0_dot0_d = kernel1_21; conv0_dot0_f = kernel1_22; conv0_dot0_h = kernel1_23;
        conv0_add0_b = conv_map0_6;
    end
end
always @(posedge clk) begin
    if(in_count > 3 && in_count < 8) begin
        conv_map0_1 <= conv_map0_2; conv_map0_2 <= conv_map0_3; conv_map0_3 <= conv_map0_4;
        conv_map0_4 <= conv0_dot1;
    end else if(in_count > 26 && in_count < 31 || in_count > 51 && in_count < 56) begin
        conv_map0_1 <= conv_map0_2; conv_map0_2 <= conv_map0_3; conv_map0_3 <= conv_map0_4;
        conv_map0_4 <= conv0_sum1;
    end
    if(in_count > 21 && in_count < 26) begin
        conv_map0_31 <= conv_map0_32; conv_map0_32 <= conv_map0_33; conv_map0_33 <= conv_map0_34; 
        conv_map0_34 <= conv0_dot1;
    end else if(in_count > 46 && in_count < 51 || in_count > 71 && in_count < 76) begin
        conv_map0_31 <= conv_map0_32; conv_map0_32 <= conv_map0_33; conv_map0_33 <= conv_map0_34; 
        conv_map0_34 <= conv0_sum1;
    end
    if(in_count == 21) begin
        conv_map0_30 <= conv0_dot1;
    end else if(in_count == 46 || in_count == 71) begin
        conv_map0_30 <= conv0_sum1;
    end
end
always @(*) begin
    conv0_dot1_a  = 0; conv0_dot1_c  = 0; conv0_dot1_e  = 0; conv0_dot1_g  = 0;
    conv0_dot1_b  = 0; conv0_dot1_d  = 0; conv0_dot1_f  = 0; conv0_dot1_h  = 0;
    conv0_add1_b = 0;
    if(in_count > 3 && in_count < 8) begin
        if(opt_reg) begin
            conv0_dot1_a = feature_map_3; conv0_dot1_c = feature_map_2; conv0_dot1_e = feature_map_3; conv0_dot1_g = feature_map_2;
            conv0_dot1_b = kernel1_02; conv0_dot1_d = kernel1_03; conv0_dot1_f = kernel1_00; conv0_dot1_h = kernel1_01;
        end else begin
            conv0_dot1_a = feature_map_3; conv0_dot1_c = feature_map_2;
            conv0_dot1_b = kernel1_02; conv0_dot1_d = kernel1_03;
        end
    end else if (in_count > 26 && in_count < 31) begin
        conv0_add1_b = conv_map0_1;
        if(opt_reg) begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_1; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_12; conv0_dot1_d = kernel1_13; conv0_dot1_f = kernel1_10; conv0_dot1_h = kernel1_11;
        end else begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0;
            conv0_dot1_b = kernel1_12; conv0_dot1_d = kernel1_13;
        end
    end else if (in_count > 51 && in_count < 56) begin
        conv0_add1_b = conv_map0_1;
        if(opt_reg) begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_1; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_22; conv0_dot1_d = kernel1_23; conv0_dot1_f = kernel1_20; conv0_dot1_h = kernel1_21;
        end else begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0;
            conv0_dot1_b = kernel1_22; conv0_dot1_d = kernel1_23;
        end
    end
    if(in_count > 21 && in_count < 26) begin
        if(opt_reg) begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_1; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_00; conv0_dot1_d = kernel1_01; conv0_dot1_f = kernel1_02; conv0_dot1_h = kernel1_03;
        end else begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0;
            conv0_dot1_b = kernel1_00; conv0_dot1_d = kernel1_01;
        end
    end else if(in_count > 46 && in_count < 51) begin
        conv0_add1_b = conv_map0_31;
        if(opt_reg) begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_1; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_10; conv0_dot1_d = kernel1_11; conv0_dot1_f = kernel1_12; conv0_dot1_h = kernel1_13;
        end else begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0;
            conv0_dot1_b = kernel1_10; conv0_dot1_d = kernel1_11;
        end
    end else if(in_count > 71 && in_count < 76) begin
        conv0_add1_b = conv_map0_31;
        if(opt_reg) begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_1; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_20; conv0_dot1_d = kernel1_21; conv0_dot1_f = kernel1_22; conv0_dot1_h = kernel1_23;
        end else begin
            conv0_dot1_a = feature_map_1; conv0_dot1_c = feature_map_0;
            conv0_dot1_b = kernel1_20; conv0_dot1_d = kernel1_21;
        end
    end
    if(in_count == 21) begin
        if(opt_reg) begin
            conv0_dot1_a = feature_map_0; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_0; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_03; conv0_dot1_d = kernel1_02; conv0_dot1_f = kernel1_01; conv0_dot1_h = kernel1_00;
        end else begin
            conv0_dot1_a = feature_map_0;
            conv0_dot1_b = kernel1_01;
        end
    end else if(in_count == 46) begin
        conv0_add1_b = conv_map0_30;
        if(opt_reg) begin
            conv0_dot1_a = feature_map_0; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_0; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_13; conv0_dot1_d = kernel1_12; conv0_dot1_f = kernel1_11; conv0_dot1_h = kernel1_10;
        end else begin
            conv0_dot1_a = feature_map_0;
            conv0_dot1_b = kernel1_11;
        end
    end else if(in_count == 71) begin
        conv0_add1_b = conv_map0_30;
        if(opt_reg) begin
            conv0_dot1_a = feature_map_0; conv0_dot1_c = feature_map_0; conv0_dot1_e = feature_map_0; conv0_dot1_g = feature_map_0;
            conv0_dot1_b = kernel1_23; conv0_dot1_d = kernel1_22; conv0_dot1_f = kernel1_21; conv0_dot1_h = kernel1_20;
        end else begin
            conv0_dot1_a = feature_map_0;
            conv0_dot1_b = kernel1_21;
        end
    end
end
always @ (posedge clk) begin
    if(in_count == 10 || in_count == 15 || in_count == 20 || in_count == 25) begin
        conv_map0_11 <= conv_map0_17; conv_map0_17 <= conv_map0_23; conv_map0_23 <= conv_map0_29; 
        conv_map0_29 <= conv0_dot2;
    end else if(in_count == 35 || in_count == 40 || in_count == 45 || in_count == 50 || 
                in_count == 60 || in_count == 65 || in_count == 70 || in_count == 75) begin
        conv_map0_11 <= conv_map0_17; conv_map0_17 <= conv_map0_23; conv_map0_23 <= conv_map0_29; 
        conv_map0_29 <= conv0_sum2;
    end
    if(in_count == 5) begin
        conv_map0_5 <= conv0_dot2;
    end else if(in_count == 30 || in_count == 55) begin
        conv_map0_5 <= conv0_sum2;
    end
    if(in_count == 26) begin
        conv_map0_35 <= conv0_dot2;
    end else if(in_count == 51 || in_count == 76) begin
        conv_map0_35 <= conv0_sum2;
    end
end
always @ (*) begin
    conv0_dot2_a  = 0; conv0_dot2_c  = 0; conv0_dot2_e  = 0; conv0_dot2_g  = 0;
    conv0_dot2_b  = 0; conv0_dot2_d  = 0; conv0_dot2_f  = 0; conv0_dot2_h  = 0;
    conv0_add2_b = 0;
    if(in_count == 10 || in_count == 15 || in_count == 20 || in_count == 25) begin
        if(opt_reg) begin
            conv0_dot2_a = feature_map_5; conv0_dot2_c = feature_map_0; conv0_dot2_e = feature_map_5; conv0_dot2_g = feature_map_0;
            conv0_dot2_b = kernel1_00; conv0_dot2_d = kernel1_02; conv0_dot2_f = kernel1_01; conv0_dot2_h = kernel1_03;
        end else begin
            conv0_dot2_a = feature_map_5; conv0_dot2_c = feature_map_0;
            conv0_dot2_b = kernel1_00; conv0_dot2_d = kernel1_02;
        end
    end else if(in_count == 35 || in_count == 40 || in_count == 45 || in_count == 50) begin
        conv0_add2_b = conv_map0_11;
        if(opt_reg) begin
            conv0_dot2_a = feature_map_5; conv0_dot2_c = feature_map_0; conv0_dot2_e = feature_map_5; conv0_dot2_g = feature_map_0;
            conv0_dot2_b = kernel1_10; conv0_dot2_d = kernel1_12; conv0_dot2_f = kernel1_11; conv0_dot2_h = kernel1_13;
        end else begin
            conv0_dot2_a = feature_map_5; conv0_dot2_c = feature_map_0;
            conv0_dot2_b = kernel1_10; conv0_dot2_d = kernel1_12;
        end
    end else if(in_count == 60 || in_count == 65 || in_count == 70 || in_count == 75) begin
        conv0_add2_b = conv_map0_11;
        if(opt_reg) begin
            conv0_dot2_a = feature_map_5; conv0_dot2_c = feature_map_0; conv0_dot2_e = feature_map_5; conv0_dot2_g = feature_map_0;
            conv0_dot2_b = kernel1_20; conv0_dot2_d = kernel1_22; conv0_dot2_f = kernel1_21; conv0_dot2_h = kernel1_23;
        end else begin
            conv0_dot2_a = feature_map_5; conv0_dot2_c = feature_map_0;
            conv0_dot2_b = kernel1_20; conv0_dot2_d = kernel1_22;
        end
    end
    if(in_count == 5) begin
        if(opt_reg) begin
            conv0_dot2_a = feature_map_0; conv0_dot2_c = feature_map_0; conv0_dot2_e = feature_map_0; conv0_dot2_g = feature_map_0;
            conv0_dot2_b = kernel1_03; conv0_dot2_d = kernel1_01; conv0_dot2_f = kernel1_02; conv0_dot2_h = kernel1_00;
        end else begin
            conv0_dot2_a = feature_map_0;
            conv0_dot2_b = kernel1_02;
        end
    end else if(in_count == 30) begin
        conv0_add2_b = conv_map0_5;
        if(opt_reg) begin
            conv0_dot2_a = feature_map_0; conv0_dot2_c = feature_map_0; conv0_dot2_e = feature_map_0; conv0_dot2_g = feature_map_0;
            conv0_dot2_b = kernel1_13; conv0_dot2_d = kernel1_11; conv0_dot2_f = kernel1_12; conv0_dot2_h = kernel1_10;
        end else begin
            conv0_dot2_a = feature_map_0;
            conv0_dot2_b = kernel1_12;
        end
    end else if(in_count == 55) begin
        conv0_add2_b = conv_map0_5;
        if(opt_reg) begin
            conv0_dot2_a = feature_map_0; conv0_dot2_c = feature_map_0; conv0_dot2_e = feature_map_0; conv0_dot2_g = feature_map_0;
            conv0_dot2_b = kernel1_23; conv0_dot2_d = kernel1_21; conv0_dot2_f = kernel1_22; conv0_dot2_h = kernel1_20;
        end else begin
            conv0_dot2_a = feature_map_0;
            conv0_dot2_b = kernel1_22;
        end
    end
    if(in_count == 26) begin
        if(opt_reg) begin
            conv0_dot2_a = feature_map_1; conv0_dot2_c = feature_map_1; conv0_dot2_e = feature_map_1; conv0_dot2_g = feature_map_1;
            conv0_dot2_b = kernel1_03; conv0_dot2_d = kernel1_01; conv0_dot2_f = kernel1_02; conv0_dot2_h = kernel1_00;
        end else begin
            conv0_dot2_a = feature_map_1;
            conv0_dot2_b = kernel1_00;
        end
    end else if(in_count == 51) begin
        conv0_add2_b = conv_map0_35;
        if(opt_reg) begin
            conv0_dot2_a = feature_map_1; conv0_dot2_c = feature_map_1; conv0_dot2_e = feature_map_1; conv0_dot2_g = feature_map_1;
            conv0_dot2_b = kernel1_13; conv0_dot2_d = kernel1_11; conv0_dot2_f = kernel1_12; conv0_dot2_h = kernel1_10;
        end else begin
            conv0_dot2_a = feature_map_1;
            conv0_dot2_b = kernel1_10;
        end
    end else if(in_count == 76) begin
        conv0_add2_b = conv_map0_35;
        if(opt_reg) begin
            conv0_dot2_a = feature_map_1; conv0_dot2_c = feature_map_1; conv0_dot2_e = feature_map_1; conv0_dot2_g = feature_map_1;
            conv0_dot2_b = kernel1_23; conv0_dot2_d = kernel1_21; conv0_dot2_f = kernel1_22; conv0_dot2_h = kernel1_20;
        end else begin
            conv0_dot2_a = feature_map_1;
            conv0_dot2_b = kernel1_20;
        end
    end
end

// Feature Map1
always @(posedge clk) begin
    if(in_count >= 6 && in_count < 26) begin 
        conv_map1_6 <= conv_map1_7; conv_map1_7 <= conv_map1_8; conv_map1_8 <= conv_map1_9; conv_map1_9 <= conv_map1_10; conv_map1_10 <= conv_map1_12;
        conv_map1_12 <= conv_map1_13; conv_map1_13 <= conv_map1_14; conv_map1_14 <= conv_map1_15; conv_map1_15 <= conv_map1_16; conv_map1_16 <= conv_map1_18;
        conv_map1_18 <= conv_map1_19; conv_map1_19 <= conv_map1_20; conv_map1_20 <= conv_map1_21; conv_map1_21 <= conv_map1_22; conv_map1_22 <= conv_map1_24;
        conv_map1_24 <= conv_map1_25; conv_map1_25 <= conv_map1_26; conv_map1_26 <= conv_map1_27; conv_map1_27 <= conv_map1_28; conv_map1_28 <= conv1_dot0; 
    end else if(in_count >= 31 && in_count < 51 || in_count >= 56 && in_count < 76) begin
        conv_map1_6 <= conv_map1_7; conv_map1_7 <= conv_map1_8; conv_map1_8 <= conv_map1_9; conv_map1_9 <= conv_map1_10; conv_map1_10 <= conv_map1_12;
        conv_map1_12 <= conv_map1_13; conv_map1_13 <= conv_map1_14; conv_map1_14 <= conv_map1_15; conv_map1_15 <= conv_map1_16; conv_map1_16 <= conv_map1_18;
        conv_map1_18 <= conv_map1_19; conv_map1_19 <= conv_map1_20; conv_map1_20 <= conv_map1_21; conv_map1_21 <= conv_map1_22; conv_map1_22 <= conv_map1_24;
        conv_map1_24 <= conv_map1_25; conv_map1_25 <= conv_map1_26; conv_map1_26 <= conv_map1_27; conv_map1_27 <= conv_map1_28; conv_map1_28 <= conv1_sum0;
    end
    if(in_count == 4) begin
        conv_map1_0 <= conv1_dot0;
    end else if(in_count == 26 || in_count == 51) begin
        conv_map1_0 <= conv1_sum0;
    end
end
always @(*) begin
    conv1_dot0_a  = 0; conv1_dot0_c  = 0; conv1_dot0_e  = 0; conv1_dot0_g  = 0;
    conv1_dot0_b  = 0; conv1_dot0_d  = 0; conv1_dot0_f  = 0; conv1_dot0_h  = 0;
    conv1_add0_b = 0;
    if(in_count == 4) begin
        if(opt_reg) begin
            conv1_dot0_a = feature_map_3; conv1_dot0_c = feature_map_3; conv1_dot0_e = feature_map_3; conv1_dot0_g = feature_map_3;
            conv1_dot0_b = kernel2_00; conv1_dot0_d = kernel2_01; conv1_dot0_f = kernel2_02; conv1_dot0_h = kernel2_03;
        end else begin
            conv1_dot0_a = feature_map_3;
            conv1_dot0_b = kernel2_03;
        end
    end else if (in_count == 26) begin
        conv1_add0_b = conv_map1_0;
        if(opt_reg) begin
            conv1_dot0_a = feature_map_0; conv1_dot0_c = feature_map_0; conv1_dot0_e = feature_map_0; conv1_dot0_g = feature_map_0;
            conv1_dot0_b = kernel2_10; conv1_dot0_d = kernel2_11; conv1_dot0_f = kernel2_12; conv1_dot0_h = kernel2_13;
        end else begin
            conv1_dot0_a = feature_map_0;
            conv1_dot0_b = kernel2_13;
        end
    end else if (in_count == 51) begin
        conv1_add0_b = conv_map1_0;
        if(opt_reg) begin
            conv1_dot0_a = feature_map_0; conv1_dot0_c = feature_map_0; conv1_dot0_e = feature_map_0; conv1_dot0_g = feature_map_0;
            conv1_dot0_b = kernel2_20; conv1_dot0_d = kernel2_21; conv1_dot0_f = kernel2_22; conv1_dot0_h = kernel2_23;
        end else begin
            conv1_dot0_a = feature_map_0;
            conv1_dot0_b = kernel2_23;
        end
    end else if(in_count == 6 || in_count == 11 || in_count == 16 || in_count == 21) begin
        if(opt_reg) begin
            conv1_dot0_a = feature_map_5; conv1_dot0_c = feature_map_0; conv1_dot0_e = feature_map_5; conv1_dot0_g = feature_map_0;
            conv1_dot0_b = kernel2_01; conv1_dot0_d = kernel2_03; conv1_dot0_f = kernel2_00; conv1_dot0_h = kernel2_02;
        end else begin
            conv1_dot0_a = feature_map_5; conv1_dot0_c = feature_map_0;
            conv1_dot0_b = kernel2_01; conv1_dot0_d = kernel2_03;
        end
    end else if(in_count == 31 || in_count == 36 || in_count == 41 || in_count == 46) begin
        conv1_add0_b = conv_map1_6;
        if(opt_reg) begin
            conv1_dot0_a = feature_map_5; conv1_dot0_c = feature_map_0; conv1_dot0_e = feature_map_5; conv1_dot0_g = feature_map_0;
            conv1_dot0_b = kernel2_11; conv1_dot0_d = kernel2_13; conv1_dot0_f = kernel2_10; conv1_dot0_h = kernel2_12;
        end else begin
            conv1_dot0_a = feature_map_5; conv1_dot0_c = feature_map_0;
            conv1_dot0_b = kernel2_11; conv1_dot0_d = kernel2_13;
        end
    end else if(in_count == 56 || in_count == 61 || in_count == 66 || in_count == 71) begin
        conv1_add0_b = conv_map1_6;
        if(opt_reg) begin
            conv1_dot0_a = feature_map_5; conv1_dot0_c = feature_map_0; conv1_dot0_e = feature_map_5; conv1_dot0_g = feature_map_0;
            conv1_dot0_b = kernel2_21; conv1_dot0_d = kernel2_23; conv1_dot0_f = kernel2_20; conv1_dot0_h = kernel2_22;
        end else begin
            conv1_dot0_a = feature_map_5; conv1_dot0_c = feature_map_0;
            conv1_dot0_b = kernel2_21; conv1_dot0_d = kernel2_23;
        end
    end else if( in_count > 6 && in_count < 26 ) begin
        conv1_dot0_a = feature_map_6; conv1_dot0_c = feature_map_5; conv1_dot0_e = feature_map_1; conv1_dot0_g = feature_map_0;
        conv1_dot0_b = kernel2_00; conv1_dot0_d = kernel2_01; conv1_dot0_f = kernel2_02; conv1_dot0_h = kernel2_03;
    end else if( in_count > 31 && in_count < 51 ) begin  
        conv1_dot0_a = feature_map_6; conv1_dot0_c = feature_map_5; conv1_dot0_e = feature_map_1; conv1_dot0_g = feature_map_0;  
        conv1_dot0_b = kernel2_10; conv1_dot0_d = kernel2_11; conv1_dot0_f = kernel2_12; conv1_dot0_h = kernel2_13;
        conv1_add0_b = conv_map1_6;
    end else if( in_count > 56 && in_count < 76 ) begin 
        conv1_dot0_a = feature_map_6; conv1_dot0_c = feature_map_5; conv1_dot0_e = feature_map_1; conv1_dot0_g = feature_map_0;
        conv1_dot0_b = kernel2_20; conv1_dot0_d = kernel2_21; conv1_dot0_f = kernel2_22; conv1_dot0_h = kernel2_23;
        conv1_add0_b = conv_map1_6;
    end
end
always @(posedge clk) begin
    if(in_count > 3 && in_count < 8) begin
        conv_map1_1 <= conv_map1_2; conv_map1_2 <= conv_map1_3; conv_map1_3 <= conv_map1_4;
        conv_map1_4 <= conv1_dot1;
    end else if(in_count > 26 && in_count < 31 || in_count > 51 && in_count < 56) begin
        conv_map1_1 <= conv_map1_2; conv_map1_2 <= conv_map1_3; conv_map1_3 <= conv_map1_4;
        conv_map1_4 <= conv1_sum1;
    end
    if(in_count > 21 && in_count < 26) begin
        conv_map1_31 <= conv_map1_32; conv_map1_32 <= conv_map1_33; conv_map1_33 <= conv_map1_34; 
        conv_map1_34 <= conv1_dot1;
    end else if(in_count > 46 && in_count < 51 || in_count > 71 && in_count < 76) begin
        conv_map1_31 <= conv_map1_32; conv_map1_32 <= conv_map1_33; conv_map1_33 <= conv_map1_34; 
        conv_map1_34 <= conv1_sum1;
    end
    if(in_count == 21) begin
        conv_map1_30 <= conv1_dot1;
    end else if(in_count == 46 || in_count == 71) begin
        conv_map1_30 <= conv1_sum1;
    end
end
always @(*) begin
    conv1_dot1_a  = 0; conv1_dot1_c  = 0; conv1_dot1_e  = 0; conv1_dot1_g  = 0;
    conv1_dot1_b  = 0; conv1_dot1_d  = 0; conv1_dot1_f  = 0; conv1_dot1_h  = 0;
    conv1_add1_b = 0;
    if(in_count > 3 && in_count < 8) begin
        if(opt_reg) begin
            conv1_dot1_a = feature_map_3; conv1_dot1_c = feature_map_2; conv1_dot1_e = feature_map_3; conv1_dot1_g = feature_map_2;
            conv1_dot1_b = kernel2_02; conv1_dot1_d = kernel2_03; conv1_dot1_f = kernel2_00; conv1_dot1_h = kernel2_01;
        end else begin
            conv1_dot1_a = feature_map_3; conv1_dot1_c = feature_map_2;
            conv1_dot1_b = kernel2_02; conv1_dot1_d = kernel2_03;
        end
    end else if (in_count > 26 && in_count < 31) begin
        conv1_add1_b = conv_map1_1;
        if(opt_reg) begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_1; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_12; conv1_dot1_d = kernel2_13; conv1_dot1_f = kernel2_10; conv1_dot1_h = kernel2_11;
        end else begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0;
            conv1_dot1_b = kernel2_12; conv1_dot1_d = kernel2_13;
        end
    end else if (in_count > 51 && in_count < 56) begin
        conv1_add1_b = conv_map1_1;
        if(opt_reg) begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_1; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_22; conv1_dot1_d = kernel2_23; conv1_dot1_f = kernel2_20; conv1_dot1_h = kernel2_21;
        end else begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0;
            conv1_dot1_b = kernel2_22; conv1_dot1_d = kernel2_23;
        end
    end
    if(in_count > 21 && in_count < 26) begin
        if(opt_reg) begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_1; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_00; conv1_dot1_d = kernel2_01; conv1_dot1_f = kernel2_02; conv1_dot1_h = kernel2_03;
        end else begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0;
            conv1_dot1_b = kernel2_00; conv1_dot1_d = kernel2_01;
        end
    end else if(in_count > 46 && in_count < 51) begin
        conv1_add1_b = conv_map1_31;
        if(opt_reg) begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_1; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_10; conv1_dot1_d = kernel2_11; conv1_dot1_f = kernel2_12; conv1_dot1_h = kernel2_13;
        end else begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0;
            conv1_dot1_b = kernel2_10; conv1_dot1_d = kernel2_11;
        end
    end else if(in_count > 71 && in_count < 76) begin
        conv1_add1_b = conv_map1_31;
        if(opt_reg) begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_1; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_20; conv1_dot1_d = kernel2_21; conv1_dot1_f = kernel2_22; conv1_dot1_h = kernel2_23;
        end else begin
            conv1_dot1_a = feature_map_1; conv1_dot1_c = feature_map_0;
            conv1_dot1_b = kernel2_20; conv1_dot1_d = kernel2_21;
        end
    end
    if(in_count == 21) begin
        if(opt_reg) begin
            conv1_dot1_a = feature_map_0; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_0; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_03; conv1_dot1_d = kernel2_02; conv1_dot1_f = kernel2_01; conv1_dot1_h = kernel2_00;
        end else begin
            conv1_dot1_a = feature_map_0;
            conv1_dot1_b = kernel2_01;
        end
    end else if(in_count == 46) begin
        conv1_add1_b = conv_map1_30;
        if(opt_reg) begin
            conv1_dot1_a = feature_map_0; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_0; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_13; conv1_dot1_d = kernel2_12; conv1_dot1_f = kernel2_11; conv1_dot1_h = kernel2_10;
        end else begin
            conv1_dot1_a = feature_map_0;
            conv1_dot1_b = kernel2_11;
        end
    end else if(in_count == 71) begin
        conv1_add1_b = conv_map1_30;
        if(opt_reg) begin
            conv1_dot1_a = feature_map_0; conv1_dot1_c = feature_map_0; conv1_dot1_e = feature_map_0; conv1_dot1_g = feature_map_0;
            conv1_dot1_b = kernel2_23; conv1_dot1_d = kernel2_22; conv1_dot1_f = kernel2_21; conv1_dot1_h = kernel2_20;
        end else begin
            conv1_dot1_a = feature_map_0;
            conv1_dot1_b = kernel2_21;
        end
    end
end
always @ (posedge clk) begin
    if(in_count == 10 || in_count == 15 || in_count == 20 || in_count == 25) begin
        conv_map1_11 <= conv_map1_17; conv_map1_17 <= conv_map1_23; conv_map1_23 <= conv_map1_29; 
        conv_map1_29 <= conv1_dot2;
    end else if(in_count == 35 || in_count == 40 || in_count == 45 || in_count == 50 || 
                in_count == 60 || in_count == 65 || in_count == 70 || in_count == 75) begin
        conv_map1_11 <= conv_map1_17; conv_map1_17 <= conv_map1_23; conv_map1_23 <= conv_map1_29; 
        conv_map1_29 <= conv1_sum2;
    end
    if(in_count == 5) begin
        conv_map1_5 <= conv1_dot2;
    end else if(in_count == 30 || in_count == 55) begin
        conv_map1_5 <= conv1_sum2;
    end
    if(in_count == 26) begin
        conv_map1_35 <= conv1_dot2;
    end else if(in_count == 51 || in_count == 76) begin
        conv_map1_35 <= conv1_sum2;
    end
end
always @ (*) begin
    conv1_dot2_a  = 0; conv1_dot2_c  = 0; conv1_dot2_e  = 0; conv1_dot2_g  = 0;
    conv1_dot2_b  = 0; conv1_dot2_d  = 0; conv1_dot2_f  = 0; conv1_dot2_h  = 0;
    conv1_add2_b = 0;
    if(in_count == 10 || in_count == 15 || in_count == 20 || in_count == 25) begin
        if(opt_reg) begin
            conv1_dot2_a = feature_map_5; conv1_dot2_c = feature_map_0; conv1_dot2_e = feature_map_5; conv1_dot2_g = feature_map_0;
            conv1_dot2_b = kernel2_00; conv1_dot2_d = kernel2_02; conv1_dot2_f = kernel2_01; conv1_dot2_h = kernel2_03;
        end else begin
            conv1_dot2_a = feature_map_5; conv1_dot2_c = feature_map_0;
            conv1_dot2_b = kernel2_00; conv1_dot2_d = kernel2_02;
        end
    end else if(in_count == 35 || in_count == 40 || in_count == 45 || in_count == 50) begin
        conv1_add2_b = conv_map1_11;
        if(opt_reg) begin
            conv1_dot2_a = feature_map_5; conv1_dot2_c = feature_map_0; conv1_dot2_e = feature_map_5; conv1_dot2_g = feature_map_0;
            conv1_dot2_b = kernel2_10; conv1_dot2_d = kernel2_12; conv1_dot2_f = kernel2_11; conv1_dot2_h = kernel2_13;
        end else begin
            conv1_dot2_a = feature_map_5; conv1_dot2_c = feature_map_0;
            conv1_dot2_b = kernel2_10; conv1_dot2_d = kernel2_12;
        end
    end else if(in_count == 60 || in_count == 65 || in_count == 70 || in_count == 75) begin
        conv1_add2_b = conv_map1_11;
        if(opt_reg) begin
            conv1_dot2_a = feature_map_5; conv1_dot2_c = feature_map_0; conv1_dot2_e = feature_map_5; conv1_dot2_g = feature_map_0;
            conv1_dot2_b = kernel2_20; conv1_dot2_d = kernel2_22; conv1_dot2_f = kernel2_21; conv1_dot2_h = kernel2_23;
        end else begin
            conv1_dot2_a = feature_map_5; conv1_dot2_c = feature_map_0;
            conv1_dot2_b = kernel2_20; conv1_dot2_d = kernel2_22;
        end
    end
    if(in_count == 5) begin
        if(opt_reg) begin
            conv1_dot2_a = feature_map_0; conv1_dot2_c = feature_map_0; conv1_dot2_e = feature_map_0; conv1_dot2_g = feature_map_0;
            conv1_dot2_b = kernel2_03; conv1_dot2_d = kernel2_01; conv1_dot2_f = kernel2_02; conv1_dot2_h = kernel2_00;
        end else begin
            conv1_dot2_a = feature_map_0;
            conv1_dot2_b = kernel2_02;
        end
    end else if(in_count == 30) begin
        conv1_add2_b = conv_map1_5;
        if(opt_reg) begin
            conv1_dot2_a = feature_map_0; conv1_dot2_c = feature_map_0; conv1_dot2_e = feature_map_0; conv1_dot2_g = feature_map_0;
            conv1_dot2_b = kernel2_13; conv1_dot2_d = kernel2_11; conv1_dot2_f = kernel2_12; conv1_dot2_h = kernel2_10;
        end else begin
            conv1_dot2_a = feature_map_0;
            conv1_dot2_b = kernel2_12;
        end
    end else if(in_count == 55) begin
        conv1_add2_b = conv_map1_5;
        if(opt_reg) begin
            conv1_dot2_a = feature_map_0; conv1_dot2_c = feature_map_0; conv1_dot2_e = feature_map_0; conv1_dot2_g = feature_map_0;
            conv1_dot2_b = kernel2_23; conv1_dot2_d = kernel2_21; conv1_dot2_f = kernel2_22; conv1_dot2_h = kernel2_20;
        end else begin
            conv1_dot2_a = feature_map_0;
            conv1_dot2_b = kernel2_22;
        end
    end
    if(in_count == 26) begin
        if(opt_reg) begin
            conv1_dot2_a = feature_map_1; conv1_dot2_c = feature_map_1; conv1_dot2_e = feature_map_1; conv1_dot2_g = feature_map_1;
            conv1_dot2_b = kernel2_03; conv1_dot2_d = kernel2_01; conv1_dot2_f = kernel2_02; conv1_dot2_h = kernel2_00;
        end else begin
            conv1_dot2_a = feature_map_1;
            conv1_dot2_b = kernel2_00;
        end
    end else if(in_count == 51) begin
        conv1_add2_b = conv_map1_35;
        if(opt_reg) begin
            conv1_dot2_a = feature_map_1; conv1_dot2_c = feature_map_1; conv1_dot2_e = feature_map_1; conv1_dot2_g = feature_map_1;
            conv1_dot2_b = kernel2_13; conv1_dot2_d = kernel2_11; conv1_dot2_f = kernel2_12; conv1_dot2_h = kernel2_10;
        end else begin
            conv1_dot2_a = feature_map_1;
            conv1_dot2_b = kernel2_10;
        end
    end else if(in_count == 76) begin
        conv1_add2_b = conv_map1_35;
        if(opt_reg) begin
            conv1_dot2_a = feature_map_1; conv1_dot2_c = feature_map_1; conv1_dot2_e = feature_map_1; conv1_dot2_g = feature_map_1;
            conv1_dot2_b = kernel2_23; conv1_dot2_d = kernel2_21; conv1_dot2_f = kernel2_22; conv1_dot2_h = kernel2_20;
        end else begin
            conv1_dot2_a = feature_map_1;
            conv1_dot2_b = kernel2_20;
        end
    end
end

// Max Pooling
reg [31:0] sort0, sort1, sort2, sort3, sort4, sort5, sort6, sort7, sort8; 
reg [31:0] sort00, sort01, sort02;
reg [31:0] sort10, sort11, sort12;
reg [31:0] sort20;
reg [31:0] maxima;
reg [31:0] max0_0, max0_1, max0_2, max0_3;
reg [31:0] max1_0, max1_1, max1_2, max1_3;
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP0 ( .a(sort0), .b(sort1), .zctr(1'b1), .z0(sort00));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP1 ( .a(sort2), .b(sort3), .zctr(1'b1), .z0(sort01));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP2 ( .a(sort4), .b(sort5), .zctr(1'b1), .z0(sort02));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP3 ( .a(sort6), .b(sort00), .zctr(1'b1), .z0(sort10));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP4 ( .a(sort7), .b(sort01), .zctr(1'b1), .z0(sort11));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP5 ( .a(sort8), .b(sort02), .zctr(1'b1), .z0(sort12));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP6 ( .a(sort10), .b(sort11), .zctr(1'b1), .z0(sort20));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) FP_CMP7 ( .a(sort20), .b(sort12), .zctr(1'b1), .z0(maxima));
always @(*) begin
    sort0 = 0; sort1 = 0; sort2 = 0; sort3 = 0; sort4 = 0; sort5 = 0; sort6 = 0; sort7 = 0; sort8 = 0;
    case(in_count) 
    76: begin 
        sort0 = conv_map0_0; sort1 = conv_map0_1; sort2 = conv_map0_2; 
        sort3 = conv_map0_6; sort4 = conv_map0_7; sort5 = conv_map0_8; 
        sort6 = conv_map0_12; sort7 = conv_map0_13; sort8 = conv_map0_14;
    end
    77: begin 
        sort0 = conv_map0_3; sort1 = conv_map0_4; sort2 = conv_map0_5;
        sort3 = conv_map0_9; sort4 = conv_map0_10; sort5 = conv_map0_11;
        sort6 = conv_map0_15; sort7 = conv_map0_16; sort8 = conv_map0_17;
    end
    78: begin 
        sort0 = conv_map1_0; sort1 = conv_map1_1; sort2 = conv_map1_2;
        sort3 = conv_map1_6; sort4 = conv_map1_7; sort5 = conv_map1_8;
        sort6 = conv_map1_12; sort7 = conv_map1_13; sort8 = conv_map1_14;
    end
    79: begin 
        sort0 = conv_map1_3; sort1 = conv_map1_4; sort2 = conv_map1_5;
        sort3 = conv_map1_9; sort4 = conv_map1_10; sort5 = conv_map1_11;
        sort6 = conv_map1_15; sort7 = conv_map1_16; sort8 = conv_map1_17;
    end
    80: begin
        sort0 = conv_map0_18; sort1 = conv_map0_19; sort2 = conv_map0_20;
        sort3 = conv_map0_24; sort4 = conv_map0_25; sort5 = conv_map0_26;
        sort6 = conv_map0_30; sort7 = conv_map0_31; sort8 = conv_map0_32;
    end
    81: begin
        sort0 = conv_map0_21; sort1 = conv_map0_22; sort2 = conv_map0_23;
        sort3 = conv_map0_27; sort4 = conv_map0_28; sort5 = conv_map0_29;
        sort6 = conv_map0_33; sort7 = conv_map0_34; sort8 = conv_map0_35;
    end
    82: begin
        sort0 = conv_map1_18; sort1 = conv_map1_19; sort2 = conv_map1_20;
        sort3 = conv_map1_24; sort4 = conv_map1_25; sort5 = conv_map1_26;
        sort6 = conv_map1_30; sort7 = conv_map1_31; sort8 = conv_map1_32;
    end
    83: begin
        sort0 = conv_map1_21; sort1 = conv_map1_22; sort2 = conv_map1_23;
        sort3 = conv_map1_27; sort4 = conv_map1_28; sort5 = conv_map1_29;
        sort6 = conv_map1_33; sort7 = conv_map1_34; sort8 = conv_map1_35;
    end
    endcase
end
always @(posedge clk) begin
    if(in_count > 75 && in_count < 84) begin
        max0_0 <= max0_1; max0_1 <= max1_0; max1_0 <= max1_1; max1_1 <= max0_2;
        max0_2 <= max0_3; max0_3 <= max1_2; max1_2 <= max1_3; max1_3 <= maxima;
    end
end

// Activation
reg [31:0] unact;
reg [31:0] act, act_unrec;
reg [31:0] act_exp;
reg [31:0] SM_or_ACT0, SM_or_ACT1, SM_or_ACT2;
reg [31:0] out_reg;
always @ (*) begin
    unact = (opt_reg) ? { ~max1_3[31], max1_3[30:23] + 1'b1, max1_3[22:0] } : { ~max1_3[31], max1_3[30:0] };
end
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) FP_E0 ( .a(SM_or_ACT0), .z(act_exp) );
assign merged_to_act0 = (in_count > 76) ? act_exp : conv1_dot2;
assign merged_to_act1 = (in_count > 76) ? 'h3f800000 : conv1_add2_b;
always @(posedge clk) begin
    act_unrec <= conv1_sum2;
end
assign merged_to_act2 = (in_count > 76) ? { out_reg[31], out_reg[30:23] + 1'b1, out_reg[22:0] } : conv0_dot2;
assign merged_to_act3 = (in_count > 76) ? 'hbf800000 : conv0_add2_b;
always @(*) begin
    if(opt_reg) begin
        act = conv0_sum2;
    end else begin
        act = out_reg;
    end
end
always @(posedge clk) begin
    act0 <= act1; act1 <= act2; act2 <= act3; act3 <= act;
end

// Fully Connected
always @(*) begin
    merged_to_fc0 = 0; merged_to_fc1 = 0; merged_to_fc2 = 0; merged_to_fc3 = 0; merged_to_fc4 = 0; merged_to_fc5 = 0; merged_to_fc6 = 0; merged_to_fc7 = 0;
    merged_to_fc8 = 0; merged_to_fc9 = 0; merged_to_fc10 = 0; merged_to_fc11 = 0; merged_to_fc12 = 0; merged_to_fc13 = 0; merged_to_fc14 = 0; merged_to_fc15 = 0;
    merged_to_fc16 = 0; merged_to_fc17 = 0; merged_to_fc18 = 0; merged_to_fc19 = 0; merged_to_fc20 = 0; merged_to_fc21 = 0; merged_to_fc22 = 0; merged_to_fc23 = 0;
    if(in_count > 78) begin
        if(in_count < 83) begin
            merged_to_fc0 = act0; merged_to_fc1 = weight00; merged_to_fc2 = act1; merged_to_fc3 = weight01; merged_to_fc4 = act2; merged_to_fc5 = weight04; merged_to_fc6 = act3; merged_to_fc7 = weight05;
            merged_to_fc8 = act0; merged_to_fc9 = weight10; merged_to_fc10 = act1; merged_to_fc11 = weight11; merged_to_fc12 = act2; merged_to_fc13 = weight14; merged_to_fc14 = act3; merged_to_fc15 = weight15;
            merged_to_fc16 = act0; merged_to_fc17 = weight20; merged_to_fc18 = act1; merged_to_fc19 = weight21; merged_to_fc20 = act2; merged_to_fc21 = weight24; merged_to_fc22 = act3; merged_to_fc23 = weight25;
        end else if(in_count < 87) begin
            merged_to_fc0 = act0; merged_to_fc1 = weight02; merged_to_fc2 = act1; merged_to_fc3 = weight03; merged_to_fc4 = act2; merged_to_fc5 = weight06; merged_to_fc6 = act3; merged_to_fc7 = weight07;
            merged_to_fc8 = act0; merged_to_fc9 = weight12; merged_to_fc10 = act1; merged_to_fc11 = weight13; merged_to_fc12 = act2; merged_to_fc13 = weight16; merged_to_fc14 = act3; merged_to_fc15 = weight17;
            merged_to_fc16 = act0; merged_to_fc17 = weight22; merged_to_fc18 = act1; merged_to_fc19 = weight23; merged_to_fc20 = act2; merged_to_fc21 = weight26; merged_to_fc22 = act3; merged_to_fc23 = weight27;
        end
    end else begin
        merged_to_fc0 = conv0_dot0_a; merged_to_fc1 = conv0_dot0_b; merged_to_fc2 = conv0_dot0_c; merged_to_fc3 = conv0_dot0_d; merged_to_fc4 = conv0_dot0_e; merged_to_fc5 = conv0_dot0_f; merged_to_fc6 = conv0_dot0_g; merged_to_fc7 = conv0_dot0_h;
        merged_to_fc8 = conv0_dot1_a; merged_to_fc9 = conv0_dot1_b; merged_to_fc10 = conv0_dot1_c; merged_to_fc11 = conv0_dot1_d; merged_to_fc12 = conv0_dot1_e; merged_to_fc13 = conv0_dot1_f; merged_to_fc14 = conv0_dot1_g; merged_to_fc15 = conv0_dot1_h;
        merged_to_fc16 = conv0_dot2_a; merged_to_fc17 = conv0_dot2_b; merged_to_fc18 = conv0_dot2_c; merged_to_fc19 = conv0_dot2_d; merged_to_fc20 = conv0_dot2_e; merged_to_fc21 = conv0_dot2_f; merged_to_fc22 = conv0_dot2_g; merged_to_fc23 = conv0_dot2_h;
    end
end
assign merged_to_fc24 = (in_count == 86) ? conv0_dot2 : conv1_dot0;
assign merged_to_fc25 = (in_count == 86) ? fc0_0 : conv0_add0_b;
assign merged_to_fc26 = (in_count == 86) ? fc1_0 : conv0_add1_b;
assign merged_to_fc27 = (in_count == 86) ? fc2_0 : conv1_add0_b;
always @(posedge clk) begin
    if(in_count < 83) begin
        fc0_0 <= conv0_dot0; fc1_0 <= conv0_dot1; fc2_0 <= conv0_dot2;
    end
    if(in_count < 87) begin
        fc0_1 <= conv0_sum0; fc1_1 <= conv0_sum1; fc2_1 <= conv1_sum0;
    end else if(in_count < 90) begin
        fc0_1 <= fc1_1; fc1_1 <= fc2_1; fc2_1 <= act_exp;
    end else begin
        fc0_1 <= fc1_1; fc1_1 <= fc2_1; fc2_1 <= fc0_1;
    end
end

// Softmax
reg [31:0] SM_sum, SM_sum_nxt;
assign SM_or_ACT0 = (in_count > 86) ? fc0_1 : unact;
assign SM_or_ACT1 = (in_count > 86) ? fc0_1 : 'h3f800000;
assign SM_or_ACT2 = (in_count > 86) ? SM_sum : act_unrec;
assign merged_to_SM0 = (in_count > 86) ? SM_sum : conv1_dot1;
assign merged_to_SM1 = (in_count > 86) ? act_exp : conv1_add1_b;
assign SM_sum_nxt = conv1_sum1;
always @(posedge clk) begin
    if(in_count < 87) begin
        SM_sum <= 0;
    end else if(in_count < 90)begin
        SM_sum <= SM_sum_nxt;
    end
end
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) FP_DIV ( .a(SM_or_ACT1), .b(SM_or_ACT2), .rnd(inst_rnd), .z(out_reg) );

// Output
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out <= 0;
    end else begin
        if(in_count > 89 && in_count < 93) begin
            out <= out_reg;
        end else begin
            out <= 0;
        end
    end
end
assign out_valid = (in_count > 90) ? 1 : 0;






endmodule
