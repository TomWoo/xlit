module Xmit(
input clk,
input rst,
input rcv_data_valid,
input [7:0] data_in,
output reg[3:0] data_out
);

reg[7:0] frame_buffer_data;

fifo_8 frame_buffer(
.clock(clk),
.aclr(rst),
.data(data_in),
.q(data_out),
.rdreq(),
.wrreq()
);

endmodule
