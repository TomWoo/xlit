module out_FSM_tester(
input clk,
input clk_phy,
input clock_select,
input rst_n,
input [7:0] data_in,
output [3:0] data_out,
output [3:0] data_out_LEDs,
output clk_out,
output rst_out
);

assign clock = clock_select ? clk : clk_phy;

out_FSM out_FSM(
.clk_phy(clock),
.reset(!rst_n),
.data_in(data_in),
.data_out(data_out),
.ctrl_block_in(24'b0),
.frame_seq_out()
);

assign clk_out = clk;
assign rst_out = !rst_n;
assign data_out_LEDs = data_out;

endmodule
