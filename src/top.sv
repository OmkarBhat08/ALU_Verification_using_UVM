//`include "uvm_macros.svh"
//`include "uvm_pkg.sv"

`include "defines.sv"
`include "alu_interfs.sv"
`include "alu_pkg.sv"
`include "alu.v"
import uvm_pkg::*;  
import alu_pkg::*;
 
module top();
	bit clk, rst;

	alu_interfs vif (clk, rst);

	alu #(.DW(`WIDTH), .CW(`COMMAND_WIDTH)) DUT(
		.CLK(clk),
		.RST(rst),
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
	always
		#5 clk = ~ clk;

	initial
	begin
		clk = 0;
		rst = 1;
	 	#5;
		rst = 0;	
	end

	initial
	begin
		uvm_config_db #(virtual alu_interfs)::set(uvm_root::get(),"*","vif",vif);
		$dumpfile("dump.vcd");
		$dumpvars;
	end

	initial
	begin
		run_test("alu_test");
	end
endmodule
