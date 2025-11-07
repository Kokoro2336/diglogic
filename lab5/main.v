`include "uart_send.v"

module main(
    input wire rst,
    input wire clk,
    input wire uart_rx,
    output wire uart_tx
);

    localparam STUDENT_ID = "hitsz2023311608";
    localparam ID_LEN = 15;
    reg [7:0] id_data [0:ID_LEN-1];
    reg [3:0] current_index;

    localparam CHAR_INTERVAL = 500_000;     // send next char every 5ms
    reg [31:0] char_counter;
    reg valid;
    reg [7:0] data;
    
    localparam STR_INTERVAL = 20_000_000;   // send every 200ms
    reg [31:0] str_counter;
    reg start_send_str;
    
    always @(posedge clk or posedge rst) begin
        // you can't write the next 2 logic into different always blocks, which would lead to multiple driver of start_send_str.
        // char sending control
        if (rst) begin
            data <= 8'b11111111;
            valid <= 0;
            char_counter <= 0;
            current_index <= 0;

        end else if (start_send_str) begin
            if (char_counter >= CHAR_INTERVAL) begin
                char_counter <= 0;
                valid <= 1;

                data <= id_data[current_index];
                if (current_index >= ID_LEN - 1) begin
                    current_index <= 0;
                    start_send_str <= 0;

                end else begin
                    current_index <= current_index + 1;
                end

            end else begin
                char_counter <= char_counter + 1;
                valid <= 0;
            end
            
        end else begin
            data <= 8'b11111111;
            valid <= 0;
            char_counter <= 0;
            current_index <= 0;
        end
        
        // char sending control
        if (rst) begin
            str_counter <= 0;
            start_send_str <= 0;
            
        end else if (str_counter < STR_INTERVAL && !start_send_str) begin
            str_counter <= str_counter + 1;

        end else if (str_counter >= STR_INTERVAL && !start_send_str) begin
            str_counter <= 0;
            start_send_str <= 1;
        end
    end

    uart_send u_uart_send(
        .rst(rst),
        .clk(clk),
        .data(data),
        .valid(valid),
        .dout(uart_tx)
    );
    
    integer i;
    initial begin
        for (i = 0; i < ID_LEN; i = i + 1) begin
            id_data[i] = STUDENT_ID[8*(ID_LEN - i) - 1 -: 8];
        end 
    end

endmodule