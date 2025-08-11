//n `include "uvm_macros.svh"
//`include "alu_sequence_item.sv"
//n import uvm_pkg ::*;
class alu_scoreboard extends uvm_component();
	
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
		end
	endtask
endclass
