`default_nettype none

module top (
    input  clk,
    output HSYNC,
    output VSYNC,
    output LED_CENTRE,
    output RED,
    output GREEN,
    output BLUE
);
  reg         running = 0;
  reg  [24:0] divider;
  reg         led = 0;

  // PLL to get 25MHz clock
  wire        sysclk;
  wire        locked;
  pll pll25Mhz (
      .clock_in(clk),
      .clock_out(sysclk),
      .locked(locked)
  );

  wire display_on;
  wire [9:0] pos_x;
  wire [9:0] pos_y;

  vga vga (
      .clk(sysclk),
      .reset(!running),
      .hsync(HSYNC),
      .vsync(VSYNC),
      .display_on(display_on),
      .pos_x(pos_x),
      .pos_y(pos_y)
  );

  always @(posedge sysclk) begin
    if (running) begin
      if (divider == 25_000_000) begin
        divider <= 0;
        led = !led;
      end else begin
        divider <= divider + 1;
      end
    end else begin
      running <= 1;
      divider <= 0;
    end
  end

  assign LED_CENTRE = led;
  assign RED = display_on && pos_x < 120;
  assign GREEN = display_on && pos_x < 200;
  assign BLUE = display_on && pos_y < 250;
endmodule
