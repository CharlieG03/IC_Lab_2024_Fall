module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

NDFF_syn u_ack(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));
NDFF_syn u_req(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));

assign sidle = (sreq | sack) ? 1'b0 : 1'b1;

reg [WIDTH-1:0] data;
always@(posedge sclk or negedge rst_n) begin
    if(~rst_n) begin
        data <= 0;
    end else begin
        data <= sready ? din : data;
    end
end

reg dreq_prop;
always@(posedge dclk or negedge rst_n) begin
    if(~rst_n) begin
        dreq_prop <= 0;
    end else begin
        dreq_prop <= dreq;
    end
end

always@(posedge dclk or negedge rst_n) begin
    if(~rst_n) begin
        dvalid <= 0;
    end else begin
        if(~dreq && dreq_prop) begin
            dvalid <= 1;
        end else begin
            dvalid <= 0;
        end
    end
end
always@(posedge dclk or negedge rst_n) begin
    if(~rst_n) begin
        dout <= 0;
    end else begin
        dout <= (~dreq && dreq_prop) ? data : dout;
    end
end

always@(posedge sclk or negedge rst_n) begin
    if(~rst_n) begin
        sreq <= 0;
    end else begin
        if(sack) begin
            sreq <= 0;
        end else if(sready) begin
            sreq <= 1;
        end
    end
end

always@(posedge dclk or negedge rst_n) begin
    if(~rst_n) begin
        dack <= 0;
    end else begin
        if(dreq) begin
            dack <= 1;
        end else begin
            dack <= 0;
        end
    end
end

reg sack_prop;
always@(posedge sclk or negedge rst_n) begin
    if(~rst_n) begin
        sack_prop <= 0;
    end else begin
        sack_prop <= sack;
    end
end

assign flag_handshake_to_clk1 = ~sack & sack_prop;

endmodule