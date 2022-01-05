`include "alu.v"
`include "regfile.v"
`include "ram.v"
`include "conditionals.v"
`include "csr.v"

module core (
  input clk,
  input reset,
  output reg [31:0] pc
  );

/*
reg [4:0] reg_read_a;
reg [4:0] reg_read_b;
reg [4:0] reg_write_idx;
reg [31:0] reg_data;
reg reg_w_enable = 1'b0;
wire [31:0] reg_a;
wire [31:0] reg_b;

regfile regfile (
  .clk(clk),
  .read_a(reg_read_a),
  .read_b(reg_read_b),
  .write_idx(reg_write_idx),
  .data(reg_data),
  .write_enable(reg_w_enable),
  .a(reg_a),
  .b(reg_b)
  );

*/
reg [2:0] alu_funct3;
reg [6:0] alu_funct7;
reg [31:0] alu_x;
reg [31:0] alu_y;
reg alu_imm;
wire [31:0] alu_out;

alu alu (
  .clk(clk),
  .x(alu_x),
  .y(alu_y),
  .funct3(alu_funct3),
  .funct7(alu_funct7),
  .imm(alu_imm),
  .out(alu_out)
  );


reg [31:0] cond_x;
reg [31:0] cond_y;
reg [2:0] cond_funct3;
wire cond_pc;

conditionals cond (
  .clk(clk),
  .x(cond_x),
  .y(cond_y),
  .funct3(cond_funct3),
  .out(cond_pc)         // output determines if pc is alu_out or pc + 4
  );


reg [13:0] ram_i_addr;
reg [31:0] ram_d_in;
reg ram_w_enable;
reg [2:0] ram_d_size;
reg [13:0] ram_d_addr;
wire [31:0] ram_d_out;
wire [31:0] ram_i_data;

ram ram (
  .clk(clk),
  .w_enable(ram_w_enable),
  .i_addr(ram_i_addr),
  .i_data(ram_i_data),
  .d_size(ram_d_size),
  .d_in(ram_d_in),
  .d_out_data(ram_d_out),
  .d_addr(ram_d_addr)
  );


reg [3:0] csr_funct3;
reg [31:0] csr_data_i;
reg [11:0] csr_addr;
reg csr_we;
reg csr_re;
reg csr_reset;
wire [31:0] csr_data_o;

csr csr (
  .clk(clk),
  .rst(csr_reset),
  .i_data(csr_data_i),
  .funct3(csr_funct3),
  .csr_addr(csr_addr),
  .csr_we(csr_we),
  .csr_re(csr_re),
  .o_data(csr_data_o)
  );


// Instruction decode
wire [6:0] opcode = ram_i_data[6:0];
wire [2:0] funct3 = ram_i_data[14:12];
wire [6:0] funct7 = ram_i_data[31:25];
wire [4:0] rs1 = ram_i_data[19:15];
wire [4:0] rs2 = ram_i_data[24:20];
wire [31:0] imm_i = {{20{ram_i_data[31]}}, ram_i_data[31], ram_i_data[30:25], ram_i_data[24:21], ram_i_data[20]};
wire [31:0] imm_s = {{20{ram_i_data[31]}}, ram_i_data[31], ram_i_data[30:25], ram_i_data[11:8], ram_i_data[7]};
wire [31:0] imm_b = {{19{ram_i_data[31]}}, ram_i_data[31], ram_i_data[7], ram_i_data[30:25], ram_i_data[11:8], 1'b0};
wire [31:0] imm_u = {{12{ram_i_data[31]}}, ram_i_data[31], ram_i_data[30:20], ram_i_data[19:12], 12'b0};
wire [31:0] imm_j = {{11{ram_i_data[31]}}, ram_i_data[31], ram_i_data[19:12], ram_i_data[20], ram_i_data[30:25], ram_i_data[24:21], 1'b0};


wire [6:0] csr_address = ram_i_data[31:20];
wire [31:0] csr_imm_rs1 = {27'b0, ram_i_data[19:5]};


reg new_pc;  // Set to 1 if pc is updated to new address in jump, branch uses cond_pc
reg store;   // if 1, store value in to memory later
reg reg_writeback;
reg [31:0] spc;
reg [6:0] ctr;

reg [31:0] regs[0:31];
reg [31:0] vs1;
reg [31:0] vs2;
reg [2:0] cycle_funct3;
reg [4:0] rd;


integer i;
always @(posedge clk)
  begin
    ctr <= ctr << 1;
    if (reset == 1'b1)
      begin
        pc <= 32'h80000000;       
        //reg_w_enable <= 1'b1;
        ctr <= 'b10;
        csr_reset <= 1'b1;
        for (i=0; i<32; i=i+1)
          begin
            regs[i] <= 0;
            //reg_write_idx <= i;
            //reg_data <= 32'b0;
          end
      end
    new_pc <= 1'b0;
    store <= 1'b0;
    reg_writeback <= 1'b0;
    //reg_read_a <= rs1;
    //reg_read_b <= rs2;
    ram_i_addr <= pc[13:0];
    spc <= pc;
    cond_funct3 <= funct3;
    alu_funct3 <= funct3;
    alu_funct7 <= funct7;
    alu_imm <= 1'b0;
    //cond_x <= reg_a;    // rs1 
    //cond_y <= reg_a;    // rs2
    vs1 = regs[rs1];
    vs2 <= regs[rs2];
    cycle_funct3 <= funct3;
    rd <= ram_i_data[11:7];
// Execute

    case (opcode)
                  
      7'b0110111:                 // LUI
        begin   
          alu_x <= imm_u;         
          alu_y <= 32'b0;
          reg_writeback <= 1'b1;
        end

      7'b0010111:                 // AUIPC
        begin
          alu_x <= imm_u;
          alu_y <= pc;
          reg_writeback <= 1'b1;
        end

      7'b1101111:                 // JAL
        begin
          alu_x <= imm_j;
          alu_y <= pc;
          new_pc <= 1'b1;
          reg_writeback <= 1'b1;
        end

      7'b1100111:                 // JALR
        begin
          alu_x <= imm_i;
          alu_y <= regs[rs1];
          new_pc <= 1'b1;
          reg_writeback <= 1'b1;
        end
      7'b1100011:                 // BRANCH

        begin
          alu_x <= imm_b;
          alu_y <= pc;
          reg_writeback <= 1'b1;
        end

      7'b0000011:                 // LOAD
        begin
          alu_x <= imm_i;
          alu_y <= regs[rs1];
          reg_writeback <= 1'b1;
        end

      7'b0100011:                 // STORE
        begin
          alu_x <= imm_s;
          alu_y <= regs[rs1];
          store <= 1'b1;
        end

      7'b0010011:                 // INT REG-IMM
        begin
          alu_x <= imm_i;
          alu_y <= regs[rs1];
          alu_imm <= 1'b1;
          reg_writeback <= 1'b1;
        end
      
      7'b0110011:                 // INT REG-REG
        begin
          alu_x <= regs[rs1];
          alu_y <= regs[rs1];
          reg_writeback <= 1'b1;
        end

      7'b0001111:                 // FENCE
        begin
        end

      7'b1110011:                 // ECALL/EBREAK/CSR
        begin
          csr_we <= 1'b1;
          csr_re <= 1'b1;
          csr_funct3 <= funct3;
          csr_addr <= csr_address;

          if (funct3 == 3'b101 || 3'b110 || 3'b111)
            csr_data_i <= csr_imm_rs1;
          else
            csr_data_i <= regs[rs1];
        end

    endcase

// Memory Access
    if (ctr[5] == 1'b1) begin
      //if (load == 1'b1)
      ram_w_enable <= 1'b1;
      ram_d_addr <= alu_out[13:0];
      
      if (store == 1'b1)
        begin
          ram_d_in <= regs[rs2];
          ram_d_size <= funct3;
        end
    end

  // Register writeback
  
    if (ctr[6] == 1'b1) begin
      if (reg_writeback == 1'b1 && rd != 5'b0)
        begin
          //reg_w_enable <= 1'b1;
          //reg_write_idx <= rd;
          if (opcode == 7'b0000011) 
            begin
              case (cycle_funct3)   //use reg_data instead of regs[rd]
                000:
                  regs[rd] <= {{24{ram_d_out[7]}}, ram_d_out[7:0]}; // Load sign extended 8 bits 
                
                001:
                  regs[rd] <= {{16{ram_d_out[15]}}, ram_d_out[15:0]}; // Load sign extended 16 bits

                010:
                  regs[rd] <= ram_d_out; // Load 32 bits

                100:
                  regs[rd] <= {24'b0, ram_d_out[7:0]}; // Load zero extended 8 bits

                101:
                  regs[rd] <= {16'b0, ram_d_out[15:0]}; // Load zero extended 16 bits
              endcase
            end
          else if (opcode == 7'b1110011 && rd != 5'b0)
            regs[rd] <= csr_data_o;
          else
            regs[rd] <= alu_out;  
        end
      if (cond_pc == 1'b1 || new_pc == 1'b1)
        pc <= alu_out;
      else
        pc <= spc + 4;

      ctr <= 'b1;
    end


  end
  
endmodule

