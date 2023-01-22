`default_nettype none

module play_area (
    input wire clk,
    input wire reset,
    input wire [6:0] x,  // or whatever
    input wire [5:0] y,  // or whatever
    input wire write_enable,
    input wire [2:0] write_value,
    output reg [2:0] out
);
  reg [2:0] RAM[(1<<11)-1:0];
  always @(posedge clk) begin
    if (reset) begin
      out <= 0;
    end else begin
      if (write_enable) begin
        RAM[{y, x}] <= write_value;
      end
      out <= RAM[{y, x}];
    end
  end

endmodule
