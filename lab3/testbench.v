`timescale 1ns/1ps
`include "light.v"

module testbench();

    // Testbench signals
    reg clk;
    reg rst;
    reg button;
    reg [1:0] freq_set;
    reg dir_set;
    wire [7:0] led;

    // Instantiate the light module
    light uut (
        .clk(clk),
        .rst(rst),
        .button(button),
        .freq_set(freq_set),
        .dir_set(dir_set),
        .led(led)
    );

    // Clock generation (100MHz)
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period (100MHz)

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1; button = 0; freq_set = 2'b00; dir_set = 0;
        // Reset the system
        #20 rst = 0; // Release reset, LED0 should light up

        // Start the LED flow (toggle using button) and let it run long enough to observe shifts
        #20 button = 1; #10 button = 0; // Start

        // Let it run at default freq (1kHz) for a noticeable time (50 ms)
        // 1 kHz setting in the DUT results in ~2 ms between LED shifts, so 50 ms shows many shifts
        #50000000;

        // Stop briefly
        #10 button = 1; #10 button = 0; // Stop
        #10000000; // 10 ms pause

        // Start again
        #10 button = 1; #10 button = 0; // Start

        // Switch to 100Hz and observe for ~200 ms (100 Hz gives ~20 ms between shifts)
        freq_set = 2'b01; #200000000;

        // Switch to 20Hz and observe for ~600 ms (20 Hz gives ~100 ms between shifts)
        freq_set = 2'b10; #600000000;

        // Switch to 5Hz and observe for ~2 s (5 Hz gives ~400 ms between shifts)
        freq_set = 2'b11; #2000000000;

        // Test direction changes: left for 300 ms, then right for 300 ms
        dir_set = 1; #300000000;
        dir_set = 0; #300000000;

        // End simulation after observations
        $finish;
    end

    // Optional waveform dump for debugging
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
    end

endmodule
