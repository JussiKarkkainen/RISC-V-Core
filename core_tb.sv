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




  initial 
    begin
      clk = 0;
      reset = 1;

      $display("loading memory");
      $readmemh("mem.txt", dut.ram.mem)

      @(posedge clk);
        reset = 0;
    end


  always 
    #5 clk <= !clk;

  
  always @(posedge clk)
    begin
      $display("pc: %h, reset: %b, Opcode: %b, funct3: %b, funct7: %b, alu_x: %h, alu_y: %h, 
                csr_we: %b, csr_re: %b, csr_funct3: %b, csr_addr: %h, csr_data_i: %h,
                ram_w_enable: %b, ram_d_addr: %h, \n\n\n\n, reg_w_enable: %b, reg_write_idx: %h",
                dut.pc, dut.reset, dut.opcode, dut.funct3, dut.funct7, dut.alu_x, dut.alu_y, 
                dut.csr_we, dut.csr_re, dut.csr_funct3, dut.csr_addr, dut.csr_data_1,
                dut.ram_w_enable, dut.ram_d_addr, dut.reg_w_enable, dut.reg_write_idx);
    end


endmodule
