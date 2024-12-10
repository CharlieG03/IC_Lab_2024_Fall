module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
	in_row,
    in_kernel,
    out_idle,
    handshake_sready,
    handshake_din,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

	fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    out_data,

    flag_clk1_to_fifo,
    flag_fifo_to_clk1
);
input clk;
input rst_n;
input in_valid;
input [17:0] in_row;
input [11:0] in_kernel;
input out_idle;
output reg handshake_sready;
output reg [29:0] handshake_din;
// You can use the the custom flag ports for your design
input  flag_handshake_to_clk1;
output flag_clk1_to_handshake;

input fifo_empty;
input [7:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [7:0] out_data;
// You can use the the custom flag ports for your design
output flag_clk1_to_fifo;
input flag_fifo_to_clk1;

reg [17:0] row_reg [5:0];
reg [11:0] kernel_reg [5:0];
reg [2:0] in_cnt;
reg [2:0] ack_cnt;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_cnt <= 0;
    end else begin
        if (in_cnt == 0) begin
            in_cnt <= in_valid;
        end else if(in_cnt > 0 & in_cnt < 7) begin
            in_cnt <= in_cnt + 1;
        end else if(ack_cnt == 6) begin
            in_cnt <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        ack_cnt <= 0;
    end else begin
        if(flag_handshake_to_clk1) begin
            ack_cnt <= ack_cnt + 1;
        end
        if(ack_cnt == 6) begin
            ack_cnt <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        row_reg <= {0, 0, 0, 0, 0, 0};
        kernel_reg <= {0, 0, 0, 0, 0, 0};
    end else begin
        if(in_valid) begin
            row_reg[5] <= in_row;
            row_reg[4] <= row_reg[5]; row_reg[3] <= row_reg[4]; row_reg[2] <= row_reg[3]; row_reg[1] <= row_reg[2]; row_reg[0] <= row_reg[1];
            kernel_reg[5] <= in_kernel;
            kernel_reg[4] <= kernel_reg[5]; kernel_reg[3] <= kernel_reg[4]; kernel_reg[2] <= kernel_reg[3]; kernel_reg[1] <= kernel_reg[2]; kernel_reg[0] <= kernel_reg[1];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        handshake_sready <= 0;
    end else begin
        if(out_idle && in_cnt > 5) begin
            if(flag_handshake_to_clk1) begin
                handshake_sready <= ack_cnt < 5;
            end else begin
                handshake_sready <= ack_cnt < 6;
            end
        end else begin
            handshake_sready <= 0;
        end
    end
end

reg [2:0] hs_tar;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        hs_tar <= 0;
    end else begin
        if(out_idle & handshake_sready & hs_tar == 5) begin
            hs_tar <= 0;
        end else if (out_idle & handshake_sready) begin
            hs_tar <= hs_tar + 1;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        handshake_din <= 0;
    end else begin
        if(out_idle & handshake_sready) begin
            handshake_din <= {row_reg[hs_tar], kernel_reg[hs_tar]};
        end
    end
end

reg fifo_rinc_reg;
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        fifo_rinc_reg <= 0;
    end else begin
        fifo_rinc_reg <= ~fifo_empty;
    end
end
assign fifo_rinc = fifo_rinc_reg & ~fifo_empty;

reg [7:0] out_data_reg;
assign out_data_reg = fifo_rdata;
assign out_data = out_valid ? out_data_reg : 0;
assign out_valid = flag_fifo_to_clk1;

endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    in_data,
    out_valid,
    out_data,
    busy,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [29:0] in_data;
output reg out_valid;
output reg [7:0] out_data;
output reg busy;

// You can use the the custom flag ports for your design
input  flag_handshake_to_clk2;
output flag_clk2_to_handshake;

input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;

reg [17:0] row_reg [5:0];
reg [11:0] kernel_reg [5:0];
reg [3:0] in_cnt;
reg [4:0] cal_cnt;

reg in_valid_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_valid_reg <= 0;
    end else begin
        in_valid_reg <= in_valid;
    end
end

assign busy = in_cnt >= 6;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_cnt <= 0;
    end else begin
        if(in_valid_reg) begin
            in_cnt <= in_cnt + 1;
        end
        if(cal_cnt == 31 & ~fifo_full) begin
            if(in_cnt < 11) begin
                in_cnt <= in_cnt + 1;
            end else begin
                in_cnt <= 0;
            end
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cal_cnt <= 0;
    end else begin
        if(in_cnt > 5) begin
            cal_cnt <= ~fifo_full ? cal_cnt + 1 : cal_cnt;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        row_reg <= {0, 0, 0, 0, 0, 0};
        kernel_reg <= {0, 0, 0, 0, 0, 0};
    end else begin
        if(in_valid_reg) begin
            row_reg[in_cnt] <= in_data[29:12];
            kernel_reg[in_cnt] <= in_data[11:0];
        end else begin
            case(cal_cnt)
            1, 2, 3, 4, 5,
            7, 8, 9, 10, 11,
            13, 14, 15, 16, 17,
            19, 20, 21, 22, 23,
            25, 26, 27, 28, 29: begin
                if(~fifo_full) begin
                    row_reg[0] <= {row_reg[0][2:0], row_reg[0][17:3]};
                    row_reg[1] <= {row_reg[1][2:0], row_reg[1][17:3]};
                end
            end
            6, 12, 18, 24, 30: begin
                if(~fifo_full) begin
                    row_reg[0] <= {row_reg[1][2:0], row_reg[1][17:3]};
                    row_reg[1] <= row_reg[2];
                    row_reg[2] <= row_reg[3];
                    row_reg[3] <= row_reg[4];
                    row_reg[4] <= row_reg[5];
                    row_reg[5] <= {row_reg[0][2:0], row_reg[0][17:3]};
                end
            end
            31: begin
                if(~fifo_full) begin
                    row_reg[0] <= row_reg[1];
                    row_reg[1] <= row_reg[2];
                    row_reg[2] <= row_reg[3];
                    row_reg[3] <= row_reg[4];
                    row_reg[4] <= row_reg[5];
                    row_reg[5] <= row_reg[0];
                end
            end
            endcase
        end
    end
end
reg [11:0] kernel_now;
reg [11:0] window;
reg [7:0] conv_result_temp;
assign window = {row_reg[1][5:0], row_reg[0][5:0]};
assign conv_result_temp = kernel_now[2:0] * window[2:0] + kernel_now[5:3] * window[5:3] + kernel_now[8:6] * window[8:6] + kernel_now[11:9] * window[11:9]; 
always @(*) begin
    case(in_cnt)
    6: kernel_now = kernel_reg[0];
    7: kernel_now = kernel_reg[1];
    8: kernel_now = kernel_reg[2];
    9: kernel_now = kernel_reg[3];
    10: kernel_now = kernel_reg[4];
    11: kernel_now = kernel_reg[5];
    default: kernel_now = 'bx;
    endcase
end
reg [7:0] conv_result;

assign out_data = conv_result;
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        conv_result <= 0;
    end else begin
        case(cal_cnt)
        1, 2, 3, 4, 5,
        7, 8, 9, 10, 11,
        13, 14, 15, 16, 17,
        19, 20, 21, 22, 23,
        25, 26, 27, 28, 29: begin
            conv_result <= ~fifo_full ? conv_result_temp : conv_result;
        end
        endcase
    end
end
always@(*) begin
    out_valid = 0;
    case(cal_cnt)
    2, 3, 4, 5, 6,
    8, 9, 10, 11, 12,
    14, 15, 16, 17, 18,
    20, 21, 22, 23, 24,
    26, 27, 28, 29, 30: begin
        out_valid = ~fifo_full;
    end
    endcase
end
endmodule