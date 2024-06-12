module nonogram_game (
    input clk,
    input rst,
    output reg [1:0] current_level, 
    output reg [1:0] next_level 
);

wire [99:0] paint, block;

reg [99:0] grid_paint;
reg [99:0] grid_block;

control_mod control_inst (clk, rst, sel_x, sel_y, paint, block, event_off);

// 각 레벨의 정답 값
localparam [99:0] LEVEL_0_ANSWER = 100'b0000110110000100100100000010000000001000000001111000001111110001111101000111111110111111111111111111;
localparam [99:0] LEVEL_1_ANSWER = 100'b0011111100111111011110111101011111110111001110110000011110000000110000001111110000111111000111111110;
localparam [99:0] LEVEL_2_ANSWER = 100'b0000110000000111100000111111000111111110111111111111111111111111011011011000001100000001100000001100;

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        current_level <= 0;
        next_level <= 0;
        grid_paint <= 0;
        grid_block <= 0;
    end else begin
        grid_paint <= paint;
        grid_block <= block;

        // Level progression logic
        if (current_level == 0 && grid_paint == LEVEL_0_ANSWER) begin
            next_level <= 1;
        end else if (current_level == 1 && grid_paint == LEVEL_1_ANSWER) begin
            next_level <= 2;
        end else if (current_level == 2 && grid_paint == LEVEL_2_ANSWER) begin
            next_level <= 0;
        end else
            next_level <= 0;
        end
end
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        current_level <= 0;
    end else if (current_level != next_level) begin
        current_level <= next_level;
        grid_paint <= 0;
        grid_block <= 0;
    end else begin
        current_level <= next_level;
    end
end   
endmodule