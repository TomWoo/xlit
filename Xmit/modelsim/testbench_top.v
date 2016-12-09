`timescale 1ns/10ps
`define CLK_PER 20

module testbench_top;

// Clock and POR
reg clk_sys, clk_phy, rst;

initial begin
	clk_sys = 1'b1;
	clk_phy = 1'b1;
	rst = 1'b1;
	#(6*`CLK_PER);
	rst = 1'b0;
end

always begin
	clk_phy <= !clk_phy;
	#`CLK_PER;
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
	.f_rec_data_valid(ata_valid),
	.f_rec_frame_valid(ctrl_block_valid),
	.f_data_in(data_in),
	.f_ctrl_in(ctrl_block_in),
	.clk_sys(clk_sys),
	.clk_phy(clk_phy),
	.reset(reset),
	.phy_data_out(frame_seq_out),
	.phy_tx_en(phy_tx_out),
	.m_discard_en(discard_en)
);

initial begin
	data_in = 8'h00;
	ctrl_block_in = 24'h000;
	#(6*`CLK_PER);

	data_in = 8'hCC;
	#(512*`CLK_PER);
	data_valid = 1'b1;
	#(512*`CLK_PER);
	hi_priority_en = 1'b1;
	#(512*`CLK_PER);
	ctrl_block_in = 24'h333;
	#(`CLK_PER);
	ctrl_block_in = 24'h000;
	#(511*`CLK_PER);
	ctrl_block_valid = 1'b1;
	#(`CLK_PER);
	ctrl_block_valid = 1'b0;
	#(511*`CLK_PER);

	data_in = 8'hAA;
	#(512*`CLK_PER);
	data_valid = 1'b1;
	#(512*`CLK_PER);
	hi_priority_en = 1'b1;
	#(512*`CLK_PER);
	ctrl_block_in = 24'h111;
	#(`CLK_PER);
	ctrl_block_in = 24'h000;
	#(511*`CLK_PER);
	ctrl_block_valid = 1'b1;
	#(`CLK_PER);
	ctrl_block_valid = 1'b0;
	#(511*`CLK_PER);

	data_in = 8'h11;
	#(512*`CLK_PER);
	data_valid = 1'b1;
	#(512*`CLK_PER);
	hi_priority_en = 1'b1;
	#(512*`CLK_PER);
	ctrl_block_in = 24'h555;
	#(`CLK_PER);
	ctrl_block_in = 24'h000;
	#(511*`CLK_PER);
	ctrl_block_valid = 1'b1;
	#(`CLK_PER);
	ctrl_block_valid = 1'b0;
	#(511*`CLK_PER);

	data_in = 8'hEE;
	#(512*`CLK_PER);
	data_valid = 1'b1;
	#(512*`CLK_PER);
	hi_priority_en = 1'b1;
	#(512*`CLK_PER);
	ctrl_block_in = 24'h0F0;
	#(`CLK_PER);
	ctrl_block_in = 24'h000;
	#(511*`CLK_PER);
	ctrl_block_valid = 1'b1;
	#(`CLK_PER);
	ctrl_block_valid = 1'b0;
	#(511*`CLK_PER);

	data_in = 8'h22;
	#(512*`CLK_PER);
	data_valid = 1'b1;
	#(512*`CLK_PER);
	hi_priority_en = 1'b0;
	#(512*`CLK_PER);
	ctrl_block_in = 24'h111;
	#(`CLK_PER);
	ctrl_block_in = 24'h000;
	#(511*`CLK_PER);
	ctrl_block_valid = 1'b1;
	#(`CLK_PER);
	ctrl_block_valid = 1'b0;
	#(511*`CLK_PER);

	data_in = 8'h55;
	#(512*`CLK_PER);
	data_valid = 1'b1;
	#(512*`CLK_PER);
	hi_priority_en = 1'b1;
	#(512*`CLK_PER);
	ctrl_block_in = 24'h111;
	#(`CLK_PER);
	ctrl_block_in = 24'h000;
	#(511*`CLK_PER);
	ctrl_block_valid = 1'b1;
	#(`CLK_PER);
	ctrl_block_valid = 1'b0;
	#(511*`CLK_PER);


	// Finish
end

endmodule

