`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: spi_s
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

module spi_s(
    input sclk,
    input ss_n,
    input mosi,
    output reg miso,
    output reg [7:0] slave_rx,
    input [7:0] slave_tx,
    input reset_n
);
    reg [2:0] bit_cnt;
    reg [8:0] tx_reg;
    reg [8:0] rx_reg;


    always @(posedge sclk or posedge reset_n or posedge ss_n) begin
        if (reset_n || ss_n) begin
            bit_cnt <= 3'd7;
            tx_reg <= slave_tx;
            miso <= 0;
        end else begin
            miso <= tx_reg[bit_cnt];
        end
    end

    always @(negedge sclk or posedge reset_n) begin
        if (reset_n) begin
            rx_reg <= 8'd0;
            slave_rx <= 8'd0;
        end else if (!ss_n) begin
            rx_reg[bit_cnt] <= mosi;
            if (bit_cnt == 0) begin
                slave_rx <= {rx_reg[7:1], mosi};
                bit_cnt <= 3'd7;
            end else begin
                bit_cnt <= bit_cnt - 1;
            end
        end
    end
endmodule
