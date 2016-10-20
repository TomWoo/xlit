module sequence_counter(
input clk,
input rst, 
output [63:0] count_out
);

reg[63:0] count;

always @(clk, rst) begin
	if(rst) begin
		count <= 0;
	end else begin
		count <= count+1;
	end
end

endmodule
