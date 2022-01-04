module csr (
  input clk,
  input rst,
  input [31:0] i_data,
  input [3:0] funct3, 
  input [11:0] csr_addr,
  input csr_we,
  input csr_re,
  output reg [31:0] o_data
  );

// Machine register addresses
`define CSR_MTVEC   12'h305
`define CSR_MEDELEG 12'h302
`define CSR_MIDELEG 12'h303
`define CSR_MIE     12'h304
`define CSR_MIP     12'h344
`define CSR_MEPC    12'h341
`define CSR_MCAUSE  12'h342
`define CSR_MTVAL   12'h343
`define CSR_MCYCLE  12'hB00

// Supervisor register addresses
`define CSR_SEPC     12'h141
`define CSR_SCAUSE   12'h142
`define CSR_STVAL    12'h143
`define CSR_SATP     12'h180
`define CSR_SSCRATCH 12'h140

// Machine CSR
reg [31:0] mtvec;
reg [31:0] medeleg;
reg [31:0] mideleg;
reg [31:0] mip;
reg [31:0] mie;
reg [31:0] mtime;
reg [31:0] mtimecmp;
reg [31:0] mepc;
reg [31:0] mcause;
reg [31:0] mtval;
reg [31:0] mcycle;


// Supervisor CSR
reg [31:0] sepc;
reg [31:0] stvec;
reg [31:0] scause;
reg [31:0] stval;
reg [31:0] satp;
reg [31.0] sscratch;


// All CSR-instructions have read
always @(posedge clk)
  begin
    if (csr_re)
      begin
        case (csr_addr)   // Read correct register

          `CSR_MTVEC: o_data = mtvec;

          `CSR_MEDELEG: o_data = medeleg;

          `CSR_MIDELEG: o_data = mideleg;

          `CSR_MIP: o_data = mip;

          `CSR_MIE: o_data = mie;

          `CSR_MEPC: o_data = mepc;

          `CSR_MCAUSE: o_data = mcause;

          `CSR_MTVAL: o_data = mtval;

          `CSR_MCYCLE: o_data = mcycle;
          
          `CSR_SEPC: o_data = sepc;

          `CSR_SCAUSE: o_data = scause;

          `CSR_STVAL: o_data = stval;

          `CSR_SATP: o_data = satp;

          `CSR_SSCRATCH: o_data = sscratch;

        endcase
      end

// Write to CSR-register
    
    if (csr_we && (funct3 == 3'b001 || funct3 == 3'b101))    // CSRRW/CSRRWI
      begin
        case (csr_addr)  

          `CSR_MTVEC: mtvec = i_data;

          `CSR_MEDELEG: medeleg = i_data;

          `CSR_MIDELEG: mideleg = i_data;

          `CSR_MIP: mip = i_data;

          `CSR_MIE: mie = i_data;

          `CSR_MEPC: mepc = i_data;

          `CSR_MCAUSE: mcause = i_data;

          `CSR_MTVAL: mtval = i_data;

          `CSR_MCYCLE: mcycle = i_data;
          
          `CSR_SEPC: sepc = i_data;

          `CSR_SCAUSE: scause = i_data;

          `CSR_STVAL: stval = i_data;

          `CSR_SATP: satp = i_data;

          `CSR_SSCRATCH: sscratch = i_data;

        endcase
      end
    else if (csr_we && (funct3 == 3'b010 || funct3 == 3'b110))   // CSRRS/CSRRSI
      begin
        case (csr_addr)
          
          `CSR_MTVEC: mtvec = (i_data | mtvec);
          
          `CSR_MEDELEG: medeleg = (i_data | medeleg);

          `CSR_MIDELEG: mideleg = (i_data | mideleg);

          `CSR_MIP: mip = (i_data | mip);

          `CSR_MIE: mie = (i_data | mie);

          `CSR_MEPC: mepc = (i_data | mepc);

          `CSR_MCAUSE: mcause = (i_data | mcause);

          `CSR_MTVAL: mtval = (i_data | mtval);

          `CSR_MCYCLE: mcycle = (i_data | mcycle);
          
          `CSR_SEPC: sepc = (i_data | sepc);

          `CSR_SCAUSE: scause = (i_data | scause);

          `CSR_STVAL: stval = (i_data | stval); 

          `CSR_SATP: satp = (i_data | satp);

          `CSR_SSCRATCH: sscratch = (i_data | sscratch);

        endcase
      end
    else if (csr_we && (funct3 == 3'b011 || funct3 == 3'b111))   // CSRRC/CSRRCI
      begin
        case (csr_addr)
          
          `CSR_MTVEC: mtvec = ((~i_data) & mtvec);

          `CSR_MEDELEG: medeleg = ((~i_data) & medeleg);

          `CSR_MIDELEG: mideleg = ((~i_data) & mideleg);

          `CSR_MIP: mip = ((~i_data) & mip);

          `CSR_MIE: mie = ((~i_data) & mie);

          `CSR_MEPC: mepc = ((~i_data) & mepc);

          `CSR_MCAUSE: mcause = ((~i_data & mcause));

          `CSR_MTVAL: mtval = ((~i_data) & mtval);

          `CSR_MCYCLE: mcycle = ((~i_data) & mcycle);
          
          `CSR_SEPC: sepc = ((~i_data) & sepc);

          `CSR_SCAUSE: scause = ((~i_data) & scause);

          `CSR_STVAL: stval = ((~i_data) & stval);

          `CSR_SATP: satp = ((~i_data) & satp);

          `CSR_SSCRATCH: sscratch = ((~i_data) & sscratch);

        endcase
      end
  end
endmodule


