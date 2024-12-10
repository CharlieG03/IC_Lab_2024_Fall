//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/10
//		Version		: v1.0
//   	File Name   : HAMMING_IP.v
//   	Module Name : HAMMING_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module HAMMING_IP #(parameter IP_BIT = 6) (
    // Input signals
    IN_code,
    // Output signals
    OUT_code
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_BIT+4-1:0]  IN_code;

output reg [IP_BIT-1:0] OUT_code;

// ===============================================================
// Design
// ===============================================================
reg [3:0] check_bit;
reg [IP_BIT+4-1:0] temp;
always @(*) begin
    case(IP_BIT)
    11: begin
        OUT_code = {temp[12], temp[10:8], temp[6:0]};
        check_bit[3] = IN_code[0] ^ IN_code[1] ^ IN_code[2] ^ IN_code[3] ^ IN_code[4] ^ IN_code[5] ^ IN_code[6] ^ IN_code[7];
        check_bit[2] = IN_code[0] ^ IN_code[1] ^ IN_code[2] ^ IN_code[3] ^ IN_code[8] ^ IN_code[9] ^ IN_code[10] ^ IN_code[11];
        check_bit[1] = IN_code[0] ^ IN_code[1] ^ IN_code[4] ^ IN_code[5] ^ IN_code[8] ^ IN_code[9] ^ IN_code[12] ^ IN_code[13];
        check_bit[0] = IN_code[0] ^ IN_code[2] ^ IN_code[4] ^ IN_code[6] ^ IN_code[8] ^ IN_code[10] ^ IN_code[12] ^ IN_code[14];
    end
    10: begin
        OUT_code = {temp[11], temp[9:7], temp[5:0]};
        check_bit[3] = IN_code[0] ^ IN_code[1] ^ IN_code[2] ^ IN_code[3] ^ IN_code[4] ^ IN_code[5] ^ IN_code[6];
        check_bit[2] = IN_code[0] ^ IN_code[1] ^ IN_code[2] ^ IN_code[7] ^ IN_code[8] ^ IN_code[9] ^ IN_code[10];
        check_bit[1] = IN_code[0] ^ IN_code[3] ^ IN_code[4] ^ IN_code[7] ^ IN_code[8] ^ IN_code[11] ^ IN_code[12];
        check_bit[0] = IN_code[1] ^ IN_code[3] ^ IN_code[5] ^ IN_code[7] ^ IN_code[9] ^ IN_code[11] ^ IN_code[13];
    end
    9: begin
        OUT_code = {temp[10], temp[8:6], temp[4:0]};
        check_bit[3] = IN_code[0] ^ IN_code[1] ^ IN_code[2] ^ IN_code[3] ^ IN_code[4] ^ IN_code[5];
        check_bit[2] = IN_code[0] ^ IN_code[1] ^ IN_code[6] ^ IN_code[7] ^ IN_code[8] ^ IN_code[9];
        check_bit[1] = IN_code[2] ^ IN_code[3] ^ IN_code[6] ^ IN_code[7] ^ IN_code[10] ^ IN_code[11];
        check_bit[0] = IN_code[0] ^ IN_code[2] ^ IN_code[4] ^ IN_code[6] ^ IN_code[8] ^ IN_code[10] ^ IN_code[12];
    end
    8: begin
        OUT_code = {temp[9], temp[7:5], temp[3:0]};
        check_bit[3] = IN_code[0] ^ IN_code[1] ^ IN_code[2] ^ IN_code[3] ^ IN_code[4];
        check_bit[2] = IN_code[0] ^ IN_code[5] ^ IN_code[6] ^ IN_code[7] ^ IN_code[8];
        check_bit[1] = IN_code[1] ^ IN_code[2] ^ IN_code[5] ^ IN_code[6] ^ IN_code[9] ^ IN_code[10];
        check_bit[0] = IN_code[1] ^ IN_code[3] ^ IN_code[5] ^ IN_code[7] ^ IN_code[9] ^ IN_code[11];
    end
    7: begin
        OUT_code = {temp[8], temp[6:4], temp[2:0]};
        check_bit[3] = IN_code[0] ^ IN_code[1] ^ IN_code[2] ^ IN_code[3];
        check_bit[2] = IN_code[4] ^ IN_code[5] ^ IN_code[6] ^ IN_code[7];
        check_bit[1] = IN_code[0] ^ IN_code[1] ^ IN_code[4] ^ IN_code[5] ^ IN_code[8]^ IN_code[9];
        check_bit[0] = IN_code[0] ^ IN_code[2] ^ IN_code[4] ^ IN_code[6] ^ IN_code[8] ^ IN_code[10];
    end
    6: begin
        OUT_code = {temp[7], temp[5:3], temp[1:0]};
        check_bit[3] = IN_code[0] ^ IN_code[1] ^ IN_code[2];
        check_bit[2] = IN_code[3] ^ IN_code[4] ^ IN_code[5] ^ IN_code[6];
        check_bit[1] = IN_code[0] ^ IN_code[3] ^ IN_code[4] ^ IN_code[7] ^ IN_code[8];
        check_bit[0] = IN_code[1] ^ IN_code[3] ^ IN_code[5] ^ IN_code[7] ^ IN_code[9];
    end
    5: begin
        OUT_code = {temp[6], temp[4:2], temp[0]};
        check_bit[3] = IN_code[0] ^ IN_code[1];
        check_bit[2] = IN_code[2] ^ IN_code[3] ^ IN_code[4] ^ IN_code[5];
        check_bit[1] = IN_code[2] ^ IN_code[3] ^ IN_code[6] ^ IN_code[7];
        check_bit[0] = IN_code[0] ^ IN_code[2] ^ IN_code[4] ^ IN_code[6] ^ IN_code[8];
    end
    default: begin
        OUT_code = 'bx;
        check_bit = 4'bx;
    end
    endcase
end
always @(*) begin
    temp = IN_code;
    if(check_bit > 0)
        temp[IP_BIT+4-check_bit] = ~IN_code[IP_BIT+4-check_bit];
end

endmodule