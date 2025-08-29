class alu_active_agent extends uvm_agent;
	alu_sequencer seqr;
	alu_driver drv;
	alu_active_monitor mon;

	`uvm_component_utils(alu_active_agent)

	function new(string name = "alu_active_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(get_is_active == UVM_ACTIVE)
		begin
			seqr  = alu_sequencer::type_id::create("seqr",this);
			drv  = alu_driver::type_id::create("drv",this);
		end
		mon  = alu_active_monitor::type_id::create("mon",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(get_is_active == UVM_ACTIVE)
			drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction

endclass
//-----------------------------------------------------------
// Passive Agent
class alu_passive_agent extends uvm_agent;
	alu_passive_monitor mon;

	`uvm_component_utils(alu_passive_agent)

	function new(string name = "alu_passive_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(get_is_active == UVM_PASSIVE)
			mon  = alu_passive_monitor::type_id::create("mon",this);
	endfunction
endclass
