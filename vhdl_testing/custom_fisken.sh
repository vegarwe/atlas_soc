#!/bin/bash

set -e

function clean {
    rm   -rf work/*
}

function compile {
    ghdl -c --std=08 --ieee=standard custom_timer.vhd custom_fisken.vhd custom_fisken_tb.vhd -e custom_fisken_tb
}

function run {
    ghdl -r custom_fisken_tb
}

function wave {
    ghdl -r custom_fisken_tb --vcd=work/custom_fisken_tb.vcd
    #gtkwave work/custom_fisken_tb.vcd 2> /dev/null
}

mkdir -p work
clean
compile
#run
wave
