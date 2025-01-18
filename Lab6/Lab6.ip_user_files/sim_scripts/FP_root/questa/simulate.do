onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib FP_root_opt

do {wave.do}

view wave
view structure
view signals

do {FP_root.udo}

run -all

quit -force
