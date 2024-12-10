module FIFO_syn #(parameter WIDTH=8, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo,

    flag_fifo_to_clk1,
	flag_clk1_to_fifo
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
output  flag_fifo_to_clk2;
input flag_clk2_to_fifo;

output flag_fifo_to_clk1;
input flag_clk1_to_fifo;

wire [WIDTH-1:0] rdata_q;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr;
reg [$clog2(WORDS):0] rptr;

reg [6:0] w2rptr, wptr_nxt;
reg [6:0] r2wptr, rptr_nxt;

reg [6:0] wptr_bin, wptr_bin_nxt;
reg [6:0] rptr_bin, rptr_bin_nxt;

NDFF_BUS_syn #(7) u_w2r(.D(wptr), .Q(w2rptr), .clk(rclk), .rst_n(rst_n));
NDFF_BUS_syn #(7) u_r2w(.D(rptr), .Q(r2wptr), .clk(wclk), .rst_n(rst_n));

DUAL_64X8X1BM1 u_dual_sram (.A0(wptr_bin[0]),.A1(wptr_bin[1]),.A2(wptr_bin[2]),.A3(wptr_bin[3]),.A4(wptr_bin[4]),.A5(wptr_bin[5]),
                            .B0(rptr_bin[0]),.B1(rptr_bin[1]),.B2(rptr_bin[2]),.B3(rptr_bin[3]),.B4(rptr_bin[4]),.B5(rptr_bin[5]),
                            .DOB0(rdata_q[0]),.DOB1(rdata_q[1]),.DOB2(rdata_q[2]),.DOB3(rdata_q[3]),.DOB4(rdata_q[4]),.DOB5(rdata_q[5]),.DOB6(rdata_q[6]),.DOB7(rdata_q[7]),
                            .DIA0(wdata[0]),.DIA1(wdata[1]),.DIA2(wdata[2]),.DIA3(wdata[3]),.DIA4(wdata[4]),.DIA5(wdata[5]),.DIA6(wdata[6]),.DIA7(wdata[7]),
                            .DIB0(1'b0),.DIB1(1'b0),.DIB2(1'b0),.DIB3(1'b0),.DIB4(1'b0),.DIB5(1'b0),.DIB6(1'b0),.DIB7(1'b0),
                            .WEAN(~winc),.WEBN(1'b1),.CKA(wclk),.CKB(rclk),.CSA(1'b1),.CSB(1'b1),.OEA(1'b1),.OEB(1'b1));

reg flag_c1, flag_c1_nxt, flag_c1_nxt_nxt;

always@(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rdata <= 0;
    end else begin
        rdata <= (flag_c1_nxt) ? rdata_q : rdata;
    end
end

always@(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wptr_bin <= 0;
    end else begin
        wptr_bin <= wptr_bin_nxt;
    end
end
always@(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rptr_bin <= 0;
    end else begin
        rptr_bin <= rptr_bin_nxt;
    end
end
always@(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        flag_c1 <= 0;
        flag_c1_nxt <= 0;
    end else begin
        flag_c1 <= flag_c1_nxt;
        flag_c1_nxt <= flag_c1_nxt_nxt;
    end
end
assign flag_fifo_to_clk1 = flag_c1; 

always@(*) begin
    wptr_bin_nxt = wptr_bin;
    if(winc & ~wfull) begin
        wptr_bin_nxt = wptr_bin + 1;
    end
end

always@(*) begin
    rptr_bin_nxt = rptr_bin;
    flag_c1_nxt_nxt = 0;
    if(rinc & ~rempty) begin
        rptr_bin_nxt = rptr_bin + 1;
        flag_c1_nxt_nxt = 1;
    end
end

reg empty_nxt, full_nxt;
always@(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wfull <= 0;
    end else begin
        wfull <= full_nxt;
    end
end
always@(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rempty <= 1;
    end else begin
        rempty <= empty_nxt;
    end
end
assign full_nxt = (wptr_nxt[6] != r2wptr[6]) & ({wptr_nxt[6] ^ wptr_nxt[5], wptr_nxt[4:0]} == {r2wptr[6] ^ r2wptr[5], r2wptr[4:0]});
assign empty_nxt = w2rptr == rptr_nxt;
always@(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wptr <= 0;
    end else begin
        wptr <= wptr_nxt;
    end
end
always@(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rptr <= 0;
    end else begin
        rptr <= rptr_nxt;
    end
end
assign wptr_nxt = wptr_bin_nxt ^ (wptr_bin_nxt >> 1);
assign rptr_nxt = rptr_bin_nxt ^ (rptr_bin_nxt >> 1);

endmodule
