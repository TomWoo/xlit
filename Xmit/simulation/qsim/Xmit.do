onerror {exit -code 1}
vlib work
vlog -work work Xmit.vo
vlog -work work Waveform_in_FSM.vwf.vt
vsim -novopt -c -t 1ps -L cycloneive_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.in_FSM_vlg_vec_tst -voptargs="+acc"
vcd file -direction Xmit.msim.vcd
vcd add -internal in_FSM_vlg_vec_tst/*
vcd add -internal in_FSM_vlg_vec_tst/i1/*
run -all
quit -f
