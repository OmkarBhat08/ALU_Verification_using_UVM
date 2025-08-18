class alu_base_test extends uvm_test;

	alu_environment env;

	`uvm_component_utils(alu_base_test)

	function new(string name = "alu_base_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = alu_environment::type_id::create("env", this);
	endfunction

	virtual function void end_of_elaboration();
		print();
	endfunction
endclass

//---------------------------------------------------------------------------------------------------------
class reset_test extends alu_base_test;
	`uvm_component_utils(reset_test)

	function new(string name = "reset_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		reset_sequence seq;
		super.run_phase(phase);
		phase.raise_objection(this, "Objection Raised");
		repeat(1)
		begin
			seq = reset_sequence::type_id::create("seq");	
			seq.start(env.agnt.seqr);
			$display("############################################################################################################################");
		end
		phase.drop_objection(this, "Objection Dropped");
	endtask

	virtual function void end_of_elaboration();
		print();
	endfunction
endclass

//---------------------------------------------------------------------------------------------------------
class latch_test extends alu_base_test;
	`uvm_component_utils(latch_test)

	function new(string name = "latch_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		latch_sequence seq;
		super.run_phase(phase);
		phase.raise_objection(this, "Objection Raised");
		repeat(20)
		begin
			seq = latch_sequence::type_id::create("seq");	
			seq.start(env.agnt.seqr);
			$display("############################################################################################################################");
		end
		phase.drop_objection(this, "Objection Dropped");
	endtask

	virtual function void end_of_elaboration();
		print();
	endfunction
endclass

//---------------------------------------------------------------------------------------------------------
class arithmetic_test extends alu_base_test;
	`uvm_component_utils(arithmetic_test)

	function new(string name = "arithmetic_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		arithmetic_sequence seq;
		super.run_phase(phase);
		phase.raise_objection(this, "Objection Raised");
		//repeat(20)
		repeat(5)
		begin
			seq = arithmetic_sequence::type_id::create("seq");	
			seq.start(env.agnt.seqr);
			$display("############################################################################################################################");
		end
		phase.drop_objection(this, "Objection Dropped");
	endtask

	virtual function void end_of_elaboration();
		print();
	endfunction
endclass

//---------------------------------------------------------------------------------------------------------
class logical_test extends alu_base_test;
	`uvm_component_utils(logical_test)

	function new(string name = "logical_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		logical_sequence seq;
		super.run_phase(phase);
		phase.raise_objection(this, "Objection Raised");
		repeat(20)
		begin
			seq = logical_sequence::type_id::create("seq");	
			seq.start(env.agnt.seqr);
			$display("############################################################################################################################");
		end
		phase.drop_objection(this, "Objection Dropped");
	endtask

	virtual function void end_of_elaboration();
		print();
	endfunction
endclass
