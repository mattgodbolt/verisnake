`default_nettype none
// stupid formatter keeps combining these lines
`timescale 1ns / 1ns

module play_area #(
    parameter WIDTH = 80,
    parameter HEIGHT = 60,
    parameter BIT_DEPTH = 3
) (
    input wire clk,
    input wire [$clog2(WIDTH)-1:0] x,
    input wire [$clog2(HEIGHT)-1:0] y,
    input wire write_enable,
    input wire [BIT_DEPTH-1:0] write_value,
    output reg [BIT_DEPTH-1:0] out
);
  reg [BIT_DEPTH-1:0] RAM[$clog2(WIDTH*HEIGHT)-1:0];
  wire [$clog2(WIDTH*HEIGHT)-1:0] address = x + WIDTH * y;

  always @(posedge clk) begin
    // TODO, this is a bit overkill. we could just Don't Do That.
    if (x < WIDTH && y < HEIGHT) begin
      if (write_enable) begin
        RAM[address] <= write_value;
        out <= write_value;
      end else begin
        out <= RAM[address];
      end
    end else begin
      out <= 0;
    end
  end

endmodule
