#!/bin/bash

set -e

function clean {
    rm   -rf work/*
}

function compile {
    ghdl -c --workdir=work --std=08 --ieee=standard custom_timer.vhd custom_timer_tb.vhd -e custom_timer_tb
}

function run {
    ghdl -r custom_timer_tb
}

function wave {
    ghdl -r custom_timer_tb --vcd=work/custom_timer_tb.vcd
    #gtkwave work/custom_timer_tb.vcd 2> /dev/null
}

mkdir -p work
clean
compile
#run
wave
