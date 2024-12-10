//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Fall
//   Lab01 Exercise		: Snack Shopping Calculator
//   Author     		  : Yu-Hsiang Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SSC.v
//   Module Name : SSC
//   Release version : V1.0 (Release Date: 2024-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SSC(
    // Input signals
    card_num,
    input_money,
    snack_num,
    price, 
    // Output signals
    out_valid,
    out_change
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [63:0] card_num;
input [8:0] input_money;
input [31:0] snack_num;
input [31:0] price;
output out_valid;
output [8:0] out_change;    

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment
reg [3:0] cn_odd[0:7];
wire [5:0] cn_ps_even[0:1];
wire [4:0] cn_ps_odd[0:3];
wire [6:0] cn_ps;
wire [7:0] check_num;

reg [7:0] snack_price0, snack_price1, snack_price2, snack_price3, snack_price4, snack_price5, snack_price6, snack_price7;
reg [7:0] sort00, sort01, sort02, sort03, sort04, sort05, sort06, sort07;
reg [7:0] sort10, sort11, sort12, sort13, sort14, sort15, sort16, sort17;
reg [7:0] sort20, sort21, sort22, sort23, sort24, sort25, sort26, sort27;
reg [7:0] sort30, sort31, sort32, sort33, sort34, sort35, sort36, sort37;
reg [7:0] sort40, sort41, sort42, sort43, sort44, sort45, sort46, sort47;
reg [7:0] sort50, sort51, sort52, sort53, sort54, sort55, sort56, sort57;

reg [8:0] out_change_buf;
//================================================================
//    DESIGN
//================================================================
genvar i;
generate
    for(i = 0; i < 8; i = i + 1) begin
        ODD_PROCESS ODD_PROCESS_inst(
            .in_num(card_num[4*(2*i+1)+3:4*(2*i+1)]),
            .out_num(cn_odd[i])
        );
    end
endgenerate

assign cn_ps_even[0] = card_num[3:0] + card_num[11:8] + card_num[19:16] + card_num[27:24];
assign cn_ps_even[1] = card_num[35:32] + card_num[43:40] + card_num[51:48] + card_num[59:56];
assign cn_ps_odd[0] = cn_odd[0] + cn_odd[1];
assign cn_ps_odd[1] = cn_odd[2] + cn_odd[3];
assign cn_ps_odd[2] = cn_odd[4] + cn_odd[5];
assign cn_ps_odd[3] = cn_odd[6] + cn_odd[7];
assign cn_ps = cn_ps_odd[0] + cn_ps_odd[1] + cn_ps_odd[2] + cn_ps_odd[3];

assign check_num = cn_ps + cn_ps_even[0] + cn_ps_even[1];

MOD10 MOD10_inst(
    .in_num(check_num),
    .out_num(out_valid)
);

assign snack_price0 = snack_num[3:0] * price[3:0];
assign snack_price1 = snack_num[7:4] * price[7:4];
assign snack_price2 = snack_num[11:8] * price[11:8];
assign snack_price3 = snack_num[15:12] * price[15:12];
assign snack_price4 = snack_num[19:16] * price[19:16];
assign snack_price5 = snack_num[23:20] * price[23:20];
assign snack_price6 = snack_num[27:24] * price[27:24];
assign snack_price7 = snack_num[31:28] * price[31:28];

assign sort00 = (snack_price0 > snack_price2)? snack_price0 : snack_price2;
assign sort02 = (snack_price0 > snack_price2)? snack_price2 : snack_price0;
assign sort01 = (snack_price1 > snack_price3)? snack_price1 : snack_price3;
assign sort03 = (snack_price1 > snack_price3)? snack_price3 : snack_price1;
assign sort04 = (snack_price4 > snack_price6)? snack_price4 : snack_price6;
assign sort06 = (snack_price4 > snack_price6)? snack_price6 : snack_price4;
assign sort05 = (snack_price5 > snack_price7)? snack_price5 : snack_price7;
assign sort07 = (snack_price5 > snack_price7)? snack_price7 : snack_price5;
assign sort10 = (sort00 > sort04)? sort00 : sort04;
assign sort14 = (sort00 > sort04)? sort04 : sort00;
assign sort11 = (sort01 > sort05)? sort01 : sort05;
assign sort15 = (sort01 > sort05)? sort05 : sort01;
assign sort12 = (sort02 > sort06)? sort02 : sort06;
assign sort16 = (sort02 > sort06)? sort06 : sort02;
assign sort13 = (sort03 > sort07)? sort03 : sort07;
assign sort17 = (sort03 > sort07)? sort07 : sort03;
assign sort20 = (sort10 > sort11)? sort10 : sort11;
assign sort21 = (sort10 > sort11)? sort11 : sort10;
assign sort22 = (sort12 > sort13)? sort12 : sort13;
assign sort23 = (sort12 > sort13)? sort13 : sort12;
assign sort24 = (sort14 > sort15)? sort14 : sort15;
assign sort25 = (sort14 > sort15)? sort15 : sort14;
assign sort26 = (sort16 > sort17)? sort16 : sort17;
assign sort27 = (sort16 > sort17)? sort17 : sort16;
assign sort30 = sort20;
assign sort31 = sort21;
assign sort32 = (sort22 > sort24)? sort22 : sort24;
assign sort34 = (sort22 > sort24)? sort24 : sort22;
assign sort33 = (sort23 > sort25)? sort23 : sort25;
assign sort35 = (sort23 > sort25)? sort25 : sort23;
assign sort36 = sort26;
assign sort37 = sort27;
assign sort40 = sort30;
assign sort41 = (sort31 > sort34)? sort31 : sort34;
assign sort42 = sort32;
assign sort43 = (sort33 > sort36)? sort33 : sort36;
assign sort44 = (sort31 > sort34)? sort34 : sort31;
assign sort45 = sort35;
assign sort46 = (sort33 > sort36)? sort36 : sort33;
assign sort47 = sort37;
assign sort50 = sort40;
assign sort51 = (sort41 > sort42)? sort41 : sort42;
assign sort52 = (sort41 > sort42)? sort42 : sort41;
assign sort53 = (sort43 > sort44)? sort43 : sort44;
assign sort54 = (sort43 > sort44)? sort44 : sort43;
assign sort55 = (sort45 > sort46)? sort45 : sort46;
assign sort56 = (sort45 > sort46)? sort46 : sort45;
assign sort57 = sort47;

always @(*) begin
    out_change_buf = input_money;
    if((sort50 + sort51 + sort52 + sort53) <= {1'b0, out_change_buf}) begin
        out_change_buf = out_change_buf - (sort50 + sort51 + sort52 + sort53);
        if((sort54 + sort55 + sort56 + sort57) <= {1'b0, out_change_buf}) begin
            out_change_buf = out_change_buf - (sort54 + sort55 + sort56 + sort57);
        end else begin 
            if((sort54 + sort55) <= out_change_buf) begin
                out_change_buf = out_change_buf - (sort54 + sort55);
                if(sort56 <= out_change_buf) begin
                    out_change_buf = out_change_buf - sort56;
                end
            end else begin
                if(sort54 <= out_change_buf) begin
                    out_change_buf = out_change_buf - sort54;
                end
            end
        end
    end else begin
        if((sort50 + sort51) <= out_change_buf) begin
            out_change_buf = out_change_buf - (sort50 + sort51);
            if(sort52 <= out_change_buf) begin
                out_change_buf = out_change_buf - sort52;
            end
        end else begin
            if(sort50 <= out_change_buf) begin
                out_change_buf = out_change_buf - sort50;
            end
        end
    end
end

// assign out_valid = (check_num == 8'd0) | (check_num == 8'd10) | (check_num == 8'd20) | (check_num == 8'd30);
assign out_change = (out_valid)? out_change_buf : input_money;
endmodule

module MOD10(
    // Input signals
    input [7:0] in_num,
    // Output signals
    output out_num
);
reg out;
always @(*) begin
    case(in_num)
            0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140: out = 1;
            default: out = 0;
    endcase
end
assign out_num = out;
endmodule

module ODD_PROCESS(
    // Input signals
    input [3:0] in_num,
    // Output signals
    output [3:0] out_num
);
wire signed [4:0] temp;
reg [3:0] out;
assign temp = in_num * 2 - 9;
assign out_num = out;
always @(*) begin
    if(temp > 0) begin
        out = in_num * 2 - 9;
    end else begin
        out = in_num * 2;
    end
end
endmodule

//56894