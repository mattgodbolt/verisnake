`default_nettype none
`timescale 1ns/1ns

module vga (
    input clk,
    input reset,
    output display_on,
    output reg hsync,
    output reg vsync,
    output reg [9:0] pos_x,
    output reg [9:0] pos_y
);

  // Timings from http://tinyvga.com/vga-timing/640x480@60Hz
  // Horizontal timing
  localparam H_VISIBLE = 640;
  localparam H_FRONT_PORCH = 16;
  localparam H_SYNC_PULSE = 96;
  localparam H_BACK_PORCH = 48;
  localparam H_WHOLE_LINE = 800;

  // Vertical timing
  localparam V_VISIBLE = 480;
  localparam V_FRONT_PORCH = 10;
  localparam V_SYNC_PULSE = 2;
  localparam V_BACK_PORCH = 33;
  localparam V_WHOLE_FRAME = 525;

  always @(posedge clk) begin
    if (reset) begin
      pos_x <= 0;
      pos_y <= 0;
      hsync <= 0;
      vsync <= 0;
    end else begin
      hsync <= (pos_x >= (H_VISIBLE + H_FRONT_PORCH - 1) && pos_x < (H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE - 1));
      vsync <= (pos_y >= (V_VISIBLE + V_FRONT_PORCH - 1) && pos_y < (V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE - 1));
      if (pos_x < H_WHOLE_LINE - 1) begin
        pos_x <= pos_x + 1;
      end else begin
        pos_x <= 0;
        if (pos_y < V_WHOLE_FRAME - 1) begin
          pos_y <= pos_y + 1;
        end else begin
          pos_y <= 0;
        end
      end
    end
  end

  assign display_on = !reset && pos_x < H_VISIBLE && pos_y < V_VISIBLE;
endmodule
