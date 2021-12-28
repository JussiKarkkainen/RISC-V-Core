`include "alu.v"
`include "regfile.v"
`include "ram.v"
`include "conditionals.v"
`include "csr.v"

module risc_core (
  input clk,
  input reset_n,
  output reg [31:0] pc
  );


reg [4:0] reg_read_a;
reg [4:0] reg_read_b;
reg [4:0] reg_write_idx;
reg [31:0] reg_data;
reg reg_w_enable;
wire [31:0] reg_a;
wire [31:0] reg_b;

regfile regfile (
  .clock(clk),
  .read_a(reg_read_a),
  .read_b(reg_read_b),
  .write_idx(reg_write_idx),
  .data(reg_data),
  .write_enable(reg_w_enable),
  .a(reg_a),
  .b(reg_b)
  );


reg [3:0] alu_funct3;
reg [6:0] alu_funct7;
reg [31:0] alu_x;
reg [31:0] alu_y;
wire [31:0] alu_out;
wire alu_zero;

alu alu (
  .x(alu_x),
  .y(alu_y),
  .funct3(alu_funct3),
  .funct7(alu_funct7),
  .out(alu_out),
  .zero(alu_zero)
  );


reg [31:0] cond_x;
reg [31:0] cond_y;
reg [2:0] cond_funct3;
wire cond_out;

conditionals cond (
  .x(cond_x),
  .y(cond_y),
  .funct3(cond_funct3),
  .out(cond_out)
  );


reg [31:0] ram_i_addr;
reg [31:0] ram_d_in;
reg ram_w_enable;
wire [31:0] ram_d_out;
wire [31:0] ram_i_data;
reg [31:0] ram_d_addr;

ram ram (
  .clk(clk),
  .i_addr(ram_i_addr),
  .d_in(ram_d_in),
  .w_enable(ram_w_enable),
  .d_out(ram_d_out),
  .i_data(ram_i_data),
  .d_addr(ram_d_addr)
  );


reg [3:0] csr_funct3;
reg [31:0] csr_data_i;
reg [11:0] csr_addr;
reg csr_we = 1'b0;
reg csr_re = 1'b0;
wire [31:0] csr_data_o;

csr csr (
  .i_clk(clk),
  .i_data(csr_data_i),
  .funct3(csr_funct3),
  .csr_addr(csr_addr),
  .csr_we(csr_we),
  .csr_re(csr_re),
  .o_data(csr_data_o)
  );


// Instruction fetch from ram and decode

wire [6:0] opcode = ram_i_data[6:0];
wire [3:0] funct3 = ram_i_data[14:2];
wire [6:0] funct7 = ram_i_data[31:25];
wire [4:0] rs1 = ram_i_data[19:15];
wire [4:0] rs2 = ram_i_data[24:20];
wire imm_i = {{20{ram_i_data[31]}}, ram_i_data[31], ram_i_data[30:25], ram_i_data[24:21], ram_i_data[20]};
wire imm_s = {{20{ram_i_data[31]}}, ram_i_data[31], ram_i_data[30:25], ram_i_data[11:8], ram_i_data[7]};
wire imm_b = {{20{ram_i_data[31]}}, ram_i_data[31], ram_i_data[7], ram_i_data[30:25], ram_i_data[11:8], 1'b0};
wire imm_u = {{12{ram_i_data[31]}}, ram_i_data[31], ram_i_data[30:20], ram_i_data[19:12], 12'b0};
wire imm_j = {{12{ram_i_data[31]}}, ram_i_data[31], ram_i_data[19:12], ram_i_data[20], ram_i_data[30:25], ram_i_data[24:21], 1'b0};
wire csr_address = ram_i_data[31:20];
wire [4:0] rd = ram_i_data[11:7];
wire [31:0] csr_imm_rs1 = {27'b0, ram_i_data[19:5]};


reg new_pc = 1'b0;  // Set to 1 if pc is updated to new address in jump or branch
reg load = 1'b0;    // If 1, load value in to memory later
reg store = 1'b0;   // if 1, store value in to memory later
reg reg_writeback = 1'b0;
reg [31:0] spc;


integer i;
always @(posedge clk)
  begin
    if (reset_n)
      begin
        pc <= 32'h800000;
        reg_w_enable <= 1'b1;
        for (i=0; i<32; i=i+1)
          begin
            reg_write_idx <= i;
            reg_data <= 32'b0;
          end
      end
    else begin

      ram_d_addr <= pc;

      ram_w_enable <= 1'b0;
      reg_w_enable <= 1'b0;
      cond_x <= rs1;
      cond_y <= rs2;
      cond_funct3 <= funct3;
      alu_funct3 <= funct3;
      alu_funct7 <= funct7;
      reg_read_a <= rs1;
      reg_read_b <= rs2;
      spc <= pc;

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
            alu_y <= spc;
            reg_writeback <= 1'b1;
          end

        7'b1101111:                 // JAL
          begin
            alu_x <= imm_j;
            alu_y <= spc;
            new_pc <= 1'b1;
            reg_writeback <= 1'b1;
          end

        7'b1100111:                 // JALR
          begin
            alu_x <= imm_i;
            alu_y <= rs1;
            new_pc <= 1'b1;
            reg_writeback <= 1'b1;
          end
        7'b1100011:                 // BRANCH

          begin
            alu_x <= imm_b;
            alu_y <= spc;
            new_pc <= 1'b1;
            reg_writeback <= 1'b1;
          end
            // alu_x & y compute new_pc, jump only if cond is true.

        7'b0000011:                 // LOAD
          begin
            alu_x <= imm_i;
            alu_y <= rs1;
            load <= 1'b1;
            reg_writeback <= 1'b1;
          end

        7'b0100011:                 // STORE
          begin
            alu_x <= imm_s;
            alu_y <= rs1;
            store <= 1'b1;
          end

        7'b0010011:                 // INT REG-IMM
          begin
            alu_x <= imm_i;
            alu_y <= rs1;
            reg_writeback <= 1'b1;
          end
        7'b0110011:                 // INT REG-REG
          begin
            alu_x <= reg_a;
            alu_y <= reg_b;
            reg_writeback <= 1'b1;
          end

        7'b0001111:                 // FENCE
          begin
          end

        7'b1110011:                 // ECALL/EBREAK/CSR
          begin
            csr_we <= 1'b1;
            csr_we <= 1'b1;
            csr_funct3 <= funct3;
            csr_addr <= csr_address;
            if (funct3 == 3'b101 || 3'b110 || 3'b111)
              csr_data_i <= csr_imm_rs1;
            else
              csr_data_i <= reg_read_a;

          end

      endcase

  // Memory Access
      if (load == 1'b1)
        ram_d_addr <= alu_out;

      if (store == 1'b1)
        begin
          ram_w_enable <= 1'b1;
          ram_d_addr <= alu_out;
        end

  // Register writeback
      if (reg_writeback == 1'b1)
        begin
          reg_w_enable <= 1'b1;
          reg_write_idx <= rd;
          if (opcode == 7'b0000011) begin
            case (funct3)
              000:
                reg_data <= {{24{ram_d_out[8]}}, ram_d_out[7:0]}; // Load sign extended 8 bits 
              
              001:
                reg_data <= {{16{ram_d_out[16]}}, ram_d_out[15:0]}; // Load sign extended 16 bits

              010:
                reg_data <= ram_d_out; // Load 32 bits

              100:
                reg_data <= {24'b0, ram_d_out[7:0]}; // Load zero extended 8 bits

              101:
                reg_data <= {16'b0, ram_d_out[15:0]}; // Load zero extended 16 bits
            endcase
          end
          else if (opcode == 7'b1110011)
            reg_data <= csr_data_o;
          else
            reg_data <= alu_out;    
        end

      
      if (new_pc == 1'b1)
        begin
          if (opcode == 7'b1100011)
            begin
              if (cond_out == 1'b1)
                pc <= alu_out;
            end
          else
            pc <= alu_out;
        end
      else
        pc <= spc + 4;
      end
    end

endmodule

