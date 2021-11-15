module ram (
  input clk,
  input [31:0] i_addr,
  output reg [31:0] i_data,
  input [31:0] d_in,
  input d_addr,
  output reg [31:0] d_out,
  input w_enable
  );


reg [31:0] mem[0:4095];

always @(posedge clk)
  begin
    if (w_enable == 1'b1)
      begin
        mem[d_addr] <= d_in;
      end
    else
      begin
        i_data <= mem[i_addr];
        d_out <= mem[d_addr]; 
      end
  end
endmodule
