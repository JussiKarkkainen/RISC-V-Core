// Used to handle conditions in branch instructions 
module conditionals (
  input clk,
  input [31:0] x,
  input [31:0] y,
  input [2:0] funct3,
  output reg out
  );

always @(posedge clk)
  begin
    case (funct3)
      
      3'b000:           // EQ
        out <= (x == y);

      3'b001:           // NE
        out <= (x != y);

      3'b100:           // LT
        out <= ($signed(x) < $signed(y));
        
      3'b101:           // GE
        out <= ($signed(x) >= $signed(y));

      3'b110:           // LTU
        out <= (x < y);

      3'b111:           // GEU
        out <= (x >= y);
      
    endcase
  end
endmodule
