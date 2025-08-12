//n `include "uvm_macros.svh"
//`include "alu_sequence_item.sv"
//n import uvm_pkg ::*;
class alu_scoreboard extends uvm_scoreboard();
	
	alu_sequence_item queue_packet[$];
	uvm_analysis_imp #(alu_sequence_item, alu_scoreboard) item_collected_export;

	`uvm_component_utils(alu_scoreboard)

	function new(string name = "alu_scoreboard", uvm_component parent = null);
		super.new(name, parent);
		item_collected_export = new("item_collected_export", this);
	endfunction

	virtual function void write(alu_sequence_item packet1);
		$display("Scoreboard received packet from monitor");
		queue_packet.push_back(packet1);
	endfunction

	virtual task run_phase(uvm_phase phase);
		alu_sequence_item packet2;
		super.run_phase(phase);
		forever
		begin
			wait(queue_packet.size() > 0)
			packet2 = queue_packet.pop_front();
			//Reference model and compare
			begin
			/*
				if(rst)
				begin
					ref2scb_trans.rst = ref_trans.rst;
															ref2scb_trans.inp_valid = ref_trans.inp_valid;
															ref2scb_trans.mode = ref_trans.mode;
															ref2scb_trans.cmd = ref_trans.cmd;
															ref2scb_trans.ce = ref_trans.ce;
															ref2scb_trans.opa = ref_trans.opa;
															ref2scb_trans.opb = ref_trans.opb;
															ref2scb_trans.cin = ref_trans.cin;
															ref2scb_trans.res = {`WIDTH{1'b0}};
															ref2scb_trans.oflow = 1'b0;
															ref2scb_trans.cout = 1'b0;
															ref2scb_trans.g = 1'b0;
															ref2scb_trans.l = 1'b0;
															ref2scb_trans.e = 1'b0;
															ref2scb_trans.err = 1'b0;
														end

			end
			*/
		end
	endtask
endclass
