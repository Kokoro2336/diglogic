module mux (
    input  wire       en,          // 1位使能
    input  wire       mux_sel,     // 1位选择信号
    input  wire [3:0] input_a,     // 4位输入数据a
    input  wire [3:0] input_b,     // 4位输入数据b
    output reg  [3:0] output_c     // 4位输出数据，驱动LED显示
);
    always @(*) begin
        if (en) begin
            if (mux_sel) begin
                output_c = input_a - input_b; // 选择输入b并做减法
            end
            else begin
                output_c = input_a + input_b; // 选择输入a
            end
        end
        else begin
            output_c = 4'b1111; // 使能信号为0时，输出全为0
        end
    end
endmodule