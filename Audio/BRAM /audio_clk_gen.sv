
module audio_clk_gen (
    input clk,
    input rst,
    output logic tick
);
    parameter DIV = 2268; // 100 MHz / 44.1 kHz ? 2267.573

    logic [15:0] count;

    always @(posedge clk) begin
        if (rst)
            count <= 0;
        else if (count == DIV - 1)
            count <= 0;
        else
            count <= count + 1;
    end

    always @(posedge clk) begin
        if (rst)
            tick <= 0;
        else
            tick <= (count == DIV - 2); // Tick one cycle before count resets
    end
endmodule
