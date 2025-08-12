`include "defines.sv"
`include "uvm_macros.svh"
import uvm_pkg ::*;

class alu_sequence_item extends uvm_sequence_item;

	rand bit mode, ce, cin;
	rand bit [1:0] inp_valid;
	rand bit [3:0] cmd;
	rand bit [`WIDTH-1:0] opa, opb;

	bit [`WIDTH:0] res;
	bit err, oflow, cout, g, l, e;

	`uvm_object_utils_begin(alu_sequence_item)
		`uvm_field_int(ce,UVM_ALL_ON);
		`uvm_field_int(mode,UVM_ALL_ON);
		`uvm_field_int(inp_valid,UVM_BIN | UVM_ALL_ON);
		`uvm_field_int(cmd,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(opa,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(opb,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(cin,UVM_ALL_ON);
	`uvm_object_utils_end

	function new(string name = "alu_sequence_item");
		super.new(name);
	endfunction

	//constraint rst_deassert {rst == 0;}
	//constraint solve_rst_first {solve rst before ce;}
	constraint solve_mode_before_cmd {solve mode before cmd;}
	constraint solve_inp_valid_before_cmd {solve inp_valid before cmd;}
	constraint solve_ce_before_mode{solve ce before mode;}

	constraint mode_rand {mode == 1;}
	//constraint mode_rand {mode inside {0,1};}

	constraint inp_valid_rand {inp_valid == 3;}
	//constraint inp_valid_rand {inp_valid inside {[0:3]};}

	constraint cmd_in_range1 {cmd == 0;}
	/*
	constraint cmd_in_range1 {if((mode == 1) && (inp_valid == 1))
															cmd inside {[4:5]};
														else
															{
																if((mode == 1) && (inp_valid == 2))
																	cmd inside {[6:7]};
																else
																	cmd inside {[0:13]};
															}
													 }
		*/
	constraint cmd_in_range0 {if((mode == 0) && (inp_valid == 1))
															cmd inside {6,8,9};
														else
														{
															if((mode == 0) &&(inp_valid == 2))
																cmd inside {7,10,11};
															else
																cmd inside {[0:13]};
														}
													 }

	constraint cin_rand{cin inside {0,1};}
endclass
