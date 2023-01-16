`default_nettype none

module snake (
    input  clk,
    input  reset,
    output led_centre,
    output hsync,
    output vsync,
    output red,
    output green,
    output blue
);

  wire       display_on;
  wire [9:0] pos_x;
  wire [9:0] pos_y;
  reg  [9:0] highlight_x = 0;
  reg  [9:0] highlight_y = 0;
  reg        led = 0;
  reg  [7:0] divider = 0;

  vga vga (
      .clk(clk),
      .reset(reset),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(display_on),
      .pos_x(pos_x),
      .pos_y(pos_y)
  );

  always @(posedge vsync) begin
    highlight_x <= highlight_x + 1;
    if (highlight_x == 640) begin
      highlight_x <= 0;
      highlight_y <= highlight_y + 1;
    end
    if (divider == 30) begin
      led = !led;
      divider <= 0;
    end else begin
      divider <= divider + 1;
    end
  end

  assign led_centre = led;
  assign red = display_on && pos_x == highlight_x;
  assign green = display_on && pos_y == highlight_y;
  assign blue = display_on && pos_y < 250;

endmodule
