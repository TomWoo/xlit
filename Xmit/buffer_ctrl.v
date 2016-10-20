module buffer_controller(
input clk,
input rst,
input[7:0] data1_in,
input[7:0] data2_in,
output data_out
);

reg[7:0] data1, data2;

always @(clk, rst) begin
	if(rst) begin
		data1 <= 8'b0;
		data2 <= 8'b0;
	end else begin
		data1 <= data1_in;
		data2 <= data2_in;
	end
end



endmodule
