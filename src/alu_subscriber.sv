`uvm_analysis_imp_decl(_drv_cg)
`uvm_analysis_imp_decl(_mon_cg)

class alu_subscriber extends uvm_component;

	uvm_analysis_imp_drv_cg #(alu_sequence_item, alu_subscriber) aport_drv;
	uvm_analysis_imp_mon_cg #(alu_sequence_item, alu_subscriber) aport_mon;

	alu_sequence_item trans_drv, trans_mon;
	real drv_cov, mon_cov;

	`uvm_component_utils(alu_subscriber)

	covergroup driver_cov;
		reset: coverpoint trans_drv.rst;
		clock_en: coverpoint trans_drv.ce;
		inp_valid: coverpoint trans_drv.inp_valid;
		cmd: coverpoint trans_drv.cmd{
			bins arithmetic[] = {[0:10]} iff(trans_drv.mode == 1);
			bins logical[] = {[0:10]} iff(trans_drv.mode == 0);
		}
		//arithmeticXinp_valid: cross arithmetic,inp_valid;
		//logicalXinp_valid: cross logical,inp_valid;
	endgroup

	covergroup monitor_cov;
		error: coverpoint trans_mon.err;
		over_flow: coverpoint trans_mon.oflow;
		carry_out: coverpoint trans_mon.cout;
		greater: coverpoint trans_mon.g;
		lesser: coverpoint trans_mon.l;
		equal: coverpoint trans_mon.e;
	endgroup

	function new(string name = "alu_subscriber", uvm_component parent = null);
		super.new(name, parent);
		driver_cov = new();
		monitor_cov = new();
		aport_drv = new("aport_drv", this);
		aport_mon = new("aport_mon", this);
	endfunction

	function void write_drv_cg(alu_sequence_item t);
		trans_drv = t;
		driver_cov.sample();
		`uvm_info(get_type_name,$sformatf("ce = %b | mode = %b | inp_valid = %b | cmd = %0d | opa = %0d | opb = %0d | cin = %b",trans_drv.ce,trans_drv.mode, trans_drv.inp_valid, trans_drv.cmd, trans_drv.opa, trans_drv.opb, trans_drv.cin), UVM_MEDIUM);
	endfunction

	function void write_mon_cg(alu_sequence_item t);
		trans_mon = t;
		monitor_cov.sample();
		`uvm_info(get_type_name,$sformatf("res = %0d | err = %b | oflow = %b | cout = %b | g = %b | l = %b | e = %b",trans_mon.res, trans_mon.err, trans_mon.oflow, trans_mon.cout, trans_mon.g, trans_mon.l, trans_mon.e), UVM_MEDIUM);
	endfunction

	function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
		drv_cov = driver_cov.get_coverage();
		mon_cov = monitor_cov.get_coverage();
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(), $sformatf("[Driver]: Coverage --> %0.2f", drv_cov), UVM_MEDIUM);
		`uvm_info(get_type_name(), $sformatf("[Monitor]: Coverage --> %0.2f", mon_cov), UVM_MEDIUM);
	endfunction
endclass
