module regfile
  (input clock,
  input [4:0] read_a,
  input [4:0] read_b,
  input [4:0] write_idx,
  input [31:0] data,
  input write_enable,
  output reg [31:0] a,
  output reg [31:0] b
  );



reg [31:0] regs[0:31];

always @(posedge clock)
  begin
    if (write_enable)
      begin
        if (write_idx != 0)
          begin
            regs[write_idx] <= data;
          end
      end
  end

always @ (*)
  begin
    if (read_a == 5'd0)
      a <= 32'b0;
    else
      a <= regs[read_a];
    if (read_b == 5'd0)
      b <= 32'b0;
    else
      b <= regs[read_b];
  end

        
endmodule
