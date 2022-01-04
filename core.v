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


reg [2:0] alu_funct3;
reg [31:0] alu_x;
reg [31:0] alu_y;
reg alu_imm = 1'b0;
wire [31:0] alu_out;

alu alu (
  .x(alu_x),
  .y(alu_y),
  .funct3(alu_funct3),
  .imm(alu_imm),
  .out(alu_out)
  );


reg [31:0] cond_x;
reg [31:0] cond_y;
reg [2:0] cond_funct3;
wire cond_out;

conditionals cond (
  .x(cond_x),
  .y(cond_y),
  .funct3(cond_funct3),
  .out(cond_pc)         // output determines if pc is alu_out or pc + 4
  );


reg [13:0] ram_i_addr;
reg [31:0] ram_d_in;
reg ram_w_enable = 1'b0;
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
reg csr_we = 1'b0;
reg csr_re = 1'b0;
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
wire [4:0] rd = ram_i_data[11:7];
wire [31:0] csr_imm_rs1 = {27'b0, ram_i_data[19:5]};


reg new_pc = 1'b0;  // Set to 1 if pc is updated to new address in jump, branch uses cond_pc
reg store = 1'b0;   // if 1, store value in to memory later
reg reg_writeback = 1'b0;
reg [31:0] spc;
reg [6:0] step;


integer i;
always @(posedge clk)
  begin
    step <= step << 1;
    if (reset == 1'b1)
      begin
        pc <= 32'h80000000;       
        reg_w_enable <= 1'b1;
        step <= 'b10;
        csr_reset <= 1'b1;
        for (i=0; i<32; i=i+1)
          begin
            reg_write_idx <= i;
            reg_data <= 32'b0;
          end
      end
    ram_i_addr <= pc[13:0];
    spc <= pc;
    cond_funct3 <= funct3;
    alu_funct3 <= funct3;
    reg_read_a <= rs1;
    reg_read_b <= rs2;
    cond_x <= reg_a;    // rs1 
    cond_y <= reg_a;    // rs2
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
          alu_y <= reg_a;
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
          alu_y <= reg_a;
          reg_writeback <= 1'b1;
        end

      7'b0100011:                 // STORE
        begin
          alu_x <= imm_s;
          alu_y <= reg_a;
          store <= 1'b1;
        end

      7'b0010011:                 // INT REG-IMM
        begin
          alu_x <= imm_i;
          alu_y <= reg_a;
          alu_imm <= 1'b1;
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
          csr_re <= 1'b1;
          csr_funct3 <= funct3;
          csr_addr <= csr_address;

          if (funct3 == 3'b101 || 3'b110 || 3'b111)
            csr_data_i <= csr_imm_rs1;
          else
            csr_data_i <= reg_read_a;
        end

    endcase

// Memory Access
    if (step[5] == 1'b1) begin
      //if (load == 1'b1)
      ram_w_enable <= 1'b1;
      ram_d_addr <= alu_out[13:0];
      
      if (store == 1'b1)
        begin
          ram_d_in <= rs2;
          ram_d_size <= funct3;
        end
    end

  // Register writeback
  
    if (step[6] == 1'b1) begin
      if (reg_writeback == 1'b1 && rd != 5'b00000)
        begin
          reg_w_enable <= 1'b1;
          reg_write_idx <= rd;
          if (opcode == 7'b0000011) 
            begin
              case (funct3)
                000:
                  reg_data <= {{24{ram_d_out[7]}}, ram_d_out[7:0]}; // Load sign extended 8 bits 
                
                001:
                  reg_data <= {{16{ram_d_out[15]}}, ram_d_out[15:0]}; // Load sign extended 16 bits

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
      if (cond_pc == 1'b1 || new_pc == 1'b1)
        pc <= alu_out;
      else
        pc <= spc + 4;

      step <= 'b1;
    end


  end
  
endmodule

