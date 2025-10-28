`timescale 1ns/1ps

module tb_reg8file;

    // Testbench signals
    reg clk;
    reg clr;
    reg en;
    reg [7:0] d;
    reg [2:0] wsel;
    reg [2:0] rsel;
    wire [7:0] q;

    // Instantiate the reg8file module
    regfile uut (
        .clk(clk),
        .clr(clr),
        .en(en),
        .d(d),
        .wsel(wsel),
        .rsel(rsel),
        .q(q)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock (10 ns period)

    // Test sequence
    initial begin
        // Initialize signals
        clr = 1; en = 0; d = 8'b0; wsel = 3'b0; rsel = 3'b0;

        // Reset all registers
        #10 clr = 0; // Release reset

        // Write data to register 1
        #10 en = 1; wsel = 3'b001; d = 8'b00000001; // Write 1 to regs[1]
        #10 en = 0; // Disable write

        // Write data to register 2
        #10 en = 1; wsel = 3'b010; d = 8'b00000010; // Write 2 to regs[2]
        #10 en = 0; // Disable write

        // Read data from register 1
        #10 rsel = 3'b001; // Read regs[1], expect q = 8'b00000001

        // Read data from register 2
        #10 rsel = 3'b010; // Read regs[2], expect q = 8'b00000010

        // Reset all registers again
        #10 clr = 1; // Assert reset
        #10 clr = 0; // Release reset

        // End simulation
        #20 $finish;
    end

    // Optional waveform dump for debugging
    initial begin
        $dumpfile("tb_reg8file.vcd");
        $dumpvars(0, tb_reg8file);
    end

endmodule
