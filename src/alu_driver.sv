//n `include "uvm_macros.svh"
//`include "alu_sequence_item.sv"
//n import uvm_pkg ::*;

class alu_driver extends uvm_driver#(alu_sequence_item);
	
	virtual alu_interfs vif;
	uvm_analysis_port #(alu_sequence_item) item_collected_port;

	`uvm_component_utils(alu_driver)

	function new(string name = "alu_driver", uvm_component parent = null);
		super.new(name, parent);
		item_collected_port = new("item_collected_port",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if( !uvm_config_db #(virtual alu_interfs)::get(this, "","vif", vif))
			`uvm_fatal(get_type_name(), "Not set at top");
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever
		begin
			seq_item_port.get_next_item(req);
			drive();
			seq_item_port.item_done();
		end
	endtask

	virtual task drive();
		repeat(2)@(posedge vif.driver_cb);
		req.rst <= vif.rst; 
		vif.ce <= req.ce;
		vif.mode <= req.mode;
		vif.inp_valid <= req.inp_valid;
		vif.cmd <= req.cmd;
		vif.opa <= req.opa;
		vif.opb <= req.opb;
		vif.cin <= req.cin;
		
		$display("--------------------------------------------DRIVER----------------------------------------");
		req.print();
		repeat(3) @(posedge vif.driver_cb);
		item_collected_port.write(req);
		repeat(1) @(posedge vif.driver_cb);
	endtask
endclass
