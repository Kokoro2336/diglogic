module light(
    input wire clk,
    input wire rst,
    input wire button,
    input wire [1:0] freq_set,
    input wire dir_set,
    output reg [7:0] led
);

    reg start;
    reg [31:0] counter;
    reg clk_div;
    reg [31:0] current_div;

    // divider parameters
    parameter FREQ_1000HZ = 100000; // 0.001s
    parameter FREQ_100HZ  = 1000000; // 0.01s
    parameter FREQ_20HZ   = 5000000; // 0.05s
    parameter FREQ_5HZ    = 20000000; // 0.2s

    // three-stage synchronizer for button input
    reg sync0, sync1, prev;

    // button signal catching
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
            prev <= 1'b0;
        end else begin
            sync0 <= button;
            sync1 <= sync0;
            prev <= sync1;
        end
    end

    // start
    always @(posedge clk or posedge rst) begin
       if (rst) begin
            start <= 1'b0;
        end else if (sync1 & ~prev) begin
            start <= ~start; // toggle start signal
        end
    end

    // set frequency divider
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_div <= FREQ_1000HZ;
        end else begin 
            case (freq_set)
                2'b00: current_div <= FREQ_1000HZ;
                2'b01: current_div <= FREQ_100HZ;
                2'b10: current_div <= FREQ_20HZ;
                2'b11: current_div <= FREQ_5HZ;
            endcase
        end
    end

    // counter controller
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_div <= 0;
        end else if (start) begin
            if (counter >= current_div) begin
                counter <= 0;
                clk_div <= ~clk_div;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // led controller
    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            led <= 8'b00000001; // Enlight LED0
        end else if (start) begin
            if (dir_set) begin
                // shift left
                led <= {led[6:0], led[7]};
            end else begin
                // shift right
                led <= {led[0], led[7:1]};
            end
        end
    end

endmodule
