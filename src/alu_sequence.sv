class alu_sequence extends uvm_sequence #(alu_sequence_item);
	`uvm_object_utils(alu_sequence)

	function new(string name = "alu_sequence");
		super.new(name);
	endfunction

	virtual task body();
		req = alu_sequence_item::type_id::create("req");
		wait_for_grant();
		req.randomize();
		send_request(req);
		wait_for_item_done();
	endtask
endclass
//------------------------------------------------------------------------------------------------------
class reset_sequence extends uvm_sequence #(alu_sequence_item); 
	`uvm_object_utils(reset_sequence)

	function new(string name = "reset_sequence");
		super.new(name);
	endfunction

	virtual task body();
	`uvm_do_with(req,{req.rst == 1;});
	endtask
endclass
//------------------------------------------------------------------------------------------------------
class latch_sequence extends uvm_sequence #(alu_sequence_item); 
	`uvm_object_utils(latch_sequence)

	function new(string name = "latch_sequence");
		super.new(name);
	endfunction

	virtual task body();
	`uvm_do_with(req,{req.rst == 0; req.ce == 0;});
	endtask
endclass
//------------------------------------------------------------------------------------------------------
class arithmetic_sequence extends uvm_sequence #(alu_sequence_item); 
	`uvm_object_utils(arithmetic_sequence)

	function new(string name = "arithmetic_sequence");
		super.new(name);
	endfunction

	virtual task body();
		//`uvm_do_with(req,{req.rst == 0;req.ce == 1; req.mode == 1; req.cmd inside{[0:10]};});
		`uvm_do_with(req,{req.rst == 0;req.ce == 1; req.mode == 1; req.inp_valid == 3; req.cmd inside{[0:10]};});
	endtask
endclass
//------------------------------------------------------------------------------------------------------
class logical_sequence extends uvm_sequence #(alu_sequence_item); 
	`uvm_object_utils(logical_sequence)

	function new(string name = "logical_sequence");
		super.new(name);
	endfunction

	virtual task body();
	`uvm_do_with(req,{req.rst == 0; req.ce == 1; req.mode == 0; req.inp_valid == 3; req.cmd inside{[0:13]};});
	endtask
endclass
//------------------------------------------------------------------------------------------------------
class regression_sequence extends uvm_sequence #(alu_sequence_item); 

	reset_sequence rst_seq;
	latch_sequence latch_seq;
	arithmetic_sequence art_seq;
	logical_sequence logi_seq;

	`uvm_object_utils(regression_sequence)

	function new(string name = "regression_sequence");
		super.new(name);
	endfunction

	virtual task body();
		`uvm_do(rst_seq);
		`uvm_do(latch_seq);
		`uvm_do(art_seq);
		`uvm_do(logi_seq);
	endtask
endclass
