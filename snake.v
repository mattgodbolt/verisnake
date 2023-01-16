`default_nettype none

module snake (
    input  clk,
    input  reset,
    output wire led_centre,
    output wire hsync,
    output wire vsync,
    output wire red,
    output wire green,
    output wire blue
);

  wire       display_on;
  wire [9:0] pos_x;
  wire [9:0] pos_y;
  reg        led = 0;
  reg  [7:0] divider = 0;

  reg  [6:0] food_x;
  reg  [5:0] food_y;
  reg  [6:0] game_speed;

  vga vga (
      .clk(clk),
      .reset(reset),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(display_on),
      .pos_x(pos_x),
      .pos_y(pos_y)
  );

  always @(posedge clk) begin
    if (reset) begin
      food_x <= 7'd20;
      food_y <= 6'd30;
      game_speed = 6'd60;
    end else begin
    end
  end

  always @(posedge (clk && vsync)) begin
    // todo this flashes much faster than I would expect so I reckon it's not working the way I'd expect
    if (divider == game_speed) begin
      led = !led;
      divider <= 0;
    end else begin
      divider <= divider + 1;
    end
  end

  wire [6:0] x_block = pos_x[9:3];
  wire [5:0] y_block = pos_y[8:3];
  wire on_food = x_block == food_x && y_block == food_y;

  assign led_centre = led;
  assign red = display_on && on_food;
  assign green = display_on && on_food;
  assign blue = display_on && pos_y < 250;

endmodule
