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
    input [4:0] key_pulse, // 1clk ������ key pulse
    output wire [3:0] sel_x, // ���õ� �׸����� X ��ǥ (0~9)
    output wire [3:0] sel_y,  // ���õ� �׸����� Y ��ǥ (0~9)
    output wire [99:0] paint, // (0,0)���� (9,9)����, 1�̸� ��ĥ, 0�̸� ��ĥx
    output wire [99:0] block, // (0,0)���� (9,9)����, 1�̸� ���, 0�̸� ���x
    output reg event_off // reset �߻� �� �̺�Ʈ ����
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

    // ��ġ ��ȭ ����
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
                if (c_block[(10 * c_y) + c_x] == 1'b0) n_paint[(10 * c_y) + c_x] = ~c_paint[(10 * c_y) + c_x]; // ���� ��� ���°� �ƴ� ��� ����Ʈ ����
                else n_paint[(10 * c_y) + c_x] = c_paint[(10 * c_y) + c_x];                  
                btn_en = 1'b1; // �̺�Ʈ ���� ���
                n_x = c_x;
                n_y = c_y;
            end
            `btn_B : begin
                n_paint = c_paint;
                n_block = c_block; 
                if (c_paint[(10 * c_y) + c_x] == 1'b0) n_block[(10 * c_y) + c_x] = ~c_block[(10 * c_y) + c_x]; // ���� ����Ʈ ���°� �ƴ� ��� ��� ����
                else n_block[(10 * c_y) + c_x] = c_block[(10 * c_y) + c_x];                   
                btn_en = 1'b1; // �̺�Ʈ ���� ���
                n_x = c_x;
                n_y = c_y;
            end
            default : begin
                n_paint = c_paint;
                n_block = c_block;
                btn_en = 1'b0; // �������
                n_x = c_x;
                n_y = c_y;
            end
        endcase
    end
    
    // clk�� ���� ��ġ ��ȭ
    reg rst_en;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            c_paint <= 100'b0;
            c_block <= 100'b0;
            c_x <= 4'b0000;
            c_y <= 4'b0000;
            rst_en <= 1'b1; // �̺�Ʈ ����
        end
        else begin
            c_paint <= n_paint;
            c_block <= n_block;
            c_x <= n_x;
            c_y <= n_y;
            rst_en <= 1'b0; // �������
        end
    end

    // rst_en�� ���� �̺�Ʈ ���ſ� btn_en�� ���� �̺�Ʈ ����
    always @ (posedge clk or posedge rst) begin
        if (rst) event_off <= 1'b1;
        else if (btn_en) event_off <= 1'b0;
        else event_off <= event_off;
    end
    
    // sel_x, sel_y �Ҵ�
    assign sel_x = c_x;
    assign sel_y = c_y;
    
    // paint, block �Ҵ�
    assign paint = c_paint;
    assign block = c_block;
    
endmodule