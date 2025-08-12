//n `include "uvm_macros.svh"
//`include "alu_sequence_item.sv"
//n import uvm_pkg ::*;

class alu_monitor extends uvm_monitor;

	virtual alu_interfs vif;
	alu_sequence_item alu_sequence_item_monitor; 
	uvm_analysis_port #(alu_sequence_item) item_collected_port;

	`uvm_component_utils(alu_monitor)

	function new(string name = "alu_monitor", uvm_component parent = null);
		super.new(name,parent);
		alu_sequence_item_monitor  = new();
		item_collected_port = new("item_collected_port", this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual alu_interfs)::get(this,"","vif", vif))
			`uvm_fatal(get_type_name,"Not set at top");
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever
		begin
			repeat(2) @(posedge vif.monitor_cb);
			alu_sequence_item_monitor.ce = vif.ce;
			alu_sequence_item_monitor.mode = vif.mode;
			alu_sequence_item_monitor.inp_valid = vif.inp_valid;
			alu_sequence_item_monitor.cmd = vif.cmd;
			alu_sequence_item_monitor.opa = vif.opa;
			alu_sequence_item_monitor.opb = vif.opb;
			alu_sequence_item_monitor.cin = vif.cin;

			alu_sequence_item_monitor.res = vif.res;
			alu_sequence_item_monitor.err = vif.err;
			alu_sequence_item_monitor.oflow = vif.oflow;
			alu_sequence_item_monitor.cout = vif.cout;
			alu_sequence_item_monitor.g = vif.g;
			alu_sequence_item_monitor.l = vif.l;
			alu_sequence_item_monitor.e = vif.e;

			//repeat(2) @(posedge vif.monitor_cb);

			item_collected_port.write(alu_sequence_item_monitor);
			alu_sequence_item_monitor.print();
			repeat(1) @(posedge vif.monitor_cb);
		end
	endtask
endclass
