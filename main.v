`default_nettype none

module top_ice (
    input  ICE_12MHZ_CLOCK,
    output LED_CENTRE,
    output HSYNC,
    output VSYNC,
    output RED,
    output GREEN,
    output BLUE
);
  reg  running = 0;
  wire reset = !running;

  // PLL to get 25MHz clock.
  wire clk;
  wire locked;
  pll pll25Mhz (
      .clock_in(ICE_12MHZ_CLOCK),
      .clock_out(clk),
      .locked(locked)
  );

  // Synthesize a reset.
  always @(posedge clk) begin
    running <= 1;
  end

  snake snake (
      .clk(clk),
      .reset(reset),
      .hsync(HSYNC),
      .vsync(VSYNC),
      .red(RED),
      .green(GREEN),
      .blue(BLUE),
      .led_centre(LED_CENTRE)
  );

endmodule
