module dump ();
  initial begin
    $dumpfile("out/vga.vcd");
    $dumpvars(0, vga);
    #1;
  end
endmodule
