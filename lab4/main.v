`include "led_ctrl_unit.v"

module main(
    input wire rst,
    input wire clk,
    input wire en,
    input wire dec_start,
    input wire hex_count,
    output wire [7:0] led_en,
    output wire [7:0] led_cx
);
    reg [31:0] display;
    parameter STUDENT_ID_LOW = 8'b00001000; // last 2 digits of student id
    // display[24 +: 8]
    always @(posedge clk) begin
        display[24 +: 8] <= STUDENT_ID_LOW;   // show the highest 2 digits of my student id
    end

    parameter DECL_CLK_FREQ = 10_000_000; // Updated for 100MHz clock (0.1s as circle)
    parameter DEC_COUNTER_MAX = 30;
    reg [31:0] dec_clk_counter; // counter for decimal clk divider
    reg [7:0] dec_counter;      // real count of low 8 bits of display

    // implement edge detection for dec_start
    reg dec_sync0, dec_sync1, dec_prev;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dec_sync0 <= 0;
            dec_sync1 <= 0;
            dec_prev  <= 0;
        end else begin
            dec_sync0 <= dec_start;
            dec_sync1 <= dec_sync0;
            dec_prev  <= dec_sync1;
        end
    end

    // set dec_start state
    reg dec_start_state;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dec_start_state <= 1;
        end else if (dec_sync1 & ~dec_prev) begin
            dec_start_state <= ~dec_start_state;
        end
    end

    // implement edge detection for hex_count
    reg hex_sync0, hex_sync1, hex_prev;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hex_sync0 <= 0;
            hex_sync1 <= 0;
            hex_prev  <= 0;
        end else begin
            hex_sync0 <= hex_count;
            hex_sync1 <= hex_sync0;
            hex_prev  <= hex_sync1;
        end
    end

    // display[16 +: 8]
    // no debounce for hex_count
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            display[16 +: 8] = 0;
        end else if (hex_sync1 & ~hex_prev) begin
            display[16 +: 8] = display[16 +: 8] + 1;
        end
    end

    // display[8 +: 8]
    // debounce for hex_count
    reg triggered;
    reg [31:0] delay_count;
    parameter DELAY = 1_500_000;
    reg stable_triggered;
    reg [31:0] stable_delay_count;
    parameter STABLE_DELAY = 2_000_000;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            display[8 +: 8] <= 0;
            delay_count <= 0;
            triggered <= 1'b0;
            stable_triggered <= 1'b0;

        end else if (!triggered && (hex_sync1 & ~hex_prev) && delay_count < DELAY) begin
            triggered <= 1'b1;

        end else if (triggered && delay_count < DELAY) begin
            delay_count <= delay_count + 1;

        end else if (triggered && hex_count && delay_count >= DELAY) begin
            triggered <= 1'b0;
            stable_triggered <= 1'b1;
            delay_count <= 0;
        
        end else if (hex_count && stable_triggered && stable_delay_count < DELAY) begin
            stable_delay_count <= stable_delay_count + 1;
           
        end else if (!hex_count && stable_triggered) begin
            stable_triggered <= 1'b0;
            
        end else if (hex_count && stable_triggered && stable_delay_count >= DELAY) begin
            stable_triggered <= 1'b0;
            stable_delay_count <= 0;
            display[8 +: 8] <= display[8 +: 8] + 1;
            
        end
    end

    // display[0 +: 8]
    // auto counter controller
    wire [3:0] higher_bit;
    wire [3:0] lower_bit;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dec_counter <= 0;
            dec_clk_counter <= 0;
            
        end else begin
            if (dec_start_state && dec_clk_counter >= DECL_CLK_FREQ) begin
                dec_clk_counter <= 0;
                // inc
                if (dec_counter >= DEC_COUNTER_MAX) begin
                    dec_counter <= 0;
                end else begin
                    dec_counter <= dec_counter + 1;
                end
            end else if (dec_start_state && dec_clk_counter < DECL_CLK_FREQ) begin
                dec_clk_counter <= dec_clk_counter + 1;
            end
        end
    end

    // divide hex number into decimal digits
    assign higher_bit = (dec_counter / 10) % 10;
    assign lower_bit = dec_counter % 10;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            display[0 +: 8] <= 0;
        end else begin
            display[0 +: 4] <= lower_bit;
            display[4 +: 4] <= higher_bit;
        end

    end

    // connect to led control unit
    led_ctrl_unit u_led_ctrl_unit (
        .rst(rst),
        .clk(clk),
        .display(display),
        .en(en),
        .led_en(led_en),
        .led_cx(led_cx)
    );
    
    initial begin
        dec_start_state <= 1;
    end

endmodule
