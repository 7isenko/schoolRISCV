
# create library
vlib work

# compile sources
vlog -vlog01compat \
     +incdir+../../../src \
     +incdir+../../../testbench \
     ../../../src/*.v \
     ../../../testbench/*.v

# run simulator
vsim -voptargs="+acc" work.sm_testbench

# add signals to waveform
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/rf
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/my_hypotenuse/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/my_hypotenuse/my_multb/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/my_hypotenuse/my_sqrt/*

# start simulation
run -all

# Zoom Full the Wave window
wave zoom full
