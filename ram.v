module ram (
  input clk,

  // write enable
  input w_enable,
  
  // instruction fetch address, output
  input [31:0] i_addr,
  output reg [31:0] i_data,
  
  // data in, data fetch address, output
  input [31:0] d_in,
  input [31:0] d_addr,
  output reg [31:0] d_out_data
  );

// 16 kb memory
reg [31:0] mem[0:4095];

// read memory
always @ *
  begin
    i_data <= mem[i_addr];
    d_data <= mem[d_addr];
  end

// write to memory
always @(posedge clk)
  begin
    if (w_enable == 1'b1)
      begin
        mem[d_addr] <= d_in;
      end
  end

/*
    else
      begin
        i_data <= mem[i_addr];
        d_out <= mem[d_addr]; 
      end
  end
*/


endmodule
