//n`include "uvm_macros.svh"
//n `include "alu_environment.sv"
//n `include "alu_sequence.sv"
//n import uvm_pkg ::*;

class alu_test extends uvm_test;

	alu_environment env;

	`uvm_component_utils(alu_test)

	function new(string name = "alu_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = alu_environment::type_id::create("env", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		alu_sequence seq;
		super.run_phase(phase);
		phase.raise_objection(this, "Objection Raised");
		seq = alu_sequence::type_id::create("seq");	
		seq.start(env.agnt.seqr);
		phase.drop_objection(this, "Objection Dropped");
	endtask

	virtual function void end_of_elaboration();
		print();
	endfunction
endclass
