module alu
  (input [31:0] x,
  input [31:0] y,
  input [3:0] funct3,
  input [6:0] funct7,
  output reg [31:0] out,
  output reg zero
  );


always @ (*)
  begin
    case (funct3)
      
      3'b000:               //  AND/SUB
        begin
          if (funct7 == 7'b0)
            out <= x + y;
          else
            out <= x - y;
        end

      3'b001:               //  SLL
        out <= x << y;      
      
      3'b010:               //  SLT
        begin
          if ($signed(x) < $signed(y))
            out <= 1'b1;
          else
            out <= 1'b0;
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
        begin
          if (funct7 == 7'b0)
            out <= x >> y;
          else
            out <= x >>> y;
        end

      3'b110:               //  OR
        out <= x || y;

      3'b111:               //  AND
        out <= x && y;

      default:
        zero <= 1'b0;

    endcase
  end
endmodule
