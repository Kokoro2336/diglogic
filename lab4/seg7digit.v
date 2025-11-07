module seg7digit(
    input wire rst,
    input wire clk_div,
    input wire en,
    input wire [3:0] display,  // 待显示的8个十六进制字�?
    output reg [7:0] led_cx    // 段�?�信�?
);
    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            led_cx <= 8'b11111110;

        end else begin
            if (en) begin
                case (display[3:0])
                    4'b0000: led_cx <= 8'b00000011; // 0
                    4'b0001: led_cx <= 8'b10011111; // 1
                    4'b0010: led_cx <= 8'b00100101; // 2
                    4'b0011: led_cx <= 8'b00001101; // 3
                    4'b0100: led_cx <= 8'b10011001; // 4
                    4'b0101: led_cx <= 8'b01001001; // 5
                    4'b0110: led_cx <= 8'b01000001; // 6
                    4'b0111: led_cx <= 8'b00011111; // 7
                    4'b1000: led_cx <= 8'b00000001; // 8
                    4'b1001: led_cx <= 8'b00001001; // 9
                    4'b1010: led_cx <= 8'b00010001; // A
                    4'b1011: led_cx <= 8'b11000001; // B
                    4'b1100: led_cx <= 8'b01100011; // C
                    4'b1101: led_cx <= 8'b10000101; // D
                    4'b1110: led_cx <= 8'b01100001; // E
                    4'b1111: led_cx <= 8'b01110001; // F
                endcase
            end else begin
                led_cx <= 8'b11111111;              // all off
            end
        end
    end
endmodule
