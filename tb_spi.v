`timescale 1ns / 1ps


module tb_spi_m_spi_s;

    reg clk = 0;
    reg reset_n = 0;
    reg start = 0;
    reg [7:0] master_tx = 8'hA5;
    reg [7:0] slave_tx  = 8'h3C;
    wire [7:0] master_rx, slave_rx; 
    wire sclk, mosi, miso, ss_n, done;

    always #10 clk = ~clk; // 100 MHz

    spi_m u_master (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .master_tx(master_tx),
        .master_rx(master_rx),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n),
        .done(done)
    );

    spi_s u_slave (
        .sclk(sclk),
        .ss_n(ss_n),
        .mosi(mosi),
        .miso(miso),
        .slave_rx(slave_rx),
        .slave_tx(slave_tx),
        .reset_n(reset_n)
    );

    initial begin
        $dumpfile("spi_master_slave.vcd");
        $dumpvars(0, tb_spi_m_spi_s);
        $monitor("T=%0t | SS_N=%b | SCLK=%b | MOSI=%b | MISO=%b | MRX=%h | SRX=%h",
                 $time, ss_n, sclk, mosi, miso, master_rx, slave_rx);

        // Reset
        reset_n = 1;
        #100 reset_n = 0;

        // Wait, then start
        #00 start = 1;
        #20  start = 0;

        wait(done);
        #100;

        $display("Master sent: %h, received: %h", master_tx, master_rx);
        $display("Slave sent:  %h, received: %h", slave_tx, slave_rx);

        #100 $finish;
    end
endmodule