module alu_assertions #(parameter DW = 8, CW=4)(res, err, oflow, cout, g, l, e, clk, rst, inp_valid, mode, cmd, ce, opa, opb, cin);
	
	input logic rst;
	input logic clk;
	input logic mode, ce, cin;
	input logic [1:0] inp_valid;
	input logic [3:0] cmd;
	input logic [DW-1:0] opa, opb;
	input logic [DW:0] res;
	input logic err, oflow, cout, g, l, e;

	property invalid_inputs;
		@(posedge clk) (inp_valid == 0) |-> err;
	endproperty

	assert property (invalid_inputs)
		$display("\n\n\nError flag is high when inp_valid is 0");
	else
		$display("\n\n\nError flag is low when inp_valid is 0");

endmodule
