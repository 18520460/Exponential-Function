module input_process_stage( 
	CLK,
	rst,
	FLOAT32_IN,
	FLOAT32_OUT, 			/*e^b IEEE 745 output*/
	A, 			 			/*x - a Q3.23 output*/
	E,           			/*e^a Q3.23 output*/
	next_stage_start,
								/*control signal*/
	load,  					/*input data load*/
	load_success,
	start, 					/*function like OE*/
	input_ready,
								/*debug only*/
	d_state,
	D_FLOAT32_OUT,
	D_A,
	D_E,
	D_int,
	D_frac
);
	input CLK, rst, load, start;
	input [31:0] FLOAT32_IN;
	output input_ready, next_stage_start, load_success;
	output [31:0] FLOAT32_OUT;
	output [25:0] A, E;
	
	output [7:0] D_int;
	output [22:0] D_frac;
	output [31:0] D_FLOAT32_OUT;
	output [25:0] D_A, D_E;
	output [2:0] d_state;
	
	wire float32tofix_reg_en, float32_a_reg_en, fixed_reg_en, output_ready;
	/*control*/
	stage_0_control my_control( 
		.d_state(d_state),
		.CLK(CLK),
		.start(start),
		.rst(rst),
		.input_ready(input_ready),
		.float32tofix_reg_en(float32tofix_reg_en),
		.float32_a_reg_en(float32_a_reg_en),
		.fixed_reg_en(fixed_reg_en),
		.output_ready(output_ready),
		.load_input(load),
		.load_success(load_success)
	);
	/*datapath*/
	stage_0 my_stage(  
		.CLK(CLK),
		.FLOAT32_IN(FLOAT32_IN),
		.FLOAT32_OUT(FLOAT32_OUT), /*e^b IEEE 745 output*/
		.A(A), 			 				/*x - a Q3.23 output*/
		.E(E),           				/*e^a Q3.23 output*/
		/*control signal*/
		.load(load),
		.start(start),
		.float32tofix_reg_en(float32tofix_reg_en),
		.float32_a_reg_en(float32_a_reg_en),
		.fixed_reg_en(fixed_reg_en),
		.output_ready(output_ready),
		.next_stage_start(next_stage_start),
		.D_FLOAT32_OUT(D_FLOAT32_OUT),
		.D_A(D_A),
		.D_E(D_E),
		.D_int(D_int),
		.D_frac(D_frac)
	);
endmodule
