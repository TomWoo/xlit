module out_FSM_tester(
input clk,
input rst_n,
input [7:0] data_in,
output [3:0] data_out,
output clk_out,
output rst_out
);

out_FSM out_FSM(
.clk_phy(clk),
.reset(!rst_n),
.data_in(data_in),
.data_out(data_out),
.ctrl_block_in(24'b0),
.frame_seq_out()
);

assign clk_out = clk;
assign rst_out = !rst_n;

endmodule
