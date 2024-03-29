module alu
  (input clk,
  input [31:0] x,
  input [31:0] y,
  input [2:0] funct3,
  input [6:0] funct7,
  input imm,
  output reg [31:0] out
  );

always @ (posedge clk)
  begin

    case (funct3)
      3'b000:               //  ADD/ADDI/SUB
        out <= (imm || funct7 == 7'b0) ? (x + y) : (x - y); // Set imm if ADDI or ADD

      3'b001:               //  SLL
        out <= x << y[4:0];      
      
      3'b010:               //  SLT
        begin
          if ($signed(x) < $signed(y))
            out <= {31'b0, 1'b1};
          else
            out <= {31'b0, 1'b0};
        end

      3'b011:               //  SLTU
        begin
          if (x < y)
            out <= 1'b1; 
          else
            out <= 1'b0;
        end

      3'b100:               //  XOR
        out <= x ^ y;

      3'b101:               //  SRL/SRA
        out <= imm ? (x >>> y[4:0]) : (x >> y[4:0]);

      3'b110:               //  OR
        out <= x | y;

      3'b111:               //  AND
        out <= x & y;

    endcase
  end
endmodule
