module BB(
    //Input Ports
    input clk,
    input rst_n,
    input in_valid,
    input [1:0] inning,   // Current inning number
    input half,           // 0: top of the inning, 1: bottom of the inning
    input [2:0] action,   // Action code

    //Output Ports
    output reg out_valid,  // Result output valid
    output reg [7:0] score_A,  // Score of team A (guest team)
    output reg [7:0] score_B,  // Score of team B (home team)
    output reg [1:0] result    // 0: Team A wins, 1: Team B wins, 2: Darw
);

//==============================================//
//             Action Memo for Students         //
// Action code interpretation:
// 3’d0: Walk (BB)
// 3’d1: 1H (single hit)
// 3’d2: 2H (double hit)
// 3’d3: 3H (triple hit)
// 3’d4: HR (home run)
// 3’d5: Bunt (short hit)
// 3’d6: Ground ball
// 3’d7: Fly ball
//==============================================//

//==============================================//
//             Parameter and Integer            //
//==============================================//
// State declaration for FSM
// Example: parameter IDLE = 3'b000;



//==============================================//
//                 reg declaration              //
//==============================================//
reg [1:0] out_reg, out_nxt;
reg [2:0] base_reg, base_nxt;
reg [1:0] player_on_base;
reg [3:0] score_A_reg, score_B_reg;
reg [2:0] score_tmp;
reg early_win;
reg out_valid_nxt;
//==============================================//
//             Current State Block              //
//==============================================//



//==============================================//
//              Next State Block                //
//==============================================//



//==============================================//
//             Base and Score Logic             //
//==============================================//
// Handle base runner movements and score calculation.
// Update bases and score depending on the action:
// Example: Walk, Hits (1H, 2H, 3H), Home Runs, etc.
always @(posedge clk) begin
    if (in_valid) begin
        if((inning > 2) & (~half)) begin
            if((score_A_reg < score_B_reg)) begin
                early_win <=  1;
            end else begin
                early_win <= 0;
            end
        end
    end else begin
        early_win <= 0;
    end
end

always @(posedge clk) begin
    if (in_valid) begin
        if(half) begin
            score_B_reg <= score_B_reg + score_tmp;
        end else begin
            score_A_reg <= score_A_reg + score_tmp;
        end
    end else begin
        if (out_reg[0]) begin
            score_B_reg <= score_B_reg;
            score_A_reg <= score_A_reg;
        end else begin
            score_A_reg <= 0;
            score_B_reg <= 0;
        end
    end
end

always @(posedge clk) begin
    out_reg <= (in_valid) ? (out_reg > 2) ? out_nxt : (out_reg[1] & out_nxt[1]) ? 3 : out_reg + out_nxt : 0;
end

always @(posedge clk) begin
    base_reg <= (in_valid) ? base_nxt : 0;
end

// assign player_on_base = base_reg[0] + base_reg[1] + base_reg[2];
always @(*) begin
    case(base_reg)
    0: player_on_base = 0;
    1, 2, 4: player_on_base = 1;
    3, 5, 6: player_on_base = 2;
    7: player_on_base = 3;
    endcase
end

always @(*) begin
    score_tmp = 0;
    base_nxt = 0;
    out_nxt = 0;
    if(action == 0) begin
        score_tmp = (player_on_base > 2);
        case(base_reg)
        0:  base_nxt = 3'b001; 1, 2: base_nxt = 3'b011; 4: base_nxt = 3'b101; 3, 5, 6, 7: base_nxt = 3'b111;
        endcase
    end else if(action == 1) begin
        if(out_reg > 1) begin
            base_nxt = (base_reg * 4) + 1;
            score_tmp = (base_reg[2] + base_reg[1]);
        end else begin
            base_nxt = (base_reg * 2) + 1;
            score_tmp = base_reg[2]; 
        end
    end else if(action == 2) begin
        if(out_reg > 1) begin
            base_nxt = 3'b010;
            score_tmp = player_on_base;
        end else begin
            base_nxt[2] = base_reg[0];
            base_nxt[1] = 1;
            score_tmp = (base_reg[2] + base_reg[1]); 
        end
    end else if(action == 3) begin
        base_nxt = 3'b100;
        score_tmp = player_on_base;
    end else if(action == 4) begin
        score_tmp = player_on_base + 1;
    end else if(action == 5) begin
        out_nxt = 1;
        base_nxt = (base_reg * 2);
    end else if(action == 6) begin
        out_nxt = base_reg[0] ? 2 : 1;
        base_nxt[2] = base_reg[1];
    end else begin
        out_nxt = 1;
        base_nxt[1:0] = base_reg[1:0];
    end
    if(action > 4) begin
        score_tmp = base_reg[2];
        if((out_reg + out_nxt > 2)) begin
            score_tmp = 0;
            base_nxt = 0;
        end
    end
    if(early_win & half) begin
        score_tmp = 0;
    end
end
//==============================================//
//                Output Block                  //
//==============================================//
// Decide when to set out_valid high, and output score_A, score_B, and result.
assign out_valid_nxt = (~in_valid & out_reg > 2) ? 1 : 0;
assign score_A = (out_valid) ? score_A_reg : 0;
assign score_B = (out_valid) ? score_B_reg : 0;
assign result = {((score_A == score_B) & out_valid),(score_A < score_B)};

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 1'b0;
    end else begin
        out_valid <= out_valid_nxt;
    end
end


endmodule

// 2787