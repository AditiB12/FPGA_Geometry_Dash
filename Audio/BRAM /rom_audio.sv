module rom_audio #(
  parameter ADDR_WIDTH = 19,
  parameter DATA_WIDTH = 8

)(
  input logic clk,
  input logic rst,
  input logic tick, // Advance on 44.1 kHz tick
  output logic [DATA_WIDTH-1:0] sample
);

  localparam ROM_DEPTH = 1 << ADDR_WIDTH;

  logic [ADDR_WIDTH-1:0] addr;

  // Output from BRAM
  logic [DATA_WIDTH-1:0] bram_out;

  // Instantiate the generated BRAM IP (read-only mode)
  blk_mem_gen_0 rom_ip (
    .clka(clk),
    .addra(addr),
    .douta(bram_out)
  );

  // Address generator
  always_ff @(posedge clk) begin
    if (rst)
      addr <= 0;
    else if (tick)
      addr <= (addr == ROM_DEPTH - 1) ? 0 : addr + 1;
  end

  assign sample = bram_out;

endmodule
