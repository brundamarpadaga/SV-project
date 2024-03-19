vlib work

vlog -lint interface.sv +acc
vlog -lint fsm.sv +acc
vlog -lint top-3.sv +acc
vlog -lint 8088if.svp +acc

vsim work.top
add wave -r *
run -all