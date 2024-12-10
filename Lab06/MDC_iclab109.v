//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/9
//		Version		: v1.0
//   	File Name   : MDC.v
//   	Module Name : MDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "HAMMING_IP.v"
//synopsys translate_on

module MDC(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_data, 
	in_mode,
    // Output signals
    out_valid, 
	out_data
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [8:0] in_mode;
input [14:0] in_data;

output reg out_valid;
output reg [206:0] out_data;

reg [8:0] in_mode_reg;
reg [14:0] in_data_reg;
reg [4:0] mode;
reg [10:0] data;
reg [10:0] data_reg0, data_reg1, data_reg2, data_reg3, data_reg4, data_reg5, data_reg6, data_reg7;
reg [10:0] data_reg_ex;

reg [4:0] i_cnt;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        i_cnt <= 0;
    end else begin
        if(in_valid) begin
            i_cnt <= i_cnt + 1;
        end else if(i_cnt > 0) begin
            i_cnt <= (i_cnt > 16) ? 0 : i_cnt + 1;
        end
    end
end

always @(posedge clk) begin
    in_mode_reg <= (i_cnt == 0 && in_valid) ? in_mode : in_mode_reg;
    in_data_reg <= (in_valid) ? in_data : 0;
end

HAMMING_IP #(.IP_BIT(5)) hamming_ip0 (.IN_code(in_mode_reg), .OUT_code(mode));
HAMMING_IP #(.IP_BIT(11)) hamming_ip1 (.IN_code(in_data_reg), .OUT_code(data));

assign data_reg7 = data;

always @(posedge clk) begin
    data_reg_ex <= data_reg0;
    data_reg0 <= data_reg1; data_reg1 <= data_reg2; data_reg2 <= data_reg3; data_reg3 <= data_reg4; data_reg4 <= data_reg5; data_reg5 <= data_reg6; 
    data_reg6 <= data_reg7;
end

reg signed [10:0] in0, in1, in2, in3;
reg signed [10:0] in4, in5, in6, in7;
reg signed [22:0] out0, out1;
reg signed [22:0] result_reg0, result_reg1, result_reg2, result_reg3, result_reg4, result_reg5;

DET22 det22_0 (.in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out0));
DET22 det22_1 (.in0(in4), .in1(in5), .in2(in6), .in3(in7), .out(out1));

always @(*) begin
    if(mode[4]) begin
        case(i_cnt)
        6: begin in0 = data_reg2; in1 = data_reg3; in2 = data_reg6; in3 = data_reg7; 
                 in4 = 'bx; in5 = 'bx; in6 = 'bx; in7 = 'bx; end
        7: begin in0 = data_reg3; in1 = data_reg1; in2 = data_reg7; in3 = data_reg5; 
                 in4 = data_reg2; in5 = data_reg3; in6 = data_reg6; in7 = data_reg7; end
        8: begin in0 = data_reg3; in1 = data_reg1; in2 = data_reg7; in3 = data_reg5; 
                 in4 = data_reg2; in5 = data_reg3; in6 = data_reg6; in7 = data_reg7; end
        9: begin in0 = data_reg2; in1 = data_reg_ex; in2 = data_reg6; in3 = data_reg3; 
                 in4 = 'bx; in5 = 'bx; in6 = 'bx; in7 = 'bx; end
        default: begin in0 = 'bx; in1 = 'bx; in2 = 'bx; in3 = 'bx; 
                       in4 = 'bx; in5 = 'bx; in6 = 'bx; in7 = 'bx; end
        endcase
    end else if(mode[1]) begin
        case(i_cnt)
        6, 10: begin in0 = data_reg2; in1 = data_reg3; in2 = data_reg6; in3 = data_reg7; 
                     in4 = 'bx; in5 = 'bx; in6 = 'bx; in7 = 'bx; end
        7, 11: begin in0 = data_reg3; in1 = data_reg1; in2 = data_reg7; in3 = data_reg5; 
                     in4 = data_reg2; in5 = data_reg3; in6 = data_reg6; in7 = data_reg7; end
        8, 12: begin in0 = data_reg3; in1 = data_reg1; in2 = data_reg7; in3 = data_reg5; 
                     in4 = data_reg2; in5 = data_reg3; in6 = data_reg6; in7 = data_reg7; end
        default: begin in0 = 'bx; in1 = 'bx; in2 = 'bx; in3 = 'bx; 
                       in4 = 'bx; in5 = 'bx; in6 = 'bx; in7 = 'bx; end
        endcase
    end else begin
        in0 = data_reg2; in1 = data_reg3; in2 = data_reg6; in3 = data_reg7;
        in4 = 'bx; in5 = 'bx; in6 = 'bx; in7 = 'bx;
    end
end

always @(posedge clk) begin
    if(mode[4]) begin
        case(i_cnt)
        6: begin result_reg0 <= out0; end
        7: begin result_reg1 <= out0; result_reg2 <= out1; end
        8: begin result_reg3 <= out0; result_reg4 <= out1; end
        9: begin result_reg5 <= out0; end
        endcase
    end else begin
        case(i_cnt)
        6: begin result_reg0 <= out0; end
        7: begin result_reg1 <= out0; result_reg2 <= out1; end
        8: begin result_reg3 <= out0; result_reg4 <= out1; end
        9: begin result_reg5 <= out0; end
        10: begin result_reg4 <= out0; end
        11: begin result_reg0 <= out0; result_reg3 <= out1; end
        12: begin result_reg1 <= out0; result_reg2 <= out1; end
        endcase
    end
end

reg signed [10:0] mult0, mult1, mult5;
reg signed [21:0] mult2, mult3;
reg signed [33:0] mult4;
reg signed [32:0] product0, product1;
reg signed [44:0] product2;

assign product0 = mult0 * mult2;
assign product1 = mult1 * mult3;

always @(*) begin
    if(mode[4]) begin
        case(i_cnt)
        9: begin mult0 = data_reg7; mult1 = data_reg7; mult2 = result_reg4; mult3 = result_reg2; end
        10: begin mult0 = (data_reg6); mult1 = data_reg7; mult2 = -result_reg3; mult3 = result_reg4; end
        11: begin mult0 = data_reg7; mult1 = data_reg7; mult2 = result_reg5; mult3 = result_reg3; end 
        12: begin mult0 = data_reg7; mult1 = data_reg7; mult2 = -result_reg1; mult3 = result_reg2; end
        13: begin mult0 = data_reg4; mult1 = data_reg4; mult2 = result_reg5; mult3 = result_reg1; end
        14: begin mult0 = data_reg5; mult1 = data_reg4; mult2 = result_reg0; mult3 = result_reg0; end  
        default: begin mult0 = 'bx; mult1 = 'bx; mult2 = 'bx; mult3 = 'bx; end 
        endcase
    end else begin
        case(i_cnt)
        9: begin mult0 = data_reg7; mult2 = result_reg2; mult1 = 'bx; mult3 = 'bx; end
        10: begin mult0 = data_reg7; mult1 = data_reg7; mult2 = result_reg1; mult3 = result_reg4; end 
        11: begin mult0 = data_reg7; mult1 = data_reg7; mult2 = result_reg0; mult3 = result_reg3; end 
        12: begin mult1 = data_reg7; mult3 = result_reg2; mult0 = 'bx; mult2 = 'bx; end
        13: begin mult0 = data_reg7; mult2 = result_reg3; mult1 = 'bx; mult3 = 'bx; end
        14: begin mult0 = data_reg7; mult1 = data_reg7; mult2 = result_reg0; mult3 = result_reg2; end
        15: begin mult0 = data_reg7; mult1 = data_reg7; mult2 = result_reg4; mult3 = result_reg1; end
        16: begin mult1 = data_reg7; mult3 = result_reg3; mult0 = 'bx; mult2 = 'bx; end 
        default: begin mult0 = 'bx; mult1 = 'bx; mult2 = 'bx; mult3 = 'bx; end
        endcase
    end
end

reg [33:0] det33_temp0, det33_temp1, det33_temp2, det33_temp3;

assign product2 = mult5 * mult4;

always @(*) begin
    case(i_cnt)
    13: begin mult5 = data_reg7; mult4 = -det33_temp0; end
    14: begin mult5 = data_reg7; mult4 = det33_temp1; end
    15: begin mult5 = data_reg7; mult4 = -det33_temp2; end
    16: begin mult5 = data_reg7; mult4 = det33_temp3; end
    default: begin mult5 = 'bx; mult4 = 'bx; end
    endcase
end

always @(posedge clk) begin
    if(i_cnt == 0) begin
        det33_temp0 <= 0; det33_temp1 <= 0; det33_temp2 <= 0; det33_temp3 <= 0;
    end
    case(i_cnt)
    9: begin det33_temp1 <= det33_temp1 + {product0[32], product0}; det33_temp3 <= det33_temp3 + {product1[32], product1}; end
    10: begin det33_temp2 <= det33_temp2 + {product0[32], product0}; det33_temp0 <= det33_temp0 + {product1[32], product1}; end
    11: begin det33_temp1 <= det33_temp1 + {product0[32], product0}; det33_temp0 <= det33_temp0 + {product1[32], product1}; end
    12: begin det33_temp1 <= det33_temp1 + {product0[32], product0}; det33_temp0 <= det33_temp0 + {product1[32], product1}; end
    13: begin det33_temp2 <= det33_temp2 + {product0[32], product0}; det33_temp3 <= det33_temp3 + {product1[32], product1}; end
    14: begin det33_temp2 <= det33_temp2 + {product0[32], product0}; det33_temp3 <= det33_temp3 + {product1[32], product1}; end 
    endcase
end

reg [51:0] ot0, ot1;

reg signed [206:0] out_temp;

always @(posedge clk) begin
    if(i_cnt == 0) begin
        out_temp <= 0;
    end
    if(mode[4]) begin
        case(i_cnt)
        13, 14, 15, 16: begin out_temp <= out_temp + product2; end
        endcase
    end else if(mode[1]) begin
        case(i_cnt)
        9: begin out_temp[203:153] <= out_temp[203:153] + ot0; end
        10, 11: begin 
            out_temp[203:153] <= out_temp[203:153] + ot0; 
            out_temp[152:102] <= out_temp[152:102] + ot1;
        end
        12: begin out_temp[152:102] <= out_temp[152:102] + ot1; end
        13: begin out_temp[101:51] <= out_temp[101:51] + ot0; end
        14, 15: begin 
            out_temp[101:51] <= out_temp[101:51] + ot0; 
            out_temp[50:0] <= out_temp[50:0] + ot1;
        end
        16: begin out_temp[50:0] <= out_temp[50:0] + ot1; end
        endcase
    end else begin
        if(i_cnt > 5 && i_cnt != 9 && i_cnt != 13) begin
            out_temp[206:184] <= out_temp[183:161]; out_temp[183:161] <= out_temp[160:138]; out_temp[160:138] <= out_temp[137:115]; 
            out_temp[137:115] <= out_temp[114:92]; out_temp[114:92] <= out_temp[91:69]; out_temp[91:69] <= out_temp[68:46]; 
            out_temp[68:46] <= out_temp[45:23]; out_temp[45:23] <= out_temp[22:0]; out_temp[22:0] <= out0;
        end
    end
end

always @(*) begin
    ot0 = (product0[32]) ? {18'b11_1111_1111_1111_1111, product0} : {18'b00_0000_0000_0000_0000, product0};
    ot1 = (product1[32]) ? {18'b11_1111_1111_1111_1111, product1} : {18'b00_0000_0000_0000_0000, product1};
end

always @(*) begin
    out_valid = i_cnt == 17;
    out_data = i_cnt == 17 ? out_temp : 0;
end

endmodule

module DET22(
    input signed [10:0] in0, in1, in2, in3, 
    output reg signed [22:0] out
);
assign out = in0 * in3 - in1 * in2;
endmodule
