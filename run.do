vlib work

vlog -lint fsm.sv +acc
vlog -lint top-3.sv +acc
vlog -lint 8088.svp +acc

vsim work.top
add wave -r *
run -all