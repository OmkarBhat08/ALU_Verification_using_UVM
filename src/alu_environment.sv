class alu_environment extends uvm_env;
	alu_active_agent active_agnt;
	alu_passive_agent passive_agnt;
	alu_scoreboard scb;
	alu_subscriber subscr;

	`uvm_component_utils(alu_environment)

	function new(string name = "alu_environment", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		active_agnt = alu_active_agent::type_id::create("active_agnt", this);
		passive_agnt = alu_passive_agent::type_id::create("passive_agnt", this);
		scb = alu_scoreboard::type_id::create("scb", this);
		subscr = alu_subscriber::type_id::create("subscr", this);

		set_config_int("passive_agnt", "is_active",UVM_PASSIVE);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		active_agnt.mon.active_item_collected_port.connect(subscr.aport_inputs);
		active_agnt.mon.active_item_collected_port.connect(scb.inputs_export);

		passive_agnt.mon.passive_item_collected_port.connect(scb.outputs_export);	
		passive_agnt.mon.passive_item_collected_port.connect(subscr.aport_outputs);	
	endfunction
endclass
