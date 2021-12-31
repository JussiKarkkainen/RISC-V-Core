`timescale 1 ns/10 ps
`include "core.v"

module core_tb;



  reg clk;
  reg reset;
  wire [31:0] pc;


  core dut (
    .clk(clk),
    .reset_n(reset),
    .pc(pc)
    );




  initial begin
    string memory;
    clk = 0;
    reset = 1;

    $display("loading memory");
    $readmemh("mem.txt", dut.ram.mem)
  end
endmodule
