module ram (
  input clk,

  input w_enable,
   
  input [31:0] i_addr,  
  output reg [31:0] i_data,
  
  input [2:0] d_size,
  input [31:0] d_in,
  input [31:0] d_addr,  
  output reg [31:0] d_out_data
  );


reg [31:0] mem[0:4095];

always @(posedge clk)
  begin
    // read
    i_data <= mem[i_addr[13:2]];    
    d_out_data <= mem[d_addr[13:2]];

    // write, support different size stores
    if (w_enable == 1'b1)
      begin
        case (d_size)
          3'b000: mem[d_addr[13:2]] <= d_in[7:0];
          3'b001: mem[d_addr[13:2]] <= d_in[15:0];
          3'b010: mem[d_addr[13:2]] <= d_in;       
        endcase
      end
  end

endmodule
