//n `include "uvm_macros.svh"
//`include "alu_sequence_item.sv"
//n import uvm_pkg ::*;
//
`include "defines.sv"
`uvm_analysis_imp_decl(_from_drv)
`uvm_analysis_imp_decl(_from_mon)

class alu_scoreboard extends uvm_scoreboard();
	
	virtual alu_interfs vif;	
	logic [`POW_2_N - 1 : 0] SH_AMT;
	uvm_analysis_imp_from_drv #(alu_sequence_item, alu_scoreboard) driver_imp;
	uvm_analysis_imp_from_mon #(alu_sequence_item, alu_scoreboard) monitor_imp;

	alu_sequence_item driver_packet[$];

	alu_sequence_item monitor_packet[$];

	alu_sequence_item ref_model_output,prev_output;

	`uvm_component_utils(alu_scoreboard)

	function new(string name = "alu_scoreboard", uvm_component parent = null);
		super.new(name, parent);
		driver_imp = new("driver_imp", this);
		monitor_imp = new("monitor_imp", this);
		ref_model_output = new();
		prev_output = new();
		if( !uvm_config_db #(virtual alu_interfs)::get(this, "","vif", vif))
			`uvm_fatal(get_type_name(), "Not set at top");
	endfunction

	virtual function void write_from_mon(alu_sequence_item t);
		`uvm_info(get_type_name,"Scoreboard received packet from monitor", UVM_NONE);
		monitor_packet.push_back(t);
	endfunction

	virtual function void write_from_drv(alu_sequence_item u);
		`uvm_info(get_type_name,"Scoreboard received packet from the driver", UVM_NONE);
		driver_packet.push_back(u);
	endfunction

	virtual task run_phase(uvm_phase phase);
		alu_sequence_item packet2;
		alu_sequence_item packet1;
		super.run_phase(phase);
		forever
		begin
			wait((driver_packet.size() > 0) && (monitor_packet.size() > 0))
			packet2 = driver_packet.pop_front();
			packet1 = monitor_packet.pop_front();

			// Reference model
			begin
				ref_model_output.rst = packet2.rst;
				ref_model_output.ce = packet2.ce;
				ref_model_output.mode = packet2.mode;
				ref_model_output.cmd = packet2.cmd;
				ref_model_output.inp_valid = packet2.inp_valid;
				ref_model_output.ce = packet2.ce;
				ref_model_output.opa = packet2.opa;
				ref_model_output.opb = packet2.opb;
				ref_model_output.cin = packet2.cin;
				if(packet2.rst)
				begin
					ref_model_output.res = 'bz;
					ref_model_output.oflow = 1'bz;
					ref_model_output.cout = 1'bz;
					ref_model_output.g = 1'bz;
					ref_model_output.l = 1'bz;
					ref_model_output.e = 1'bz;
					ref_model_output.err = 1'bz;
				end
				else
				begin
					if(packet2.ce)
					begin
						if(packet2.mode)		// Arithmetic operations
						begin
							ref_model_output.res = 'bz;
							ref_model_output.oflow = 1'bz;
							ref_model_output.cout = 1'bz;
							ref_model_output.g = 1'bz;
							ref_model_output.l = 1'bz;
							ref_model_output.e = 1'bz;
							ref_model_output.err = 1'bz;
							if((packet2.cmd < 4) || (packet2.cmd > 7 && packet2.cmd <11))	// All 2 operand operations
							begin
								if(packet2.inp_valid == 2'b00)
									ref_model_output.err = 1'b1;
								else if(packet2.inp_valid == 2'b11)
								begin
										case(packet2.cmd)
											4'd0:	//ADD
											begin
												ref_model_output.res = packet2.opa + packet2.opb;
												ref_model_output.cout = (ref_model_output.res[`WIDTH])?1:1'b0;
											end
											4'd1:	//SUB
											begin
												ref_model_output.res = packet2.opa - packet2.opb;
												ref_model_output.oflow = (packet2.opa < packet2.opb)?1:0;
											end
											4'd2:	//ADD_CIN
											begin
												ref_model_output.res = packet2.opa + packet2.opb + packet2.cin;
												ref_model_output.cout = (ref_model_output.res[`WIDTH])?1:1'bz;
											end
											4'd3:	// SUB_CIN
											begin
												ref_model_output.res = (packet2.opa - packet2.opb) - packet2.cin;
												ref_model_output.oflow = (packet2.opa < packet2.opb || ( packet2.opa == packet2.opb && packet2.cin))?1:0;
											end
											4'd8:	// CMP
											begin
												if(packet2.opa == packet2.opb)
                	    		{ref_model_output.g,ref_model_output.l,ref_model_output.e} = 3'bzz1;
                  			else if (packet2.opa > packet2.opb)
                    			{ref_model_output.g,ref_model_output.l,ref_model_output.e} = 3'b1zz;
                    		else
        	            		{ref_model_output.g,ref_model_output.l,ref_model_output.e} = 3'bz1z;
											end	
											4'd9:	//Increment and multiply
												ref_model_output.res = (packet2.opa + 1) * (packet2.opb+1);
											4'd10:	//Shift and multiply
												ref_model_output.res = (packet2.opa << 1) * packet2.opb;
										endcase
								end
								else 
								begin
									int i;
									for(i = 0; i < 16; i++) 
									begin
										//repeat(1) @ (vif.ref_model_cb);
										if(packet2.inp_valid == 2'b11)
											break;
									end	
									if(i==15)
										ref_model_output.err = 1'b1;
									else
									begin
										case(packet2.cmd)
											4'd0:	//ADD
											begin
												ref_model_output.res = packet2.opa + packet2.opb;
												ref_model_output.cout = (ref_model_output.res[`WIDTH])?1:1'b0;
											end
											4'd1:	//SUB
											begin
												ref_model_output.res = packet2.opa - packet2.opb;
												ref_model_output.oflow = (packet2.opa < packet2.opb)?1:0;
											end
											4'd2:	//ADD_CIN
											begin
												ref_model_output.res = packet2.opa + packet2.opb + packet2.cin;
												ref_model_output.cout = (ref_model_output.res[`WIDTH])?1:1'bz;
											end
											4'd3:	// SUB_CIN
											begin
												ref_model_output.res = (packet2.opa - packet2.opb) - packet2.cin;
												ref_model_output.oflow = (packet2.opa < packet2.opb || ( packet2.opa == packet2.opb && packet2.cin))?1:0;
											end
											4'd8:	// CMP
											begin
												if(packet2.opa == packet2.opb)
                	    		{ref_model_output.g,ref_model_output.l,ref_model_output.e} = 3'bzz1;
                  			else if (packet2.opa > packet2.opb)
                    			{ref_model_output.g,ref_model_output.l,ref_model_output.e} = 3'b1zz;
                    		else
        	            		{ref_model_output.g,ref_model_output.l,ref_model_output.e} = 3'bz1z;
											end	
											4'd9:	//Increment and multiply
											begin
												//repeat(1) @ (posedge vif.ref_model_cb);
												ref_model_output.res = (packet2.opa + 1) * (packet2.opb+1);
											end
											4'd10:	//Shift and multiply
											begin
											//	repeat(1) @ (vif.ref_model_cb);
												ref_model_output.res = (packet2.opa << 1) * packet2.opb;
											end
										endcase
									end
								end
							end
							if((packet2.cmd == 4) || (packet2.cmd == 5))	// OPA operations
							begin
								if((packet2.inp_valid == 2'b00) || (packet2.inp_valid == 2'b10))
										ref_model_output.err = 1;
								else
								begin
									if(packet2.cmd == 4)		// INC_A
										ref_model_output.res = packet2.opa + 1;
									else		// DEC_A
										ref_model_output.res = packet2.opa - 1;
								end
							end

							if((packet2.cmd == 6) || (packet2.cmd == 7))	// OPB operations
							begin
								if((packet2.inp_valid == 2'b00) || (packet2.inp_valid == 2'b01))
										ref_model_output.err = 1;
								else
								begin
									if(packet2.cmd == 6)		// INC_B
										ref_model_output.res = packet2.opb + 1;
									else		// DEC_B
										ref_model_output.res = packet2.opb - 1;
								end
							end
							//repeat(1)@(vif.ref_model_cb);
						end		// Arithmetic opeation ends
						else	//logical operations
						begin
							ref_model_output.res = {`WIDTH{1'bz}};
							ref_model_output.oflow = 1'bz;
							ref_model_output.cout = 1'bz;
							ref_model_output.g = 1'bz;
							ref_model_output.l = 1'bz;
							ref_model_output.e = 1'bz;
							ref_model_output.err = 1'bz;
							if((packet2.cmd < 6) || (packet2.cmd > 11 && packet2.cmd < 14))	// All 2 operand operations
							begin
								if(packet2.inp_valid == 2'b00)
									ref_model_output.err = 1'b1;
								else if(packet2.inp_valid == 2'b11) 
								begin
										case(packet2.cmd)
											4'd0:	//AND
												ref_model_output.res = {1'b0,packet2.opa & packet2.opb};
											4'd1:	// NAND
												ref_model_output.res = {1'b0,~(packet2.opa & packet2.opb)};
											4'd2:	// OR
												ref_model_output.res = {1'b0,packet2.opa | packet2.opb};
											4'd3:	// NOR
												ref_model_output.res = {1'b0,~(packet2.opa | packet2.opb)};
											4'd4:	// XOR
												ref_model_output.res = {1'b0,packet2.opa ^ packet2.opb};
											4'd5:	// XNOR
												ref_model_output.res = {1'b0,~(packet2.opa ^ packet2.opb)};
											4'd12:	// ROL_A_B
											begin
												SH_AMT = packet2.opb;
												ref_model_output.res = 16'h00FF & ({1'b0,(packet2.opa << SH_AMT | packet2.opa >> (`WIDTH - SH_AMT))});
												ref_model_output.err = |packet2.opb[`WIDTH - 1 : `POW_2_N +1];
											end
											4'd13:	// ROR_A_B
											begin
												SH_AMT = packet2.opb;
												ref_model_output.res = 16'h00FF & ({1'b0,packet2.opa << (`WIDTH- SH_AMT) | packet2.opa >> SH_AMT});
												ref_model_output.err = |packet2.opb[`WIDTH - 1 : `POW_2_N +1];
											end
										endcase
								end
								else
								begin
									int i;
									for(i = 0; i < 16; i++ ) 
									begin
										//repeat(1) @ (vif.ref_model_cb);
										if(packet2.inp_valid == 2'b11)
											break;
									end	
									if(i==15)
										ref_model_output.err = 1'b1;
									else
									begin
										case(packet2.cmd)
											4'd0:	//AND
												ref_model_output.res = {1'b0,packet2.opa & packet2.opb};
											4'd1:	// NAND
												ref_model_output.res = {1'b0,~(packet2.opa & packet2.opb)};
											4'd2:	// OR
												ref_model_output.res = {1'b0,packet2.opa | packet2.opb};
											4'd3:	// NOR
												ref_model_output.res = {1'b0,~(packet2.opa | packet2.opb)};
											4'd4:	// XOR
												ref_model_output.res = {1'b0,packet2.opa ^ packet2.opb};
											4'd5:	// XNOR
												ref_model_output.res = {1'b0,~(packet2.opa ^ packet2.opb)};
											4'd12:	// ROL_A_B
											begin
												SH_AMT = packet2.opb;
												ref_model_output.res = 16'h00FF & ({1'b0,(packet2.opa << SH_AMT | packet2.opa >> (`WIDTH - SH_AMT))});
												ref_model_output.err = |packet2.opb[`WIDTH - 1 : `POW_2_N +1];
											end
											4'd13:	// ROR_A_B
											begin
												SH_AMT = packet2.opb;
												ref_model_output.res = 16'h00FF & ({1'b0,packet2.opa << (`WIDTH- SH_AMT) | packet2.opa >> SH_AMT});
												ref_model_output.err = |packet2.opb[`WIDTH - 1 : `POW_2_N +1];
											end
										endcase
									end
								end
							end
							if((packet2.cmd == 6) || (packet2.cmd == 8) || (packet2.cmd == 9))	// OPA operations
							begin
								if((packet2.inp_valid == 2'b00) || (packet2.inp_valid == 2'b10))
										ref_model_output.err = 1;
								else
								begin
									if(packet2.cmd == 6)		// NOT_A
										ref_model_output.res = {1'b0,~(packet2.opa)};
									else if(packet2.cmd == 8)		// SHR1_A
										ref_model_output.res = {1'b0,packet2.opa >> 1};
									else		// SHL1_A
										ref_model_output.res = {1'b0,packet2.opa << 1};
								end
							end

							if((packet2.cmd == 7) || (packet2.cmd == 10) || (packet2.cmd == 11))	// OPB  operations
							begin
								if((packet2.inp_valid == 2'b00) || (packet2.inp_valid == 2'b01))
										ref_model_output.err = 1;
								else
								begin
									if(packet2.cmd == 7)		// NOT_B
										ref_model_output.res = {1'b0,~(packet2.opb)};
									else if(packet2.cmd == 10)		// SHR1_B
										ref_model_output.res = {1'b0,packet2.opb >> 1};
									else		// SHL1_B
										ref_model_output.res = {1'b0,packet2.opb << 1};
								end
							end
						end		// logical opeation ends
						prev_output = ref_model_output;
					end			// ce = 1 ends
					else
					begin
						ref_model_output.res = prev_output.res;
						ref_model_output.oflow = prev_output.oflow;
						ref_model_output.cout = prev_output.cout;
						ref_model_output.g = prev_output.g;
						ref_model_output.l = prev_output.l;
						ref_model_output.e = prev_output.e;
						ref_model_output.err = prev_output.err;
					end
				end
			end		// Reference model end
			begin		// Compare 
				$display("Field\t\t|\tReference Output\t|\tActual Response");
				$display("--------------|-------------------------------|-----------------------------");
				$display("rst\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.rst, packet1.rst);
				$display("ce\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.ce, packet1.ce);
				$display("mode\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.mode, packet1.mode);
				$display("cmd\t\t|\t\t%0d\t\t|\t\t%0d", ref_model_output.cmd, packet1.cmd);
				$display("inp_valid\t|\t\t%b\t\t|\t\t%b", ref_model_output.inp_valid, packet1.inp_valid);
				$display("opa\t\t|\t\t%0d\t\t|\t\t%0d", ref_model_output.opa, packet1.opa);
				$display("opb\t\t|\t\t%0d\t\t|\t\t%0d	", ref_model_output.opb, packet1.opb);
				$display("cin\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.cin, packet1.cin);
				$display("res\t\t|\t\t%0d\t\t|\t\t%0d", ref_model_output.res, packet1.res);
				$display("err\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.err, packet1.err);
				$display("oflow\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.oflow, packet1.oflow);
				$display("cout\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.cout, packet1.cout);
				$display("g\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.g, packet1.g);
				$display("l\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.l, packet1.l);
				$display("e\t\t|\t\t%b\t\t|\t\t%b", ref_model_output.e, packet1.e);
				if((packet1.res === ref_model_output.res) && (packet1.err === ref_model_output.err) && (packet1.oflow === ref_model_output.oflow) && (packet1.cout === ref_model_output.cout) && (packet1.g === ref_model_output.g) && (packet1.l === ref_model_output.l) && (packet1.e === ref_model_output.e))
				begin
					`uvm_info(get_type_name(), $sformatf("\n------------------------------------------------------------------------------"), UVM_NONE);
					$display("	           		TEST PASS																	");
					$display("------------------------------------------------------------------------------");
				end
				else
				begin
					`uvm_info(get_type_name(), $sformatf("\n------------------------------------------------------------------------------"), UVM_NONE);
					$display("	           		TEST FAILED																	");
					$display("------------------------------------------------------------------------------");
				end
			end
		end
	endtask
endclass
