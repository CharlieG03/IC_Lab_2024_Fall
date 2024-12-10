module CHIP(
    // Input signals
    rst_n,
    clk,
    in_valid,
    tetrominoes,
    position,
    // Output signals
    tetris_valid,
    score_valid,
    fail,
    score,
    tetris
);

input               rst_n;
input               clk;
input               in_valid;
input       [2:0]   tetrominoes;
input       [2:0]   position;
output              tetris_valid;
output              score_valid;
output              fail;
output      [3:0]   score;
output      [71:0]  tetris;

wire            C_rst_n;
wire            C_clk;
wire            C_in_valid;
wire    [2:0]   C_tetrominoes;
wire    [2:0]   C_position;
wire            C_tetris_valid;
wire            C_score_valid;
wire            C_fail;
wire    [3:0]   C_score;
wire    [71:0]  C_tetris;

TETRIS CORE(
    .rst_n(C_rst_n),
    .clk(C_clk),
    .in_valid(C_in_valid),
    .tetrominoes(C_tetrominoes),
    .position(C_position),
    .tetris_valid(C_tetris_valid),
    .score_valid(C_score_valid),
    .fail(C_fail),
    .score(C_score),
    .tetris(C_tetris)
);

XMD I_CLK    ( .O(C_clk),            .I(clk),            .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_RST    ( .O(C_rst_n),          .I(rst_n),          .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_VALID  ( .O(C_in_valid),       .I(in_valid),       .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_TET0   ( .O(C_tetrominoes[0]), .I(tetrominoes[0]), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_TET1   ( .O(C_tetrominoes[1]), .I(tetrominoes[1]), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_TET2   ( .O(C_tetrominoes[2]), .I(tetrominoes[2]), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_POS0   ( .O(C_position[0]),    .I(position[0]),    .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_POS1   ( .O(C_position[1]),    .I(position[1]),    .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_POS2   ( .O(C_position[2]),    .I(position[2]),    .PU(1'b0), .PD(1'b0), .SMT(1'b0));

YA2GSD O_TVALID ( .I(C_tetris_valid), .O(tetris_valid),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_SVALID ( .I(C_score_valid),  .O(score_valid),    .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_FAIL   ( .I(C_fail),         .O(fail),           .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_SCORE0 ( .I(C_score[0]),     .O(score[0]),       .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_SCORE1 ( .I(C_score[1]),     .O(score[1]),       .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_SCORE2 ( .I(C_score[2]),     .O(score[2]),       .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_SCORE3 ( .I(C_score[3]),     .O(score[3]),       .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET0   ( .I(C_tetris[0]),    .O(tetris[0]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET1   ( .I(C_tetris[1]),    .O(tetris[1]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET2   ( .I(C_tetris[2]),    .O(tetris[2]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET3   ( .I(C_tetris[3]),    .O(tetris[3]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET4   ( .I(C_tetris[4]),    .O(tetris[4]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET5   ( .I(C_tetris[5]),    .O(tetris[5]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET6   ( .I(C_tetris[6]),    .O(tetris[6]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET7   ( .I(C_tetris[7]),    .O(tetris[7]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET8   ( .I(C_tetris[8]),    .O(tetris[8]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET9   ( .I(C_tetris[9]),    .O(tetris[9]),      .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET10  ( .I(C_tetris[10]),   .O(tetris[10]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET11  ( .I(C_tetris[11]),   .O(tetris[11]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET12  ( .I(C_tetris[12]),   .O(tetris[12]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET13  ( .I(C_tetris[13]),   .O(tetris[13]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET14  ( .I(C_tetris[14]),   .O(tetris[14]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET15  ( .I(C_tetris[15]),   .O(tetris[15]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET16  ( .I(C_tetris[16]),   .O(tetris[16]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET17  ( .I(C_tetris[17]),   .O(tetris[17]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET18  ( .I(C_tetris[18]),   .O(tetris[18]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET19  ( .I(C_tetris[19]),   .O(tetris[19]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET20  ( .I(C_tetris[20]),   .O(tetris[20]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET21  ( .I(C_tetris[21]),   .O(tetris[21]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET22  ( .I(C_tetris[22]),   .O(tetris[22]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET23  ( .I(C_tetris[23]),   .O(tetris[23]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET24  ( .I(C_tetris[24]),   .O(tetris[24]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET25  ( .I(C_tetris[25]),   .O(tetris[25]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET26  ( .I(C_tetris[26]),   .O(tetris[26]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET27  ( .I(C_tetris[27]),   .O(tetris[27]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET28  ( .I(C_tetris[28]),   .O(tetris[28]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET29  ( .I(C_tetris[29]),   .O(tetris[29]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET30  ( .I(C_tetris[30]),   .O(tetris[30]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET31  ( .I(C_tetris[31]),   .O(tetris[31]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET32  ( .I(C_tetris[32]),   .O(tetris[32]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET33  ( .I(C_tetris[33]),   .O(tetris[33]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET34  ( .I(C_tetris[34]),   .O(tetris[34]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET35  ( .I(C_tetris[35]),   .O(tetris[35]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET36  ( .I(C_tetris[36]),   .O(tetris[36]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET37  ( .I(C_tetris[37]),   .O(tetris[37]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET38  ( .I(C_tetris[38]),   .O(tetris[38]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET39  ( .I(C_tetris[39]),   .O(tetris[39]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET40  ( .I(C_tetris[40]),   .O(tetris[40]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET41  ( .I(C_tetris[41]),   .O(tetris[41]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET42  ( .I(C_tetris[42]),   .O(tetris[42]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET43  ( .I(C_tetris[43]),   .O(tetris[43]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET44  ( .I(C_tetris[44]),   .O(tetris[44]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET45  ( .I(C_tetris[45]),   .O(tetris[45]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET46  ( .I(C_tetris[46]),   .O(tetris[46]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET47  ( .I(C_tetris[47]),   .O(tetris[47]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET48  ( .I(C_tetris[48]),   .O(tetris[48]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET49  ( .I(C_tetris[49]),   .O(tetris[49]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET50  ( .I(C_tetris[50]),   .O(tetris[50]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET51  ( .I(C_tetris[51]),   .O(tetris[51]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET52  ( .I(C_tetris[52]),   .O(tetris[52]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET53  ( .I(C_tetris[53]),   .O(tetris[53]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET54  ( .I(C_tetris[54]),   .O(tetris[54]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET55  ( .I(C_tetris[55]),   .O(tetris[55]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET56  ( .I(C_tetris[56]),   .O(tetris[56]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET57  ( .I(C_tetris[57]),   .O(tetris[57]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET58  ( .I(C_tetris[58]),   .O(tetris[58]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET59  ( .I(C_tetris[59]),   .O(tetris[59]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET60  ( .I(C_tetris[60]),   .O(tetris[60]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET61  ( .I(C_tetris[61]),   .O(tetris[61]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET62  ( .I(C_tetris[62]),   .O(tetris[62]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET63  ( .I(C_tetris[63]),   .O(tetris[63]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET64  ( .I(C_tetris[64]),   .O(tetris[64]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET65  ( .I(C_tetris[65]),   .O(tetris[65]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET66  ( .I(C_tetris[66]),   .O(tetris[66]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET67  ( .I(C_tetris[67]),   .O(tetris[67]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET68  ( .I(C_tetris[68]),   .O(tetris[68]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET69  ( .I(C_tetris[69]),   .O(tetris[69]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET70  ( .I(C_tetris[70]),   .O(tetris[70]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_TET71  ( .I(C_tetris[71]),   .O(tetris[71]),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));

//I/O power 3.3V pads x? (DVDD + DGND)
VCC3IOD VDDP0 ();
GNDIOD  GNDP0 ();
VCC3IOD VDDP1 ();
GNDIOD  GNDP1 ();
VCC3IOD VDDP2 ();
GNDIOD  GNDP2 ();
VCC3IOD VDDP3 ();
GNDIOD  GNDP3 ();
VCC3IOD VDDP4 ();
GNDIOD  GNDP4 ();
VCC3IOD VDDP5 ();
GNDIOD  GNDP5 ();
VCC3IOD VDDP6 ();
GNDIOD  GNDP6 ();
VCC3IOD VDDP7 ();
GNDIOD  GNDP7 ();
VCC3IOD VDDP8 ();
GNDIOD  GNDP8 ();
VCC3IOD VDDP9 ();
GNDIOD  GNDP9 ();
VCC3IOD VDDP10 ();
GNDIOD  GNDP10 ();
VCC3IOD VDDP11 ();
GNDIOD  GNDP11 ();
VCC3IOD VDDP12 ();
GNDIOD  GNDP12 ();
VCC3IOD VDDP13 ();
GNDIOD  GNDP13 ();
VCC3IOD VDDP14 ();
GNDIOD  GNDP14 ();
VCC3IOD VDDP15 ();
GNDIOD  GNDP15 ();
VCC3IOD VDDP16 ();
GNDIOD  GNDP16 ();
VCC3IOD VDDP17 ();
GNDIOD  GNDP17 ();
VCC3IOD VDDP18 ();
GNDIOD  GNDP18 ();
VCC3IOD VDDP19 ();
GNDIOD  GNDP19 ();


//...

//Core poweri 1.8V pads x? (VDD + GND)
VCCKD VDDC0 ();
GNDKD GNDC0 ();
VCCKD VDDC1 ();
GNDKD GNDC1 ();
VCCKD VDDC2 ();
GNDKD GNDC2 ();
VCCKD VDDC3 ();
GNDKD GNDC3 ();
//...



endmodule

