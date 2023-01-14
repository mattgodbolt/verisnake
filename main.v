`default_nettype none

module top(
   input clk,
   output LED_N,
   output LED_E,
   output LED_S,
   output LED_W,
   output LED_CENTRE);
   reg running = 0;
   reg [23:0] divider;
   reg [3:0] leds;
   
   always @(posedge clk) begin
      if (running) begin
           if (divider == 1000000) 
             begin
                divider <= 0;
                leds <= {leds[2:0], leds[3]};
             end
           else begin
             divider <= divider + 1;
           end
      end else begin
         running <= 1;
         leds <= 4'b0001;
         divider <= 0;
      end
   end
   
   assign LED_N = leds[0];
   assign LED_E = leds[1];
   assign LED_S = leds[2];
   assign LED_W = leds[3];
   assign LED_CENTRE = 1;
endmodule // top
