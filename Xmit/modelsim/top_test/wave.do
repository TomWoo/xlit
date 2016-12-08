onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /xmitTop_vlg_vec_tst/clk_phy
add wave -noupdate /xmitTop_vlg_vec_tst/clk_sys
add wave -noupdate /xmitTop_vlg_vec_tst/f_ctrl_in
add wave -noupdate /xmitTop_vlg_vec_tst/f_data_in
add wave -noupdate /xmitTop_vlg_vec_tst/f_hi_priority
add wave -noupdate /xmitTop_vlg_vec_tst/f_rec_data_valid
add wave -noupdate /xmitTop_vlg_vec_tst/f_rec_frame_valid
add wave -noupdate /xmitTop_vlg_vec_tst/reset
add wave -noupdate /xmitTop_vlg_vec_tst/m_discard_en
add wave -noupdate /xmitTop_vlg_vec_tst/m_discard_frame
add wave -noupdate /xmitTop_vlg_vec_tst/m_tx_done
add wave -noupdate /xmitTop_vlg_vec_tst/m_tx_frame
add wave -noupdate /xmitTop_vlg_vec_tst/phy_data_out
add wave -noupdate /xmitTop_vlg_vec_tst/phy_tx_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {133203 ps} 0}
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
WaveRestoreZoom {0 ps} {512 ns}
