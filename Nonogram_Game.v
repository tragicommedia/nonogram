`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/11 17:14:32
// Design Name: 
// Module Name: Nonogram_Game
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////

module nonogram_game (
    input clk,
    input rst,
    input [1:0] current_level, 
    output reg game_over,
    output reg [1:0] next_level 
);

wire [4:0] key_pulse;
wire [3:0] sel_x, sel_y;
wire [99:0] paint, block;
wire event_off;
reg [4:0] wrong_count;

reg [99:0] grid_paint;
reg [99:0] grid_block;

reg [3:0] player_x;
reg [3:0] player_y;

integer k;

reg level_clear; 

control_mod control_inst (clk, rst, key_pulse, sel_x, sel_y, paint, block, event_off);

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        // 초기화
        game_over <= 0;
        wrong_count <= 0;
        player_x <= 0;
        player_y <= 0;
        
        if (current_level == 0) begin
            // 첫 번째 
            grid_paint[0] <= 10'b0000110110;
            grid_paint[1] <= 10'b0001001001;
            grid_paint[2] <= 10'b0000001000;
            grid_paint[3] <= 10'b0000001000;
            grid_paint[4] <= 10'b0000011110;
            grid_paint[5] <= 10'b0000111111;
            grid_paint[6] <= 10'b0001111101;
            grid_paint[7] <= 10'b0001111111;
            grid_paint[8] <= 10'b1011111111;
            grid_paint[9] <= 10'b1111111111;
        end else if (current_level == 1) begin
            // 두 번째 
            grid_paint[0] <= 10'b0011111100;
            grid_paint[1] <= 10'b1111110111;
            grid_paint[2] <= 10'b1011110101;
            grid_paint[3] <= 10'b1111110111;
            grid_paint[4] <= 10'b0011101100;
            grid_paint[5] <= 10'b0001111000;
            grid_paint[6] <= 10'b0000110000;
            grid_paint[7] <= 10'b0011111100;
            grid_paint[8] <= 10'b0011111100;
            grid_paint[9] <= 10'b0111111110;
        end else if (current_level == 2) begin
            // 세 번째 
            grid_paint[0] <= 10'b0000110000;
            grid_paint[1] <= 10'b0001111000;
            grid_paint[2] <= 10'b0011111100;
            grid_paint[3] <= 10'b0111111110;
            grid_paint[4] <= 10'b1111111111;
            grid_paint[5] <= 10'b1111111111;
            grid_paint[6] <= 10'b1111111111;
            grid_paint[7] <= 10'b0110110110;
            grid_paint[8] <= 10'b0000110000;
            grid_paint[9] <= 10'b0000110000;
        end

        // 초기화 
        grid_block <= 100'b1111111111;
    end else begin
        // 레벨이 끝나면 초기화
        if (game_over) begin
            wrong_count <= 0;
            player_x <= 0;
            player_y <= 0;
        end
    end
end

always @* begin
    // 각 레벨 클리어 조건
    if (current_level == 0) begin
        level_clear = (grid_paint == 100'b0000110110000100100100000010000000001000000001111000001111110001111101000111111110111111111111111111);
    end else if (current_level == 1) begin
        level_clear = (grid_paint == 100'b0011111100111111011110111101011111110111001110110000011110000000110000001111110000111111000111111110);
    end else begin
        level_clear = (grid_paint == 100'b0000110000000111100000111111000111111110111111111111111111111111111111011011011000001100000001111000);
    end
end



always @ (posedge clk or posedge rst) begin
    if (rst) begin
        // 초기화
        game_over <= 0;
        next_level <= 0;
    end else begin
        // 게임이 시작되었을 때마다
        if (!game_over && (next_level == current_level)) begin
            if (current_level == 2) 
                next_level <= 0;
            else
                next_level <= current_level + 1; 
        end
    end
end

endmodule