`include "defines.sv"
`include "alu_interfs.sv"
`include "alu_pkg.sv"
`include "alu.v"
`include "alu_assertions.sv"
import uvm_pkg::*;  
import alu_pkg::*;
 
module top();
	bit clk;

	alu_interfs vif (clk);

	alu #(.DW(`WIDTH), .CW(`COMMAND_WIDTH)) DUT(
		.CLK(clk),
		.RST(vif.rst),
		.INP_VALID(vif.inp_valid),
		.MODE(vif.mode),
		.CMD(vif.cmd),
		.CE(vif.ce),
		.OPA(vif.opa),
		.OPB(vif.opb),
		.CIN(vif.cin),
		.ERR(vif.err),
		.RES(vif.res),
		.OFLOW(vif.oflow),
		.COUT(vif.cout),
		.G(vif.g),
		.L(vif.l),
		.E(vif.e)
	);


	alu_assertions #(.DW(`WIDTH), .CW(`COMMAND_WIDTH)) ASSERTION(
		.clk(clk),
		.rst(vif.rst),
		.inp_valid(vif.inp_valid),
		.mode(vif.mode),
		.cmd(vif.cmd),
		.ce(vif.ce),
		.opa(vif.opa),
		.opb(vif.opb),
		.cin(vif.cin),
		.err(vif.err),
		.res(vif.res),
		.oflow(vif.oflow),
		.cout(vif.cout),
		.g(vif.g),
		.l(vif.l),
		.e(vif.e)
	);


	always
		#5 clk = ~ clk;

	initial
	begin
		clk = 0;
	end

	initial
	begin
		uvm_config_db #(virtual alu_interfs)::set(uvm_root::get(),"*","vif",vif);
		$dumpfile("dump.vcd");
		$dumpvars;
	end

	initial
	begin
		//run_test("base_test");
		//run_test("reset_test");
		//run_test("arithmetic_test");
		run_test("logical_test");
		//run_test("latch_test");
		//run_test("regression_test");
	end
endmodule
