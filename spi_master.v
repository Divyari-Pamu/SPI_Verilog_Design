`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: spi_m
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

module spi_m(
    input clk,
    input reset_n,
    input start,
    input [7:0] master_tx,
    output reg [7:0] master_rx,
    output reg sclk,
    output reg mosi,
    input miso,
    output reg ss_n,
    output reg done
);

    reg [2:0] bit_cnt;
    reg [8:0] tx_reg;
    reg [8:0] rx_reg;
    reg [2:0] state;

    parameter IDLE = 3'b000,
              LOAD = 3'b001,
              TRANSFER = 3'b010,
              COMPLETE = 3'b011;

    reg busy;
    assign busy_flag = busy;

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            sclk <= 0; 
            ss_n <= 1;
            done <= 0;
            busy <= 0;
            bit_cnt <= 0;
            tx_reg <= 0;
            rx_reg <= 0;
            mosi <= 0;
            master_rx <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    sclk <= 0;
                    ss_n <= 1;
                    busy <= 0;
                    if (start) begin
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    tx_reg <= master_tx;
                    rx_reg <= 0;
                    bit_cnt <= 7;
                    ss_n <= 0;
                    busy <= 1;
                    state <= TRANSFER;
                end

                TRANSFER: begin
                    sclk <= ~sclk; // Toggle clock
                    if (sclk == 0) begin
                        mosi <= tx_reg[bit_cnt];
                    end else begin
                        rx_reg[bit_cnt] <= miso;
                        if (bit_cnt == 0) begin
                            master_rx <= rx_reg;
                            state <= COMPLETE;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

               COMPLETE: begin
                   sclk <= 0; 
                   ss_n <= 1;
                   
                  done <= 1;
                  busy <= 0;
                state <= IDLE;
                end
            endcase
        end
    end

endmodule
