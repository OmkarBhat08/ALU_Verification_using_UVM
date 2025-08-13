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
	alu_sequence_item ref_model_output;

	`uvm_component_utils(alu_scoreboard)

	function new(string name = "alu_scoreboard", uvm_component parent = null);
		super.new(name, parent);
		driver_imp = new("driver_imp", this);
		monitor_imp = new("monitor_imp", this);
		ref_model_output = new();
	endfunction

	virtual function void write_from_mon(alu_sequence_item t);
		$display("Scoreboard received packet from monitor");
		monitor_packet.push_back(t);
		$display();
		t.print();
	endfunction

	virtual function void write_from_drv(alu_sequence_item u);
		$display("Scoreboard received from the driver");
		driver_packet.push_back(u);
		u.print();
	endfunction

	virtual task run_phase(uvm_phase phase);
		alu_sequence_item packet2;
		super.run_phase(phase);
		forever
		begin
			wait(driver_packet.size() > 0)
			packet2 = driver_packet.pop_front();
			//Reference model and compare
			begin
				if(packet2.rst)
				begin
					ref_model_output.res = {`WIDTH{1'b0}};
					ref_model_output.oflow = 1'b0;
					ref_model_output.cout = 1'b0;
					ref_model_output.g = 1'b0;
					ref_model_output.l = 1'b0;
					ref_model_output.e = 1'b0;
					ref_model_output.err = 1'b0;
				end
				else
				begin
					if(packet2.ce)
					begin
						if(packet2.mode)		// Arithmetic operations
						begin
							ref_model_output.res = {`WIDTH{1'b0}};
							ref_model_output.oflow = 1'b0;
							ref_model_output.cout = 1'b0;
							ref_model_output.g = 1'b0;
							ref_model_output.l = 1'b0;
							ref_model_output.e = 1'b0;
							ref_model_output.err = 1'b0;
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
												ref_model_output.cout = ref_model_output.res[`WIDTH];
											end
											4'd1:	//SUB
											begin
												ref_model_output.res = packet2.opa - packet2.opb;
												ref_model_output.oflow = (packet2.opa < packet2.opb);
											end
											4'd2:	//ADD_CIN
											begin
												ref_model_output.res = packet2.opa + packet2.opb + packet2.cin;
												ref_model_output.cout = ref_model_output.res[`WIDTH];
											end
											4'd3:	// SUB_CIN
											begin
												ref_model_output.res = (packet2.opa - packet2.opb) - packet2.cin;
												ref_model_output.oflow = packet2.opa < packet2.opb || ( packet2.opa == packet2.opb && packet2.cin);
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
												ref_model_output.cout = ref_model_output.res[`WIDTH];
											end
											4'd1:	//SUB
											begin
												ref_model_output.res = packet2.opa - packet2.opb;
												ref_model_output.oflow = (packet2.opa < packet2.opb);
											end
											4'd2:	//ADD_CIN
											begin
												ref_model_output.res = packet2.opa + packet2.opb + packet2.cin;
												ref_model_output.cout = ref_model_output.res[`WIDTH];
											end
											4'd3:	// SUB_CIN
											begin
												ref_model_output.res = (packet2.opa - packet2.opb) - packet2.cin;
												ref_model_output.oflow = packet2.opa < packet2.opb || ( packet2.opa == packet2.opb && packet2.cin);
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
											//	repeat(1) @ (vif.ref_model_cb);
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
									begin
										ref_model_output.res = packet2.opa + 1;
										ref_model_output.cout = ref_model_output.res[`WIDTH];
									end
									else		// DEC_A
									begin
										ref_model_output.res = packet2.opa - 1;
										ref_model_output.oflow = packet2.opb==0;
									end
								end
							end

							if((packet2.cmd == 6) || (packet2.cmd == 7))	// OPB operations
							begin
								if((packet2.inp_valid == 2'b00) || (packet2.inp_valid == 2'b01))
										ref_model_output.err = 1;
								else
								begin
									if(packet2.cmd == 6)		// INC_B
									begin
										ref_model_output.res = packet2.opb + 1;
										ref_model_output.cout = ref_model_output.res[`WIDTH];
									end
									else		// DEC_B
									begin
										ref_model_output.res = packet2.opb - 1;
										ref_model_output.oflow = packet2.opb==0;
									end
								end
							end
							$display("----------------------------------------------Reference model @time = %0t-----------------------------------------------",$time);
							$display("@time=%0t | inp_valid=%b | mode=%b | cmd=%0d | ce=%b | opa=%0d | opb=%0d | cin=%b",$time, packet2.inp_valid, packet2.mode,packet2.cmd,packet2.ce,packet2.opa,packet2.opb,packet2.cin);
							$display("@time=%0t | err=%b | res=%0d | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref_model_output.err,ref_model_output.res,ref_model_output.oflow,ref_model_output.cout,ref_model_output.g,ref_model_output.l,ref_model_output.e);
							//repeat(1)@(vif.ref_model_cb);
						end		// Arithmetic opeation ends
						else	//logical operations
						begin
							ref_model_output.res = {`WIDTH{1'b0}};
							ref_model_output.oflow = 1'b0;
							ref_model_output.cout = 1'b0;
							ref_model_output.g = 1'b0;
							ref_model_output.l = 1'b0;
							ref_model_output.e = 1'b0;
							ref_model_output.err = 1'b0;
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
									begin
										ref_model_output.res = {1'b0,packet2.opa >> 1};
									end
									else		// SHL1_A
									begin
										ref_model_output.res = {1'b0,packet2.opa << 1};
									end
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
							$display("----------------------------------------------Reference model @time = %0t-----------------------------------------------",$time);
							$display("@time=%0t | inp_valid=%b | mode=%b | cmd=%0d | ce=%b | opa=%b | opb=%b | cin=%b",$time, packet2.inp_valid, packet2.mode,packet2.cmd,packet2.ce,packet2.opa,packet2.opb,packet2.cin);
							$display("@time=%0t | err=%b | res=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref_model_output.err,ref_model_output.res,ref_model_output.oflow,ref_model_output.cout,ref_model_output.g,ref_model_output.l,ref_model_output.e);
							//repeat(1)@(vif.ref_model_cb);
						end		// logical opeation ends
					end			// ce = 1 ends
				end
			end
		end
	endtask
endclass
