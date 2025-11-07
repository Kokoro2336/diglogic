`timescale 1ns/1ps
`include "main.v"

module testbench;

    // Testbench signals
    reg rst;
    reg clk;
    reg en;
    reg dec_start;
    reg hex_count;
    wire [7:0] led_en;
    wire [7:0] led_cx;

    // Instantiate the main module
    main uut (
        .rst(rst),
        .clk(clk),
        .en(en),
        .dec_start(dec_start),
        .hex_count(hex_count),
        .led_en(led_en),
        .led_cx(led_cx)
    );

    // Clock generation (100MHz)
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period (100MHz)

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1; en = 0; dec_start = 0; hex_count = 0;

        // Apply reset
        #200 rst = 0; // Release reset, all counters start from 0

        // Test SW0 (enable signal)
        #200 en = 1; // Enable display
        #1000 en = 0; // Disable display (all segments off)
        #1000 en = 1; // Enable display again

        // Test S2 (decimal counter start/stop)
        #2000 dec_start = 1; #100 dec_start = 0; // Start counting
        #10000 dec_start = 1; #100 dec_start = 0; // Stop counting
        #10000 dec_start = 1; #100 dec_start = 0; // Resume counting

        // Test S3 (hex_count without debounce)
        #100 hex_count = 1; #10 hex_count = 0; // Increment DK5-DK4
        #100 hex_count = 1; #10 hex_count = 0; // Increment DK5-DK4 again

        // Test S3 (hex_count with debounce)
        #100 hex_count = 1; #50 hex_count = 0; // Increment DK3-DK2 (debounced)
        #200 hex_count = 1; #50 hex_count = 0; // Increment DK3-DK2 again

        // Test S1 (reset signal)
        #100 rst = 1; // Assert reset
        #20 rst = 0; // Release reset

        // Extend simulation duration for better observation
        #1000 en = 1; // Enable display for a longer period
        #5000 dec_start = 1; #10 dec_start = 0; // Start counting and observe longer
        #10000 hex_count = 1; #50 hex_count = 0; // Increment DK5-DK4 with extended time
        #20000 hex_count = 1; #50 hex_count = 0; // Increment DK3-DK2 with debounce
        #5000 rst = 1; // Assert reset for a longer period
        #50 rst = 0; // Release reset

        // End simulation after extended observation
        #10000 $finish;
    end

    // Optional waveform dump for debugging
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
    end

endmodule
