module uart_send(
    input        clk,        
    input        rst,        
    input        valid,       // �?1表明接下来的8位data有效，只维持�?个时钟周�?
    input [7:0]  data,        // 待发送的8位数�?
    output reg   dout         // 发�?�信�?
);

    localparam IDLE  = 2'b00;   // 空闲态，发�?�高电平
    localparam START = 2'b01;   // 起始态，发�?�起始位
    localparam DATA  = 2'b10;   // 数据态，�?8位数据位发�?�出�?
    localparam STOP  = 2'b11;   // 停止态，发�?�停止位

    reg [1:0] current_state, next_state;
    reg [7:0] data_to_send;     // data cache to be sent

    always @(posedge clk) begin
        if (valid) begin
            data_to_send <= data;
        end
    end

    // State transition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    reg end_start;
    reg end_data;
    reg end_stop;
    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (valid) begin
                    next_state <= START;

                end else begin
                    next_state <= IDLE;
                end
            end

            START: begin
                if (end_start) begin
                    next_state <= DATA;

                end else begin
                    next_state <= START;
                end
            end

            DATA: begin
                if (end_data) begin
                    next_state <= STOP;

                end else begin
                    next_state <= DATA;
                end
            end

            STOP: begin
                if (end_stop) begin
                    next_state <= IDLE;
                    
                end else begin
                    next_state <= STOP;
                end
            end

            default: begin
                next_state <= IDLE;
            end
        endcase
    end

    reg [2:0] bit_count;                // count bits sent in DATA state
    localparam BAUD_RATE = 9600;        // baud is the interval that every bit keeps.
    localparam CLK_FREQ = 100_000_000;  // 100 MHz
    reg [31:0] baud_count;              // count cycles for baud rate

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= 1;          // idle state is high
            baud_count <= 0;
            bit_count <= 0;

        end else begin
            if (baud_count < (CLK_FREQ / BAUD_RATE - 1)) begin
                baud_count <= baud_count + 1;
                end_start <= 0;
                end_data <= 0;
                end_stop <= 0;

            end else begin
                baud_count <= 0;

                case (current_state)
                    IDLE: begin
                        dout <= 1;      // idle state is high
                    end

                    START: begin
                        dout <= 0;  // start bit
                        end_start <= 1;
                    end

                    DATA: begin
                        dout <= data_to_send[bit_count];    // transmit from lower bit
                        if (bit_count == 7) begin
                            bit_count <= 0;
                            end_data <= 1;

                        end else begin
                            bit_count <= bit_count + 1;
                        end
                    end

                    STOP: begin
                        dout <= 1;      // stop bit
                        end_stop <= 1;
                    end

                    default: begin
                        dout <= 1;
                    end
                endcase
            end
        end
    end

endmodule
