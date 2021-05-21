module output_process_stage( 
	CLK,
	start,
	rst,
	FIXED_taylor_input,
	FIXED_e_input,
	FLOAT_e_input,
	FLOAT_result_output,
	output_ready,
	/*debug*/
	D_taylor_output
);
	input CLK, start, rst;
	input [25:0] FIXED_taylor_input, FIXED_e_input;
	input [31:0] FLOAT_e_input;
	output [31:0] FLOAT_result_output;
	output [25:0] 	D_taylor_output;
	output output_ready;
	
	wire reg_mul_output_en, reg_fixtofloat_output_en, reg_binary_mul_output_en, output_oe;
	/*control*/
	stage_5_control my_control( 
		.CLK(CLK),
		.start(start),
		.rst(rst),
		.reg_mul_output_en(reg_mul_output_en),
		.reg_fixtofloat_output_en(reg_fixtofloat_output_en),
		.reg_binary_mul_output_en(reg_binary_mul_output_en),
		.output_oe(output_oe)
	);
	/*datapath*/
	stage_5 my_datapath( 
		.CLK(CLK),
		.FIXED_taylor_input(FIXED_taylor_input),
		.FIXED_e_input(FIXED_e_input),
		.FLOAT_e_input(FLOAT_e_input),
		.FLOAT_result_output(FLOAT_result_output),
		/*control signal*/
		.reg_mul_output_en(reg_mul_output_en),
		.reg_fixtofloat_output_en(reg_fixtofloat_output_en),
		.reg_binary_mul_output_en(reg_binary_mul_output_en),
		.output_oe(output_oe),
		.reg_output_oe(output_ready),
		.D_taylor_output(D_taylor_output)
);
endmodule 