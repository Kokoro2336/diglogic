`include "seg7digit.v"

module led_ctrl_unit (
    input wire rst,
    input wire clk,
    input wire en,
    input wire [31:0] display,  // 待显示的8个十六进制字�?
    output reg [7:0]  led_en,   // 位�?�信�?
    output wire [7:0]  led_cx    // 段�?�信�?
);
    parameter SCAN_FREQ = 200_000; 

    reg clk_div;
    reg [31:0] counter;
    reg [3:0] current_display;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
            counter <= 0;
        end else begin
            // every 1ms toggle clk_div(2ms as a circle)
            if (counter >= (SCAN_FREQ/2 - 1)) begin
                clk_div <= ~clk_div;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    seg7digit u_seg7digit(
        .rst(rst),
        .clk_div(clk_div),
        .en(en),
        .display(current_display),
        .led_cx(led_cx)
    );

    always @(posedge clk) begin
        current_display = 
            (led_en == 8'b11111110) ? display[3:0] :
            (led_en == 8'b11111101) ? display[7:4] :
            (led_en == 8'b11111011) ? display[11:8] :
            (led_en == 8'b11110111) ? display[15:12] :
            (led_en == 8'b11101111) ? display[19:16] :
            (led_en == 8'b11011111) ? display[23:20] :
            (led_en == 8'b10111111) ? display[27:24] :
                                    display[31:28];
    end 
    
    // implement edge detection for hex_count
    reg sync0, sync1, prev;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync0 <= 0;
            sync1 <= 0;
            prev  <= 0;
        end else begin
            sync0 <= clk_div;
            sync1 <= sync0;
            prev  <= sync1;
        end
    end

    // Update current display based on led_en
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_en <= 8'b11111110;  // restart from first digit
        end else if (sync1 & ~prev) begin
            // Update LED control signals
            led_en <= {led_en[6:0], led_en[7]}; // Rotate enable signals
        end
    end
endmodule
