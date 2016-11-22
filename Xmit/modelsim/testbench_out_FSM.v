`timescale 1ns/10ps
`define CLK_PER 20

module testbench_out_FSM;

// Clock and POR
reg clk, rst;

initial begin
	clk = 1'b1;
	rst = 1'b1;
	#(6*`CLK_PER);
	rst = 1'b0;
end

always begin
	clk <= !clk;
	#`CLK_PER;
end

// Input Signals
reg [ 7:0] data_in;
reg [23:0] ctrl_block_in;

// Output signals
//wire 	    wren_ctrl_out;
wire [11:0] frame_seq_out;
wire 	    xmit_done_out;
wire [ 3:0] data_out;

// UUT
out_FSM UUT(
	.clk_phy(clk),
	.reset(rst),
	.data_in(data_in),
	.ctrl_block_in(ctrl_block_in),
	//.wren_ctrl_out(wren_ctrl_out),
	.frame_seq_out(frame_seq_out),
	.xmit_done_out(xmit_done_out),
	.data_out(data_out)
);

initial begin
	data_in = 8'h00;
	ctrl_block_in = 24'hFF_FFFF;
	#(8*`CLK_PER);
	
	data_in = 8'hAB;
	#(2*`CLK_PER);
	data_in = 8'hCD;
	#(2*`CLK_PER);
	data_in = 8'hEF;
	#(2*`CLK_PER);
	
	// Finish
	#(200*`CLK_PER);
	//$stop;
end

endmodule
