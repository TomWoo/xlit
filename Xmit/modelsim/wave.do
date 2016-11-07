onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/UUT/clk_phy
add wave -noupdate /testbench/UUT/reset
add wave -noupdate -radix hexadecimal /testbench/UUT/data_in
add wave -noupdate /testbench/UUT/ctrl_block_in
add wave -noupdate /testbench/UUT/frame_seq_out
add wave -noupdate /testbench/UUT/xmit_done_out
add wave -noupdate /testbench/UUT/data_out
add wave -noupdate /testbench/UUT/my_state
add wave -noupdate /testbench/UUT/count
add wave -noupdate -radix hexadecimal /testbench/UUT/data_in_fifo
add wave -noupdate /testbench/UUT/rden
add wave -noupdate /testbench/UUT/wren
add wave -noupdate /testbench/UUT/is_empty
add wave -noupdate /testbench/UUT/is_full
add wave -noupdate -radix hexadecimal /testbench/UUT/data_out_fifo
add wave -noupdate -radix decimal /testbench/UUT/length_fifo
add wave -noupdate /testbench/UUT/clk_phy_2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {290640 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 212
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {2838720 ps}
