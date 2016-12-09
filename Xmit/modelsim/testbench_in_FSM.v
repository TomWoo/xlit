`timescale 1ns/10ps
`define CLK_PER 20

model testbench_in_FSM;

// clk and reset
reg clk_sys, clk_phy, rst

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

// input signals
reg			hi_priority;
reg			lo_overflow;
reg			hi_overflow;
reg			ctrl_ctrl;
reg [23:0]	ctrl_block_in;
reg	[ 7:0]	data_in;
reg			ctrl_block_enable;
reg			data_enable;
reg	[10:0]	used_hi;
reg	[10:0]	used_lo;

// output signals
wire		discard_en;
wire		write_to_fifo;
wire 		write_priority;
wire [ 7:0]	data_out;
wire [23:0]	ctrl_block_out;
wire 		stop;

// OBJECT
in_FSM fmstest(
	.in_priority(hi_priority),
	.in_lo_overflow(lo_overflow),
	.in_hi_overflow(hi_overflow),
	.in_ctrl_ctrl(ctrl_ctrl),
	.out_m_discard_en(discard_en),
	.out_wren(write_to_fifo),
	.out_priority(write_priority),
	.clk_phy(clk_phy),
	.clk_sys(clk_sys),
	.reset(reset),
	.controli(ctrl_block_in),
	.wrend(data_enable),
	.wrenc(ctrl_block_enable),
	.datai(data_in),
	.datao(data_out),
	.controlo(ctrl_block_out),
	.stop(stop),
	.numusedhi(used_hi),
	.numusedlo(used_lo),
);	

initial begin
	data_in = 8'h00;
	ctrl_block_in = 24'hFFF;
	#(6*`CLK_PER);

	// stop!
	#(2000*`CLK_PER);

end

endmodule
