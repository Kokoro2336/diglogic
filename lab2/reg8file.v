module reg8file (
    input  wire clk,  
    input  wire clr,    
    input  wire en,
    input  wire [7:0] d,
    input  wire [2:0] wsel,
    input  wire [2:0] rsel,
    output reg  [7:0] q    
);

    // Define 8 registers
    reg [7:0] regs [7:0];

    // Write logic
    always @(posedge clk or posedge clr) begin
        if (clr) begin
            integer i;
            for (i = 0; i < 8; i = i + 1) begin
                regs[i] <= 8'b0;
            end
        end else if (en) begin
            regs[wsel] <= d; // Write to selected register
        end
    end

    // Read logic
    always @(*) begin
        q = regs[rsel]; // Read from selected register
    end

endmodule
