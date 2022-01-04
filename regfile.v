module regfile
  (input clk,
  input [4:0] read_a,
  input [4:0] read_b,
  input [4:0] write_idx,
  input [31:0] data,
  input write_enable,
  output [31:0] a,
  output [31:0] b
  );



reg [31:0] regs[0:31];

assign a = regs[read_a];
assign b = regs[read_b];

always @(negedge clk)
  begin
    if (write_enable)
      begin
        if (write_idx != 0)
          regs[write_idx] <= data;
      end
  end


        
endmodule
