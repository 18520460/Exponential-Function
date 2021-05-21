module stage_5( 
	CLK,
	FIXED_taylor_input,
	FIXED_e_input,
	FLOAT_e_input,
	FLOAT_result_output,
	reg_output_oe,

	/*control signal*/
	reg_mul_output_en,
	reg_fixtofloat_output_en,
	reg_binary_mul_output_en,
	output_oe,
	/*debug*/
	D_taylor_output
);
	input CLK, reg_mul_output_en, reg_fixtofloat_output_en, reg_binary_mul_output_en, output_oe;
	input [25:0] FIXED_taylor_input, FIXED_e_input;
	input [31:0] FLOAT_e_input;
	output [31:0] FLOAT_result_output;
	output [25:0] D_taylor_output;
	/*------------------------*/
	wire [25:0] mul_output;
	multiplier my_mul( 
		.IN_FRAC_1(FIXED_e_input[22:0]),
		.IN_INT_1(FIXED_e_input[25:23]),
		.IN_FRAC_2(FIXED_taylor_input[22:0]),
		.IN_INT_2(FIXED_taylor_input[25:23]),
		.OUT_FRAC(mul_output[22:0]),
		.OUT_INT(mul_output[25:23])
	);
	/*reg*/
	assign D_taylor_output = reg_mul_output;
	reg [25:0] reg_mul_output;
	reg [31:0] reg_FLOAT_e_input;
	always @ (posedge CLK)
		if(reg_mul_output_en) begin
			reg_mul_output <= mul_output;
			reg_FLOAT_e_input <= FLOAT_e_input;
			end
	/*----fixed to float-------*/
	wire [31:0] fixtofloat_output;
	fixedtofloat32 my_fixtofloat(
		.IN_FRAC(reg_mul_output[22:0]), /*fraction part input*/
		.IN_INT(reg_mul_output[25:23]), /*integer part input*/
		.OUT_FLOAT32(fixtofloat_output) /*float32 output*/
	);
	/*reg*/
	reg [31:0] reg_fixtofloat_output;
	always @ (posedge CLK)
		if(reg_fixtofloat_output_en)
			reg_fixtofloat_output <= fixtofloat_output;
	/*--------float mul ---------*/
	wire [31:0] float_mul_output;
	FP_MUL my_float_mul(
		.CLK(CLK), 
		.reg_en(reg_binary_mul_output_en),
		.A(reg_fixtofloat_output), /*float32 A input*/
		.B(reg_FLOAT_e_input), /*float32 B input*/
		.OUT(float_mul_output) /*float32 output*/
	);
	/*reg result*/
	reg [31:0] result;
	output reg reg_output_oe;
	always @ (posedge CLK) begin
		if(output_oe) begin
			result <= float_mul_output;
			reg_output_oe <= 1'b1;
			end 
		else begin
			result <= 32'd0;
			reg_output_oe <= 1'b0;
			end 
	end
	assign FLOAT_result_output = result;
endmodule
