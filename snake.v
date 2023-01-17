`default_nettype none

module snake (
    input clk,
    input reset,
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
  reg        led;
  reg  [7:0] divider;
  reg  [6:0] food_x;
  reg  [5:0] food_y;
  reg  [6:0] game_speed;
  reg        prev_vsync;

  wire       ram_out;
  reg        ram_in = 1;
  reg        ram_value = 0;
  play_area play_area (
      .clk(clk),
      .reset(reset),
      .x(pos_x[9:3]),
      .y(pos_y[8:3]),
      .write_enable(ram_in),
      .write_value(ram_value),
      .out(ram_out)
  );

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
      led <= 0;
      prev_vsync <= 0;
      divider <= 0;
      food_x <= 7'd20;
      food_y <= 6'd30;
      game_speed = 7'd60;
      // clear game area:
      ram_in <= 1;
      ram_value <= 0;
    end else begin
      ram_value  <= pos_x[3] ^ pos_y[3];
      prev_vsync <= vsync;
      if (!prev_vsync && vsync) begin
        if (divider == game_speed) begin
          led = !led;
          divider <= 0;
          // poor man's state machine, stop clearing area
          ram_in  <= 0;
        end else begin
          divider <= divider + 1;
        end
      end
    end
  end

  wire [6:0] x_block = pos_x[9:3];
  wire [5:0] y_block = pos_y[8:3];
  wire on_food = x_block == food_x && y_block == food_y;
  wire on_play_edge = pos_x <= 2 || pos_x >= 637 || pos_y <= 2 || pos_y >= 477;
  wire on_snake = ram_out;

  assign led_centre = led;
  assign red = display_on && on_food;
  assign green = display_on && on_food;
  assign blue = display_on && (on_play_edge || on_snake);

endmodule
