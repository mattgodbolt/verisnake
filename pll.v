/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * tweaked by hand per: https://mjoldfield.com/atelier/2018/02/ice40-blinky-icestick.html
 *
 * Given input frequency:        12.000 MHz
 * Requested output frequency:   25.175 MHz
 * Achieved output frequency:    25.125 MHz
 */

module pll (
    input  clock_in,
    output clock_out,
    output locked
);
  wire internal_clock;

  SB_PLL40_CORE #(
      .FEEDBACK_PATH("SIMPLE"),
      .DIVR(4'b0000),  // DIVR = 0
      .DIVF(7'b1000010),  // DIVF = 66
      .DIVQ(3'b101),  // DIVQ = 5
      .FILTER_RANGE(3'b001)  // FILTER_RANGE = 1
  ) uut (
      .LOCK(locked),
      .RESETB(1'b1),
      .BYPASS(1'b0),
      .REFERENCECLK(clock_in),
      .PLLOUTCORE(internal_clock)
  );

  // magic for the icestorm to use its global buffer
  SB_GB global_buffer (
      .USER_SIGNAL_TO_GLOBAL_BUFFER(internal_clock),
      .GLOBAL_BUFFER_OUTPUT        (clock_out)
  );
endmodule
