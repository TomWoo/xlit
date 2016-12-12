`timescale 1ns/10ps
`define CLK_PER 20

module testbench_diff_packet_lengths;

// Clock and POR
reg clk_sys, clk_phy, rst;
integer i, j, n, num_cycles, delay_cycles;
integer num_cycles_0, num_cycles_1, num_cycles_2, num_cycles_3;

initial begin
	// Parameters
	n = 1024;
	num_cycles_0 = 256;
	num_cycles_1 = 512;
	num_cycles_2 = 1024;
	num_cycles_3 = 1536;
	num_cycles = 2048;
	delay_cycles = 2;

	clk_sys = 1'b1;
	clk_phy = 1'b1;
	rst = 1'b1;
	#(6*`CLK_PER);
	rst = 1'b0;
end

always begin
	clk_sys <= !clk_sys;
	#(`CLK_PER);
end

always begin
	clk_phy <= !clk_phy;
	#(2*`CLK_PER);
end

// Input signals
reg [ 7:0] 	data_in;
reg [23:0] 	ctrl_block_in;
reg 		data_valid;
reg			ctrl_block_valid;
reg			hi_priority_en;

// Output signals
wire [3:0] 	frame_seq_out;
wire		phy_tx_out;
wire		discard_en;

// UUT
xmitTop topLevel(
	.f_hi_priority(hi_priority_en),
	.f_rec_data_valid(data_valid),
	.f_rec_frame_valid(ctrl_block_valid),
	.f_data_in(data_in),
	.f_ctrl_in(ctrl_block_in),
	.clk_sys(clk_sys),
	.clk_phy(clk_phy),
	.reset(rst),
	.phy_data_out(frame_seq_out),
	.phy_tx_en(phy_tx_out),
	.m_discard_en(discard_en)
);

initial begin
	data_in = 8'h00;
	#(5.5*`CLK_PER);

	for (j = 0; j < n; j = j +1) begin

		data_in = 8'hCC;
		data_valid = 1'b1;
		hi_priority_en = 1'b1;
		#(num_cycles_0*`CLK_PER);

		data_in = 8'hAA;
		data_valid = 1'b1;
		hi_priority_en = 1'b0;
		#(num_cycles_1*`CLK_PER);

		data_in = 8'h11;
		data_valid = 1'b1;
		hi_priority_en = 1'b0;
		#(num_cycles_2*`CLK_PER);

		data_in = 8'hEE;
		data_valid = 1'b1;
		hi_priority_en = 1'b0;
		#(num_cycles_3*`CLK_PER);

		data_in = 8'h55;
		data_valid = 1'b1;
		hi_priority_en = 1'b0;
		#(num_cycles*`CLK_PER);

	end

end

initial begin
	ctrl_block_in = 24'h000;
	#(5.5*`CLK_PER);

	for (i = 0; i < n; i = i +1) begin

		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b1;
		#(delay_cycles*`CLK_PER);
		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b0;
		#((num_cycles_0-delay_cycles)*`CLK_PER);

		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b1;
		#(delay_cycles*`CLK_PER);
		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b0;
		#((num_cycles_1-delay_cycles)*`CLK_PER);

		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b1;
		#(delay_cycles*`CLK_PER);
		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b0;
		#((num_cycles_2-delay_cycles)*`CLK_PER);

		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b1;
		#(delay_cycles*`CLK_PER);
		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b0;
		#((num_cycles_3-delay_cycles)*`CLK_PER);

		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b1;
		#(delay_cycles*`CLK_PER);
		ctrl_block_in = 24'h200200;
		ctrl_block_valid = 1'b0;
		#((num_cycles-delay_cycles)*`CLK_PER);
	end

end

endmodule
