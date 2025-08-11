//n `include "uvm_macros.svh"
// `include "alu_sequence_item.sv"
//n import uvm_pkg ::*;
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
