module Synchronous_FIFO #(
    parameter WIDTH = 32,     
    parameter DEPTH = 1024     //should be in power of 2
)(
    input wire clk,
    input wire reset,
    input wire [WIDTH-1:0] d_in,
    input wire w_enb,
    input wire r_enb,
    output reg [WIDTH-1:0] d_out,
    output wire full,
    output wire empty
);

localparam ADDR_WIDTH = $clog2(DEPTH);
reg [WIDTH-1:0] fifo [0:DEPTH-1];
reg [ADDR_WIDTH:0] w_ptr, r_ptr;  

wire [ADDR_WIDTH:0] ptr_diff = w_ptr - r_ptr;  //diff in pointer calc

assign empty = (w_ptr == r_ptr);
assign full  = (ptr_diff == DEPTH);

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        w_ptr  <= 0;
        r_ptr  <= 0;
        d_out  <= 0;
    end else begin
      if (w_enb && !full) begin    //write operation
            fifo[w_ptr[ADDR_WIDTH-1:0]] <= d_in; 
            w_ptr <= w_ptr + 1;
      end
      if (r_enb && !empty) begin    //read operation
            d_out <= fifo[r_ptr[ADDR_WIDTH-1:0]]; 
            r_ptr <= r_ptr + 1;
        end
    end
end

endmodule
