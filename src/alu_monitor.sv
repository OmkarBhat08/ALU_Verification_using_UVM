// Active monitor
class alu_active_monitor extends uvm_monitor;

	virtual alu_interfs vif;
	alu_sequence_item alu_sequence_item_active_monitor; 
	uvm_analysis_port #(alu_sequence_item) active_item_collected_port;

	`uvm_component_utils(alu_active_monitor)

	function new(string name = "alu_active_monitor", uvm_component parent = null);
		super.new(name,parent);
		alu_sequence_item_active_monitor  = new();
		active_item_collected_port = new("active_item_collected_port", this);
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
			repeat(3) @(posedge vif.monitor_cb);

			if((((vif.mode == 1) && ( vif.cmd < 4 || (vif.cmd > 7 && vif.cmd < 11)))||((vif.mode == 0) && (vif.cmd < 6 || vif.cmd == 12 || vif.cmd == 13))) && (vif.inp_valid == 1 || vif.inp_valid == 2))
				// give a delay
			$display("--------------------------------------------ACTIVE MONITOR @ %0t----------------------------------------------",$time);
			alu_sequence_item_active_monitor.rst = vif.rst;
			alu_sequence_item_active_monitor.ce = vif.ce;
			alu_sequence_item_active_monitor.mode = vif.mode;
			alu_sequence_item_active_monitor.inp_valid = vif.inp_valid;
			alu_sequence_item_active_monitor.cmd = vif.cmd;
			alu_sequence_item_active_monitor.opa = vif.opa;
			alu_sequence_item_active_monitor.opb = vif.opb;
			alu_sequence_item_active_monitor.cin = vif.cin;
			
			$display("From active monitor");
			alu_sequence_item_active_monitor.print();
			active_item_collected_port.write(alu_sequence_item_active_monitor);
		end
	endtask
endclass
//-----------------------------------------------------
// Passive Monitor
class alu_passive_monitor extends uvm_monitor;

	virtual alu_interfs vif;
	alu_sequence_item alu_sequence_item_passive_monitor; 
	uvm_analysis_port #(alu_sequence_item) passive_item_collected_port;

	`uvm_component_utils(alu_passive_monitor)

	function new(string name = "alu_passive_monitor", uvm_component parent = null);
		super.new(name,parent);
		alu_sequence_item_passive_monitor  = new();
		passive_item_collected_port = new("passive_item_collected_port", this);
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
			repeat(3) @(posedge vif.monitor_cb);

			if((((vif.mode == 1) && ( vif.cmd < 4 || (vif.cmd > 7 && vif.cmd < 11)))||((vif.mode == 0) && (vif.cmd < 6 || vif.cmd == 12 || vif.cmd == 13))) && (vif.inp_valid == 1 || vif.inp_valid == 2))
				// Give a delay
			$display("-------------------------------------------PASSIVE MONITOR @ %0t----------------------------------------------",$time);
			alu_sequence_item_passive_monitor.res = vif.res;
			alu_sequence_item_passive_monitor.err = vif.err;
			alu_sequence_item_passive_monitor.oflow = vif.oflow;
			alu_sequence_item_passive_monitor.cout = vif.cout;
			alu_sequence_item_passive_monitor.g = vif.g;
			alu_sequence_item_passive_monitor.l = vif.l;
			alu_sequence_item_passive_monitor.e = vif.e;

			$display("From passive monitor");
			alu_sequence_item_passive_monitor.print();
			passive_item_collected_port.write(alu_sequence_item_passive_monitor);
		end
	endtask
endclass
