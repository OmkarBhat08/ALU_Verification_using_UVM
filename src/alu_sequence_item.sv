`include "defines.sv"
`include "uvm_macros.svh"
import uvm_pkg ::*;

class alu_sequence_item extends uvm_sequence_item;

	rand logic rst;
	rand logic mode, ce, cin;
	rand logic [1:0] inp_valid;
	rand logic [3:0] cmd;
	rand logic [`WIDTH-1:0] opa, opb;

	logic [`WIDTH:0] res;
	logic err, oflow, cout, g, l, e;

	`uvm_object_utils_begin(alu_sequence_item)
		`uvm_field_int(rst,UVM_ALL_ON);
		`uvm_field_int(ce,UVM_ALL_ON);
		`uvm_field_int(mode,UVM_ALL_ON);
		`uvm_field_int(cmd,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(inp_valid,UVM_BIN | UVM_ALL_ON);
		`uvm_field_int(opa,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(opb,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(cin,UVM_ALL_ON);

		`uvm_field_int(res,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(err,UVM_ALL_ON);
		`uvm_field_int(oflow,UVM_ALL_ON);
		`uvm_field_int(cout,UVM_ALL_ON);
		`uvm_field_int(g,UVM_ALL_ON);
		`uvm_field_int(l,UVM_ALL_ON);
		`uvm_field_int(e,UVM_ALL_ON);
	`uvm_object_utils_end

	function new(string name = "alu_sequence_item");
		super.new(name);
	endfunction
endclass
