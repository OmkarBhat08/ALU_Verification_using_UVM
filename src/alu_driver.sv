class alu_driver extends uvm_driver#(alu_sequence_item);
	reg [3:0] temp_cmd;	
	reg  temp_mode;	
	reg [3:0] count;	
	alu_sequence_item temp_seq;
	virtual alu_interfs vif;
	uvm_analysis_port #(alu_sequence_item) item_collected_port;

	`uvm_component_utils(alu_driver)

	function new(string name = "alu_driver", uvm_component parent = null);
		super.new(name, parent);
		item_collected_port = new("item_collected_port",this);
		count = 0;
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
			if((((req.mode == 1) && ( req.cmd < 4 || (req.cmd > 7 && req.cmd < 11)))||((req.mode == 0) && (req.cmd < 6 || req.cmd == 12 || req.cmd == 13))) && (req.inp_valid == 1 || req.inp_valid == 2) && (count != 15))
			begin
				if(count == 0)
				begin
					temp_cmd = req.cmd;
					temp_mode = req.mode;
				end
				drive_for_cycle();
				count ++;
			end
			else if((count > 0) && (req.inp_valid == 1 || req.inp_valid == 2))
			begin
				drive_for_cycle();
				count ++;
			end
			else	// For operatons requiring inp_valid 01 or 10 or we directly get 11 
			begin
				if(count != 0)
				begin
					drive_for_cycle();
				end
				else
					drive();
				count = 0;
			end

			seq_item_port.item_done();
		end
	endtask

	virtual task drive();
				vif.rst <= req.rst;
				vif.ce <= req.ce;
				vif.mode <= req.mode;
				vif.inp_valid <= req.inp_valid;
				vif.cmd <= req.cmd;
				vif.opa <= req.opa;
				vif.opb <= req.opb;
				vif.cin <= req.cin;
			
		$display("------------------------------DRIVER @%0t------------------------------------",$time);
		$display("Field\t\t|\tValue");
		$display("--------------|---------------");
		$display("rst\t\t|\t%b", req.rst);
		$display("ce\t\t|\t%b", req.ce);
		$display("mode\t\t|\t%b", req.mode);
		$display("cmd\t\t|\t%0d", req.cmd);
		$display("inp_valid\t|\t%b", req.inp_valid);
		$display("opa\t\t|\t%0d", req.opa);
		$display("opb\t\t|\t%0d", req.opb);
		$display("cin\t\t|\t%b", req.cin);
		$display("------------------------------");

		repeat(3) @(posedge vif.driver_cb);

		item_collected_port.write(req);
	endtask

	virtual task drive_for_cycle();
			// Copy values
				temp_seq = req;
				temp_seq.mode = temp_mode;
				temp_seq.cmd = temp_cmd;

			// Send to DUT
				vif.rst = req.rst;
				vif.ce = req.ce;
				vif.mode = temp_mode;
				vif.inp_valid = req.inp_valid;
				vif.cmd = temp_cmd;
				vif.opa = req.opa;
				vif.opb = req.opb;
				vif.cin = req.cin;
			
		$display("------------------------------DRIVER @%0t------------------------------------",$time);
				$display("Field\t\t|\tValue");
				$display("--------------|---------------");
				$display("rst\t\t|\t%b", req.rst);
				$display("ce\t\t|\t%b", req.ce);
				$display("mode\t\t|\t%b", temp_mode);
				$display("cmd\t\t|\t%0d", temp_cmd);
				$display("inp_valid\t|\t%b", req.inp_valid);
				$display("opa\t\t|\t%0d", req.opa);
				$display("opb\t\t|\t%0d", req.opb);
				$display("cin\t\t|\t%b", req.cin);
				$display("------------------------------");

		repeat(3) @(posedge vif.driver_cb);

		item_collected_port.write(temp_seq);
	endtask
endclass
