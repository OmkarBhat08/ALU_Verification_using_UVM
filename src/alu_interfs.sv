`include "defines.sv"

interface alu_interfs(input logic clk);

	logic [1:0] inp_valid;
	logic rst, mode, ce, cin;
	logic [3:0] cmd;
	logic [`WIDTH-1:0] opa, opb;
	
	logic err, oflow, cout, g, l, e;
	logic [`WIDTH:0] res;

	clocking driver_cb @(posedge clk);
		default input #0 output #0;
		output rst;
		output inp_valid, mode, cmd, ce, opa, opb, cin;
	endclocking

	clocking monitor_cb @(posedge clk);
		default input #0 output #0;
		input rst;
		input inp_valid, mode, cmd, ce, opa, opb, cin;
		input err, res, oflow, cout, g, l, e;	
	endclocking

	clocking ref_model_cb @(posedge clk);
		default input #0 output #0;
	endclocking

	modport DRIVER (clocking driver_cb, input clk, rst);
	modport MONITOR (clocking monitor_cb, input clk, rst);
	modport SCOREBOARD (clocking ref_model_cb, input clk, rst);

endinterface
