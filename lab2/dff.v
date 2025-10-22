module dff (
    input      clk,
    input      clr,
    input      en ,
    input      d  ,
    output reg q
);
    always @(posedge clk or posedge clr) begin
        if (clr) begin
            q <= 0;
        end
        else if (en) begin
            q <= d;
        end
    end
endmodule
