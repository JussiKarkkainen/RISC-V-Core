`include "core.v"

module core_tb;

  reg clk;
  reg reset;
  reg [7:0] cnt;
  wire [31:0] pc;
  
  core dut (
    .clk (clk),
    .reset (reset),
    .pc(pc)
  );

  initial begin
    clk = 0;
    cnt = 0;
    reset = 0;

    $readmemh("test-cache/rv32ui-p-add", dut.ram.mem);
    $display("starting test", cnt);
    @(posedge clk);
    reset = 1;
  end

  always
    #5 clk = !clk;

  always @(posedge clk) begin
    cnt <= cnt + 1;
    reset <= 0;
  end



  always @(posedge clk) begin
    if (dut.ctr[6] == 1'b1) begin
   /* 
    $display("ins %h pc %h opcode %b funct3 %b funct7 %b ram_w_enable %b reg_w_enable %b rs1 %b rs2 %b imm_i %h imm_s %h imm_b %h imm_u %h imm_j %h rd %b alu_x %b alu_y %b", 
      c.ram_i_data, c.pc, c.opcode, c.alu_funct3, c.alu_funct7, c.ram_w_enable, c.reg_w_enable, c.reg_read_a, c.reg_read_b, c.imm_i, c.imm_s, c.imm_b, c.imm_u, c.imm_j, c.rd, c.alu_x, c.alu_y);
      */
      $display("ram_i_data:%h pc:%h opcode:%b funct3:%b alu_funct7 %b alu_imm %b alu_x:%h alu_y:%h alu_out:%h ram_d_addr:%h ram_d_data:%h con_pc%b",
        dut.ram_i_data, dut.pc, dut.opcode, dut.alu_funct3, dut.alu_funct7, dut.alu_imm, dut.alu_x, dut.alu_y, dut.alu_out, dut.ram_d_addr, dut.ram_d_out, dut.cond_pc);
    
    end
  end
  
  initial begin
    #7500
    $display("Finished ", cnt);
    $finish;
  end
endmodule
