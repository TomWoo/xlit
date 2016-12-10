`timescale 1ns/10ps
`define CLK_PER 20

module testbench_high_priority_long_packet;

// Clock and POR
reg clk_sys, clk_phy, rst;
integer i, num_packets;
integer j, n;

initial begin
	// Parameters
	n = 512;
	num_packets = 2048;

	clk_sys = 1'b1;
	clk_phy = 1'b1;
	rst = 1'b1;
	#(6*`CLK_PER);
	rst = 1'b0;
end

always begin
	clk_phy <= !clk_phy;
	#(`CLK_PER);
end

always begin
	clk_sys <= !clk_sys;
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

ctrl_block_in = 24'd512;
hi_priority_en = 1'b1;

for (i = 0; i<num_packets; i=i+1)

	for (j = 0; j < n; j = j+1) begin
		if(j>0) begin
			ctrl_block_valid = 1'b1;
			data_valid = 1'b1;
		end else begin
			ctrl_block_valid = 1'b0;
			data_valid = 1'b1;
		end

		if(j<4 || j>=n-4) begin
			data_in = 8'h00;
		end else begin
			data_in = 8'hFF;
		end

		#(`CLK_PER);
	end

end

endmodule
