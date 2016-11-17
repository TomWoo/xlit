onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_out_FSM/UUT/clk_phy
add wave -noupdate /testbench_out_FSM/UUT/reset
add wave -noupdate -radix hexadecimal /testbench_out_FSM/UUT/data_in
add wave -noupdate -radix hexadecimal /testbench_out_FSM/UUT/ctrl_block_in
add wave -noupdate /testbench_out_FSM/UUT/frame_seq_out
add wave -noupdate /testbench_out_FSM/UUT/xmit_done_out
add wave -noupdate /testbench_out_FSM/UUT/data_out
add wave -noupdate /testbench_out_FSM/UUT/my_state
add wave -noupdate /testbench_out_FSM/UUT/count
add wave -noupdate -radix hexadecimal /testbench_out_FSM/UUT/data_in_fifo
add wave -noupdate /testbench_out_FSM/UUT/rden
add wave -noupdate /testbench_out_FSM/UUT/wren
add wave -noupdate /testbench_out_FSM/UUT/is_empty
add wave -noupdate /testbench_out_FSM/UUT/is_full
add wave -noupdate -radix hexadecimal /testbench_out_FSM/UUT/data_out_fifo
add wave -noupdate /testbench_out_FSM/UUT/length_fifo
add wave -noupdate /testbench_out_FSM/UUT/clk_phy_2
add wave -noupdate /testbench_out_FSM/UUT/count_mod
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1060000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1484800 ps}
