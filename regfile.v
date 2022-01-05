module regfile
  (input clk,
  input [4:0] read_a,
  input [4:0] read_b,
  input [4:0] write_idx,
  input [31:0] data,
  input write_enable,
  output reg [31:0] a,
  output reg [31:0] b
  );



reg [31:0] regs[0:31];


always @(posedge clk)
  begin
    a <= regs[read_a];
    b <= regs[read_b];
    if (write_enable)
      begin
        if (write_idx != 0)
          regs[write_idx] <= data;
      end
  end


        
endmodule
