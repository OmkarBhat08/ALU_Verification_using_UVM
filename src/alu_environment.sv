class alu_environment extends uvm_env;
	alu_agent agnt;
	alu_scoreboard scb;
	alu_subscriber subscr;

	`uvm_component_utils(alu_environment)

	function new(string name = "alu_environment", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agnt = alu_agent::type_id::create("agnt", this);
		scb = alu_scoreboard::type_id::create("scb", this);
		subscr = alu_subscriber::type_id::create("subscr", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agnt.mon.item_collected_port.connect(scb.monitor_imp);
		agnt.drv.item_collected_port.connect(scb.driver_imp);

		agnt.drv.item_collected_port.connect(subscr.aport_drv);	
		agnt.mon.item_collected_port.connect(subscr.aport_mon);	
	endfunction
endclass
