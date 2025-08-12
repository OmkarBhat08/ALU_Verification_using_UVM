vsim: vlog
	vsim -c top -do "run -all;"

vlog:
	vlog top.sv +incdir+/tools/mentor/questasim_10.6c/questasim/uvm-1.1d/../verilog_src/uvm-1.1d/src

clean:
	rm -rf work/
	rm transcript
