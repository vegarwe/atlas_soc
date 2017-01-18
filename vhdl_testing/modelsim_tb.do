vlib /home/vegarwe/devel/atlas_soc/atlas_linux_ghrd/software/vhdl/work
vmap work /home/vegarwe/devel/atlas_soc/atlas_linux_ghrd/software/vhdl/work
vcom -explicit -2008 -work work /home/vegarwe/devel/atlas_soc/atlas_linux_ghrd/software/vhdl/custom_fisken.vhd
vcom -explicit -2008 -work work /home/vegarwe/devel/atlas_soc/atlas_linux_ghrd/software/vhdl/custom_fisken_tb.vhdl

vsim -t 1ps work.custom_fisken_tb
add wave -position insertpoint sim:/custom_fisken_tb/*
add wave -position insertpoint sim:/custom_fisken_tb/dut/*
run -all
