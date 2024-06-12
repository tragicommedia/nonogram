`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/24 20:41:19
// Design Name: 
// Module Name: control_mod
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
//////////////////////////////////////////////////////////////////////////////////
`define btn_2 5'b10010
`define btn_4 5'b10100
`define btn_6 5'b10110
`define btn_8 5'b11000
`define btn_A 5'b11010
`define btn_B 5'b11011

module control_mod(
    input clk,
    input rst,
    input [4:0] key_pulse, // 1clk 동안의 key pulse
    output wire [3:0] sel_x, // 선택된 그리드의 X 좌표 (0~9)
    output wire [3:0] sel_y,  // 선택된 그리드의 Y 좌표 (0~9)
    output wire [99:0] paint, // (0,0)부터 (9,9)까지, 1이면 색칠, 0이면 색칠x
    output wire [99:0] block, // (0,0)부터 (9,9)까지, 1이면 블록, 0이면 블록x
    output reg event_off // reset 발생 시 이벤트 제거
);
    
    // 0  1  2  3  4  5  6  7  8  9   
    // 1
    // 2
    // 3
    // 4
    // 5
    // 6
    // 7
    // 8
    // 9

    // 위치 변화 정의
    reg [3:0] c_x, c_y, n_x, n_y;
    reg [99:0] c_paint = 100'b0, n_paint = 100'b0, c_block = 100'b0, n_block = 100'b0;
    reg btn_en;
    always @ (key_pulse) begin
        case (key_pulse)
            `btn_2 : begin
                n_paint = c_paint;
                n_block = c_block;
                btn_en = btn_en; 
                n_x = c_x;
                if (c_y != 4'b0000) n_y = c_y - 4'b0001;
                else n_y = 4'b1001;
            end
            `btn_4 : begin
                n_paint = c_paint;
                n_block = c_block;
                btn_en = btn_en;
                n_y = c_y;
                if (c_x != 4'b0000) n_x = c_x - 4'b0001;
                else n_x = 4'b1001;
            end
            `btn_6 : begin
                n_paint = c_paint;
                n_block = c_block;
                btn_en = btn_en;
                n_y = c_y;
                if (c_x != 4'b1001) n_x = c_x + 4'b0001;
                else n_x = 4'b0000;
            end
            `btn_8 : begin
                n_paint = c_paint;
                n_block = c_block;
                btn_en = btn_en;
                n_x = c_x;
                if (c_y != 4'b1001) n_y = c_y + 4'b0001;
                else n_y = 4'b0000;
            end
            `btn_A : begin
                n_paint = c_paint;
                n_block = c_block;  
                if (c_block[(10 * c_y) + c_x] == 1'b0) n_paint[(10 * c_y) + c_x] = ~c_paint[(10 * c_y) + c_x]; // 셀이 블록 상태가 아닐 경우 페인트 반전
                else n_paint[(10 * c_y) + c_x] = c_paint[(10 * c_y) + c_x];                  
                btn_en = 1'b1; // 이벤트 제거 취소
                n_x = c_x;
                n_y = c_y;
            end
            `btn_B : begin
                n_paint = c_paint;
                n_block = c_block; 
                if (c_paint[(10 * c_y) + c_x] == 1'b0) n_block[(10 * c_y) + c_x] = ~c_block[(10 * c_y) + c_x]; // 셀이 페인트 상태가 아닐 경우 블록 반전
                else n_block[(10 * c_y) + c_x] = c_block[(10 * c_y) + c_x];                   
                btn_en = 1'b1; // 이벤트 제거 취소
                n_x = c_x;
                n_y = c_y;
            end
            default : begin
                n_paint = c_paint;
                n_block = c_block;
                btn_en = 1'b0; // 원래대로
                n_x = c_x;
                n_y = c_y;
            end
        endcase
    end
    
    // clk에 따른 위치 변화
    reg rst_en;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            c_paint <= 100'b0;
            c_block <= 100'b0;
            c_x <= 4'b0000;
            c_y <= 4'b0000;
            rst_en <= 1'b1; // 이벤트 제거
        end
        else begin
            c_paint <= n_paint;
            c_block <= n_block;
            c_x <= n_x;
            c_y <= n_y;
            rst_en <= 1'b0; // 원래대로
        end
    end

    // rst_en에 따른 이벤트 제거와 btn_en에 따른 이벤트 생성
    always @ (posedge clk or posedge rst) begin
        if (rst) event_off <= 1'b1;
        else if (btn_en) event_off <= 1'b0;
        else event_off <= event_off;
    end
    
    // sel_x, sel_y 할당
    assign sel_x = c_x;
    assign sel_y = c_y;
    
    // paint, block 할당
    assign paint = c_paint;
    assign block = c_block;
    
endmodule