`timescale 1ns/10ps
`define CLK_PHY 40
`define CLK_SYS 20

module testbench_10hi_lo;

// signals
reg clk_sys, clk_phy, rst;
integer i, j, l, n, num_loops, packet_length, num_hi;
integer start_hi, start_lo;

initial begin
	// parameters
	packet_length = 512; // also modify packet length in control block!!!
	num_loops = 256;
	start_hi = 239;
	start_lo = 0;
 	num_hi = 10;

	clk_sys = 1'b1;
	clk_phy = 1'b1;
	rst = 1'b1;
	#(6*`CLK_SYS);
	rst = 1'b0;
end

always begin
	clk_sys <= !clk_sys;
	#`CLK_SYS;
end

always begin
	clk_phy = !clk_phy;
	#`CLK_PHY;
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

initial begin // assigning value of data, data valid, and priority
	data_in = 8'h00;
	data_valid = 1'b0;
	hi_priority_en = 1'b1;
	#(6*`CLK_SYS);

	for (i=0; i < num_loops; i=i+1)
		for (n = 0; n < num_hi; n=n+1)
			start_hi=start_hi+1;
			data_in = start_hi;
			data_valid = 1'b1;
			hi_priority_en = 1'b1;
			#((packet_length)*`CLK_SYS);

		data_in = start_lo;
		data_valid = 1'b1;
		hi_priority_en = 1'b0;
		start_lo=(start_lo+1);
		#((packet_length)*`CLK_SYS);
end

initial begin // assigning value of ctrl, ctrl valid
	ctrl_block_in = 24'hFFF;
	ctrl_block_valid = 1'b0;
	#(6*`CLK_SYS);

	for (j=0; j < num_loops; j=j+1)
		for (l=0; l < num_hi; l=l+1)
			// turn on control block for first cycle
			ctrl_block_in = 24'h200200;
			ctrl_block_valid = 1'b1;
			#(`CLK_SYS);

			// turn off control block again
			ctrl_block_in = 24'h000000;
			ctrl_block_valid = 1'b0;
			#((packet_length-1)*`CLK_SYS);

		// turn on control block for short cycle
		ctrl_block_in = 24'h040040;
		ctrl_block_valid = 1'b1;
		#(`CLK_SYS);

		// turn off control block again
		ctrl_block_in = 24'h000000;
		ctrl_block_valid = 1'b0;
		#((packet_length-1)*`CLK_SYS);

end

endmodule