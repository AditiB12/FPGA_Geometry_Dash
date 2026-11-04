module pwm_audio (
    input  wire clk,
    input  wire rst,
    input  wire [7:0] audio_sample, // 8-bit audio input
    output reg  pwm_out
);
    reg [7:0] counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            pwm_out <= 1'b0;
        end else begin
            counter <= counter + 1;
            pwm_out <= (counter < audio_sample); // Dynamic duty cycle
        end
    end
endmodule
