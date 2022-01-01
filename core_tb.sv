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
      $readmemh("mem.txt", dut.ram.mem);
      $display("first mem: %h", dut.ram.mem[1]);
      $display("memory loaded");
      reset = 0;
    end


  always 
    #50 clk <= !clk;
  

  always @(posedge clk) begin
    $display("pc: %h\n", 
              "reset: %b\n", 
              "Opcode: %b\n", 
              "funct3: %b\n", 
              "funct7: %b\n", 
              "alu_x: %h\n",
              "alu_y: %h\n", 
              "csr_we: %b\n", 
              "csr_re: %b\n", 
              "csr_funct3: %b\n", 
              "csr_addr: %h\n", 
              "csr_data_i: %h\n",
              "ram_w_enable: %b\n", 
              "ram_d_addr: %h\n", 
              "reg_w_enable: %b\n", 
              "reg_write_idx: %h\n",
              dut.pc, 
              dut.reset_n, 
              dut.opcode, 
              dut.funct3, 
              dut.funct7, 
              dut.alu_x, 
              dut.alu_y, 
              dut.csr_we, 
              dut.csr_re, 
              dut.csr_funct3, 
              dut.csr_addr, 
              dut.csr_data_i,
              dut.ram_w_enable, 
              dut.ram_d_addr, 
              dut.reg_w_enable, 
              dut.reg_write_idx);
   $finish; 
  end

  integer i;
  initial begin
    for (i=0; i<32; i=i+1) begin
      $display("%d:  %h", i, dut.regfile.regs[i]);
    end
    
    $finish;
  end

endmodule














    /*
    $display("x1:  %h\n", 
             "x2:  %h\n", 
             "x3:  %h\n", 
             "x4:  %h\n",
             "x5:  %h\n", 
             "x6:  %h\n", 
             "x7:  %h\n", 
             "x8:  %h\n", 
             "x9:  %h\n", 
             "x10:  %h\n", 
             "x11:  %h\n", 
             "x12:  %h\n", 
             "x13:  %h\n", 
             "x14:  %h\n", 
             "x15:  %h\n", 
             "x16:  %h\n", 
             "x17:  %h\n", 
             "x18:  %h\n", 
             "x19:  %h\n",
             "x20:  %h\n", 
             "x21:  %h\n", 
             "x22:  %h\n", 
             "x23:  %h\n", 
             "x24:  %h\n", 
             "x25:  %h\n", 
             "x26:  %h\n",
             "x28:  %h\n", 
             "x31:  %h\n", 
             "x32:  %h\n",
             dut.regfile.regs[0],
             dut.regfile.regs[1],
             dut.regfile.regs[2],
             dut.regfile.regs[3],
             dut.regfile.regs[4],
             dut.regfile.regs[5],
             dut.regfile.regs[6],
             dut.regfile.regs[7],
             dut.regfile.regs[8],
             dut.regfile.regs[9],
             dut.regfile.regs[10],
             dut.regfile.regs[11],
             dut.regfile.regs[12],
             dut.regfile.regs[13],
             dut.regfile.regs[14],
             dut.regfile.regs[15],
             dut.regfile.regs[16],
             dut.regfile.regs[17],
             dut.regfile.regs[18],
             dut.regfile.regs[19],
             dut.regfile.regs[20],
             dut.regfile.regs[21],
             dut.regfile.regs[22],
             dut.regfile.regs[23],
             dut.regfile.regs[24],
             dut.regfile.regs[25],
             dut.regfile.regs[26],
             dut.regfile.regs[27],
             dut.regfile.regs[28],
             dut.regfile.regs[29],
             dut.regfile.regs[30],
             dut.regfile.regs[31]
             );
             */
